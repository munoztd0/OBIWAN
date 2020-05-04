%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE FOR PAVLOVIAN LEARNING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified by David on August 2020
% added ACCuracy and rescued 101 and 103


dbstop if error
clear all

analysis_name = 'OBIWAN_PAV';
task          = 'pavlovianlearning';

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
            
            %missing trials
            if strcmp(subjX(end-2:end), '214')  
                continue
            end
            
            %missing PAV sess
            if  strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '245') || strcmp(subjX(end-2:end), '249')
                continue
            end
           

            behavior_dir = fullfile(homedir,'SOURCEDATA/behav/', num2str(subjX), sess);
            if exist(behavior_dir, 'dir')
                cd (behavior_dir)
                load (['conditioning_2' subjX(end-2:end) ])
            else 
                continue
            end
        else
            
            %old structure
            if strcmp(subjX(end-2:end), '103') 
                continue
            end

            %missing trials
            if strcmp(subjX(end-2:end), '212') %|| strcmp(subjX(end-2:end), '218') %|| strcmp(subjX(end-2:end), '234')
                continue
            end
% 
%             %missing PAV sess
%             if strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '224')
%                 continue
%             end
%             
            behavior_dir = fullfile(homedir,'SOURCEDATA/behav/', num2str(subjX), sess);
            if exist(behavior_dir, 'dir')
                cd (behavior_dir)
                load (['conditioning_' subjX(end-2:end) ])
            else 
                continue
            end
        end
        
        
        disp (['****** PARTICIPANT: ' subjX ' **** session ' sessionX ' ****' ]);
        
        k = k +1;
        
        ntrials = length(data.SwallowPresentation);  %+1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get onsets  

        ONSETS.action  = nan;

        ONSETS.CS = data.Onsets.StageTwo;
        cmpt = 0;

        for ii = 1:ntrials % here take other variable length(data.Durations.TrialStageSix)
            if data.Durations.TrialStageSix(ii) < 0.9999
                cmpt = cmpt+1;
                ONSETS.action(cmpt,1) = data.Onsets.StageSix(ii) + data.Durations.TrialStageSix(ii);
            end
        end

        ONSETS.signal = data.Onsets.StageSix;
        ONSETS.reward  = data.Onsets.StageNine;
        ONSETS.swallow = data.Onsets.StageThirten;
        ONSETS.ITI     = data.Onsets.StageThirten;
        ONSETS.baseline = data.Onsets.BaselineStart;



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get durations

        DURATIONS.action  = nan;

        DURATIONS.CS = data.Durations.TrialStageTwo;
        cmpt = 0;
        for ii = 1:length(data.Durations.TrialStageSix) % here take onther variable
            if data.Durations.TrialStageSix(ii) < 0.9999
                cmpt = cmpt+1;
                DURATIONS.action(cmpt,1) = data.Durations.TrialStageSix(ii);
            end
        end

        DURATIONS.signal   = data.Durations.TrialStageSix;
        DURATIONS.reward   = data.Durations.TrialStageNine + data.Durations.TrialStageEleven;
        DURATIONS.swallow  = data.Durations.TrialStageThirten;
        DURATIONS.ITI      = data.Durations.TrialStageThirten;
        DURATIONS.baseline = data.Durations.ShowBaseline;

    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get condition name
        %rescuing data from old structure 
        if strcmp(subjX(end-2:end), '101') 
            data.rounds = data.rounds(1:ntrials);
            CONDITIONS.CS =  data.csNames(1:ntrials);
            
            for p = 1:ntrials
                if strcmp(CONDITIONS.CS{p}, 'CSminu')
                    CONDITIONS.CS{p} = 'CSminus';
                end
            end
            
            PavCheck.imagesCond = PavCheck.imagesName;
            for o = 1:3
                if strcmp(PavCheck.imagesCond{o}, 'Baseli.jpg')
                    PavCheck.imagesCond{o} = 'BL';
                elseif strcmp(PavCheck.imagesCond{o}, 'CSminu.jpg')
                    PavCheck.imagesCond{o} = 'CSminus';
                elseif strcmp(PavCheck.imagesCond{o}, 'CSplus.jpg')
                    PavCheck.imagesCond{o} = 'CSplus';
                end
            end
        else

            CONDITIONS.CS =  data.PavCond(~cellfun('isempty',data.csNames));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% get Behavior
        BEHAVIOR.RT  = nan(ntrials,1);
        BEHAVIOR.ACC = nan(ntrials,1);
        for ii = 1:length(DURATIONS.action)
            BEHAVIOR.RT(ii) = DURATIONS.action(ii);
            if strcmp(keysPressed{ii},'3#') 
                BEHAVIOR.ACC(ii) = 1; % to be added
            else
                BEHAVIOR.ACC(ii) = 0; % to be added
            end
        end
        
        

        BEHAVIOR.liking.CSp = PavCheck.ratings(strcmp('CSplus',PavCheck.imagesCond)); 
        BEHAVIOR.liking.CSm = PavCheck.ratings(strcmp('CSminus',PavCheck.imagesCond)); 
        BEHAVIOR.liking.b   = PavCheck.ratings(strcmp('BL',PavCheck.imagesCond)); 

        % item by condition
        itemxc          = nan(ntrials,1);
        count_CSp       = 0;
        count_CSm       = 0;
        Behavior.liking = nan(ntrials,1);


        for ii = 1:length(CONDITIONS.CS)

            if strcmp ('CSplus', CONDITIONS.CS(ii))
                count_CSp            =  count_CSp + 1;
                itemxc(ii)           = count_CSp;
                Behavior.liking (ii) = BEHAVIOR.liking.CSp;
            elseif strcmp ('CSminus', CONDITIONS.CS(ii))
                count_CSm            = count_CSm + 1;
                itemxc(ii)           = count_CSm;
                Behavior.liking(ii) = BEHAVIOR.liking.CSm;
            end

        end
        
        
        ROUNDS = data.rounds;


       

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save mat file
        func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-' num2str(subjX)], ['ses-' sessionX], 'func');
        bids_dir = fullfile (homedir, ['sub-' num2str(subjX)], ['ses-' sessionX], 'func');
        
        if ~exist(func_dir, 'dir')
            mkdir(func_dir)
        end
        
        cd (func_dir)
        matfile_name = ['sub-' num2str(subjX)  '_ses-' sessionX  '_task-' task '_events.mat'];
        save(matfile_name, 'ONSETS', 'DURATIONS',  'BEHAVIOR', 'CONDITIONS', 'ROUNDS')


       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save tsv file according to BIDS format
        phase = {'CS';'signal';'reward';'swallow';'baseline'};
        nevents = ntrials*length(phase);

        % put everything in the event structure
        events.onsets       = zeros(nevents,1);
        events.durations    = zeros(nevents,1);
        events.phase        = cell (nevents,1);
        events.CSname       = cell (nevents,1);
        events.reactionTime = nan (nevents,1);
        events.responseACC  = nan (nevents,1);
        events.rounds       = zeros(nevents,1);

        cmpt = 0;
        for ii = 1:ntrials

            for iii = 1:length(phase)

                cmpt = cmpt+1;
                phaseX = char(phase(iii));

                events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
                events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
                events.phase(cmpt)      = phase (iii);
                events.CSname(cmpt)     = CONDITIONS.CS(ii);
                events.reactionTime(cmpt) = BEHAVIOR.RT(ii);
                events.responseACC(cmpt) = BEHAVIOR.ACC(ii);
                events.rounds(cmpt)   = ROUNDS(ii);

            end

        end

        events.onsets       = num2cell(events.onsets);
        events.durations    = num2cell(events.durations);
        events.reactionTime = num2cell(events.reactionTime);
        events.responseACC  = num2cell(events.responseACC);
        events.rounds  = num2cell(events.rounds);
        eventfile = [events.onsets, events.durations, events.phase,...
            events.CSname, events.reactionTime,events.responseACC, events.rounds];

        cd (bids_dir)
        
        % open data base
        eventfile_name = ['sub-' num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.tsv'];
        fid = fopen(eventfile_name,'wt');

        % print heater
        fprintf (fid, '%s   %s   %s   %s   %s   %s   %s\n',...
            'onset', 'duration', 'trialPhase',...
            'CSname','RT', 'ACC', 'Rounds');

        % print data
        formatSpec = '%d   %d   %s   %s  %d  %d  %d\n';
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
        db.condition(:,k) = CONDITIONS.CS;
        db.itemxc(:,k)    = itemxc;
        db.RT (:,k)       = BEHAVIOR.RT;
        db.ACC(:,k)       = BEHAVIOR.ACC;
        db.liking(:,k)    = Behavior.liking;
        db.baseLiking(:,k)= BEHAVIOR.liking.b;
        db.rounds(:,k)    = ROUNDS;
    
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE RESULTS IN TXT for analysis in R

% random
R.id      = db.id(:);
R.trial   = num2cell(db.trial(:));

%fixe
R.group     = db.group(:);
R.session   = db.session(:);
R.task      = db.task(:);
R.condition = db.condition(:);

% mixed
R.itemxc    = num2cell(db.itemxc(:));
R.rounds    = num2cell(db.rounds(:));

% dependent variable
R.RT        = num2cell(db.RT(:));
R.ACC       = num2cell(db.ACC(:));
R.liking    = num2cell(db.liking(:));


%% print the database
if save_Rdatabase
    
    cd (R_dir)
    
    % concatenate
    Rdatabase = [R.task, R.id, R.group, R.session, R.trial,R.condition, R.itemxc, R.RT, R.ACC, R.liking, R.rounds];
    
    % open database
    fid = fopen([analysis_name '.txt'], 'wt');
    
    % print heater
    fprintf(fid,'%s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s\n',...
        'task','id', 'group', ...
        'session','trial', 'condition',...
        'trialxcondition','RT', 'ACC', 'liking', 'rounds');
    
    % print data
    formatSpec ='%s   %s   %s   %s   %d    %s   %d   %d   %d   %d   %d\n';
    [nrows,~] = size(Rdatabase);
    for row = 1:nrows
        fprintf(fid,formatSpec,Rdatabase{row,:});
    end
    
    fclose(fid);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% CREATE FIGURE
% 
% for id = 1:length(subj)
%     
%     % get data for that participant
%     subjX=subj(id,1);
%     subjX=char(subjX);
%     
%     idx = strcmp(db.id, subjX);
%     
%     tmp.condition = db.condition(idx);
%     tmp.RT        = db.RT(idx);
%     tmp.ratings    = db.ratings(idx);
%     
%     all.RT.CSplus(id,:)   = nanmean(tmp.RT (strcmp ('CSplus', tmp.condition)));
%     all.RT.CSminus(id,:)  = nanmean(tmp.RT (strcmp ('CSminus', tmp.condition)));
%     
%     all.ratings.CSplus(id,:)  = tmp.ratings(strcmp ('CSplus', tmp.condition));
%     all.ratings.CSminus(id,:) = tmp.ratings(strcmp ('CSminus', tmp.condition));
%     
% end



%%%%%%%%%%%%%%%%%%%%%%%%%% ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get means and std

% bysub.ratingsCSp  =  PavCheck.ratings(strcmp('CSplus.jpg',PavCheck.imagesName));
% bysub.ratingsCSm  =  PavCheck.ratings(strcmp('CSminu.jpg',PavCheck.imagesName));
% bysub.ratingsbase = PavCheck.ratings(strcmp('CSbaseli.jpg',PavCheck.imagesName));

%f.ratings.means.CSp = nanmean(bysub.ratingsCSp,1);
%f.ratings.means.CSm = nanmean(bysub.ratingsCSm,1);
%f.ratings.means.b   = nanmean(bysub.ratingsbase,1);

%f.ratings.stnd.CSp  = nanstd(bysub.ratingsCSp,1)/sqrt(length(subj));
%f.ratings.stnd.CSm  = nanstd(bysub.ratingsCSm,1)/sqrt(length(subj));
%f.ratings.stnd.b    = nanstd(bysub.ratingsbase,1)/sqrt(length(subj));

%means = ([f.ratings.means.CSp, f.ratings.means.CSm, f.ratings.means.b]);
%sems  = ([f.ratings.stnd.CSp, f.ratings.stnd.CSm, f.ratings.stnd.b]);

%y = means ((1:length(means)));
%bars = sems (1:length(sems));

%figure;
%bar(1, y(1),0.5, 'faceColor',[1 1 1],'EdgeColor', [0 0 0], 'LineWidth', 1);
%hold on
%bar(2, y(2),0.5, 'faceColor',[0 0 0]);
%bar(3, y(3),0.5, 'faceColor',[0.4 0.4 0.4],'EdgeColor', [0 0 0], 'LineWidth', 1);

%errorbar(1:length(sems),y,bars,'.k', 'LineWidth', 1.5);
%set(gca, 'XTickLabel', '')

% general
%set(gcf, 'Color', 'w')
%box off

%legend
%LEG = legend ('CS+','CS-','baseline');
%set(LEG,'FontSize',18)

%axis
%xlabel('Fractals', 'FontSize', 18)
%ylabel('ratings', 'FontSize', 18)
%ylim ([0 100])

%plot
%title ('Pavlovian learning: ratings ratings', 'FontSize', 18)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%f.RT.means.CSp = nanmean(all.RT.CSplus);
%f.RT.means.CSm = nanmean(all.RT.CSminus);

%f.RT.stnd.CSp  = nanstd(all.RT.CSplus,1)/sqrt(length(subj));
%f.RT.stnd.CSm  = nanstd(all.RT.CSminus,1)/sqrt(length(subj));

%figure;
%means = ([f.RT.means.CSp, f.RT.means.CSm]);
%sems  = ([f.RT.stnd.CSp, f.RT.stnd.CSm]);

%y = means ((1:length(means)));
%bars = sems (1:length(sems));

%bar(1, y(1),0.5, 'faceColor',[1 1 1],'EdgeColor', [0 0 0], 'LineWidth', 1);
%hold on
%bar(2, y(2),0.5, 'faceColor',[0 0 0]);

%errorbar(1:length(sems),y,bars,'.k', 'LineWidth', 1.5);
%set(gca, 'XTickLabel', '')

% general
%set(gcf, 'Color', 'w')
%box off

%legend
%LEG = legend ('CS+','CS-');
%set(LEG,'FontSize',18)

%axis
%xlabel('Fractals', 'FontSize', 18)
%ylabel('Reaction Times', 'FontSize', 18)

%title
%title ('Pavlovian learning: Reaction times', 'FontSize', 18)
