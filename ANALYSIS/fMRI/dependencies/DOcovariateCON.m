function DOcovariateCON(task, name_ana, name_soft, covariateNames, remove)

% intended for REWOD hedonic reactivity GROUP X COND
% 2nd level behavioral covariate demeaned by groups
% last modified on July 2020 by David Munoz

%variables
task = 'hedonicreactivity';
name_ana = 'GLM-01_0'; % output folder for this analysis
name_soft = 'AFNI'; % output folder for this analysis

covariateNames = {'rew_lik_clean'; 'con_lik_clean'; 'rew_int_clean'; 'con_int_clean'}; %9
conImage = {'con-0001'; 'con-0002'; 'con-0001'; 'con-0002'};
remove = 0;

dbstop if error
%does t-test and full_factorial

%removesub = {'sub-23'} ;
%removedsub = 'no variance neutral';


%% define path

cd ~
home = pwd;
homedir = [home '/OBIWAN'];


mdldir   = fullfile (homedir, '/DERIVATIVES/GLM/', name_soft, task);% mdl directory (timing and outputs of the analysis)
covdir   = fullfile (homedir, 'DERIVATIVES/GLM/', name_soft, task, name_ana, 'covariates'); % director with the extracted second level covariates
groupdir = fullfile (mdldir,name_ana);

if ~exist(covdir, 'dir')
    mkdir (covdir)
end

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


%% prepare batch for each contrasts
clear matlabbatch

for c = 1:length(covariateNames)

    covariateX = covariateNames{c};
    contrastX = conImage{c};

    filename = fullfile(covdir, [covariateX '.txt']);
    delimiterIn = '\t';
    headerlinesIn = 1;
    C = importdata(filename,delimiterIn,headerlinesIn); %importdata
   
    data = C.data;
    

     x = dir([groupdir '/group/*' contrastX '*.nii' ]);
    
    if contains(covariateX, 'lik') 
        if contains(covariateX, 'hw') 
            x = dir ([groupdir '/group/*control*' conImageX '*.nii' ]);
        elseif contains(covariateX, 'ob') 
            x = dir ([groupdir '/group/*control*' conImageX '*.nii' ]);
        end
        
        for i = 1:length(x)
            x(i).name
            V = niftiread(['sub-' 'brain.nii']);
        end
        cov(c).dataX(1:sizeHW) = cov(c).dataX(1:sizeHW) - meanHW;
        if  0.01 < abs(mean(cov(c).dataX(end-sizeHW+1:end)));
            error(msg)
        end
    elseif contains(covariateX, 'int')   
        x = dir ([groupdir '/group/*control*' conImageX '*.nii' ]);
        sizeOB = length(x);
        meanOB = mean(cov(c).dataX(end-sizeOB+1:end));
        cov(c).dataX(end-sizeOB+1:end) = cov(c).dataX(end-sizeOB+1:end) - meanOB; 
        if  0.01 < abs(mean(cov(c).dataX(end-sizeOB+1:end)));
            error(msg)
        end
    else
        meanX = mean(cov(c).dataX);
        cov(c).dataX = cov(c).dataX - meanX; 
        if  0.01 < abs(mean(cov(c).dataX));
            error(msg)
        end
    end
      
    cd(covdir)
    fid = fopen([covariateNames{c} '_clean.txt'],'w');
    for x = 1:length(cov(c).dataX)
        fprintf(fid,'%.2f\n',cov(c).dataX(x));
    end
    fclose(fid);
end


end

    