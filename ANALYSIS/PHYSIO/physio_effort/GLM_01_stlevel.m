
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
x = [];
ID = [];
df = [];
for j = 1:length(session)
    for i = 1:length(subj)
        
        clear matlabbatch

        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        number = subjX(end-2:end);
        numdec = str2num(number);
        

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
        
        mkdir([homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-01/sub-' subjX '/output'])
        
        cd([homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-01/sub-' subjX '/output'])
        
        disp('')
        disp('')
        disp('************************--------------------------*****************')
        disp(['doing_sub-' subjX])
        disp('************************--------------------------*****************')
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.modelfile = 'GLM-01';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.outdir = {[homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-01/sub-' subjX '/output']};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.chan.chan_def.best_eye = 'pupil';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.timeunits.seconds = 'seconds';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.datafile = {[homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/ptpspm_' number '.mat']};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.missing.no_epochs = 0;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(1).name = 'CSp';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(1).onsets = onsets.CSp';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(1).durations = 4;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(1).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(2).name = 'CSm';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(2).onsets = onsets.CSm';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(2).durations = 4;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(2).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(3).name = 'Base';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(3).onsets = onsets.Baseline;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(3).durations = 4;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(3).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(4).name = 'USp';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(4).onsets = onsets.rew;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(4).durations = 2;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(4).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(5).name = 'USm';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(5).onsets = onsets.emp;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(5).durations = 2;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(5).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
                
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(6).name = 'rinse';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(6).onsets = onsets.wat;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(6).durations = 2;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition(6).pmod = struct('name', {}, 'poly', {}, 'param', {});
        
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.nuisancefile = {''};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.latency.fixed = 'fixed';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.bf.psrf_fc1 = 1;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.norm = true;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.filter.def = 0;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.exclude_missing.excl_no = 'No';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.overwrite = true;
        
        matlabbatch{2}.pspm{1}.first_level{1}.export.modelfile = cfg_dep('GLM for PS (fear-conditioning): Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','modelfile'));
        matlabbatch{2}.pspm{1}.first_level{1}.export.datatype = 'cond';
        matlabbatch{2}.pspm{1}.first_level{1}.export.exclude_missing = false;
        matlabbatch{2}.pspm{1}.first_level{1}.export.target.filename = [homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-01/sub-' subjX '/output/statsGLM-01'];
        matlabbatch{2}.pspm{1}.first_level{1}.export.delim.tab = '\t';


        matlabbatch{3}.pspm{1}.first_level{1}.contrast.modelfile = cfg_dep('GLM for PS (fear-conditioning): Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','modelfile'));
        matlabbatch{3}.pspm{1}.first_level{1}.contrast.datatype = 'param';
        matlabbatch{3}.pspm{1}.first_level{1}.contrast.con.conname = 'CSp-CSm';
        matlabbatch{3}.pspm{1}.first_level{1}.contrast.con.convec = [1 0 -1 0 0 0 0 0 0 0 0 0];
        matlabbatch{3}.pspm{1}.first_level{1}.contrast.deletecon = true;
        matlabbatch{3}.pspm{1}.first_level{1}.contrast.zscored = false;
        
        pspm_jobman('run',matlabbatch)
        
        [sts, glm] = pspm_glm_recon('GLM-01.mat');
        
        %save(['GLM-01.mat'], 'glm')
        glm.resp(:,7) = numdec;
        glm.resp(:,8) = 1:length(glm.resp(:,7));
        df = [df; glm.resp];
        
        disp(['DONE' ' sub-' subjX '*************'])
        
        %export to R
        %% Setup the Import Options and import the data
        opts = delimitedTextImportOptions("NumVariables", 6);
        opts.DataLines = [3, 3];
        opts.Delimiter = "\t";
        opts.VariableNames = ["CSp", "CSm", "Base", "USp", "USm", "rinse"];
        opts.VariableTypes = ["double", "double", "double", "double", "double", "double"];
        opts.ExtraColumnsRule = "ignore";

        % Import the data
        stats = readtable([homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-01/sub-' subjX '/output/statsGLM-01.txt'], opts);
        
        x = [x; stats];
        ID = [ID; numdec];
 
    end
    
    mkdir([homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-01/group'])
    cd ([homedir 'DERIVATIVES/GLM/PSPM/PAV/GLM-01/group'])
    
    x.ID = ID;

    filename = 'group_GLM-01.txt';
    fid = fopen(filename, 'wt');
    fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'CSp', 'CSm', 'Base', 'USp', 'USm', 'rinse', 'ID');  % header
    fclose(fid);
    dlmwrite(filename,x.Variables,'delimiter','\t','-append');
    
    T = table(df);
    
    filename = 'recon_GLM-01.txt';
    fid = fopen(filename, 'wt');
    fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'CSp', 'CSm', 'Base', 'USp', 'USm', 'rinse', 'ID', 'time');  % header
    fclose(fid);
    dlmwrite(filename,T.Variables,'delimiter','\t','-append');

    
end