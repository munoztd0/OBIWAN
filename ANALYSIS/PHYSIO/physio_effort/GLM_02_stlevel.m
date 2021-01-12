
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1st level pupil DATA
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
control = [homedir 'SOURCEDATA/physio/control*'];
obese = [homedir 'SOURCEDATA/physio/obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);
session = {'second'}; %only ses second

for j = 1:length(session)
    for i = 1:length(subj)
        
        
        clear matlabbatch

        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        number = subjX(end-2:end);
        

        fileX = dir([homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/ptpspm*']);
        
        if length(fileX) == 0 
           continue
        else
            cd([homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/'])
        end
        
        if i == 89
            continue %what the hell is wrong with 63
        end
        
        load(['onsets_' number '.mat'])
        
        mkdir([homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-02/sub-' subjX '/output'])
        
        cd([homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-02/sub-' subjX '/output'])
        
        disp('')
        disp('')
        disp('************************--------------------------*****************')
        disp(['doing_sub-' subjX])
        disp('************************--------------------------*****************')
        
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.modelfile = 'GLM-02';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.outdir = {[homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-02/sub-' subjX '/output']};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.chan.chan_def.best_eye = 'pupil';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.timeunits.seconds = 'seconds';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.datafile = {[homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/ptpspm_' number '.mat']};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.missing.no_epochs = 0;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(1).name = 'CSp';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(1).onsets = onsets.CSp';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(1).durations = 3;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(1).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(2).name = 'CSm';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(2).onsets = onsets.CSm';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(2).durations = 3;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(2).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(3).name = 'Base';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(3).onsets = onsets.Baseline;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(3).durations = 0;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(3).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
%         matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(4).name = 'Rew';
%         matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(4).onsets = onsets.rew;
%         matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(4).durations = 0;
%         matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(4).pmod = struct('name', {}, 'poly', {}, 'param', {});
%         
%         matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(5).name = 'NoRew';
%         matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(5).onsets = onsets.norew;
%         matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(5).durations = 0;
%         matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(5).pmod = struct('name', {}, 'poly', {}, 'param', {});
%         
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.nuisancefile = {''};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.latency.fixed = 'fixed';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.bf.psrf_fc1 = 1;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.norm = true;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.filter.def = 0;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.exclude_missing.excl_no = 'No';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.overwrite = true;

 
        
        
        matlabbatch{2}.pspm{1}.first_level{1}.contrast.modelfile = cfg_dep('GLM for PS (fear-conditioning): Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','modelfile'));
        matlabbatch{2}.pspm{1}.first_level{1}.contrast.datatype = 'param';
        matlabbatch{2}.pspm{1}.first_level{1}.contrast.con.conname = 'CSp-CSm';
        matlabbatch{2}.pspm{1}.first_level{1}.contrast.con.convec = [1 0 -1 0 0 0];
        matlabbatch{2}.pspm{1}.first_level{1}.contrast.deletecon = true;
        matlabbatch{2}.pspm{1}.first_level{1}.contrast.zscored = false;
        
        pspm_jobman('run',matlabbatch)
        
        disp(['DONE' ' sub-' subjX '*************'])
       
         
    end
end