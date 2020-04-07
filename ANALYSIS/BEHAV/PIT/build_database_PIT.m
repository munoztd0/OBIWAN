
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Eva
% last modified by David on August 2019

% note: this scripts works only on participants who followed the full
% protocol (from obsese200 on)

dbstop if error
clear all

analysis_name = 'REWOD_PIT_ses_second';
task          = 'PIT';
%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 1; % leave 1 when saving all subjects

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/REWOD/'];


analysis_dir = fullfile(homedir, 'ANALYSIS/BEHAV/build_database');
R_dir        = fullfile(homedir,'DERIVATIVES/BEHAV');
% add tools
addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));

%% DEFINE POPULATION
subj    = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};    % subject ID excluding 8 & 19
session = {'two';'two';'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'};

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
            load (['PIT_S' num2str(subjX) ])
   
    
    
    % get ntrials
    [a b c] = size(ResultsPIT.ITI);
    PIT.ntrials = b*c;
    PE.ntrials = size(ResultsPartialExtinction.TrialOnset,2);
    RIM.ntrials = size(ResultsRimind.TrialOnset,2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get onsets
    
    PIT.ONSETS.trialstart   = reshape(ResultsPIT.Onset,PIT.ntrials,1);
    ResultsPIT.onset        = reshape(ResultsPIT.Onset,PIT.ntrials,1)';
    PIT.ONSETS.trigger      = reshape(ResultsPIT.TriggerOnset,PIT.ntrials,1);
    PIT.ONSETS.ITI          = reshape(ResultsPIT.OnsetITI,PIT.ntrials,1);
  
    PE.ONSETS.trigger       = ResultsPartialExtinction.TriggerOnset'; 
    PE.ONSETS.trialstart       = ResultsPartialExtinction.TrialOnset';
    ResultsPE.onset       = ResultsPartialExtinction.TrialOnset;
    PE.ONSETS.ValveOpenR    = ResultsPartialExtinction.tValveOpenR';
    PE.ONSETS.ValveCloseR   = ResultsPartialExtinction.tValveCloseR';
    PE.ONSETS.ITI           = ResultsPartialExtinction.onsetITI';
    
    
    RIM.ONSETS.trigger       = ResultsRimind.TriggerOnset'; 
    RIM.ONSETS.trialstart         = ResultsRimind.TrialOnset';
    ResultsRimind.onset         = ResultsRimind.TrialOnset;
    RIM.ONSETS.ValveOpenR1    = ResultsRimind.tValveOpenR1';
    RIM.ONSETS.ValveCloseR1   = ResultsRimind.tValveCloseR1';
    RIM.ONSETS.ValveOpenR2    = ResultsRimind.tValveOpenR2';
    RIM.ONSETS.ValveCloseR2   = ResultsRimind.tValveCloseR2';
    RIM.ONSETS.ITI            = ResultsRimind.OnsetITI';
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get durations
    PIT.DURATIONS.trialstart      = reshape(ResultsPIT.ItemDuration,1,PIT.ntrials)';
    ResultsPIT.duration      = reshape(ResultsPIT.ItemDuration,1,PIT.ntrials);
    PIT.DURATIONS.ITI             = reshape(ResultsPIT.ITI,1,PIT.ntrials)';
    PIT.reward1                    = zeros(1,PIT.ntrials);
    PIT.reward2                    = zeros(1,PIT.ntrials);
    
    PE.DURATIONS.trialstart       = ResultsPartialExtinction.TrialDuration';
    ResultsPE.duration       = ResultsPartialExtinction.TrialDuration;
    PE.DURATIONS.FirstReward      = ResultsPartialExtinction.FirstRewardTime';
    PE.reward1                    = ResultsPartialExtinction.tValveCloseR - ResultsPartialExtinction.tValveOpenR;
    PE.reward2                    = zeros(1,PE.ntrials);
    PE.DURATIONS.ITI              = ResultsPartialExtinction.ITI';
    
    RIM.DURATIONS.trialstart            = ResultsRimind.TrialDuration';
    ResultsRimind.duration            = ResultsRimind.TrialDuration;
    RIM.DURATIONS.FirstReward      = ResultsRimind.FirstRewardTime';
    RIM.DURATIONS.SecondReward     = ResultsRimind.SecondRewardTime';
    RIM.reward1                    = ResultsRimind.tValveCloseR1 - ResultsRimind.tValveOpenR1; %we needed to compute it like this because the windowdurations are off
    RIM.reward1(isnan(RIM.reward1)) = 0;  % converting NaN to 0
    RIM.reward2                    = ResultsRimind.tValveCloseR2 - ResultsRimind.tValveOpenR2;
    RIM.DURATIONS.ITI              = ResultsRimind.ITI';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PIT.ITEM    = reshape(ResultsPIT.Item,1,PIT.ntrials)';
    PIT.IMAGE    = reshape(ResultsPIT.Image,1,PIT.ntrials)';
    PIT.TRIAL = [1:PIT.ntrials]';
    PIT.REWARD = [1: PIT.ntrials]';
    PIT.REWARD(:) = [0]; %get reward for PIT even so it doesnt have one
    
    PE.TRIAL = ResultsPartialExtinction.Trial';
    PE.DRIFT = ResultsPartialExtinction.drift';
    PE.REWARD = ResultsPartialExtinction.RewardedResponses';
    
    RIM.TRIAL = ResultsRimind.Trial';
    RIM.DRIFT = ResultsRimind.drift';
    RIM.REWARD = ResultsRimind.RewardedResponses';
    
   
   

    %%%  get condition name
    A =strcmp(PIT.IMAGE,'CSplus.jpg');
    B = strcmp(PIT.IMAGE,'CSminu.jpg');
    PIT.IMAGE2 = categorical(zeros(1,PIT.ntrials)'+ 2*A + B);
    PIT.IMAGE2 = mergecats(PIT.IMAGE2,'2','CSplus');
    PIT.IMAGE2 = mergecats(PIT.IMAGE2,'1','CSminus');
    PIT.IMAGE2 = cellstr(mergecats(PIT.IMAGE2,'0','Baseline')); 
    PIT.CONDITIONS = PIT.IMAGE2;
    
    
    %get conditions for PE and RIM
    PE.CONDITIONS = cell(1, PE.ntrials)';
    PE.CONDITIONS(:) = {'None'}; 
    
    RIM.CONDITIONS = cell(1, RIM.ntrials)';
    RIM.CONDITIONS(:) = {'None'};
    
    
    %CS = '';
    %cmp = 0;
    %for ii = 1:5
        %for n = 1:9
            %cmp = cmp + 1;
            %CS = IMAGE{ii,n};%first dimension of the matrix
            %CONDITIONS.CS{cmp} = CS;
        %end
    %end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get the mobilized effort % concatenate the mobilized effort
    % compute the treshold to determine what we consider as a response (50% of the maximal force)
    threshold = data.maximalforce/100*50;
    %get force
    PIT.ntrials1 = size(ResultsPIT.force, 1);
    PIT.force = reshape(ResultsPIT.force,PIT.ntrials1,PIT.ntrials);  %we need to reshape in a 360*45 matrix
    PE.force = ResultsPartialExtinction.mobilizedforce;
    RIM.force = ResultsRimind.mobilizedforce;
    
    %get ncolons and nlines
    [PIT.nlines PIT.ncolons] = size(PIT.force);
    [PE.nlines PE.ncolons] = size(PE.force);
    [RIM.nlines RIM.ncolons] = size(RIM.force);
    
    %get freq to get mob_effort &     % extract the number of grips
    PIT.gripsFrequence (1,:) = countgrips(threshold,PIT.nlines,PIT.ncolons,PIT.force); %i need a revrrser by 45 matrix
    PIT.BEHAVIOR.mobilized_effort = PIT.gripsFrequence';
    
    PE.gripsFrequence (1,:) = countgrips(threshold,PE.nlines,PE.ncolons,PE.force);
    PE.BEHAVIOR.mobilized_effort = PE.gripsFrequence';
   
    
    RIM.gripsFrequence (1,:) = countgrips(threshold,RIM.nlines,RIM.ncolons,RIM.force);
    RIM.BEHAVIOR.mobilized_effort = RIM.gripsFrequence';
    
    % extract the onset of each grip??
    
   
    
    PIT.ONSETS.grips = gripsOnsets(threshold,PIT.nlines,PIT.ncolons,PIT.force, ResultsPIT.onset,PIT.reward1,PIT.reward2, ResultsPIT.duration);
    PE.ONSETS.grips = gripsOnsets(threshold,PE.nlines,PE.ncolons,ResultsPartialExtinction.mobilizedforce,ResultsPE.onset,PE.reward1,PE.reward2, ResultsPE.duration);
    RIM.ONSETS.grips = gripsOnsets(threshold,RIM.nlines,RIM.ncolons,ResultsRimind.mobilizedforce,ResultsRimind.onset, RIM.reward1,RIM.reward2, ResultsRimind.duration);
    
    %create TASK
    PIT.TASK = cell(1, PIT.ntrials)';
    PIT.TASK(:) = {'PIT'}; 
    
    PE.TASK = cell(1, PE.ntrials)';
    PE.TASK(:) = {'Partial_Extinction'}; 
    
    RIM.TASK = cell(1, RIM.ntrials)';
    RIM.TASK(:) = {'Reminder'}; 
    
    %%now concatenate all
    ONSETS.trialstart = vertcat(RIM.ONSETS.trialstart, PE.ONSETS.trialstart, PIT.ONSETS.trialstart);
    ONSETS.trigger = vertcat(RIM.ONSETS.trigger, PE.ONSETS.trigger, PIT.ONSETS.trigger);
    ONSETS.ITI = vertcat(RIM.ONSETS.ITI, PE.ONSETS.ITI, PIT.ONSETS.ITI);
    ONSETS.grips = vertcat(RIM.ONSETS.grips, PE.ONSETS.grips,PIT.ONSETS.grips);
    
    DURATIONS.trialstart = vertcat(RIM.DURATIONS.trialstart, PE.DURATIONS.trialstart, PIT.DURATIONS.trialstart);
    DURATIONS.ITI = vertcat(RIM.DURATIONS.ITI, PE.DURATIONS.ITI, PIT.DURATIONS.ITI);
    
    BEHAVIOR.mobilized_effort = vertcat(RIM.BEHAVIOR.mobilized_effort, PE.BEHAVIOR.mobilized_effort, PIT.BEHAVIOR.mobilized_effort);
    
    CONDITIONS = vertcat(RIM.CONDITIONS, PE.CONDITIONS, PIT.CONDITIONS);
    REWARD = vertcat(RIM.REWARD, PE.REWARD, PIT.REWARD);
    TASK = vertcat(RIM.TASK, PE.TASK, PIT.TASK);
    
    ntrials = size(ONSETS.trialstart,1);
   % TRIAL = [1:ntrials];
    TRIAL = vertcat(RIM.TRIAL, PE.TRIAL, PIT.TRIAL); % or the one above ??
 
    
    % item by condition
    itemxc          = nan  (length(ntrials/4),1); %change 3 by 4
    count_CSp       = 0;
    count_CSm       = 0;
    count_baseline  = 0;
    count_none      = 0; %added a condition
        
    for ii = 1:length(CONDITIONS)
        
        if strcmp ('CSplus', CONDITIONS(ii))
            count_CSp     =  count_CSp + 1;
             itemxc(ii)   = count_CSp;
        elseif strcmp ('CSminus', CONDITIONS(ii))
            count_CSm      = count_CSm + 1;
            itemxc(ii)   = count_CSm;
        elseif strcmp ('Baseline', CONDITIONS(ii))
            count_baseline = count_baseline + 1;
            itemxc(ii)   = count_baseline;
        elseif strcmp ('None', CONDITIONS(ii))
            count_none = count_none + 1;
            itemxc(ii)   = count_none;
        end
        
    end
    
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save mat file
    func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-' num2str(subjX)], 'ses-second', 'func');
    cd (func_dir)
    matfile_name = ['sub-' num2str(subjX) '_ses-second' '_task-' task '_run-01_events.mat'];


    save(matfile_name, 'ONSETS', 'DURATIONS',  'BEHAVIOR', 'CONDITIONS', 'REWARD', 'TRIAL', 'RIM', 'PE', 'PIT')


    
    
    dir_dir = fullfile (homedir, ['sub-' num2str(subjX)], 'ses-second', 'func');
    cd (dir_dir)

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save tvs file according to BIDS format
    phase = {'trialstart';'ITI'};
    nevents = ntrials*length(phase);
    
    % put everything in the event structure
    events.onsets       = zeros(nevents,1);
    events.durations    = zeros(nevents,1);
    events.trial        = zeros(nevents,1);
    events.phase        = cell (nevents,1);
    events.CSname       = cell (nevents,1);
    events.grips        = nan (nevents,1);
    events.reward       = zeros(nevents,1);
    events.task         = cell (nevents,1);
    
    cmpt = 0;
    for ii = 1:ntrials
        
        for iii = 1:length(phase)
            
            cmpt = cmpt+1;
            phaseX = char(phase(iii));
            
            events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
            events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
            events.phase(cmpt)      = phase (iii);
            events.CSname(cmpt)     = CONDITIONS(ii);
            events.trial(cmpt)      = TRIAL(ii);
            events.grips(cmpt)      = BEHAVIOR.mobilized_effort(ii);
            events.reward(cmpt)      = REWARD(ii);
            events.task(cmpt)      = TASK(ii);
            
        end
        
    end
    
    events.onsets       = num2cell(events.onsets);
    events.durations    = num2cell(events.durations);
    events.grips        = num2cell(events.grips);
    events.trial        = num2cell(events.trial);
    events.reward        = num2cell(events.reward);
    
     eventfile = [events.onsets, events.durations,events.phase,...
        events.trial events.CSname, events.grips, events.reward, events.task];
    
    % open data base
    eventfile_name = ['sub-' num2str(subjX) '_ses-second' '_task-' task '_run-01_events.tsv'];
    fid = fopen(eventfile_name,'wt');
    
    % print heater
    fprintf (fid, '%s	%s	%s	%s	%s	%s	%s	%s\n',...
        'onset', 'duration', 'trial_phase',...
        'trial', 'condition','n_grips', 'rewarded_response', 'phase');
    
    % print data
    formatSpec = '%f	%f	%s	%d	%s	%d	%d	%s\n';
    [nrows,ncols] = size(eventfile);
    for row = 1:nrows
        fprintf(fid,formatSpec,eventfile{row,:});
    end
    
    fclose(fid);
 
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save data for compiled database
    
    db.id(:,i)        = repmat(subj(i,1),ntrials, 1);
    %db.group(:,i)     = repmat(group(i,1),ntrials, 1);
    db.session(:,i)   = repmat(session(i,1),ntrials,1);
    %db.task(:,i)      = repmat({task},ntrials,1);
    db.task(:,i)      = TASK;
    db.trial(:,i)     = [1:ntrials]';
    db.condition(:,i) = CONDITIONS;
    db.itemxc(:,i)    = itemxc;
    db.gripFreq (:,i) = BEHAVIOR.mobilized_effort;
    db.reward(:,i)    = REWARD;
    db.task (:,i) = TASK;
    
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
R.condition = db.condition(:);
R.task = db.task(:);

% mixed
R.itemxc     = num2cell(db.itemxc(:));

% dependent variable
R.gripFreq  = num2cell(db.gripFreq(:));
R.reward  = num2cell(db.reward(:));


%% print the database
cd (R_dir)

% concatenate
Rdatabase = [R.task, R.id, R.session, R.trial,R.condition, R.itemxc, R.gripFreq, R.reward];

% open database
fid = fopen([analysis_name '.txt'], 'wt');

% print heater
fprintf(fid,'%s %s %s %s %s %s %s %s\n',...
    'task','id', ...
    'session','trial', 'condition',...
    'trialxcondition','n_grips', 'reward');

% print data
formatSpec ='%s %s %s %d %s %d %d %d\n';
[nrows,~] = size(Rdatabase);
for row = 1:nrows
    fprintf(fid,formatSpec,Rdatabase{row,:});
end

fclose(fid);


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
%     condition = db.condition(idx);
%     gripsFreq = db.gripFreq(idx);
%     
%     grips.CSplus(id,:)   = gripsFreq (strcmp ('CSplus', condition));
%     grips.CSminus(id,:)  = gripsFreq (strcmp ('CSminus', condition));
%     grips.baseline(id,:) = gripsFreq (strcmp ('Baseline', condition));
%     %grips.none(id,:) = gripsFreq (strcmp ('None', condition));
%     
% end
% 
% % get means and std
% f.means.CSp = nanmean(grips.CSplus,1);
% f.means.CSm = nanmean(grips.CSminus,1);
% f.means.B   = nanmean(grips.baseline,1);
% %f.means.none   = nanmean(grips.none,1);
% 
% %f.stnd.CSp  = nanstd(grips.CSplus,1)/sqrt(length(subj));
% %f.stnd.CSm  = nanstd(grips.CSminus,1)/sqrt(length(subj));
% %f.stnd.B    = nanstd(grips.baseline,1)/sqrt(length(subj));
% 
% 
% figure; hold;
% 
% % cs plus
% csp = plot(f.means.CSp,'-o');
% set(csp(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% 
% 
% % csminus
% csm = plot(f.means.CSm,'-o');
% set(csm(1),'MarkerEdgeColor','none','MarkerFaceColor', [0 0 0],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% 
% 
% % baseline
% b = plot(f.means.B,'--o');
% set(b(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])
% 
% %none
% %none = plot(f.means.none,'--o');
% %set(b(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.7 0.7 0.7],'MarkerEdgeColor', [0.4 0.4 0.4], 'Color', [0 0 0])
% 
% 
% %legend
% LEG = legend ('CS+','CS-','baseline');
% set(LEG,'FontSize',18)
% 
% %axis
%  xlabel('Trial', 'FontSize', 18)
%  ylabel('Grips', 'FontSize', 18)
%  
% %plot
% title ('Pavlovian Instrumental Transfer', 'FontSize', 18)
% set(gcf, 'Color', 'w')
