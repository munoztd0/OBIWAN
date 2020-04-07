function exctract_ROI()

%clear
%clc
dbstop if error

glm= 'GLM-03';

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

con_name1 = 'int';
con_name2 = 'lik';


% which contrast

con_names1 = {'odor_int'};
con_names2 = {'odor_lik'};


con_list1 = {'con_0001.nii,1'}; %
con_list2 = {'con_0002.nii,1'}; % 


dir_data   =  fullfile (homedir, '/DERIVATIVES/ANALYSIS', task_name, ana_name, 'group');

roi_int = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm, con_name1);
roi_lik = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm, con_name2);


% %% DOING FOR int
cd (roi_int)

sphere1.AMY_BM_LEFT = struct('centre', [-22 -11 -14],'radius', 2); % in mm

sphere1.PIRI_RIGHT = struct('centre', [22 -4 -9],'radius', 2); % in mm

sphere1.AMY_BLA_LEFT = struct('centre', [-23 -2 -20],'radius', 2); % in mm
sphere1.AMY_AAA_RIGHT = struct('centre', [23 -2 -16],'radius', 2); % in mm

sphere1.CAUD_ANT_LEFT = struct('centre', [-11 7 9],'radius', 2); % in mm 
sphere1.CAUD_ANT_RIGHT = struct('centre', [11 7 9],'radius', 2); % in mm 

sphere1.GPe_RIGHT = struct('centre', [25 -7 -2],'radius', 2); % in mm 

sphere1.GPi_LEFT = struct('centre', [-16 -2 -7],'radius', 2); % in mm 

sphere1.dlPFC_LEFT = struct('centre', [-38 29 5],'radius', 2); % in mm 

sphere1.vmPFC_RIGHT = struct('centre', [9 40 -16],'radius', 2); % in mm 

sphere1.OFC_RIGHT = struct('centre', [24 32 -11],'radius', 2); % in mm 

sphere1.FRONTAL_LEFT = struct('centre', [-11 61 -9],'radius', 2); % in mm 

sphere1.vlPFC_RIGHT = struct('centre', [31 50 -13],'radius', 2); % in mm 


fns = fieldnames(sphere1);

for i = 1:length(fns)
    sphere1_roi = maroi_sphere(sphere1.(fns{i}));
    saveroi(sphere1_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end

%% DOING FOR lik
cd (roi_lik)

sphere2.CAUD_VENTR_LEFT = struct('centre', [-9 18 -5],'radius', 2); % in mm 
sphere2.CAUD_VENTR_RIGHT = struct('centre', [7 20 -2],'radius', 2); % in mm % NACC in FSL

sphere2.PUT_POST_RIGHT = struct('centre', [31 -9 2],'radius', 2); % in mm 

sphere2.NACC_RIGHT = struct('centre', [5 11 -7],'radius', 2); % in mm 
sphere2.NACC_RIGHT = struct('centre', [-9 15 -5],'radius', 2); % in mm 

sphere2.OFC_LEFT = struct('centre', [-20 27 -23],'radius', 2); % in mm 
sphere2.OFC_RIGHT = struct('centre', [27 18 -25],'radius', 2); % in mm 

sphere2.aINS_LEFT = struct('centre', [-36 2 -4],'radius', 2); % in mm 
sphere2.aINS_RIGHT = struct('centre', [38 5 -9],'radius', 2); % in mm 

sphere2.SUBCAL_RIGHT = struct('centre', [11 27 -18],'radius', 2); % in mm 
sphere2.SUBCAL_LEFT = struct('centre', [-3 21 -18],'radius', 2); % in mm 

sphere2.GPe_LEFT = struct('centre', [-22 7 -2],'radius', 2); % in mm 

fns = fieldnames(sphere2);

for i = 1:length(fns)
    sphere2_roi = maroi_sphere(sphere2.(fns{i}));
    saveroi(sphere2_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end

%% EFFORT

ana_name = glm;

% which task?
task_name = taskPIT; %

con_name1 = 'eff';



% which contrast

con_names1 = {'CSp_eff_CSm_eff'};

con_list1 = {'con_0005.nii,1'}; %


dir_data   =  fullfile (homedir, '/DERIVATIVES/ANALYSIS', task_name, ana_name,  'group');

roi_eff = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm, con_name1);

%% DOING FOR CSp-CSm

cd (roi_eff)


sphere3.CAUD_ANT_RIGHT = struct('centre', [9 20 5],'radius', 2); %

sphere3.CAUD_VENTR_LEFT = struct('centre', [-9 9 0],'radius', 2); % 
sphere3.CAUD_VENTR_RIGHT = struct('centre', [7 14 -7],'radius', 2); % in mmin FSL its NAcc

sphere3.NACC_RIGHT = struct('centre', [7 14 -7],'radius', 2); % in mm % SAME

sphere3.CLOSTRUM_LEFT = struct('centre', [-32 11 -2],'radius', 2); % in mm 
sphere3.aINS_RIGHT = struct('centre', [36 9 -9],'radius', 2); % in mm 

sphere3.pINS_LEFT = struct('centre', [-38 -11 -13],'radius', 2); % in mm  %ISH
sphere3.pINS_RIGHT = struct('centre', [38 -11 -11],'radius', 2); % in mm %ISH

sphere3.dlPFC_LEFT = struct('centre', [-56 23 -4],'radius', 2); % in mm %ISH
sphere3.dlPFC_RIGHT = struct('centre', [50 34 -5],'radius', 2); % in mm 

sphere3.FRONTAL_LEFT = struct('centre', [-18 61 -7],'radius', 2); % in mm 
sphere3.FRONTAL_RIGHT = struct('centre', [4 67 -7],'radius', 2); % in mm 

sphere3.vmPFC_LEFT = struct('centre', [-4 36 -14],'radius', 2); % in mm 
sphere3.vmPFC_RIGHT = struct('centre', [4 32 -22],'radius', 2); % in mm 

sphere3.SUBCAL_LEFT = struct('centre', [-5 13 -14],'radius', 2); % in mm 
sphere3.SUBCAL_RIGHT = struct('centre', [5 16 -7],'radius', 2); % in mm 

sphere3.OFC_LEFT = struct('centre', [-9 40 -29],'radius', 2); % in mm %ISH
sphere3.OFC_RIGHT = struct('centre', [9 22 -27],'radius', 2); % in mm  %ISH

fns = fieldnames(sphere3);

for i = 1:length(fns)
    sphere3_roi = maroi_sphere(sphere3.(fns{i}));
    saveroi(sphere3_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end
