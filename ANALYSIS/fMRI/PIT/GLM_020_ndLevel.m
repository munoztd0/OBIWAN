function GLM_020_ndLevel()

%parametric modulator at first level
dbstop if error

%does t-test and full_factorial
do_ttest = 1;
removesub = 'control114'; % or 0 % which sub do we want to remove


%% define path

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

task = 'PIT';

mdldir   = fullfile (homedir, '/DERIVATIVES/GLM', task);% mdl directory (timing and outputs of the analysis)
name_ana = 'GLM-02'; % output folder for this analysis
groupdir = fullfile (mdldir,name_ana, 'group/');


%% specify spm param
addpath('/usr/local/external_toolboxes/spm12/');
addpath ([homedir '/CODE/ANALYSIS/fMRI/dependencies']);
spm('Defaults','fMRI');
spm_jobman('initcfg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% define constrasts and constrasts names
if do_ttest
    
    % These contrast names become folders
    contrastNames = {'CSp&CSm_Baseline'
        'Effort'};
        
%     'CSp_CSm'%1
%         'CSpEffort_CSmEffort'%2
%         'CSp_CSm&Baseline'%3
%         'CSpEffort_CSmEffort&BaselineEffort' %4
%         'grips'
%         'CSp_Baseline'
%         'CSm_Baseline'};%5
   
    
    conImages = {'con-0001'
        'con-0002'} ;
%         'con-0003'
%         'con-0004'
%         'con-0005'
%         'con-0006'
%         'con-0007'};
    
    
    %% prepare batch for each contrasts
    
    for n = 1:length(contrastNames)
        
        clear matlabbatch
        
        conImageX = conImages{n};
        contrastX = contrastNames{n};
        
        if removesub
            contrastFolder = fullfile (groupdir, 'ttests', removesub, contrastX);
        else
            contrastFolder = fullfile (groupdir, 'ttests', 'all', contrastX);
        end
        
        mkdir(contrastFolder);
        
        % create the group level spm file
        matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; % directory
        
        conAll     = spm_select('List',groupdir,['^'  '.*' conImageX '.nii']); % select constrasts
        for j =1:size(conAll,1)
            matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{j,1} = [deblank([groupdir conAll(j,:)]) ',1'];
        end
        
        if removesub % remove subject from analysis
            
            disp(['removing subject' removesub]);
            allsub = matlabbatch{1}.spm.stats.factorial_design.des.t1.scans; % let's put this in a smaller variable
            idx = (regexp(allsub,removesub)); % find string containing the sub id
            idxtoRemove = find(~cellfun(@isempty,idx)); % get the index of that string
            matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(idxtoRemove) = []; % remove the string from the scans selected for the analysis
            
        end
        
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
        
        % estimate design matrix
        matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
        % specify one sample tconstrast
        matlabbatch{3}.spm.stats.con.spmmat(1)               = {[contrastFolder  '/SPM.mat']};
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name     = contrastX (1:end);
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights  = [1];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep  = 'none';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name     = ['Neg ' contrastX(1:end)];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights  = [-1];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep  = 'none';
        
        spm_jobman('run',matlabbatch)
        
    end
end



end