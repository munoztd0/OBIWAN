%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified by David on August 2020



dbstop if error
clear all

analysis_name = 'OBIWAN_INST';
task          = 'inst';

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
        %unroll to vector
        ForceVector = data.mobilizedforce(:);
        %standardize to get ngrips
        ForceVectorN = (ForceVector - nanmean(ForceVector))/nanstd(ForceVector);
        TimeVector = data.Time(:);
        
        
        
        % compute the threshold to determine what we consider as a response (50% of the maximal force)
        %threshold = PIT.data.minimalforce+((PIT.data.maximalforce-PIT.data.minimalforce)/100*50);% value
        threshold = min(ForceVector)+((max(ForceVector)-min(ForceVector))/100*50);% value
        %threshold = min(PIT.data.PIT.mobilizedforce)+((max(PIT.data.PIT.mobilizedforce)-min(PIT.data.PIT.mobilizedforce))/100*50);% value
        
        thresholdN = min(ForceVectorN)+((max(ForceVectorN)-min(ForceVectorN))/100*50);% value
        
        %sort by time
        [TimeSort, idxSort] = sort(TimeVector);
        ForceSort(idxSort) = ForceVector;
        idxForce = 1:length(ForceVector);        

        %re-roll to matrix %N
        
        mobilized_effort = reshape(ForceVector,A, ntrials);    %data.mobilizedforce;
        nlines = A;    ncolons = ntrials;
        gripsFrequence (1,:) = countgrips(threshold,nlines,ncolons,mobilized_effort);
        
        %ForceVectorSTD = scaledata(ForceVector,0,1);
        %mobilized_effort = reshape(ForceVectorSTD,A, ntrials);
       %(nanmean(data.mobilized_effort) / (max(ForceVectorSTD)) * 100)
        
        % extract the area under the curve
        BEHAVIOR.AUC = trapz(mobilized_effort>threshold); %N
        %#BEHAVIOR.AUC_calib = trapz(mobilized_effort>threshold_calib);
        [pks,locs] = findpeaks(ForceVector, 'MinPeakDistance',15,'MinPeakHeight',threshold,'MinPeakProminence', (max(ForceVector)-min(ForceVector))/50);
        peak_idx(1:length(ForceVector)) = ismember(1:length(ForceSort),locs);
        
        %unsort & reshape into trials
        peak_idx = peak_idx(idxForce);
        peak_idx = reshape(peak_idx,A,ntrials);        
        
        BEHAVIOR.grip = sum(peak_idx);

            %normal
        %BEHAVIOR.grip = gripsFrequence';
        
        
        REWARD = data.RewardedResponses;


       

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save mat file
        func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-' num2str(subjX)], ['ses-' sessionX], 'func');
        bids_dir = fullfile (homedir, ['sub-' num2str(subjX)], ['ses-' sessionX], 'func');
        
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
        events.grip        = zeros (nevents,1);
        events.auc        = zeros (nevents,1);
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
                events.grip(cmpt)   = BEHAVIOR.grip(ii);
                events.auc(cmpt)   = BEHAVIOR.AUC(ii);
                %events.reward(cmpt)     = REWARD(ii);
                %events.trial(cmpt)      = TRIAL(ii);

            end

        end

        events.onsets       = num2cell(events.onsets);
        events.durations    = num2cell(events.durations);
        events.grip       = num2cell(events.grip);
        events.auc       = num2cell(events.auc);
        %events.reward    = num2cell(events.reward);
        %events.trial    = num2cell(events.trial);

         cd (bids_dir)

         eventfile = [events.onsets, events.durations, events.phase,...
            events.grip, events.auc];



        % open data base
        eventfile_name = ['sub-' num2str(subjX) '_ses-' sessionX  '_task-' task '_run-01_events.tsv'];
        fid = fopen(eventfile_name,'wt');

        % print heater
        fprintf (fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n',...
            'onset', 'duration', 'trial_phase',...
             'grips', 'auc');

        % print data
        formatSpec = '%f\t%f\t%s\t%d\t%d\t\n'; %d = vector s=text
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
        db.grip(:,k)        = BEHAVIOR.grip;
        db.auc(:,k)        = BEHAVIOR.AUC;
        
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
R.grip     = num2cell(db.grip(:));
R.auc     = num2cell(db.auc(:));


%% print the database
if save_Rdatabase
    cd (R_dir)

    % concatenate
    Rdatabase = [R.task, R.id, R.group, R.session, R.trial, R.grip, R.auc];

    % open database
    fid = fopen([analysis_name '.txt'], 'wt');

    % print heater
    fprintf(fid,'%s %s %s  %s %s %s  %s\n',...
        'task','id', 'group',  ...
        'session','trial', ...
        'grips', 'auc');

    % print data
    formatSpec ='%s %s %s %s %d %d %d \n';
    [nrows,~] = size(Rdatabase);
    for row = 1:nrows
        fprintf(fid,formatSpec,Rdatabase{row,:});
    end

    fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
