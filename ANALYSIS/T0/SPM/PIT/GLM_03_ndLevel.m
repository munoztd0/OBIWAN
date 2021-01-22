function GLM_03_ndLevel()

%parametric modulator at first level
dbstop if error

%does t-test and full_factorial
do_ttest = 1;
removesub = 0; %'control114'; % or 0 % which sub do we want to remove


%% define path

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

task = 'PIT';

mdldir   = fullfile (homedir, '/DERIVATIVES/GLM/SPM', task);% mdl directory (timing and outputs of the analysis)
name_ana = 'GLM-03'; % output folder for this analysis
covdir   = fullfile (homedir, 'DERIVATIVES/GLM/SPM', task, name_ana, 'covariates'); % director with the extracted second level covariates   
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
    
    covariateNames = {'age_cov'; 'bmi_cov'};
        
    % These contrast names become folders
    contrastNames = {'CSp&CSm_Baseline'
                'CSpEffort_CSmEffort'
                'Effort'
                'CSpEffort_CSmEffort&BaselineEffort'
                'CSp_CSm&Baseline'
                'CSp_CSm'
                'CSp_ITI'};

    
    conImages = {'con-0001'
                'con-0002'
                'con-0003'
                'con-0004'
                'con-0005'
                'con-0006'
                'con-0007'};
    
    
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
        
        for c = 1:length(covariateNames)
            
            covariateX = covariateNames{c};

            filename = fullfile(covdir, [covariateX '.txt']);
            delimiterIn = '\t';
            headerlinesIn = 1;
            C = importdata(filename,delimiterIn,headerlinesIn); %importdata

            cov(c).ID   = C.data(:,1);
            cov(c).data = C.data(:,2);
    
            
            l = 0; %lag
            s = 1;
            while s < length(conAll) +1
                t = s + l;
                if contains(conAll(s,:), num2str(cov(c).ID(t)))
                    cov(c).IDX(s)      = cov(c).ID(t);
                    cov(c).dataX(s)     =  cov(c).data(t);
                    s = s+1;
                else
                    l = l+1; %skip this line
                end
            end

            matlabbatch{1}.spm.stats.factorial_design.cov(c).c      = cov(c).dataX;
            matlabbatch{1}.spm.stats.factorial_design.cov(c).cname  = covariateX;
            matlabbatch{1}.spm.stats.factorial_design.cov(c).iCFI = 1;
            matlabbatch{1}.spm.stats.factorial_design.cov(c).iCC = 1; 
            
         end


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
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name     = [covariateX];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights  = [0 0 1];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep  = 'none';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.name     = ['Neg ' covariateX];
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights  = [0 0 -1];
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep  = 'none';
        
        spm_jobman('run',matlabbatch)
        
    end
end

end