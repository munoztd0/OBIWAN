dbstop if error
clear all

analysis_name = 'REWOD_EMG_ses_second';
task          = 'hedonic';
%% DEFINE WHAT WE WANT TO DO
IDXsubj    = [1     2     3     4     5     6     7     9    10    11    12    13    14    15    16    17    18   20    21    22    23    24    25    26];
subj    = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};  

save_Rdatabase = 1; % leave 1 when saving all subjects #!

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/REWOD/'];


analysis_dir = fullfile(homedir, 'DERIVATIVES/ANALYSIS/hedonic/EMG');
dir        = fullfile(homedir,'SOURCEDATA/physio');
% add tools
addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/my_tools')));

load(fullfile(dir,'REWOD_EMG.mat'));

REWODEMG4MRI(1,:) = [];

REWODEMG4MRI.COR = REWODEMG4MRI.VarName2; % mean corru muscular activity btw 2500 3000 after breathing
REWODEMG4MRI.VarName2 = [];

REWODEMG4MRI.COND = cellstr(REWODEMG4MRI.COND);


for i = 1:length(subj)
    
    EMG = REWODEMG4MRI((REWODEMG4MRI.SUBJ(:,1) == IDXsubj(i)),:);
    subjX= char(subj(i));
    data(1).COR = EMG.COR;
    data(1).BASE = EMG.BASELINE;
    data(1).TRIAL = EMG.TRIAL;
    data(1).ORDER = EMG.ORDER;
    data(1).COND = EMG.COND;
    
    
    
    %%% save mat file
    physio_dir = fullfile (homedir, 'SOURCEDATA', 'physio', subjX);
    cd (physio_dir)
    matfile_name = ['sub-' num2str(subjX) '_ses-second' '_task-' task '_EMG.mat'];
    save(matfile_name, 'data' )
   
end
    
    
    