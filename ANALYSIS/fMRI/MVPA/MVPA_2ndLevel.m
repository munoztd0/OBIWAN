function MVPA_ndLevel()

% intended for REWOD HED VMPA
% quick second level for MVPA Reward vs Empty
% last modified on July 2020 by David Munoz

%dbstop if error
%does t-test and full_factorial
do_ttest = 1;
remove = 0;
removesub = {'sub-24'} ;
removedsub = '24';

%% define task variable
%sessionX = 'second';
task = 'hedonic';
ana_name = 'MVPA-04'; % output folder for this analysis 
copy = 1;
%% define path


cd ~
home = pwd;
homedir = [home '/REWOD'];

%maskfile = fullfile(homedir,'DERIVATIVES','ANALYSIS', 'GLM', 'hedonic', 'GLM-04', 'group', 'covariate', 'Odor-NoOdor_lik_meancent', 'all', 'Odor-NoOdor', 'mask.nii');
maskfile = fullfile(homedir, 'DERIVATIVES', 'EXTERNALDATA', 'LABELS', 'Olfa_cortex', 'mask.nii'); 
   

% | add spm12 to matlab path
addpath '/usr/local/external_toolboxes/spm12/'
%addpath /usr/local/MATLAB/R2018a/spm12 ; 
addpath ([homedir '/CODE/ANALYSIS/fMRI/dependencies']);
spm('Defaults','fMRI');
spm_jobman('initcfg');



mdl_dir = fullfile(homedir,'DERIVATIVES','ANALYSIS','MVPA','hedonic',ana_name);
groupdir = fullfile (mdl_dir, 'group');
%% create group dir

subj       =  {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26';}; %subID;


% participant's specifics
     


%%create and copy into groupdir
cd (mdl_dir)



for i = 1:length(subj)

    subjX = char(subj(i));
    subj_dir =fullfile(mdl_dir, [ 'sub-' subjX], 'mvpa3', '*l_corrected_smoothed.nii'); 
    old = dir(subj_dir);

    if copy 
        mkdir (groupdir);

        new = [groupdir '/sub-' subjX '_' old.name];

        fprintf('participant number: %s \n', subj{i});
        cd(old.folder)
        copyfile(old.name, new)
            %cd (groupdir)
    %end  
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% define contrasts and contrasts names
if do_ttest
    

    % These contrast names become folders
    contrastNames = {'smell_nosmell'};%1
    
    
    conImages = {old.name};
      
    
    %% prepare batch for each contrasts
    
    for n = 1:length(contrastNames)
        
        clear matlabbatch
        
        conImageX = conImages{n};
        contrastX = contrastNames{n};
        
        if remove
           contrastFolder = fullfile (groupdir, 'ttests', ['removing-' removedsub], contrastX);
        else
            contrastFolder = fullfile (groupdir, 'ttests', 'all', contrastX);
        end
        
        mkdir(contrastFolder);
        
        % create the group level spm file
        matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; % directory
        
        %  FORMAT [dirs] = spm_select('List',direc,'dir',filt)
        conAll     = spm_select('List',groupdir,['^'  '.*' conImageX]); % select contrasts ?WHat is LIST?
        for j =1:size(conAll) %%wathca
            matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{j,1} = [groupdir '/' conAll(j,:) ',1'];
        end
        
        if remove % remove subject from analysis
            allsub = matlabbatch{1}.spm.stats.factorial_design.des.t1.scans; % let's put this in a smaller variable
            for i = 1:length(removesub)
                    idx = (regexp(allsub,removesub{i})); % find string containing the sub id
                    idxtoRemove = find(~cellfun(@isempty,idx)); % get the index of that string
                    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(idxtoRemove) = []; % remove the string from the scans selected for the analysis
                    allsub = matlabbatch{1}.spm.stats.factorial_design.des.t1.scans;
            end
               
        end
        
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = [];
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {maskfile};

%      
        %matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        %matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 0;
%         matlabbatch{1}.spm.stats.factorial_design.masking.im = 0.1;
%         matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 0.1;
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
%         
%         SPM.xM.gMT =  0.1;%!! NOPE set -inf if we want to use explicit masking 0.8 is the spm default
%         SPM.xM.VM  =  spm_vol(Maskimage);
%         SPM.xM.I   =  0.1;
        % estimate design matrix
        matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
        % specify one sample tcontrast
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
