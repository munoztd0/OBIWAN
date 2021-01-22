function exctract_ROI()

%clear
%clc
dbstop if error

glm= 'GLM-04';

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

con_name1 = 'R_N_int';



dir_data   =  fullfile (homedir, '/DERIVATIVES/ANALYSIS', task_name, ana_name, 'group');

roi_int = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm, con_name1);



% %% DOING FOR int
cd (roi_int)

sphere1.vmPFC_RIGHT = struct('centre', [27 34 -21],'radius', 2); % in mm 

sphere1.AMY_ant_LEFT = struct('centre', [-25 -1 -17],'radius', 2); % in mm
sphere1.AMY_ant_RIGHT = struct('centre', [-21 -1 -17],'radius', 2); % in mm


sphere1.AMY_post_RIGHT = struct('centre', [21 -7 -19],'radius', 2); % in mm

sphere1.midbrain = struct('centre', [-4 -30 -19],'radius', 2); % in mm 


fns = fieldnames(sphere1);

%load marsbar
for i = 1:length(fns)
    sphere1_roi = maroi_sphere(sphere1.(fns{i}));
    saveroi(sphere1_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end

%% DOING FOR lik


con_name2 = 'R_N_lik';


roi_lik = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm, con_name2);

cd (roi_lik)

sphere2.OPERCULUM_RIGHT = struct('centre', [36 29 3],'radius', 2); % in mm 

sphere2.OFC_RIGHT = struct('centre', [14 25 -17],'radius', 2); % in mm 

sphere2.OFC2_RIGHT = struct('centre', [15 13 -14],'radius', 2); % in mm 

sphere2.CAUD_post_RIGHT = struct('centre', [-39 12 9],'radius', 2); % in mm 

sphere2.PUT_ant_LEFT = struct('centre', [-21.363 7.317924 -3.650782],'radius', 2); % in mm 


sphere2.pINS_LEFT = struct('centre', [-36 -8 9],'radius', 2); % in mm 


fns = fieldnames(sphere2);

for i = 1:length(fns)
    sphere2_roi = maroi_sphere(sphere2.(fns{i}));
    saveroi(sphere2_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end


%% DOING FOR lik


con_name3 = 'R_NoR_lik';


roi_lik = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm, con_name3);

cd (roi_lik)

sphere2a.vlPFC_RIGHT = struct('centre', [36 54 -14],'radius', 2); % in mm 

sphere2a.vmPFC_LEFT = struct('centre', [-17 52 -18],'radius', 2); % in mm 
sphere2a.vmPFC_LEFT = struct('centre', [-17 52 -14],'radius', 2); % in mm 


sphere2a.OFC_RIGHT = struct('centre', [36 30 -20],'radius', 2); % in mm 

sphere2a.IFG_RIGHT = struct('centre', [37 31 4],'radius', 2); % in mm 
sphere2a.IFG_LEFT = struct('centre', [-39 20 11],'radius', 2); % in mm 

sphere2a.SUBCAL_RIGHT = struct('centre', [12 25 -18],'radius', 2); % in mm 

sphere2a.PUT_LEFT = struct('centre', [-23 7 8],'radius', 2); % in mm 

sphere2a.PUT_ant_LEFT = struct('centre', [-21.67912 6.412216 -2.141999],'radius', 2); % in mm 

sphere2a.CAUD_LEFT = struct('centre', [-9 7 7],'radius', 2); % in mm 

sphere2a.OPER_LEFT = struct('centre', [-40 -14 17],'radius', 2); % in mm 

sphere2a.midbrain = struct('centre', [-9 -26 -16],'radius', 2); % in mm 

fns = fieldnames(sphere2a);

for i = 1:length(fns)
    sphere2_roi = maroi_sphere(sphere2a.(fns{i}));
    saveroi(sphere2_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end

%% EFFORT


% which task?
task_name = taskPIT; %

con_name1 = 'CSp_CSm_eff';


% which contrast

roi_eff = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm, con_name1);

%% DOING FOR CSp-CSm

cd (roi_eff)


sphere3.CAUD_VENTR_LEFT = struct('centre', [-11 14 1],'radius', 2); % 
sphere3.CAUD_VENTR_RIGHT = struct('centre', [10 19 0],'radius', 2); % in mmin FSL its NAcc

sphere3.vlPFC_LEFT = struct('centre', [-36 36 -9],'radius', 2); % in mm 
sphere3.vlPFC_RIGHT = struct('centre', [38 40 -12],'radius', 2); % in mm 

sphere3.BNST_LEFT = struct('centre', [-7 2 -1],'radius', 2); % in mm 
sphere3.BNST_RIGHT = struct('centre', [5 3 1],'radius', 2); % in mm 

sphere3.AMY_LEFT = struct('centre', [-24 0 -20],'radius', 2); % in mm 
sphere3.AMY_RIGHT = struct('centre', [19 0 -20],'radius', 2); % in mm 
sphere3.AMY_post_RIGHT = struct('centre', [-17 -3 -23],'radius', 2); % in mm 

sphere3.PUT_LEFT = struct('centre', [-28 5 4],'radius', 2); % in mm 
sphere3.pINS_RIGHT = struct('centre', [38 -5 9],'radius', 2); % in mm 


fns = fieldnames(sphere3);

for i = 1:length(fns)
    sphere3_roi = maroi_sphere(sphere3.(fns{i}));
    saveroi(sphere3_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end
