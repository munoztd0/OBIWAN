function GLM_04_ndLevel()

    % intended for REWOD PIT GROUP X COND (Flex Facto)
    % 2nd level behavioral covariate demeaned by groups
    % last modified on July 2020 by David Munoz

    task = 'PIT';
    dbstop if error
    %does t-test and flex facto
    remove = 0;
    %removesub = {'sub-23'} ;
    %removedsub = 'no variance neutral';
    
    
    %% define path
    
    cd ~
    home = pwd;
    homedir = [home '/OBIWAN'];
    
    name_ana = 'GLM-04'; % output folder for this analysis
    
    mdldir   = fullfile (homedir, '/DERIVATIVES/GLM/SPM', task);% mdl directory (timing and outputs of the analysis)
    covdir   = fullfile (homedir, 'DERIVATIVES/GLM/SPM', task, name_ana, 'group_covariates'); % director with the extracted second level covariates
    groupdir = fullfile (mdldir,name_ana, 'group/');
    
    
    %% specify spm param
    addpath('/usr/local/external_toolboxes/spm12/');
    addpath ([homedir '/CODE/ANALYSIS/fMRI/dependencies']);
    spm('Defaults','fMRI');
    spm_jobman('initcfg');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DO FLEX FACT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% define factor names

    factorNames = {'subject'; 'group'; 'condition'}; 
    condsLevelsHW = [1 1; 1 2]; %matrix group1
    condsLevelsOB = [2 1; 2 2]; %matrix group2
    nc = 2;%(number of levels in condition factor) 
    ng = 2;%(number of groups) 
    
    intera = [2 3]; %interaction group X cond
    main = [1]; %mian subject
    
    conImageX = {'con-0001';'con-0002'};
    
    covariateNames = {'age_cov'}; % 'bmi_cov'};
        
    %% prepare batch for each contrasts
    clear matlabbatch

        if remove 
            contrastFolder = fullfile (groupdir, 'ttest',  ['removing-' removedsub]);
        else
            contrastFolder = fullfile (groupdir, 'ttests', 'all');
        end
    
        mkdir(contrastFolder);
    
        % create the group level spm file
        matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; % directory
        
        
        for i = 1:length(factorNames)
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).name = factorNames{i};
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).dept = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).variance = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).gmsca = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).ancova = 0;
        end
        
        n1 = 0; %start counter for contrasts group HW
        n2 = 0; %start counter for contrasts
        for i = 1:length(conImageX)
            idX = [groupdir '*' conImageX{i} '.nii' ];
            conAll = dir(idX);
            for ii = 1:length(conAll)
                if strfind(conAll(ii).name, 'control')
                    n1 = n1 +1;
                    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(ii).scans{i,1} = [groupdir conAll(ii).name ',1'];
                    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(ii).conds = condsLevelsHW;
                else
                    n2 = n2 +1;
                    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(ii).scans{i,1} = [groupdir conAll(ii).name ',1'];
                    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(ii).conds = condsLevelsOB;
                end 
            end
        end
        
%         
%         l = 0; %lag
%         s = 1;
%         while s < length(conAll) +1
%             t = s + l;
%             if contains(conAll(s).name, num2str(cov(c).ID(t)))
%                 cov(c).IDX(s)      = cov(c).ID(t);
%                 cov(c).dataX(s)     =  cov(c).data(t);
%                 conAll{s}  = dir([groupdir '*' num2str(cov(c).ID(t)) '_' conImageX '*.nii' ]);
%                 s = s+1;
%             else
%                 l = l+1; %skip this line
%             end
%         end    
        
%         matlabbatch{1}.spm.stats.factorial_design.cov(c).c      = cov(c).dataX;
%         matlabbatch{1}.spm.stats.factorial_design.cov(c).cname  = covariateX;
%         matlabbatch{1}.spm.stats.factorial_design.cov(c).iCFI = 1;
%         matlabbatch{1}.spm.stats.factorial_design.cov(c).iCC = 1;  %not centering bc I laready centerd by factor
    

    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = main; %main eff
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = intera; %interaction
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    % extimate design matrix
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    %matlabbatch{2}.spm.stats.fmri_est.method.Bayesian2 = 1;

    %specify tconstrast
    n1 = n1/2
    n2 = n2/2
    if nc > 2
        MEc = [1:nc]-mean(1:nc);%(main effect of condition,
    else
        MEc = [1 -1]; 
    end
        
    MEg = [-1 1]; %(main effect of group: Group 1 < Group 2) 
    
    
%     matlabbatch{3}.spm.stats.con.spmmat(1)                = {[contrastFolder  '/SPM.mat']};
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.name     = [contrastX  '_cov'];
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights  = [0 0 1 1]; % in the covariate the second colon is the one of interest
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep  = 'none';
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.name     = [contrastX  '_ob-hw'];
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights  = [1 -1 0 0]; % in the covariate the second colon is the one of interest
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep  = 'none';
%     matlabbatch{3}.spm.stats.con.consess{4}.tcon.name     = [contrastX  '_hw-ob'];
%     matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights  = [-1 1 0 0];
%     matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep  = 'none';
%     matlabbatch{3}.spm.stats.con.consess{5}.tcon.name     = [contrastX  '_ob-hw_cov'];
%     matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights  = [0 0 1 -1];
%     matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep  = 'none';
%     matlabbatch{3}.spm.stats.con.consess{6}.tcon.name     = [contrastX  '_hw-ob_cov'];
%     matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights  = [0 0 -1 1];
%     matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep  = 'none';


%general advise is to centre the covariate before splitting it.

    disp ('***************************************************************') 
    disp (['running batch']) 
    disp ('***************************************************************') 

    spm_jobman('run',matlabbatch)

    end
    
    