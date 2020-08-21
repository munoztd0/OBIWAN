%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE FIGURES FOR SIGNGOAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified April 2018 by EVa

%% ************************************************************************
% DEFINE PATH

clear all
% get homedirectory
current_dir       = pwd;
where_to_cut      = (regexp (pwd, 'ANALYSIS/Matlab') -1);
homedir           = current_dir(1:where_to_cut);

matlabdir  = fullfile (homedir,'ANALYSIS', 'Matlab');
datadir    = fullfile(matlabdir,'my_databases');
% output
figuredir  = fullfile(matlabdir,'my_figures');
% tools
addpath (genpath(fullfile(matlabdir,'/my_tools')));

%% ************************************************************************
%  LOAD DATA

load (fullfile(datadir, 'Database-SIGNGOAL.mat'))


%% ************************************************************************
%  GET DATA FOR THE LEARNING 

% for pupil over time

% concatenate the first three session for each participants

session         = {'session_01';'session_02'; 'session_03'};
sessionNtrials  = [ 54         ; 54         ;  54];


nparticipants  = size(Pupil_plot_all,2);
pupil_learning = nan(sum(sessionNtrials)*nparticipants,200);
antX_learning  = nan(sum(sessionNtrials)*nparticipants,200);
antY_learning  = nan(sum(sessionNtrials)*nparticipants,200);

% initialize counter
cmpt = 1;

for i = 1:nparticipants% for each participant
    
    for ii = 1:length(session)
        
        sessionX = char(session(ii));
        ntrials   = sessionNtrials(ii);
        pl = size(Pupil_plot_all(50).(sessionX),2); % pupil length
        xl = size(Gaze_antX(i).(sessionX),2); % x co.ordinates lenght
        yl = size(Gaze_antY(i).(sessionX),2); % y co ordinates length
        
        pupil_learning(cmpt:cmpt+ntrials-1,1:pl) = Pupil_plot_all(i).(sessionX);
        antX_learning(cmpt:cmpt+ntrials-1,1:xl)  = Gaze_antX(i).(sessionX);
        antY_learning(cmpt:cmpt+ntrials-1,1:yl)  = Gaze_antY(i).(sessionX);
        cmpt = cmpt+ ntrials;
        
    end
    
end

% other measures of interest
l.ID             = db.id(:);
l.CSname         = db.CS(:);
l.congruency     = db.CONGR(:);
l.liking         = db.liking(:);

l.mean_pupil     = db.pupil(:);
l.ANT.gaze_right = db.dw_ANT_right(:);
l.ANT.gaze_left  = db.dw_ANT_left(:);
l.ANT.gaze_congr = db.dw_ANT_congr(:);
l.ANT.gaze_cue   = db.dw_ANT_cue(:);

l.CS.gaze_right = db.dw_CS_right(:);
l.CS.gaze_left  = db.dw_CS_left(:);
l.CS.gaze_congr = db.dw_CS_congr(:);
l.CS.gaze_cue   = db.dw_CS_cue(:);

l.US.RT         = db.USRT(:);
l.US.ACC        = db.USACC(:);

%% ************************************************************************
% average across conditions for each participant and each condition

% get the participant id
subj   = char(l.ID);
subj   = unique(str2num(subj(:,5:6)));

%subj   = 01; %USe this if you want to visualize subjects one by one
%% extract by condition and by subject

for id = 1:length(subj)
    
    % transform ID in mat
    id_char   = char(l.ID);
    id_num    = str2num(id_char(:,5:6));
   
    
    % get participant ID
    idx              = find(id_num == subj(id));
    
    % condition
    s.CSname         = l.CSname(idx);
    s.congr          = l.congruency(idx);
    
    % extract the data of interst of the participant
    s.pupil_all  = pupil_learning(idx,:);
    s.antx       = antX_learning(idx,:);
    s.anty       = antY_learning(idx,:);
    
    % for bar plots
    
    s.pupil_mean = l.mean_pupil(idx);
    
    s.ANT.gaze_left  = l.ANT.gaze_left(idx);
    s.ANT.gaze_right = l.ANT.gaze_right(idx);
    s.ANT.gaze_congr = l.ANT.gaze_congr(idx);
    s.ANT.gaze_cue   = l.ANT.gaze_cue(idx);
    
    s.CS.gaze_left  = l.CS.gaze_left(idx);
    s.CS.gaze_right = l.CS.gaze_right(idx);
    s.CS.gaze_congr = l.CS.gaze_congr(idx);
    s.CS.gaze_cue   = l.CS.gaze_cue(idx);
    
    s.liking        = l.liking(idx);
    % get the mean per condition
    C.idxCSpR               = strcmp(s.CSname,'CSpR');
    C.idxCSpL               = strcmp(s.CSname,'CSpL');
    C.idxCSm                = strcmp(s.CSname,'CSmi');
    
    CSpR.pupil_all (id,:)   = nanmean(s.pupil_all(C.idxCSpR,:),1);
    CSpL.pupil_all (id,:)   = nanmean(s.pupil_all(C.idxCSpL,:),1);
    CSm.pupil_all  (id,:)   = nanmean(s.pupil_all(C.idxCSm,:),1);
    
    ANTX.CSpL(:,:,id)       = s.antx(C.idxCSpL,:);% for heatmaps we need all data non-avaraged
    ANTX.CSpR(:,:,id)       = s.antx(C.idxCSpR,:);% for heatmaps we need all data non-avaraged
    ANTX.CSm(:,:,id)        = s.antx(C.idxCSm,:); % for heatmaps we need all data non-avaraged
    
    ANTY.CSpL(:,:,id)       = s.anty(C.idxCSpL,:);% for heatmaps we need all data non-avaraged
    ANTY.CSpR(:,:,id)       = s.anty(C.idxCSpR,:);% for heatmaps we need all data non-avaraged
    ANTY.CSm(:,:,id)        = s.anty(C.idxCSm,:); % for heatmaps we need all data non-avaraged
    
    CSpR.pupil_mean(id)     = nanmean(s.pupil_mean(C.idxCSpR));
    CSpL.pupil_mean(id)     = nanmean(s.pupil_mean(C.idxCSpL));
    CSm.pupil_mean(id)      = nanmean(s.pupil_mean(C.idxCSm));
    
    CSpR.liking(id)     = nanmean(s.liking(C.idxCSpR));
    CSpL.liking(id)     = nanmean(s.liking(C.idxCSpL));
    CSm.liking(id)      = nanmean(s.liking(C.idxCSm));
    
    list = {'ANT'; 'CS'};
    for iii = 1:length(list)
        
        fieldX = char(list(iii));
        
        CSpR.(fieldX).gaze_right(id)  = nanmean(s.(fieldX).gaze_right(C.idxCSpR));
        CSpL.(fieldX).gaze_right(id)  = nanmean(s.(fieldX).gaze_right(C.idxCSpL));
        CSm.(fieldX).gaze_right(id)   = nanmean(s.(fieldX).gaze_right(C.idxCSm));
        
        CSpR.(fieldX).gaze_left(id)   = nanmean(s.(fieldX).gaze_left(C.idxCSpR));
        CSpL.(fieldX).gaze_left(id)   = nanmean(s.(fieldX).gaze_left(C.idxCSpL));
        CSm.(fieldX).gaze_left(id)    = nanmean(s.(fieldX).gaze_left(C.idxCSm));
        
        CSpR.(fieldX).gaze_congr(id)  = nanmean(s.(fieldX).gaze_congr(C.idxCSpR));
        CSpL.(fieldX).gaze_congr(id)  = nanmean(s.(fieldX).gaze_congr(C.idxCSpL));
        CSm.(fieldX).gaze_congr(id)   = nanmean(s.(fieldX).gaze_congr(C.idxCSm));
        
        CSpR.(fieldX).gaze_cue(id)   = nanmean(s.(fieldX).gaze_cue(C.idxCSpR));
        CSpL.(fieldX).gaze_cue(id)   = nanmean(s.(fieldX).gaze_cue(C.idxCSpL));
        CSm.(fieldX).gaze_cue(id)    = nanmean(s.(fieldX).gaze_cue(C.idxCSm));
        
    end
    
    
    % get reaction times on the us by subject
    s.US.RT    = l.US.RT(idx);
    s.US.ACC   = l.US.ACC(idx);
    
    
    % get the mean per condition
    C.idxCongr  = strcmp(s.congr,'congr');
    C.idxIncongr= strcmp(s.congr,'incongr');
    
    US.congr(id)     = nanmean(s.US.RT(C.idxCongr,:),1);
    US.incongr(id)  = nanmean(s.US.RT(C.idxIncongr,:),1);
    
    
end


%% plot and save raw pupil
% 
% pupil_plot.CSpL = CSpL.pupil_all(:,:);
% pupil_plot.CSpR = CSpR.pupil_all(:,:);
% pupil_plot.CSm  = CSm.pupil_all(:,:);
% 
% raw_pupil_plot = plotRawPupil (pupil_plot, {'CSpL'; 'CSpR'; 'CSm'}, {'CS+ L'; 'CS+ R'; 'CS-'});
% save_figures ('PAVoneUS-pupil', figuredir, matlabdir);
% 

%% plot and save means

%pupil
pupil_mean.CSpL = CSpL.pupil_mean;
pupil_mean.CSpR = CSpR.pupil_mean;
pupil_mean.CSm  = CSm.pupil_mean;

plotMeans('Average Pupil',pupil_mean,{'CSpL'; 'CSpR'; 'CSm'},{'CS+ L'; 'CS+ R'; 'CS-'});
%save_figures ('SIGNGOAL-means-pupil', figuredir, matlabdir);

liking.CSpL = CSpL.liking;
liking.CSpR = CSpR.liking;
liking.CSm = CSm.liking;

plotMeans('Liking',liking,{'CSpL'; 'CSpR'; 'CSm'},{'CS+ L'; 'CS+ R'; 'CS-'});

% gaze left
DW_L.CSpL = CSpL.ANT.gaze_left;
DW_L.CSpR = CSpR.ANT.gaze_left;
DW_L.CSm  = CSm.ANT.gaze_left;

plotMeans('Dwell Time Left ROI',DW_L,{'CSpL'; 'CSpR'; 'CSm'},{'CS+ L'; 'CS+ R'; 'CS-'});

% gaze right
DW_R.CSpL = CSpL.ANT.gaze_right;
DW_R.CSpR = CSpR.ANT.gaze_right;
DW_R.CSm  = CSm.ANT.gaze_right;

plotMeans('Dwell Time Right ROI',DW_R,{'CSpL'; 'CSpR'; 'CSm'},{'CS+ L'; 'CS+ R'; 'CS-'});

% gaze congruent
DW_C.CSpL = CSpL.ANT.gaze_congr;
DW_C.CSpR = CSpR.ANT.gaze_congr;
DW_C.CSm  = CSm.ANT.gaze_congr;

plotMeans('Dwell Time Congruent ROI',DW_C,{'CSpL'; 'CSpR'; 'CSm'},{'CS+ L'; 'CS+ R'; 'CS-'});

% gaze congruent
DW_C.CSpL = CSpL.ANT.gaze_congr;
DW_C.CSpR = CSpR.ANT.gaze_congr;
DW_C.CSm  = CSm.ANT.gaze_congr;

plotMeans('Dwell Time Congruent ROI',DW_C,{'CSpL'; 'CSpR'; 'CSm'},{'CS+ L'; 'CS+ R'; 'CS-'});



% gaze cue

% gaze congruent
DW_CS_cue.CSpL = CSpL.CS.gaze_cue;
DW_CS_cue.CSpR = CSpR.CS.gaze_cue;
DW_CS_cue.CSm  = CSm.CS.gaze_cue;

plotMeans('Dwell Time CS during CS',DW_CS_cue,{'CSpL'; 'CSpR'; 'CSm'},{'CS+ L'; 'CS+ R'; 'CS-'})

% gaze congruent
DW_CS_congr.CSpL = CSpL.CS.gaze_congr;
DW_CS_congr.CSpR = CSpR.CS.gaze_congr;
DW_CS_congr.CSm  = CSm.CS.gaze_congr;

plotMeans('Dwell Time congruent ROI during CS',DW_CS_congr,{'CSpL'; 'CSpR'; 'CSm'},{'CS+ L'; 'CS+ R'; 'CS-'})

% plot reaction time
US.tmp = zeros(1,length(US.congr)); % we will need to write a better plot code
plotMeans('normalized RT', US, {'congr','incongr','tmp'}, {'congr'; 'incongr'; ''});

%% plot and save heatmaps

plotHeatmap(ANTX.CSpL, ANTY.CSpL)
%save_figures ('PAVoneUS-heatmap_CSpL', figuredir, matlabdir);

plotHeatmap(ANTX.CSpR, ANTY.CSpR)
%save_figures ('PAVoneUS-heatmap_CSpR', figuredir, matlabdir);

plotHeatmap(ANTX.CSm, ANTY.CSm)
%save_figures ('PAVoneUS-heatmap_CSm', figuredir, matlabdir);


