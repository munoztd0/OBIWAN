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

con_name1 = 'Wolfgang';
con_name2 = 'Prevost';
con_name3 = 'Talmi';
  


dir_data   =  fullfile (homedir, '/DERIVATIVES/ANALYSIS', task_name, ana_name, 'group');

roi_roi = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI',  threshold, glm);


% %% DOING FOR R_C
cd (roi_roi)

mkdir (con_name1)

cd (con_name1)

sphere1.VS_apetitive = struct('centre', [-15 1 -9],'radius', 2); % in mm TD RPE apetitive
sphere1.VS_averisive = struct('centre', [-12 3 -10],'radius', 2); % in mm with averisive

sphere1.mAMY_aversive = struct('centre', [-20 -3 -23],'radius', 2); % in mm -> aversive
sphere1.SN = struct('centre', [-5 -12 -12],'radius', 2); % in mm -> apetitive

fns = fieldnames(sphere1);

for i = 1:length(fns)
    sphere1_roi = maroi_sphere(sphere1.(fns{i}));
    saveroi(sphere1_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end

%% DOING FOR R_N
cd (roi_roi)

mkdir (con_name2)

cd (con_name2)

sphere2.AMY_BLA_specific = struct('centre', [-18 -3 -22],'radius', 2); % in mm 

sphere2.AMY_CMN_general = struct('centre', [-15 -10 -11],'radius', 2); % in mm


fns = fieldnames(sphere2);

for i = 1:length(fns)
    sphere2_roi = maroi_sphere(sphere2.(fns{i}));
    saveroi(sphere2_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end


%%%
cd (roi_roi)

mkdir (con_name3)

cd (con_name3)

sphere3.NAcc_prePIT = struct('centre', [4 0 2.34],'radius', 2); % in mm

sphere3.NAcc_PIT = struct('centre', [4 8 -2.7],'radius', 2); % in mm
sphere3.AMY_RIGHT = struct('centre', [20 -6 -18],'radius', 2); % in mm


fns = fieldnames(sphere3);

for i = 1:length(fns)
    sphere3_roi = maroi_sphere(sphere3.(fns{i}));
    saveroi(sphere3_roi, [fns{i} '.mat']);
    mars_rois2img([fns{i} '.mat'],  [fns{i} '.nii']);
end

end
