   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2nd level pupil DATA ONE-sample t-test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by David


dbstop if error
clear all

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN/'];

addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));
addpath  /usr/local/MATLAB/R2020a/PsPM/src/
%% DEFINE POPULATION
control = [homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-02/sub-control*/output/GLM-02.mat'];
obese = [homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-02/sub-obese*/output/GLM-02.mat'];

controlX = dir(control);
obeseX = dir(obese);

for i=1:length(controlX)
    dfcontrol{i,1} = [controlX(i).folder '/' controlX(i).name];
end

for i=1:length(obeseX)
    dfobese{i,1} = [obeseX(i).folder '/' obeseX(i).name];
end


session = {'second'}; 

mkdir([homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-02/group'])
df = vertcat (dfcontrol, dfobese);
matlabbatch{1}.pspm{1}.second_level{1}.contrast.testtype.one_sample.modelfile = df;
%matlabbatch{1}.pspm{1}.second_level{1}.contrast.testtype.two_sample.modelfile1 = dfcontrol;
%matlabbatch{1}.pspm{1}.second_level{1}.contrast.testtype.two_sample.modelfile2 = dfobese;
matlabbatch{1}.pspm{1}.second_level{1}.contrast.outdir = {[homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-02/group']};
matlabbatch{1}.pspm{1}.second_level{1}.contrast.filename = 'group_GLM_02';
matlabbatch{1}.pspm{1}.second_level{1}.contrast.def_con_name.file.con_all = 'all';
matlabbatch{1}.pspm{1}.second_level{1}.contrast.overwrite = true;

pspm_jobman('run',matlabbatch)

disp(['done level 2'])
       
        

