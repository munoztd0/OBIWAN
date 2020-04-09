%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE FOR PIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Eva
% last modified by Eva on March 22 2018

% note: this scripts works only on participants who followed the full
% protocol (from obsese200 on)

clear all
analysis_name = 'OBIWAN_PIT';
task          =  'PIT';

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
%subj    = {    '100';    '102';    '105';    '106';    '107';    '108';    '109';    '112';    '113';    '114';    '115';    '116';    '118';    '119';    '120';    '121';    '122';    '123';    '124';    '125';    '126';    '127';    '128';    '129';    '130';    '131';    '132';    '133'};     % subject ID
%group   = {'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control'}; % control or obsese
%session = { 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'; 'second'};

ntrials = 45;

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
            load (['participant_2' num2str(subjX) ])
    else
        behavior_dir = fullfile(home,'/DATA/STUDY/RAW/BEHAVIORAL/', [ conditionX num2str(subjX)], sessionX);
        cd (behavior_dir)
        load (['participant_' num2str(subjX) ])
    end
    

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get onsets
    
    ONSETS.trial    = reshape(data.PIT.Onsets.StartTrial,1,ntrials)';
    ONSETS.ITI      = reshape(data.PIT.Onsets.ITI,1,ntrials)';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get durations
    DURATIONS.trial = reshape(data.PIT.Durations.TimeTrial',1,ntrials); 
    DURATIONS.ITI    = reshape(data.PIT.Durations.ITI',1,ntrials);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get condition name
    CS = '';
    cmp = 0;
    for ii = 1:5
        for n = 1:9
            cmp = cmp + 1;
            CS = data.PIT.Cond{ii,n};%first dimension of the matrix
            CONDITIONS.CS{cmp} = CS;
        end
    end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get the mobilized effort

    % concatenate the mobilized effort
    mobilized_effort = reshape(data.PIT.mobilizedforce,600,ntrials);
    
    
    % compute the trashold to determine what we consider as a response (50% of the maximal force)
    trashold = data.minimalforce+((data.maximalforce-data.minimalforce)/100*50);% value
  
    % extract the number of grips
    nlines = size(mobilized_effort,1);
    ncolons = size(mobilized_effort,2);
    BEHAVIOR.gripFreq = countgrips(trashold,nlines,ncolons,mobilized_effort);
    
    % extract the onset of each grip
    ONSETS.grips = gripsOnsets (trashold,nlines,ncolons,mobilized_effort,ONSETS.trial);

    % item by condition
    itemxc          = nan  (length(ntrials/3),1);
    count_CSp       = 0;
    count_CSm       = 0;
    count_baseline  = 0;
        
    for ii = 1:length(CONDITIONS.CS)
        
        if strcmp ('CSplus', CONDITIONS.CS(ii))
            count_CSp     =  count_CSp + 1;
             itemxc(ii)   = count_CSp;
        elseif strcmp ('CSminus', CONDITIONS.CS(ii))
            count_CSm      = count_CSm + 1;
            itemxc(ii)   = count_CSm;
        elseif strcmp ('BL', CONDITIONS.CS(ii))
            count_baseline = count_baseline + 1;
            itemxc(ii)   = count_baseline;
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save mat file
    func_dir = fullfile (home, 'DATA/STUDY/DERIVED/PIT_HEDONIC/', ['sub-' conditionX num2str(subjX)], ['ses-' sessionX], 'func');
    cd (func_dir)
    matfile_name = ['sub-' conditionX num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.mat'];
    save(matfile_name, 'ONSETS', 'DURATIONS',  'BEHAVIOR', 'CONDITIONS')
  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save tvs file according to BIDS format
    phase = {'trial';'ITI'};
    nevents = ntrials*length(phase);
    
    % put everything in the event structure
    events.onsets       = zeros(nevents,1);
    events.durations    = zeros(nevents,1);
    events.phase        = cell (nevents,1);
    events.CSname       = cell (nevents,1);
    events.grips        = nan (nevents,1);
    
    cmpt = 0;
    for ii = 1:ntrials
        
        for iii = 1:length(phase)
            
            cmpt = cmpt+1;
            phaseX = char(phase(iii));
            
            events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
            events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
            events.phase(cmpt)      = phase (iii);
            events.CSname(cmpt)     = CONDITIONS.CS(ii);
            events.grips(cmpt)      = BEHAVIOR.gripFreq(ii);
            
        end
        
    end
    
    events.onsets       = num2cell(events.onsets);
    events.durations    = num2cell(events.durations);
    events.grips        = num2cell(events.grips);
    
     eventfile = [events.onsets, events.durations,events.phase,...
        events.CSname, events.grips];
    
    % open data base
    eventfile_name = ['sub-' conditionX num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.tsv'];
    fid = fopen(eventfile_name,'wt');
    
    % print heater
    fprintf (fid, '%s   %s   %s   %s   %s\n',...
        'onset', 'duration', 'trialPhase',...
        'CSname','grips');
    
    % print data
    formatSpec = '%d   %d   %s   %s  %d \n';
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
    db.trial(:,i)     = [1:45]';
    db.condition(:,i) = CONDITIONS.CS;
    db.itemxc(:,i)    = itemxc;
    db.gripFreq (:,i) = BEHAVIOR.gripFreq;
    
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
R.condition = db.condition(:);

% mixed
R.itemxc     = num2cell(db.itemxc(:));

% dependent variable
R.gripFreq  = num2cell(db.gripFreq(:));


%% print the database
cd (R_dir)

% concatenate
Rdatabase = [R.task, R.id, R.group, R.session, R.trial,R.condition, R.itemxc, R.gripFreq];

% open database
fid = fopen([analysis_name '.txt'], 'wt');

% print heater
fprintf(fid,'%s   %s   %s   %s   %s   %s   %s   %s\n',...
    'task','id', 'group', ...
    'session','trial', 'condition',...
    'trialxcondition','gripFreq');

% print data
formatSpec ='%s   %s   %s   %s   %d    %s   %d   %d\n';
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
    
    condition = db.condition(idx);
    gripsFreq = db.gripFreq(idx);
    
    grips.CSplus(id,:)   = gripsFreq (strcmp ('CSplus', condition));
    grips.CSminus(id,:)  = gripsFreq (strcmp ('CSminus', condition));
    grips.baseline(id,:) = gripsFreq (strcmp ('BL', condition));
    
end

% get means and std
f.means.CSp = nanmean(grips.CSplus,1);
f.means.CSm = nanmean(grips.CSminus,1);
f.means.B   = nanmean(grips.baseline,1);

%f.stnd.CSp  = nanstd(grips.CSplus,1)/sqrt(length(subj));
%f.stnd.CSm  = nanstd(grips.CSminus,1)/sqrt(length(subj));
%f.stnd.B    = nanstd(grips.baseline,1)/sqrt(length(subj));


figure; hold;

% cs plus
csp = plot(f.means.CSp,'-o');
set(csp(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])


% csminus
csm = plot(f.means.CSm,'-o');
set(csm(1),'MarkerEdgeColor','none','MarkerFaceColor', [0 0 0],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])


% baseline
b = plot(f.means.B,'--o');
set(b(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])


%legend
LEG = legend ('CS+','CS-','baseline');
set(LEG,'FontSize',18)

%axis
 xlabel('Trial', 'FontSize', 18)
 ylabel('Grips', 'FontSize', 18)
 
%plot
title ('Pavlovian Instrumental Transfer', 'FontSize', 18)
set(gcf, 'Color', 'w')