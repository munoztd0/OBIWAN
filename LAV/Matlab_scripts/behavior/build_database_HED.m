%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Eva
% last modified by Eva on March 27 2018

% note: this scripts works only on participants who followed the full
% protocol (from obsese200 on)

dbstop if error
clear all

analysis_name = 'OBIWAN_HEDONIC';
task          = 'hedonicreactivity';

%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 0; % leave 1 when saving all subjects

%% DEFINE PATH
%cd ~
%home = pwd;
%homedir = [home '/OBIWAN/'];
home = '/home/cisa/mountpoint';
%home = '/home/cisa/mountpoint/OBIWAN';
%home = '/Users/lavinia/mountpoint';
%home = '/Users/evapool/mountpoint';
%home = '/home/OBIWAN';
analysis_dir = fullfile(home, '/ANALYSIS/Matlab_scripts');
R_dir        = fullfile(home,'/ANALYSIS/R_scripts');
% add tools
addpath (genpath(fullfile(analysis_dir,'my_tools')));

%% DEFINE POPULATION
subj    = {'265'};     % subject ID
group   = {'obese'}; % control or obsese
session = {'third'};
%subj    = {    '100';    '102';    '105';    '106';    '107';    '108';    '109';    '110';    '112';    '113';    '114';    '115';    '116';    '118';    '119';    '120';    '121';    '122';    '125';    '126';    '127';    '128';    '129';    '130';    '131';    '132';    '133'; '124'};     % subject ID
%group   = {'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control'; 'control'}; % control or obsese
%session = { 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'};

ntrials = 40; %

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
            load (['hedonic_2' num2str(subjX) ])
    else
        behavior_dir = fullfile(home,'/DATA/STUDY/RAW/BEHAVIORAL/', [ conditionX num2str(subjX)], sessionX);
        cd (behavior_dir)
        load (['hedonic_' num2str(subjX) ])
    end
    
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get onsets

    ONSETS.trialstart  = data.Onsets.TrialStart; 
    ONSETS.liquid      = data.Onsets.PumpStart; % PumpStart or Stop?
    ONSETS.break       = data.Onsets.Starttjietter;
    ONSETS.liking      = data.Onsets.Liking;
    ONSETS.intensity   = data.Onsets.Intensity;
    ONSETS.familiarity = data.Onsets.Familiarity;
    ONSETS.rince       = data.Onsets.RinseStart; % start or stop?
    ONSETS.ITI         = data.Onsets.ITI;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get durations
    DURATIONS.trialstart  = data.Durations.count1+data.Durations.count2+data.Durations.count3;
    DURATIONS.liquid      = data.Durations.asterix1 + data.Durations.asterix2; % what is asterix 3 and 4?
    DURATIONS.break       = data.Durations.jitter;
    DURATIONS.liking      = data.Durations.Liking;
    DURATIONS.intensity   = data.Durations.Intensity;
    DURATIONS.familiarity = data.Durations.Familiarity;
    DURATIONS.rince       = data.Durations.asterix3; % start or stop?
    DURATIONS.ITI         = data.Durations.ITI;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get condition name
    CONDITIONS = data.tasteLabel;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get the ratings
    BEHAVIOR.liking      = data.liking;
    BEHAVIOR.intensity   = data.intensity;
    BEHAVIOR.familiarity = data.familiarity;
    
    
    % item by condition
    itemxc          = nan(ntrials,1);
    count_reward    = 0;
    count_control   = 0;
    
    for ii = 1:length(CONDITIONS)
        
        if strcmp ('MilkShake', CONDITIONS(ii))
            count_reward         = count_reward + 1;
            itemxc(ii)           = count_reward;
     
        elseif strcmp ('Empty', CONDITIONS(ii))
            count_control        = count_control + 1;
            itemxc(ii)           = count_control;
        
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
    phase = {'trialstart';'liquid';'liking'; 'intensity';'familiarity'; 'rince'; 'ITI'};
    nevents = ntrials*length(phase);
    
    % put everything in the event structure
    events.onsets       = zeros(nevents,1);
    events.durations    = zeros(nevents,1);
    events.phase        = cell (nevents,1);
    events.condition    = cell (nevents,1);
    events.liking       = nan (nevents,1);
    events.intensity    = nan (nevents,1);
    events.familiarity  = nan (nevents,1);
    
    
    cmpt = 0;
    for ii = 1:ntrials
        
        for iii = 1:length(phase)
            
            cmpt = cmpt+1;
            phaseX = char(phase(iii));
            
            events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
            events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
            events.phase(cmpt)      = phase (iii);
            events.condition(cmpt) = CONDITIONS(ii);
            events.liking(cmpt)     = BEHAVIOR.liking(ii);
            events.familiarity(cmpt)= BEHAVIOR.familiarity(ii);
            events.intensity(cmpt)  = BEHAVIOR.intensity(ii);
            
        end
        
    end
    
    events.onsets       = num2cell(events.onsets);
    events.durations    = num2cell(events.durations);
    events.liking       = num2cell(events.liking);
    events.familiarity  = num2cell(events.familiarity);
    events.intensity    = num2cell(events.intensity);
    
    
    
     eventfile = [events.onsets, events.durations, events.phase,...
        events.condition, events.liking, events.familiarity, events.intensity];
    
    % open data base
    eventfile_name = ['sub-' conditionX num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.tsv'];
    fid = fopen(eventfile_name,'wt');
    
    % print heater
    fprintf (fid, '%s   %s   %s   %s   %s   %s   %s\n',...
        'onset', 'duration', 'trialPhase',...
        'condition','perceived_liking','perceived_familiarity','perceived_intesity');
    
    % print data
    formatSpec = '%d   %d   %s   %s  %d  %d  %d \n';
    [nrows,ncols] = size(eventfile);
    for row = 1:nrows
        fprintf(fid,formatSpec,eventfile{row,:});
    end
    
    fclose(fid);
 
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save data for compiled database
    
    db.id(:,i)           = repmat(subj(i,1),ntrials, 1);
    db.group(:,i)        = repmat(group(i,1),ntrials, 1);
    db.session(:,i)      = repmat(session(i,1),ntrials,1);
    db.task(:,i)         = repmat({task},ntrials,1);
    db.trial(:,i)        = [1:ntrials]';
    db.condition(:,i)    = CONDITIONS;
    db.itemxc(:,i)       = itemxc;
    db.liking (:,i)      = BEHAVIOR.liking;
    db.familiarity (:,i) = BEHAVIOR.familiarity;
    db.intensity (:,i)   = BEHAVIOR.intensity;
    
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
R.condition  = db.condition(:);

% mixed
R.itemxc     = num2cell(db.itemxc(:));

% dependent variable
R.liking      = num2cell(db.liking(:));
R.intensity   = num2cell(db.intensity(:));
R.familiarity = num2cell(db.familiarity(:));

%% print the database
cd (R_dir)

% concatenate
Rdatabase = [R.task, R.id, R.group, R.session, R.trial,R.condition, R.itemxc, R.liking, R.familiarity, R.intensity];

% open database
fid = fopen([analysis_name '.txt'], 'wt');

% print heater
fprintf(fid,'%s   %s   %s   %s   %s   %s   %s   %s   %s   %s\n',...
    'task','id', 'group', ...
    'session','trial', 'condition',...
    'trialxcondition','perceived_liking','perceived_familiarity', 'perceived_intensity');

% print data
formatSpec ='%s   %s   %s   %s   %d    %s   %d   %d   %d   %d\n';
[nrows,~] = size(Rdatabase);
for row = 1:nrows
    fprintf(fid,formatSpec,Rdatabase{row,:});
end

fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CREATE FIGURE

for id = 1:length(subj)
    
    % get data for that participant
    subjX=subj(id,1);
    subjX=char(subjX);
    
    idx = strcmp(db.id, subjX);
    
    s.condition   = db.condition(idx);
    s.liking      = db.liking(idx);
    s.familiarity = db.familiarity(idx);
    s.intensity   = db.intensity(idx);
    
    ratings.liking.reward(id,:)      = s.liking (strcmp ('MilkShake', s.condition));
    ratings.liking.control(id,:)     = s.liking (strcmp ('Empty', s.condition));
   
    ratings.familiarity.reward(id,:) = s.familiarity (strcmp ('MilkShake', s.condition));
    ratings.familiarity.control(id,:)= s.familiarity (strcmp ('Empty', s.condition));

    ratings.intensity.reward(id,:)   = s.intensity (strcmp ('MilkShake', s.condition));
    ratings.intensity.control(id,:)  = s.intensity (strcmp ('Empty', s.condition));

    
end

% get means and std
list = {'liking'; 'familiarity';'intensity'};

for ii = 1:length(list)
    
    conditionX = char(list(ii));
    
    means.(conditionX).reward = nanmean(ratings.(conditionX).reward,1);
    means.(conditionX).control= nanmean(ratings.(conditionX).control,1);
    
    
    stnd.(conditionX).reward = nanstd(ratings.(conditionX).reward,1)/sqrt(length(subj));
    stnd.(conditionX).control= nanstd(ratings.(conditionX).control,1)/sqrt(length(subj));
    
end


% plot the means and std
figure;

set(gcf, 'Color', 'w')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% liking pannel
subplot(3,1,1)

% reward
forplot.liking.reward = plot(means.liking.reward,'-o');
set(forplot.liking.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
hold
% control
forplot.liking.control= plot(means.liking.control,'--o');
set(forplot.liking.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])

%axis
xlabel('Trial', 'FontSize', 15)
ylabel('Liking', 'FontSize', 18)
ylim ([0 100])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% intesity pannel
subplot(3,1,2)

% reward
forplot.intensity.reward = plot(means.intensity.reward,'-o');
set(forplot.intensity.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
hold
% control
forplot.intensity.control= plot(means.intensity.control,'--o');
set(forplot.intensity.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])

%axis
xlabel('Trial', 'FontSize', 15)
ylabel('Intensity', 'FontSize', 18)
ylim ([0 100])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  familiarity pannel
subplot(3,1,3)

% reward
forplot.familiarity.reward = plot(means.familiarity.reward,'-o');
set(forplot.familiarity.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
hold
% control
forplot.familiarity.control= plot(means.familiarity.control,'--o');
set(forplot.familiarity.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])

%axis
xlabel('Trial', 'FontSize', 15)
ylabel('Familiarity', 'FontSize', 18)
ylim ([0 100])

%legend
LEG = legend ('reward','control');
set(LEG,'FontSize',18)
