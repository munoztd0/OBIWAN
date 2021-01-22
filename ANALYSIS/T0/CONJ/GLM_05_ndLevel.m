function GLM_05_ndLevel()

% does: analysis on run 2 and 3

% one sample ttest
% a flexible factorial with contrasted images
% a conjuction analysis


%sub_list = {'01'; '02';'03';'04';'05';'06';'07';'09';'10';
    %'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%% define path

cd ~
home = pwd;
homedir = [home '/REWOD/'];

mdldir   = fullfile(homedir, 'DERIVATIVES/ANALYSIS/CONJ');% mdl directory (timing and outputs of the analysis)
name_ana = 'GLM-05'; % output folder for this analysis
groupdir = fullfile (mdldir,name_ana, 'group', 'ttests', 'all/');


%% specify spm param
addpath('/usr/local/external_toolboxes/spm12/');
addpath /usr/local/MATLAB/R2018a/spm12 ;
addpath ([homedir 'CODE/ANALYSIS/fMRI/dependencies']);
spm('Defaults','fMRI');
spm_jobman('initcfg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% These contrast names become folders
    % These contrast names become sub-folders
    contrastNames = {'CSp-CSm' %1
                     'odor-lik'}; %2

    conImages = {'spmT_0003.nii'
             'spmT_0002.nii'};

%% prepare batch for each contrasts

% for n = 1:length(contrastNames)
%     
%     clear matlabbatch
%     
%     conImageX = conImages{n};
%     contrastX = contrastNames{n};
%     
%    contrastFolder = fullfile (groupdir, 'ttests', 'all');
% 
%     mkdir(contrastFolder);
%     
%     % create the group level spm file
%     matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; % directory
%     
%     conAll     = spm_select('List',groupdir,['^'  '.*' conImageX '.nii']); % select constrasts
%     for j =1:length(conAll)
%         matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{j,1} = [groupdir conAll(j,:) ',1'];
%     end
%     
%     
%     matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
%     matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
%     matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
%     matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
%     matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
%     matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
%     matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
%     matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
%     
%     % extimate design matrix
%     matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
%     matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
%     
%     % specify one sample tconstrast
%     matlabbatch{3}.spm.stats.con.spmmat(1)                = {[contrastFolder  '/SPM.mat']};
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.name     = contrastX (1:end);
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights  = [1];
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep  = 'none';
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.name     = ['Neg ' contrastX(1:end)];
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights  = [-1];
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep  = 'none';
%     
%     spm_jobman('run',matlabbatch)
%     
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FLEXIBLE FACTORIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%--------------------------------------------------------------------------
% %CS: Valcorr - Devalcorr
% 
% analysisX = 'FF.PITxHED';
% 
% factor(1).name       = 'PIT';
% factor(1).condition  = 1;
% factor(1).levels     = 1;
% 
% factor(2).name       = 'HED';
% factor(2).condition  = 2;
% factor(2).levels     = 1;
% 
% 
% factor(1).idx2cons   = {'con-0001', 'con-0002'};
% 
% contrast(1).weights  = [        1,    -1];
% contrast(1).name     = 'PIT>HED';
% 
% contrast(2).weights  = [    -1,          1];
% contrast(2).name     = 'negative PIT>HED';
% 
% matlabbatch = espm_level2_ff(groupdir,sub_list, factor, contrast, analysisX);
% 
% 
% disp ('***************************************************************')
% disp (['running batch for: '  analysisX ] )
% disp ('***************************************************************')
% 
% spm_jobman('run',matlabbatch)
% 
% clear analysisX factor constrast
% 


%--------------------------------------------------------------------------
% CONJUNCTION 1  

analysisX = 'CONJ1.HEDxPIT';
    
%     factor(1).name       = 'TASK';
%     factor(1).condition  = 2;
%     factor(1).levels     = 1;
%     
% 
%     
%     factor(1).idx2cons   = {'con-0001', 'con-0002'};
%     
%     contrast(1).weights  = [         1,          -1]; %???
%     contrast(1).name     = 'HEDxPIT';
% 
%     matlabbatch = espm_level2_ff(groupdir,sub_list, factor, contrast, analysisX);
%     
%     
%     disp ('***************************************************************')
%     disp (['running batch for: '  analysisX ] )
%     disp ('***************************************************************')
%     
%     spm_jobman('run',matlabbatch)
    
    % run the conjunction analysis
    espm_conjunction(groupdir, 'conjuction.nii', 2)
    
    clear analysisX factor constrast
    


end