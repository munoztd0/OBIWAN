%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE FOR PAVLOVIAN LEARNING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Eva
% last modified by Eva on March 27 2018

% note: this scripts works only on participants who followed the full
% protocol (from obsese200 on)

clear all
analysis_name = 'OBIWAN_Pavlovian';
task          = 'pavlovianlearning';

%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 0; % leave 1 when saving all subjects

%% DEFINE PATH

home = '/home/cisa/mountpoint';
%home = '/home/cisa/mountpoint/OBIWAN';
%home = '/Users/lavinia/mountpoint';
%home = '/Users/evapool/mountpoint';

analysis_dir = fullfile(home, '/ANALYSIS/Matlab_scripts');
R_dir        = fullfile(home,'/ANALYSIS/R_scripts');
% add tools
addpath (genpath(fullfile(analysis_dir,'my_tools')));

%% DEFINE POPULATION
subj    = {'265'};     % subject ID
group   = {'obese'}; % control or obsese
session = {'third'};

%subj    = {    '100';    '102';    '105';    '106';    '107';    '108';    '109';    '110';    '112';    '113';    '114';    '115';    '116';    '118';    '119';    '120';    '121';    '122';    '123';    '124';    '125';    '126';    '127';    '128';    '129';    '130';    '131';    '132';    '133'};     % subject ID
%group   = {'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control'}; % control or obsese
%session = { 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'};
ntrials = 40;

for i = 1:length(subj)
        
    subjX=subj(i,1);
    subjX=char(subjX);
    conditionX=char(group(i,1));
    sessionX  =char(session(i,1));
    
    disp (['****** PARTICIPANT: ' subjX ' *******']);
    
    %load behavioral file
    if strcmp(sessionX, 'third')
            behavior_dir = fullfile(home,'/DATA/STUDY/RAW/BEHAVIORAL/', [ conditionX num2str(subjX)], sessionX);
            cd (behavior_dir)
            load (['conditioning_2' num2str(subjX) ])
    else
        behavior_dir = fullfile(home,'/DATA/STUDY/RAW/BEHAVIORAL/', [ conditionX num2str(subjX)], sessionX);
        cd (behavior_dir)
        load (['conditioning_' num2str(subjX) ])
    end
    

        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get onsets  
  
    ONSETS.action  = nan;
    
    ONSETS.CS = data.Onsets.StageTwo;
    cmpt = 0;
  
    for ii = 1:length(data.Durations.TrialStageSix) % here take onther variable
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
    CONDITIONS.CS =  data.PavCond(~cellfun('isempty',data.csNames));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get Behavior
    BEHAVIOR.RT  = nan(ntrials,1);
    BEHAVIOR.ACC = nan(ntrials,1);
    for ii = 1:length(DURATIONS.action)
        BEHAVIOR.RT(ii) = DURATIONS.action(ii);
        BEHAVIOR.ACC(ii) = nan; % to be added
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save mat file
    func_dir = fullfile (home, 'DATA/STUDY/DERIVED/PIT_HEDONIC/', ['sub-' conditionX num2str(subjX)], ['ses-' sessionX], 'func');
    cd (func_dir)
    matfile_name = ['sub-' conditionX num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.mat'];
    save(matfile_name, 'ONSETS', 'DURATIONS',  'BEHAVIOR', 'CONDITIONS')
    
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
            
        end
        
    end
    
    events.onsets       = num2cell(events.onsets);
    events.durations    = num2cell(events.durations);
    events.reactionTime = num2cell(events.reactionTime);
    events.responseACC  = num2cell(events.responseACC);
            
    eventfile = [events.onsets, events.durations, events.phase,...
        events.CSname, events.reactionTime,events.responseACC];
    
    % open data base
    eventfile_name = ['sub-' conditionX num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.tsv'];
    fid = fopen(eventfile_name,'wt');
    
    % print heater
    fprintf (fid, '%s   %s   %s   %s   %s    %s\n',...
        'onset', 'duration', 'trialPhase',...
        'CSname','reactionTimes', 'reactionAccuracy');
    
    % print data
    formatSpec = '%d   %d   %s   %s  %d   %d\n';
    [nrows,ncols] = size(eventfile);
    for row = 1:nrows
        fprintf(fid,formatSpec,eventfile{row,:});
    end
    
    fclose(fid);
 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save data for compiled database
    
    db.id(:,i)        = repmat(subj(i,1),ntrials, 1);
    db.group(:,i)     = repmat(group(i,1),ntrials, 1);
    db.session(:,i)   = repmat(session(i,1),ntrials,1);
    db.task(:,i)      = repmat({task},ntrials,1);
    db.trial(:,i)     = [1:ntrials]';
    db.condition(:,i) = CONDITIONS.CS;
    db.itemxc(:,i)    = itemxc;
    db.RT (:,i)       = BEHAVIOR.RT;
    db.ACC(:,i)       = BEHAVIOR.ACC;
    db.liking(:,i)    = Behavior.liking;
    db.baseLiking(:,i)= BEHAVIOR.liking.b;
    
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

% dependent variable
R.RT        = num2cell(db.RT(:));
R.ACC       = num2cell(db.ACC(:));
R.liking    = num2cell(db.liking(:));


%% print the database
if save_Rdatabase
    
    cd (R_dir)
    
    % concatenate
    Rdatabase = [R.task, R.id, R.group, R.session, R.trial,R.condition, R.itemxc, R.RT, R.ACC, R.liking];
    
    % open database
    fid = fopen([analysis_name '.txt'], 'wt');
    
    % print heater
    fprintf(fid,'%s   %s   %s   %s   %s   %s   %s   %s    %s   %s\n',...
        'task','id', 'group', ...
        'session','trial', 'condition',...
        'trialxcondition','RT', 'ACC', 'liking');
    
    % print data
    formatSpec ='%s   %s   %s   %s   %d    %s   %d   %d   %d   %d\n';
    [nrows,~] = size(Rdatabase);
    for row = 1:nrows
        fprintf(fid,formatSpec,Rdatabase{row,:});
    end
    
    fclose(fid);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CREATE FIGURE

for id = 1:length(subj)
    
    % get data for that participant
    subjX=subj(id,1);
    subjX=char(subjX);
    
    idx = strcmp(db.id, subjX);
    
    tmp.condition = db.condition(idx);
    tmp.RT        = db.RT(idx);
    tmp.liking    = db.liking(idx);
    
    all.RT.CSplus(id,:)   = nanmean(tmp.RT (strcmp ('CSplus', tmp.condition)));
    all.RT.CSminus(id,:)  = nanmean(tmp.RT (strcmp ('CSminus', tmp.condition)));
    
    all.liking.CSplus(id,:)  = tmp.liking(strcmp ('CSplus', tmp.condition));
    all.liking.CSminus(id,:) = tmp.liking(strcmp ('CSminus', tmp.condition));
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%% liking %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get means and std

bysub.likingCSp  =  nanmean(all.liking.CSplus,2);
bysub.likingCSm  =  nanmean(all.liking.CSminus,2);
bysub.likingbase = db.baseLiking';

f.liking.means.CSp = nanmean(bysub.likingCSp,1);
f.liking.means.CSm = nanmean(bysub.likingCSm,1);
f.liking.means.b   = nanmean(bysub.likingbase,1);

f.liking.stnd.CSp  = nanstd(bysub.likingCSp,1)/sqrt(length(subj));
f.liking.stnd.CSm  = nanstd(bysub.likingCSm,1)/sqrt(length(subj));
f.liking.stnd.b    = nanstd(bysub.likingbase,1)/sqrt(length(subj));

means = ([f.liking.means.CSp, f.liking.means.CSm, f.liking.means.b]);
sems  = ([f.liking.stnd.CSp, f.liking.stnd.CSm, f.liking.stnd.b]);

y = means ((1:length(means)));
bars = sems (1:length(sems));

figure;
bar(1, y(1),0.5, 'faceColor',[1 1 1],'EdgeColor', [0 0 0], 'LineWidth', 1);
hold on
bar(2, y(2),0.5, 'faceColor',[0 0 0]);
bar(3, y(3),0.5, 'faceColor',[0.4 0.4 0.4],'EdgeColor', [0 0 0], 'LineWidth', 1);

errorbar(1:length(sems),y,bars,'.k', 'LineWidth', 1.5);
set(gca, 'XTickLabel', '')

% general
set(gcf, 'Color', 'w')
box off

%legend
LEG = legend ('CS+','CS-','baseline');
set(LEG,'FontSize',18)

%axis
xlabel('Fractals', 'FontSize', 18)
ylabel('Liking', 'FontSize', 18)
ylim ([0 100])

%plot
title ('Pavlovian learning: liking ratings', 'FontSize', 18)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f.RT.means.CSp = nanmean(all.RT.CSplus);
f.RT.means.CSm = nanmean(all.RT.CSminus);

f.RT.stnd.CSp  = nanstd(all.RT.CSplus,1)/sqrt(length(subj));
f.RT.stnd.CSm  = nanstd(all.RT.CSminus,1)/sqrt(length(subj));

figure;
means = ([f.RT.means.CSp, f.RT.means.CSm]);
sems  = ([f.RT.stnd.CSp, f.RT.stnd.CSm]);

y = means ((1:length(means)));
bars = sems (1:length(sems));

bar(1, y(1),0.5, 'faceColor',[1 1 1],'EdgeColor', [0 0 0], 'LineWidth', 1);
hold on
bar(2, y(2),0.5, 'faceColor',[0 0 0]);

errorbar(1:length(sems),y,bars,'.k', 'LineWidth', 1.5);
set(gca, 'XTickLabel', '')

% general
set(gcf, 'Color', 'w')
box off

%legend
LEG = legend ('CS+','CS-');
set(LEG,'FontSize',18)

%axis
xlabel('Fractals', 'FontSize', 18)
ylabel('Reaction Times', 'FontSize', 18)

%title
title ('Pavlovian learning: Reaction times', 'FontSize', 18)
