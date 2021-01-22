function GLM_01_ndLevel()

% intended for OBIWAN
% last modified on January 2021 by David MUNOZ

do_ttest = 1;
remove = 0;

%% define task variable
task = 'VBM';

%% define path

cd ~
home = pwd;
homedir = [home '/OBIWAN/'];


mdldir   = fullfile (homedir, 'DERIVATIVES/GLM/SPM/', task);% mdl directory (timing and outputs of the analysis)
name_ana = 'GLM-01'; % output folder for this analysis 
groupdir = fullfile (mdldir,name_ana, 'group/');


%% specify spm param
%addpath /usr/local/MATLAB/R2018a/spm12 ; 
addpath /usr/local/external_toolboxes/spm12/ ;

addpath ([homedir 'CODE/ANALYSIS/fMRI/dependencies']);
spm('Defaults','fMRI');
spm_jobman('initcfg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% define contrasts and contrasts names
if do_ttest
    
    % These contrast names become folders
    contrastNames = {'group'; 
        'cova';
        'groupXcova'};
   
    
    conImages = {'GM'; 
        'WM'};
    
    
    %% prepare batch for each contrasts
    
    for i = 1:length(conImages)
        
        clear matlabbatch
        
        conImageX = conImages{i};

        contrastFolder = fullfile (groupdir, 'ttests', 'all', conImageX);

        
        mkdir(contrastFolder);
        
        % create the group level spm file
        matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; % directory
        
        %  FORMAT [dirs] = spm_select('List',direc,'dir',filt)
        conLean     = spm_select('List',groupdir,['^' '.*' 'control' '.*' conImageX '.nii']); % select contrasts 
       
        for j =1:length(conLean)
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1{j,1} = [groupdir conLean(j,:) ',1'];
        end
        
        conObese     = spm_select('List',groupdir,['^' '.*' 'obese' '.*' conImageX '.nii']);
        for j =1:length(conObese)
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2{j,1} = [groupdir conObese(j,:) ',1'];
        end
        
        matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
        
        %cova
        x =rand(94,1);
        matlabbatch{1}.spm.stats.factorial_design.cov.c = [x];
        matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'cova';
        
        matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 2;
        matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 5;
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
        
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
        % estimate design matrix
        matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
        
%         % specify one sample tcontrast
        matlabbatch{3}.spm.stats.con.spmmat(1)               = {[contrastFolder  '/SPM.mat']};
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name     = contrastNames{1};
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights  = [-1 1 0 0];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep  = 'none';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name     = ['Neg ' contrastNames{1}];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights  = [1 -1 0 0];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep  = 'none';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name     = contrastNames{2};
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights  = [0 0 1 1];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep  = 'none';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.name     = contrastNames{3};
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights  = [0 0 -1 1];
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep  = 'none';
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.name     = ['Neg ' contrastNames{3}];
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights  = [0 0 1 -1];
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep  = 'none';
        
        spm_jobman('run',matlabbatch)
        
    end
end

end