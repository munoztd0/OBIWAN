%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Eva
% last modified by David on JULY 2019

% note: this scripts works only on participants who followed the full
% protocol 

dbstop if error
clear all

analysis_name = 'REWOD_HEDONIC_ses_second';
task          = 'hedonic';
%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 1; % leave 1 when saving all subjects

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/REWOD/'];


analysis_dir = fullfile(homedir, 'ANALYSIS/BEHAV/build_database');
R_dir        = fullfile(homedir,'DERIVATIVES/BEHAV');
% add tools
addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/my_tools')));

%% DEFINE POPULATION

subj    = {'01'; '02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};    % outliers and removed ?? subject ID excluding 8 & 1
session = {'two';'two';'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'};

ses = {'ses-second'};


for i = 1:length(subj)
        
    subjO=subj(i,1);
    subjX=char(subjO);
    %conditionX=char(group(i,1))
    sessionX  =char(ses);   
    
    disp (['****** PARTICIPANT: ' subjX ' *******']);
   
    %load behavioral file
    behavior_dir = fullfile(homedir, 'SOURCEDATA', 'behav', subjX, [sessionX '_task-' task]);
            cd (behavior_dir)
            load (['hedonic_S' num2str(subjX) ])
    
    
   ntrials = data.Trial(end);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get onsets

    ONSETS.trialstart  = data.tTrialStart; 
    ONSETS.trialEnd  = data.tTrialEnd; 
    ONSETS.sniffSignalOnset  = data.sniffSignalOnset; 
    ONSETS.ValveOpen      = data.tValveOpen;
    ONSETS.ValveClose      = data.tValveClose;
    %ONSETS.break       = data.Onsets.Startjitter;
    ONSETS.ITI         = data.sniffSignalOnset+data.duration.asterix1+data.duration.oCommitISI+ data.duration.asterix2+data.duration.jitter+data.duration.Liking+data.duration.IQCross+data.duration.Intensity;
    ONSETS.liking          = data.sniffSignalOnset+data.duration.asterix1+data.duration.oCommitISI+ data.duration.asterix2+data.duration.jitter;
    ONSETS.intensity       = data.sniffSignalOnset+data.duration.asterix1+data.duration.oCommitISI+ data.duration.asterix2+data.duration.jitter+data.duration.Liking+data.duration.IQCross;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get durations
    DURATIONS.trialstart  = data.duration.asterix1 + data.duration.asterix2;
    DURATIONS.break       = data.duration.jitter;
    DURATIONS.liking      = data.duration.Liking;
    DURATIONS.intensity   = data.duration.Intensity;
    DURATIONS.ITI         = data.duration.ITI;
    DURATIONS.SendTriggerStart         = data.duration.SendTriggerStart;
    DURATIONS.CommitOdor         = data.duration.oCommitOdor;
    DURATIONS.CommitISI         = data.duration.oCommitISI;
    DURATIONS.SendTriggerSniff         = data.duration.SendTriggerSniff;
    DURATIONS.fixation      = data.duration.IQCross;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get condition name and the trial and drift
    % fix the cell bug for odorLabel
    A =strcmp(data.odorLabel,'empty');
    B = strcmp(data.odorLabel,'chocolate');
    data.odorLabel2 = categorical(zeros(1,data.Trial(end))'+ A + A + B);
    data.odorLabel2 = mergecats(data.odorLabel2,'2','empty');
    data.odorLabel2 = mergecats(data.odorLabel2,'1','chocolate');
    data.odorLabel2 = cellstr(mergecats(data.odorLabel2,'0','neutral')); 
    CONDITIONS = data.odorLabel2;
    TRIAL = data.Trial;
    DRIFT = data.drift;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get the ratings
    BEHAVIOR.liking      = data.liking;
    BEHAVIOR.intensity   = data.intensity;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get the odor
    ODOR.Trigger = data.odorTrigger;
    ODOR.Side = data.odorSide;
    ODOR.Stim = data.odorStim;
    
    % item by condition
    itemxc          = nan(ntrials,1);
    count_reward    = 0;
    count_control   = 0;
    count_neutral   = 0;
    
    for ii = 1:length(CONDITIONS)
        
        if strcmp ('chocolate', CONDITIONS(ii))
            count_reward         = count_reward + 1;
            itemxc(ii)           = count_reward;
     
        elseif strcmp ('empty', CONDITIONS(ii))
            count_control        = count_control + 1;
            itemxc(ii)           = count_control;
        
        elseif strcmp ('neutral', CONDITIONS(ii))
            count_neutral        = count_neutral + 1;
            itemxc(ii)           = count_neutral;
        
        end
        
    end
    
    %load physio file
    physio_dir = fullfile(homedir, 'SOURCEDATA', 'physio', subjX);
    cd (physio_dir)
    load (['sub-' num2str(subjX) '_ses-second_task-hedonic_EMG'])
    
    [A IdX] = sort(data.ORDER);
    
    PHYSIO.EMG = data.COR(IdX,:);
    %EMG.BASE = data.BASE(IdX,:);
    
    ONSETS.EMG     =    ONSETS.sniffSignalOnset + 2.5;
    DURATIONS.EMG  =    zeros(length(ONSETS.EMG),1) + 0.5;
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save mat file
    func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-' num2str(subjX)], 'ses-second', 'func');
    cd (func_dir)
    matfile_name = ['sub-' num2str(subjX) '_ses-second' '_task-' task '_run-01_events.mat'];
    %cd (behavior_dir)
    save(matfile_name, 'ONSETS', 'DURATIONS', 'BEHAVIOR', 'CONDITIONS', 'ODOR', 'TRIAL', 'DRIFT', 'PHYSIO' )
    


    
    
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save tvs file according to BIDS format
    phase = {'trialstart';'liking'; 'EMG'; 'intensity'; 'ITI'};
    nevents = ntrials*length(phase);
    
    % put everything in the event structure
    events.onsets       = zeros(nevents,1);
    events.durations    = zeros(nevents,1);
    events.phase        = cell (nevents,1);
    events.condition    = cell (nevents,1);
    events.liking       = nan (nevents,1);
    events.intensity    = nan (nevents,1);
    events.trial        = zeros (nevents,1);
    events.EMG          = nan (nevents,1);
    
    
    
    cmpt = 0;
    for ii = 1:ntrials
        
        for iii = 1:length(phase)
            
            cmpt = cmpt+1;
            phaseX = char(phase(iii));
            
            events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
            events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
            events.phase(cmpt)      = phase (iii);
            events.condition(cmpt)  = CONDITIONS(ii);
            events.liking(cmpt)     = BEHAVIOR.liking(ii);
            events.intensity(cmpt)  = BEHAVIOR.intensity(ii);
            events.trial(cmpt)      = TRIAL(ii);
            events.EMG(cmpt)        = PHYSIO.EMG(ii);
            
        end
        
    end
    
    events.onsets       = num2cell(events.onsets);
    events.durations    = num2cell(events.durations);
    events.liking       = num2cell(events.liking);
    events.intensity    = num2cell(events.intensity);
    events.trial        = num2cell(events.trial);
    events.EMG        = num2cell(events.EMG);
    
    
    
     eventfile = [events.onsets, events.durations, events.phase,...
        events.trial, events.condition, events.EMG, events.liking, events.intensity];
    
    % open data base
    eventfile_name = ['sub-' num2str(subjX) '_ses-second' '_task-' task '_run-01_events.tsv'];
    fid = fopen(eventfile_name,'wt');
    
    % print heater
    fprintf (fid, '%s	%s	%s	%s	%s	%s	%s	%s\n',...
        'onset', 'duration', 'trial_phase',...
        'trial', 'condition','EMG_cor', 'perceived_liking','perceived_intensity');
    
    % print data
    formatSpec = '%f	%f	%s	%d	%s	%f	%f	%f\n'; %d = vector s=text
    [nrows,ncols] = size(eventfile);
    for row = 1:nrows
        fprintf(fid,formatSpec,eventfile{row,:});
    end
    
    fclose(fid);
 
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save data for compiled database
    
    db.id(:,i)           = repmat(subj(i,1),ntrials, 1);
    %db.group(:,i)        = repmat(group(i,1),ntrials, 1);
    db.session(:,i)      = repmat(session(i,1),ntrials,1);
    db.task(:,i)         = repmat({task},ntrials,1);
    db.trial(:,i)        = [1:ntrials]';
    db.condition(:,i)    = CONDITIONS;
    db.itemxc(:,i)       = itemxc;
    db.liking (:,i)      = BEHAVIOR.liking;
    %db.familiarity (:,i) = BEHAVIOR.familiarity;
    db.intensity (:,i)   = BEHAVIOR.intensity;
    db.EMG (:,i)         = PHYSIO.EMG;
    
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% SAVE RESULTS IN TXT for analysis in R

% random
R.id      = db.id(:);
R.trial   = num2cell(db.trial(:));

%fixe
%R.group      = db.group(:);
R.session    = db.session(:);
R.task       = db.task(:);
R.condition  = db.condition(:);

% mixed
R.itemxc     = num2cell(db.itemxc(:));

% dependent variable
R.liking      = num2cell(db.liking(:));
R.intensity   = num2cell(db.intensity(:));
R.EMG   = num2cell(db.EMG(:));
%R.familiarity = num2cell(db.familiarity(:));

%% print the database
cd (R_dir)

% concatenate
Rdatabase = [R.task, R.id, R.session, R.trial, R.condition, R.itemxc, R.liking, R.intensity, R.EMG];

% open database
fid = fopen([analysis_name '.txt'], 'wt');

% print heater
fprintf(fid,'%s %s %s %s %s %s %s %s %s\n',...
    'task','id', 'session','trial', 'condition','trialxcondition','perceived_liking', 'perceived_intensity', 'EMG');

% print data
formatSpec ='%s %s %s %d %s %d %f %f %f\n';
[nrows,~] = size(Rdatabase);
for row = 1:nrows
    fprintf(fid,formatSpec,Rdatabase{row,:});
end

fclose(fid);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%     s.condition   = db.condition(idx);
%     s.liking      = db.liking(idx);
%     %s.familiarity = db.familiarity(idx);
%     s.intensity   = db.intensity(idx);
%     
%     ratings.liking.reward(id,:)      = s.liking (strcmp ('chocolate', s.condition));
%     ratings.liking.control(id,:)     = s.liking (strcmp ('empty', s.condition));
%     ratings.liking.neutral(id,:)     = s.liking (strcmp ('neutral', s.condition));
%    
%     %ratings.familiarity.reward(id,:) = s.familiarity (strcmp ('chocolate', s.condition));
%     %ratings.familiarity.control(id,:)= s.familiarity (strcmp ('empty', s.condition));
% 
%     ratings.intensity.reward(id,:)   = s.intensity (strcmp ('chocolate', s.condition));
%     ratings.intensity.control(id,:)  = s.intensity (strcmp ('empty', s.condition));
%     ratings.intensity.neutral(id,:)  = s.intensity (strcmp ('neutral', s.condition));
% 
%     
% end
% 
% % get means and std
% list = {'liking'; 'intensity'};
% 
% for ii = 1:length(list)
%     
%     conditionX = char(list(ii));
%     
%     means.(conditionX).reward = nanmean(ratings.(conditionX).reward,1);
%     means.(conditionX).control= nanmean(ratings.(conditionX).control,1);
%     means.(conditionX).neutral= nanmean(ratings.(conditionX).neutral,1);
%     
%     
%     stnd.(conditionX).reward = nanstd(ratings.(conditionX).reward,1)/sqrt(length(subj));
%     stnd.(conditionX).control= nanstd(ratings.(conditionX).control,1)/sqrt(length(subj));%eva, you put reward twice?
%     stnd.(conditionX).neutral= nanstd(ratings.(conditionX).neutral,1)/sqrt(length(subj));
%     
% end
% 
% 
% % plot the means and std
% figure;
% 
% set(gcf, 'Color', 'w')
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%% liking pannel
% subplot(3,1,1)
% 
% % reward
% forplot.liking.reward = plot(means.liking.reward,'-o');
% set(forplot.liking.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% hold
% % control
% forplot.liking.control= plot(means.liking.control,'--o');
% set(forplot.liking.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])
% 
% % neutral
% forplot.liking.neutral= plot(means.liking.neutral,'--o');
% set(forplot.liking.neutral(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.3 0.4 0.4],'MarkerEdgeColor', [0.3 0.7 0.7], 'Color', [0 0 0])
% 
% %axis
% xlabel('Trial', 'FontSize', 15)
% ylabel('Liking', 'FontSize', 18)
% ylim ([0 100])
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%% intesity pannel
% subplot(3,1,2)
% 
% % reward
% forplot.intensity.reward = plot(means.intensity.reward,'-o');
% set(forplot.intensity.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% hold
% % control
% forplot.intensity.control= plot(means.intensity.control,'--o');
% set(forplot.intensity.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])
% 
% % neutral
% forplot.intensity.neutral= plot(means.intensity.neutral,'--o');
% set(forplot.intensity.neutral(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.3 0.4 0.4],'MarkerEdgeColor', [0.3 0.7 0.7], 'Color', [0 0 0])
% 
% %axis
% xlabel('Trial', 'FontSize', 15)
% ylabel('Intensity', 'FontSize', 18)
% ylim ([0 100])
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%  familiarity pannel
% %subplot(3,1,3)
% 
% % reward
% %forplot.familiarity.reward = plot(means.familiarity.reward,'-o');
% %set(forplot.familiarity.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% %hold
% % control
% %forplot.familiarity.control= plot(means.familiarity.control,'--o');
% %set(forplot.familiarity.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])
% 
% %axis
% %xlabel('Trial', 'FontSize', 15)
% %ylabel('Familiarity', 'FontSize', 18)
% %ylim ([0 100])
% 
% %legend
% LEG = legend ('reward','control','neutral');  % 'neutral');
% set(LEG,'FontSize',18);