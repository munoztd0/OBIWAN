function exctract_ROI()

%clear
%clc
dbstop if error

glm= 'GLM-02';

threshold = '0.01';

taskHED='hedonic';

taskPIT='PIT';

% path

cd ~
home = pwd;
homedir = [home '/REWOD'];


%% HED

ana_name = glm;

% which task?
task_name = taskHED; %

con_name1 = 'spheres';

con_names5 = {'Reward-NoReward'};



con_list5 = {'con_0005.nii,1'}; %
%R_C = CONTRAT 1   
%R_N = CONTRAT 2   


dir_data   =  fullfile (homedir, '/DERIVATIVES/ANALYSIS', task_name, ana_name, 'group');


roi_R_NoR = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI',  con_name1);

%%
cd (roi_R_NoR)

sphere2.SUBCAL_RIGHT = struct('centre', [7 10.5 -13],'radius', 2); % in mm

sphere2.AMY_LA_LEFT = struct('centre', [-27 -0 -22],'radius', 2); % in mm
sphere2.VS_LEFT = struct('centre', [-9 16 -5],'radius', 2); % in mm

fns = fieldnames(sphere2);

for i = 1:length(fns)
    sphere2_roi = maroi_sphere(sphere2.(fns{i}));
    saveroi(sphere2_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end

%% PIT

ana_name = glm;

% which task?
task_name = taskPIT; %

con_name1 = 'CSp_CSm';



% which contrast

con_names1 = {'CSp-CSm'};

con_list1 = {'con_0001.nii,1'}; %


dir_data   =  fullfile (homedir, '/DERIVATIVES/ANALYSIS', task_name, ana_name, 'group');

roi_CSp_CSm = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm, con_name1);

%% DOING FOR CSp-CSm

cd (roi_CSp_CSm)

sphere3.CAUD_ANT_RIGHT = struct('centre', [9 20 5],'radius', 2); % in mm %in FSL its NAcc

sphere3.CAUD_VENT_LEFT = struct('centre', [-9 -13 -5],'radius', 2); % in mm %in FSL its NAcc
sphere3.CAUD_VENT_RIGHT = struct('centre', [5 13 -5],'radius', 2); % in mm %in FSL its NAcc

sphere3.PUT_LEFT = struct('centre', [-16 7 -2],'radius', 2); % in mm
sphere3.PUT_RIGHT = struct('centre', [18 18 -5],'radius', 2); % in mm 

sphere3.NACC_LEFT = struct('centre', [-5 7 -7],'radius', 2); % in mm 
sphere3.NACC_RIGHT = struct('centre', [7 11 -5],'radius', 2); % in mm 

fns = fieldnames(sphere3);

for i = 1:length(fns)
    sphere3_roi = maroi_sphere(sphere3.(fns{i}));
    saveroi(sphere3_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end
