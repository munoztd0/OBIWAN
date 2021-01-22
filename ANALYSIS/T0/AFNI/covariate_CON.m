function DOcovariateCON(task, name_ana, name_soft, covariateNames, remove)

% intended for REWOD hedonic reactivity GROUP X COND
% 2nd level behavioral covariate demeaned by groups
% last modified on July 2020 by David Munoz

%variables
task = 'PIT'; %PIT hedonicreactivity
name_soft = 'SPM'; % output folder for this analysis
name_ana = 'GLM-01_HW'; % output folder for this analysis
covariateNames = {'CSp_eff'; 'CSm_eff'}; %{'REW_lik'; 'NEU_lik'}; %{'CSp_eff'; 'CSm_eff'}; %9
conImage = {'con-0001'; 'con-0002'};
group = 'control' %'obese'
covariate=1


dbstop if error
remove = 0;

%% define path

cd ~
home = pwd;
homedir = [home '/OBIWAN'];


mdldir   = fullfile (homedir, '/DERIVATIVES/GLM/', name_soft, task);% mdl directory (timing and outputs of the analysis)
covdir   = fullfile (homedir, 'DERIVATIVES/GLM/', name_soft, task, name_ana); % director with the extracted second level covariates
groupdir = fullfile (mdldir,name_ana, 'group');



%% specify spm param
% addpath('/usr/local/external_toolboxes/spm12/');
% addpath ([homedir '/CODE/ANALYSIS/fMRI/dependencies']);
% spm('Defaults','fMRI');
% spm_jobman('initcfg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for c = 1:length(covariateNames)

    covariateX = covariateNames{c};
    conImageX =  conImage{c};

    filename = fullfile(covdir, [covariateX '.txt']);
    delimiterIn = '\t';
    headerlinesIn = 1;
    C = importdata(filename,delimiterIn,headerlinesIn); %importdata

    cov(c).ID   = C.textdata(:,1);
    cov(c).data = C.data(:,1);
    cov(c).ID(1) = []; %erase ID header

    if remove
        for i = 1:length(removesub)
            idx            = str2double(removesub{i}(5:end));
            torm           = find(cov(c).ID==idx);

            cov(c).ID{torm}   = [];
            cov(c).data(torm) = [];
        end
    end
    
    
    fileX = dir ([groupdir '/*' conImageX '*.nii' ]);
    F = struct2cell(fileX);
    F = F(1,:);
    
    for s = 1:length(F)
        cellContents = F{s};
        % Truncate and stick back into the cell
        F{s} = cellContents(10:12);
    end
    
    check = setdiff(F,cov(c).ID);
    if ~ length(F) - length(cov(c).ID) == length(check)
        disp('error')
        continue
    end
    cd(groupdir)
    if covariate
        mkdir('cov')
       for i = 1:length(cov(c).ID)
           cd(groupdir)
           o = dir(['*' num2str(cov(c).ID{i})]);
           HeaderInfo = spm_vol([pwd '/sub-' group num2str(cov(c).ID{i}) '_' conImageX '.nii']);
           vol = spm_read_vols(HeaderInfo);
           cof = vol .* cov(c).data(i);
           cd('cov')

           HeaderInfo.fname = ['sub-' group cov(c).ID{i} '_con-000' num2str(c) '.nii'];  % This is where you fill in the new filename
           HeaderInfo.private.dat.fname = HeaderInfo.fname;
           spm_write_vol(HeaderInfo,cof);
       end   
    else
           mkdir('no_cov')
       for i = 1:length(cov(c).ID)
           cd(groupdir)
           o = dir(['*' num2str(cov(c).ID{i})]);
           HeaderInfo = spm_vol([pwd '/sub-' group num2str(cov(c).ID{i}) '_' conImageX '.nii']);
           cof = spm_read_vols(HeaderInfo);
           cd('no_cov')

           HeaderInfo.fname = ['sub-' group cov(c).ID{i} '_con-000' num2str(c) '.nii'];  % This is where you fill in the new filename
           HeaderInfo.private.dat.fname = HeaderInfo.fname;
           spm_write_vol(HeaderInfo,cof);
       end  
    end
    
    
    
end
