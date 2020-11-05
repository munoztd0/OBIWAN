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

con_name1 = 'R_C';
con_name2 = 'R_N';
con_name3 = 'Od_NoOd';
con_name5 = 'R_NoR';

% which contrast

con_names1 = {'reward-control'};
con_names2 = {'reward-neutral'};
con_names3 = {'Odor-NoOdor'};
con_names5 = {'Reward-NoReward'};


con_list1 = {'con_0001.nii,1'}; %
con_list2 = {'con_0002.nii,1'}; %
con_list3 = {'con_0003.nii,1'}; %
con_list5 = {'con_0005.nii,1'}; %
%R_C = CONTRAT 1   
%R_N = CONTRAT 2   


dir_data   =  fullfile (homedir, '/DERIVATIVES/ANALYSIS', task_name, ana_name, 'group');

roi_R_C = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI',  threshold, glm, con_name1);
roi_R_N = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI',  threshold, glm, con_name2);
roi_O_N = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI',  threshold, glm, con_name3);
roi_R_NoR = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI',  threshold, glm, con_name5);

% %% DOING FOR R_C
cd (roi_R_C)

sphere1.AMY_PIRI_LEFT = struct('centre', [-18 -5 -13],'radius', 2); % in mm
sphere1.AMY_PIRI_RIGHT = struct('centre', [22 -5 -13],'radius', 2); % in mm

sphere1.AMY_BLA_LEFT = struct('centre', [-27 -2 -22],'radius', 2); % in mm
sphere1.AMY_BLA_RIGHT = struct('centre', [25 -2 -20],'radius', 2); % in mm

sphere1.CAUD_POST_LEFT = struct('centre', [-16 -23 16],'radius', 2); % in mm 
sphere1.CAUD_POST_RIGHT = struct('centre', [23 -32 7],'radius', 2); % in mm 

sphere1.CAUD_ANT_LEFT = struct('centre', [-9 16 -7],'radius', 2); % in mm  
sphere1.CAUD_ANT_RIGHT = struct('centre', [10 20 2],'radius', 2); % in mm   

sphere1.PUT_RIGHT = struct('centre', [22 -2 9],'radius', 2); % in mm  

sphere1.NACC_LEFT = struct('centre', [-9 9 -13],'radius', 2); % in mm  
sphere1.NACC_RIGHT = struct('centre', [7 9 -11],'radius', 2); % in mm  

fns = fieldnames(sphere1);

for i = 1:length(fns)
    sphere1_roi = maroi_sphere(sphere1.(fns{i}));
    saveroi(sphere1_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end

%% DOING FOR R_N
cd (roi_R_N)

sphere2.AMY_BLA_LEFT = struct('centre', [-29 -5 -23],'radius', 2); % in mm

sphere2.AMY_BM_LEFT = struct('centre', [-20 -5 -16],'radius', 2); % in mm

sphere2.CAUD_VENT_LEFT = struct('centre', [-9 -16 -5],'radius', 2); % in mm %in FSL its NAcc
sphere2.CAUD_VENT_RIGHT = struct('centre', [7 10 6],'radius', 2); % in mm %in FSL its NAcc

sphere2.PUT_LEFT = struct('centre',[-23 -11 5] ,'radius', 2); % in mm
sphere2.PUT_RIGHT = struct('centre', [20 0 7],'radius', 2); % in mm 

fns = fieldnames(sphere2);

for i = 1:length(fns)
    sphere2_roi = maroi_sphere(sphere2.(fns{i}));
    saveroi(sphere2_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end


%%%
cd (roi_O_N)

sphere2.AMY_piri_RIGHT = struct('centre', [28 1 -18],'radius', 2); % in mm

sphere2.AMY_AAA_LEFT = struct('centre', [-19 -5 -13],'radius', 2); % in mm
sphere2.AMY_AAA_RIGHT = struct('centre', [20 -4 -12],'radius', 2); % in mm


fns = fieldnames(sphere2);

for i = 1:length(fns)
    sphere2_roi = maroi_sphere(sphere2.(fns{i}));
    saveroi(sphere2_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end


%%%
cd (roi_R_NoR)

sphere2.SUBCAL_RIGHT = struct('centre', [7 10.5 -13],'radius', 2); % in mm
sphere2.SUBCAL_LEFT = struct('centre', [-1.4 26.6 -16.3],'radius', 2); % in mm

sphere2.AMY_LA_LEFT = struct('centre', [-27 -1 -21],'radius', 2); % in mm
sphere2.AMY_CMN_LEFT = struct('centre', [-19 -5 -14],'radius', 2); % in mm

sphere2.VS_LEFT = struct('centre', [-9 16 -7],'radius', 2); % in mm

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
