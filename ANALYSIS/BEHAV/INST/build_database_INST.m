%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified by David on August 2020



dbstop if error
clear all

analysis_name = 'OBIWAN_INST';
task          = 'instrumentallearning';

%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 1; % leave 1 when saving all subjects

%% DEFINE PATH
cd ~
home = pwd;
homedir = [home '/OBIWAN/'];


analysis_dir = fullfile(homedir, 'ANALYSIS/BEHAV/PIT');
R_dir        = fullfile(homedir,'DERIVATIVES/BEHAV');
% add tools
addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));

%% DEFINE POPULATION

control = [homedir 'SOURCEDATA/behav/control*'];
obese = [homedir 'SOURCEDATA/behav/obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);

session = {'second'; 'third'};
% 
% subj    = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};    % subject ID excluding 8 & 19
% session = {'two';'two';'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'};
% 
% ses = {'ses-second'};

k = 0; %counter for database index

for j = 1:length(session)
    
    for i = 1:length(subj)

        
        %subjX=subj(i,1);
        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        sub = subjX(end-2:end);
        %conditionX=char(group(i,1));
        sessionX=char(session(j)); 
        sess=['ses-' sessionX];



        %load behavioral file
        if strcmp(sessionX, 'third')
            
            %missing PIT
            if strcmp(subjX(end-2:end), '214')  
                continue
            end
             
            %missing INST sess
            if  strcmp(subjX(end-2:end), '212')  || strcmp(subjX(end-2:end), '245') || strcmp(subjX(end-2:end), '249')
                continue
            end
           

            behavior_dir = fullfile(homedir,'SOURCEDATA/behav/', num2str(subjX), sess);
            if exist(behavior_dir, 'dir')
                cd (behavior_dir)
                load (['instrumental_2' subjX(end-2:end) ])
                PIT = load (['participant_2' subjX(end-2:end) ]);
            else 
                continue
            end
        else
            
%             %old structure
%             if strcmp(subjX(end-2:end), '101') || strcmp(subjX(end-2:end), '103')
%                 continue
%             end

%             %missing trials
%             if strcmp(subjX(end-2:end), '212') %|| strcmp(subjX(end-2:end), '218') %|| strcmp(subjX(end-2:end), '234')
%                 continue
%             end

            %missing INST sess
            if strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '224')
                continue
            end
            
            behavior_dir = fullfile(homedir,'SOURCEDATA/behav/', num2str(subjX), sess);
            if exist(behavior_dir, 'dir')
                cd (behavior_dir)
                load (['instrumental_' subjX(end-2:end) ])
                PIT = load (['participant_' subjX(end-2:end) ]);
            else 
                continue
            end
        end
        
        
        disp (['****** PARTICIPANT: ' subjX ' **** session ' sessionX ' ****' ]);
        
        k = k +1;
        
        [A ntrials] = size(data.mobilizedforce);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get onsets

        %ONSETS.trigger      = data.TriggerOnset'; 
        ONSETS.trial        = data.Onsets.StartTrial;
        ONSETS.ITI         = data.Onsets.ITI;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get durations
        DURATIONS.trial       = data.Durations.TimeTrialProcedure;
        DURATIONS.ITI         = data.Durations.ITI;
   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% get the mobilized effort
        % concatenate the mobilized effort
        mobilized_effort = reshape(data.mobilizedforce,A,ntrials);
        maxForce = PIT.data.maximalforce;
        force = data.mobilizedforce;
        threshold = maxForce/100*50;% value
        [nlines ncolons] = size(force);
        gripsFrequence (1,:) = countgrips(threshold,nlines,ncolons,force);
        REWARD = data.RewardedResponses;
        BEHAVIOR = gripsFrequence';

       

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save mat file
        func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-' num2str(subjX)], ['ses-' sessionX], 'func');
        
        if ~exist(func_dir, 'dir')
            mkdir(func_dir)
        end
        
        cd (func_dir)
        matfile_name = ['sub-' num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.mat'];
        save(matfile_name, 'ONSETS', 'DURATIONS',  'BEHAVIOR') %, 'TRIAL', 'DRIFT' )


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save tsv file according to BIDS format
        phase = {'trial'; 'ITI'};
        nevents = ntrials*length(phase);

        % put everything in the event structure
        events.onsets       = zeros(nevents,1);
        events.durations    = zeros(nevents,1);
        events.phase        = cell (nevents,1);
        events.behavior        = zeros (nevents,1);
        %events.reward       = zeros (nevents,1);
        %events.trial        = zeros (nevents,1);



        cmpt = 0;
        for ii = 1:ntrials

            for iii = 1:length(phase)

                cmpt = cmpt+1;
                phaseX = char(phase(iii));

                events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
                events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
                events.phase(cmpt)      = phase (iii);
                events.behavior(cmpt)   = BEHAVIOR(ii);
                %events.reward(cmpt)     = REWARD(ii);
                %events.trial(cmpt)      = TRIAL(ii);

            end

        end

        events.onsets       = num2cell(events.onsets);
        events.durations    = num2cell(events.durations);
        events.behavior       = num2cell(events.behavior);
        %events.reward    = num2cell(events.reward);
        %events.trial    = num2cell(events.trial);



         eventfile = [events.onsets, events.durations, events.phase,...
            events.behavior];


            %%% save mat file
        %base_dir = fullfile (homedir, ['sub-' num2str(subjX)], 'ses-first', 'beh');
        %mkdir(base_dir)
        %cd (base_dir)

        % open data base
        eventfile_name = ['sub-' num2str(subjX) '_ses-' sessionX  '_task-' task '_run-01_events.tsv'];
        fid = fopen(eventfile_name,'wt');

        % print heater
        fprintf (fid, '%s\t%s\t%s\t%s\t%s\t%s\t\n',...
            'onset', 'duration', 'trial_phase',...
             'grips');

        % print data
        formatSpec = '%f\t%f\t%s\t%d\t\n'; %d = vector s=text
        [nrows,ncols] = size(eventfile);
        for row = 1:nrows
            fprintf(fid,formatSpec,eventfile{row,:});
        end

        fclose(fid);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save data for compiled database

        db.id(:,k)        = cellstr(repmat(sub,ntrials, 1));
        db.group(:,k)     = cellstr(repmat(group,ntrials, 1));
        db.session(:,k)   = cellstr(repmat(sessionX,ntrials,1));
        db.task(:,k)      = repmat({task},ntrials,1);  
        db.trial(:,k)     = [1:ntrials]';
        db.behavior(:,k)        = BEHAVIOR;
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE RESULTS IN TXT for analysis in R

% random
R.id      = db.id(:);
R.trial   = num2cell(db.trial(:));

%fixe
R.group      = db.group(:);
R.session    = db.session(:);
R.task       = db.task(:);


% mixed


% dependent variable
R.behavior     = num2cell(db.behavior(:));


%% print the database
if save_Rdatabase
    cd (R_dir)

    % concatenate
    Rdatabase = [R.task, R.id, R.group, R.session, R.trial, R.behavior];

    % open database
    fid = fopen([analysis_name '.txt'], 'wt');

    % print heater
    fprintf(fid,'%s %s %s  %s %s %s \n',...
        'task','id', 'group',  ...
        'session','trial', ...
        'grips');

    % print data
    formatSpec ='%s %s %s %s %d %d \n';
    [nrows,~] = size(Rdatabase);
    for row = 1:nrows
        fprintf(fid,formatSpec,Rdatabase{row,:});
    end

    fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CREATE FIGURE

%for id = 1:length(subj)
    
    % get data for that participant
    %subjX=subj(id,1);
    %subjX=char(subjX);
    
    %idx = strcmp(db.id, subjX);
    
    %s.force   = db.force(idx);
    %s.liking      = db.liking(idx);
    %s.familiarity = db.familiarity(idx);
    %s.intensity   = db.intensity(idx);
    
    %ratings.liking.reward(id,:)      = s.liking (strcmp ('chocolate', s.condition));
    %ratings.liking.control(id,:)     = s.liking (strcmp ('empty', s.condition));
    %ratings.liking.neutral(id,:)     = s.liking (strcmp ('neutral', s.condition));
   
    %ratings.familiarity.reward(id,:) = s.familiarity (strcmp ('chocolate', s.condition));
    %ratings.familiarity.control(id,:)= s.familiarity (strcmp ('empty', s.condition));

    %ratings.intensity.reward(id,:)   = s.intensity (strcmp ('chocolate', s.condition));
    %ratings.intensity.control(id,:)  = s.intensity (strcmp ('empty', s.condition));
    %ratings.intensity.neutral(id,:)  = s.intensity (strcmp ('neutral', s.condition));

    
%end

% get means and std
%list = {'liking'; 'intensity'};

%for ii = 1:length(list)
    
    %conditionX = char(list(ii));
    
    %means.(conditionX).reward = nanmean(ratings.(conditionX).reward,1);
    %means.(conditionX).control= nanmean(ratings.(conditionX).control,1);
    
    %means.(conditionX).neutral= nanmean(ratings.(conditionX).neutral,1);
    
    
    %stnd.(conditionX).reward = nanstd(ratings.(conditionX).reward,1)/sqrt(length(subj));
    %stnd.(conditionX).control= nanstd(ratings.(conditionX).control,1)/sqrt(length(subj));%eva, you put reward twice?
    %stnd.(conditionX).neutral= nanstd(ratings.(conditionX).neutral,1)/sqrt(length(subj));
    
%end


% plot the means and std
%figure;

%set(gcf, 'Color', 'w')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% liking pannel
%subplot(3,1,1)

% reward
%forplot.liking.reward = plot(means.liking.reward,'-o');
%set(forplot.liking.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
%hold
% control
%forplot.liking.control= plot(means.liking.control,'--o');
%set(forplot.liking.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])

% neutral
%forplot.liking.neutral= plot(means.liking.neutral,'--o');
%set(forplot.liking.neutral(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.3 0.4 0.4],'MarkerEdgeColor', [0.3 0.7 0.7], 'Color', [0 0 0])

%axis
%xlabel('Trial', 'FontSize', 15)
%ylabel('Liking', 'FontSize', 18)
%ylim ([0 100])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% intesity pannel
%subplot(3,1,2)

% reward
%forplot.intensity.reward = plot(means.intensity.reward,'-o');
%set(forplot.intensity.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
%hold
% control
%forplot.intensity.control= plot(means.intensity.control,'--o');
%set(forplot.intensity.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])

% neutral
%forplot.intensity.neutral= plot(means.intensity.neutral,'--o');
%set(forplot.intensity.neutral(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.3 0.4 0.4],'MarkerEdgeColor', [0.3 0.7 0.7], 'Color', [0 0 0])

%axis
%xlabel('Trial', 'FontSize', 15)
%ylabel('Intensity', 'FontSize', 18)
%ylim ([0 100])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  familiarity pannel
%subplot(3,1,3)

% reward
%forplot.familiarity.reward = plot(means.familiarity.reward,'-o');
%set(forplot.familiarity.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
%hold
% control
%forplot.familiarity.control= plot(means.familiarity.control,'--o');
%set(forplot.familiarity.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])

%axis
%xlabel('Trial', 'FontSize', 15)
%ylabel('Familiarity', 'FontSize', 18)
%ylim ([0 100])

%legend
%LEG = legend ('reward','control','neutral');
%set(LEG,'FontSize',18)