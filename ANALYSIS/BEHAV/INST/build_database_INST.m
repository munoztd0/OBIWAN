%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified by David on August 2020



dbstop if error
clear all

analysis_name = 'REWOD_INSTRU_ses_first';
task          = 'instrulearning';
taskshort          = 'INSTRU';
%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 1; % leave 1 when saving all subjects

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/REWOD/'];


analysis_dir = fullfile(homedir, 'ANALYSIS/BEHAV/INSTRU');
R_dir        = fullfile(homedir,'DERIVATIVES/BEHAV/INSTRU');
% add tools
addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));

%% DEFINE POPULATION

subj    = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};    % number 01 has not instru

session = {'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'};

ses = {'ses-first'};

for i = 1:length(subj)
        
    subjO=subj(i,1);
    subjX=char(subjO);
    %conditionX=char(group(i,1))
    sessionX  =char(ses);   
    
    disp (['****** PARTICIPANT: ' subjX ' *******']);
   
    %load behavioral file
    behavior_dir = fullfile(homedir, 'SOURCEDATA', 'behav', subjX, [sessionX '_task-' task]);
    cd (behavior_dir)
    load (['instrumental' num2str(subjX) ])
   
   ntrials = ResultsInstru.Trial(end);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get onsets

    ONSETS.trigger      = ResultsInstru.TriggerOnset'; 
    ONSETS.trialstart        = ResultsInstru.TrialOnset';
    %ONSETS.PE           = ResultsPartialExtinction.TrialOnset';
    %ONSETS.sniffSignalOnset  = ResultsInstru.sniffSignalOnset; 
    ONSETS.ValveOpenR1    = ResultsInstru.tValveOpenR1';
    ONSETS.ValveCloseR1   = ResultsInstru.tValveCloseR1';
    ONSETS.ValveOpenR2    = ResultsInstru.tValveOpenR2';
    ONSETS.ValveCloseR2   = ResultsInstru.tValveCloseR2';
    %ONSETS.break       = ResultsInstru.Onsets.Startjitter;
    %ONSETS.liking      = ResultsInstru.likingOnset;
    %ONSETS.intensity   = ResultsInstru.intensityOnset;
    %ONSETS.familiarity = ResultsInstru.Onsets.Familiarity;
    %ONSETS.rince       = ResultsInstru.Onsets.RinseStart; % start or stop?
    ONSETS.ITI         = ResultsInstru.OnsetITI';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get durations
    DURATIONS.trialstart       = ResultsInstru.TrialDuration';
    DURATIONS.FirstReward  = ResultsInstru.FirstRewardTime';
    DURATIONS.SecondReward       = ResultsInstru.SecondRewardTime';
    DURATIONS.RewardWindow1      = ResultsInstru.tValveCloseR1' - ResultsInstru.tValveOpenR1';
    DURATIONS.RewardWindow2  = ResultsInstru.tValveCloseR2' - ResultsInstru.tValveOpenR2';
    DURATIONS.ITI         = ResultsInstru.ITI';
    %DURATIONS.rince       = ResultsInstru.Durations.asterix3; % start or stop?
    %DURATIONS.SendTriggerStart         = ResultsInstru.duration.SendTriggerStart;
    %DURATIONS.CommitOdor         = ResultsInstru.duration.oCommitOdor;
    %DURATIONS.CommitISI         = ResultsInstru.duration.oCommitISI;
    %DURATIONS.SendTriggerSniff         = ResultsInstru.duration.SendTriggerSniff;
    %DURATIONS.fixation      = ResultsInstru.duration.IQCross;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get condition name and the trial and drift
    force = ResultsInstru.mobilizedforce;
    threshold = data.maximalforce/100*50;% value
    [nlines ncolons] = size(force);
    gripsFrequence (1,:) = countgrips(threshold,nlines,ncolons,force);
    REWARD = ResultsInstru.RewardedResponses;
    FORCE = gripsFrequence';
    TRIAL = ResultsInstru.Trial';
    DRIFT = ResultsInstru.drift';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get the ratings
    %BEHAVIOR.liking      = ResultsInstru.liking;
    %BEHAVIOR.intensity   = ResultsInstru.intensity;
    %BEHAVIOR.familiarity = ResultsInstru.familiarity;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get the odor
    %ODOR.Trigger = ResultsInstru.odorTrigger;
    %ODOR.Side = ResultsInstru.odorSide;
    %ODOR.Stim = ResultsInstru.odorStim;
    
    % item by condition
    %itemxc          = nan(ntrials,1);
    %count_reward    = 0;
    %count_control   = 0;
    %count_neutral   = 0;
    
   % for ii = 1:length(CONDITIONS)
        
       % if strcmp ('chocolate', CONDITIONS(ii))
            %count_reward         = count_reward + 1;
            %itemxc(ii)           = count_reward;
     
        %elseif strcmp ('empty', CONDITIONS(ii))
            %count_control        = count_control + 1;
            %itemxc(ii)           = count_control;
        
       % elseif strcmp ('neutral', CONDITIONS(ii))
            %count_neutral        = count_neutral + 1;
            %itemxc(ii)           = count_neutral;
        
        %end
        
    %end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save mat file
    func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-' num2str(subjX)], 'ses-first', 'beh');
    cd (func_dir)
    matfile_name = ['sub-' num2str(subjX) '_ses-first' '_task-' task '_events.mat'];
    save(matfile_name, 'ONSETS', 'DURATIONS',  'REWARD', 'FORCE', 'TRIAL', 'DRIFT' )
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save tvs file according to BIDS format
    phase = {'trialstart'; 'ITI'};
    nevents = ntrials*length(phase);
    
    % put everything in the event structure
    events.onsets       = zeros(nevents,1);
    events.durations    = zeros(nevents,1);
    events.phase        = cell (nevents,1);
    events.force        = zeros (nevents,1);
    events.reward       = zeros (nevents,1);
    events.trial        = zeros (nevents,1);
    
    
    
    cmpt = 0;
    for ii = 1:ntrials
        
        for iii = 1:length(phase)
            
            cmpt = cmpt+1;
            phaseX = char(phase(iii));
            
            events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
            events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
            events.phase(cmpt)      = phase (iii);
            events.force(cmpt)      = FORCE(ii);
            events.reward(cmpt)     = REWARD(ii);
            events.trial(cmpt)      = TRIAL(ii);
            
        end
        
    end
    
    events.onsets       = num2cell(events.onsets);
    events.durations    = num2cell(events.durations);
    events.force       = num2cell(events.force);
    events.reward    = num2cell(events.reward);
    events.trial    = num2cell(events.trial);
    
    
    
     eventfile = [events.onsets, events.durations, events.phase,...
        events.trial, events.force, events.reward];
    
    
        %%% save mat file
    base_dir = fullfile (homedir, ['sub-' num2str(subjX)], 'ses-first', 'beh');
    %mkdir(base_dir)
    cd (base_dir)
    
    % open ResultsInstru base
    eventfile_name = ['sub-' num2str(subjX) '_ses-first' '_task-' task '_events.tsv'];
    fid = fopen(eventfile_name,'wt');
    
    % print heater
    fprintf (fid, '%s\t%s\t%s\t%s\t%s\t%s\t\n',...
        'onset', 'duration', 'trial_phase',...
        'trial', 'n_grips','rewarded_response');
    
    % print ResultsInstru
    formatSpec = '%f\t%f\t%s\t%d\t%d\t%d\t\n'; %d = vector s=text
    [nrows,ncols] = size(eventfile);
    for row = 1:nrows
        fprintf(fid,formatSpec,eventfile{row,:});
    end
    
    fclose(fid);
 
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save ResultsInstru for compiled ResultsInstrubase
    
    db.id(:,i)           = repmat(subj(i,1),ntrials, 1);
    %db.group(:,i)        = repmat(group(i,1),ntrials, 1);
    db.session(:,i)      = repmat(session(i,1),ntrials,1);
    db.task(:,i)         = repmat({task},ntrials,1);
    db.trial(:,i)        = [1:ntrials]';
    db.force(:,i)        = FORCE;
    %db.itemxc(:,i)       = itemxc;
    db.reward (:,i)      = REWARD;
    %db.familiarity (:,i) = BEHAVIOR.familiarity;
    %db.intensity (:,i)   = BEHAVIOR.intensity;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE RESULTS IN TXT for analysis in R

% random
R.id      = db.id(:);
R.trial   = num2cell(db.trial(:));

%fixe
%R.group      = db.group(:);
R.session    = db.session(:);
R.task       = db.task(:);
%R.force  = db.force(:);

% mixed
R.reward     = num2cell(db.reward(:));

% dependent variable
R.force      = num2cell(db.force(:));
%R.intensity   = num2cell(db.intensity(:));
%R.familiarity = num2cell(db.familiarity(:));

%% print the ResultsInstrubase
cd (R_dir)

% concatenate
Rdatabase = [R.task, R.id, R.session, R.trial, R.reward, R.force,];

% open ResultsInstrubase
fid = fopen([analysis_name '.txt'], 'wt');

% print heater
fprintf(fid,'%s %s %s %s %s %s\n',...
    'task','id',  ...
    'session','trial', ...
    'rewarded_response','n_grips');

% print ResultsInstru
formatSpec ='%s %s %s %d %d %f\n';
[nrows,~] = size(Rdatabase);
for row = 1:nrows
    fprintf(fid,formatSpec,Rdatabase{row,:});
end

fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CREATE FIGURE

%for id = 1:length(subj)
    
    % get ResultsInstru for that participant
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