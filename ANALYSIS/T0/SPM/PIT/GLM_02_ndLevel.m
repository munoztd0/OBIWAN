function GLM_02_ndLevel()

% intended for REWOD PIT GROUP X COND
% 2nd level behavioral covariate demeaned by groups
% last modified on July 2020 by David Munoz

task = 'PIT';
covariate = 'effort';
dbstop if error
%does t-test and full_factorial
remove = 0;
%removesub = {'sub-23'} ;
%removedsub = 'no variance neutral';


%% define path

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

name_ana = 'GLM-02'; % output folder for this analysis

mdldir   = fullfile (homedir, '/DERIVATIVES/GLM/SPM', task);% mdl directory (timing and outputs of the analysis)
covdir   = fullfile (homedir, 'DERIVATIVES/GLM/SPM', task, name_ana, 'group_covariates'); % director with the extracted second level covariates
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
%do_covariate % covariate of interest name become folder

covariateNames = {'CSp_CSm_eff_ob'; 'CSp_CSm_eff_hw'}; %9
contrastX = 'CSp_CSm';%2 Only one at a time now

conImageX = 'con-0001';


%% prepare batch for each contrasts
clear matlabbatch

for c = 1:length(covariateNames)

    covariateX = covariateNames{c};

    filename = fullfile(covdir, [covariateX '.txt']);
    delimiterIn = '\t';
    headerlinesIn = 1;
    C = importdata(filename,delimiterIn,headerlinesIn); %importdata

    cov(c).ID   = C.data(:,1);
    cov(c).data = C.data(:,2);


    if remove
        for i = 1:length(removesub)
            idx            = str2double(removesub{i}(5:end));
            torm           = find(cov(c).ID==idx);

            cov(c).ID(torm)   = [];
            cov(c).data(torm) = [];
        end
    end


    if remove 
        contrastFolder = fullfile (groupdir, 'covariate', covariate, ['removing-' removedsub], contrastX);
    else
        contrastFolder = fullfile (groupdir, 'covariate', covariate, 'all', contrastX);
    end

    mkdir(contrastFolder);

    % create the group level spm file
    matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; % directory

    %group factor
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.name = 'Group';
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.levels = 2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = 2;

    l = 0; %lag
    s = 1;
    idX = [groupdir '*' conImageX '.nii' ];
    fileX = dir(idX);
    while s < length(fileX) +1
        t = s + l;
        if contains(fileX(s).name, num2str(cov(c).ID(t)))
            cov(c).IDX(s)      = cov(c).ID(t);
            cov(c).dataX(s)     =  cov(c).data(t);
            conAll{s}  = dir([groupdir '*' num2str(cov(c).ID(t)) '_' conImageX '*.nii' ]);
            s = s+1;
        else
            l = l+1; %skip this line
        end
    end


    %ugly but works  
    l = 0;
    for j=1:length(conAll)
        if strfind(conAll{1,j}.name, 'control')
            if remove
                for k=1:length(removesub)
                    if strfind(conAll{1,j}.name, removesub{k})
                        continue
                    else        
                        matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans{j,1} = [groupdir conAll{1,j}.name ',1'];
                    end
                end
            else        
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans{j,1} = [groupdir conAll{1,j}.name ',1'];
            end
        else
            l = l +1 ;
            if remove
                for k=1:length(removesub)
                    if strfind(conAll{1,j}.name, removesub{k})
                        continue
                    else        
                        matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans{l,1} = [groupdir conAll{1,j}.name ',1'];
                    end
                end
            else        
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans{l,1} = [groupdir conAll{1,j}.name ',1'];
            end
        end
    end

    sizeOB = length(matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans);
    sizeHW = length(matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans);

    if c == 1 %covariate ob
        meanOB = mean(cov(c).dataX(end-sizeOB+1:end));
        cov(c).dataX(end-sizeOB+1:end) = cov(c).dataX(end-sizeOB+1:end) - meanOB;
    else
        meanHW = mean(cov(c).dataX(1:sizeHW));
        cov(c).dataX(1:sizeHW) = cov(c).dataX(1:sizeHW) - meanHW;
    end   

    matlabbatch{1}.spm.stats.factorial_design.cov(c).c      = cov(c).dataX;
    matlabbatch{1}.spm.stats.factorial_design.cov(c).cname  = covariateX;
    matlabbatch{1}.spm.stats.factorial_design.cov(c).iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(c).iCC = 5;  %not centering bc I laready centerd by factor


end

matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1; %%??
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% extimate design matrix
matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%specify one sample tconstrast
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

disp ('***************************************************************') 
disp (['running batch for: '  contrastX ': ' covariateX] ) 
disp ('***************************************************************') 

spm_jobman('run',matlabbatch)

end

