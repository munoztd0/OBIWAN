function covariate(task, name_ana, name_soft, covariateNames)

% intended for REWOD hedonic reactivity GROUP X COND
% 2nd level behavioral covariate demeaned by groups
% last modified on July 2020 by David Munoz

%variables
task = 'hedonicreactivity';
name_ana = 'GLM-01_HW'; % output folder for this analysis
name_soft = 'SPM'; % output folder for this analysis
covariateNames = {'rew_lik_HW'; 'neu_lik_HW'}; %'con_int';'age_cov'; 'bmi_cov'}; %9
%covariateNames = {'bmi_cov'}; %; 'age_cov'}; %9
conImage = {'con_0001'; 'con_0002'};
group = 'control';
dbstop if error
%does t-test and full_factorial


%% define path

cd ~
home = pwd;
homedir = [home '/OBIWAN'];


mdldir   = fullfile (homedir, '/DERIVATIVES/GLM/', name_soft, task);% mdl directory (timing and outputs of the analysis)
covdir   = fullfile (homedir, 'DERIVATIVES/GLM/SPM/hedonicreactivity/covariates/T0'); % director with the extracted second level covariates
groupdir = fullfile (mdldir,name_ana);
%/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/covariates/T0

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
conImageX = 'con_0001'; %any of them would work actually


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
    cov(c).int = C.data(:,3);
    cov(c).fam = C.data(:,4);

    l = 0; %lag
    s = 1;
    fileX = dir ([groupdir '/group/*' conImageX '*.nii' ]);
    while s < length(fileX) +1
        t = s + l;
        if contains(fileX(s).name, num2str(cov(c).ID(t)))
            cov(c).IDX(s)      = cov(c).ID(t);
            cov(c).dataX(s)     =  cov(c).data(t);
            s = s+1;
        else
            l = l+1; %skip this line
        end
    end
      
    cd(covdir)
    fid = fopen([covariateNames{c} '_clean.txt'],'w');
    for x = 1:length(cov(c).dataX)
        fprintf(fid,'%.2f\n',cov(c).dataX(x));
    end
    fclose(fid);

   contrastX =  conImage{c};
   for i = 1:length(cov(c).IDX)
       cd(groupdir)
       o = dir(['*' num2str(cov(c).IDX(i))]);
       cd([o.name '/output'] )
       HeaderInfo = spm_vol([pwd '/' contrastX '.nii']);
       vol = spm_read_vols(HeaderInfo);
       cof = vol .* cov(c).dataX(i);
       idx = 5 + c;
       cd([groupdir '/group/'])
       HeaderInfo.fname = ['sub-' group '-' num2str(cov(c).IDX(i)) '_con_000' num2str(idx) '.nii'];  % This is where you fill in the new filename
       HeaderInfo.private.dat.fname = HeaderInfo.fname;
       spm_write_vol(HeaderInfo,cof);    
       display(['done' num2str(cov(c).IDX(i))])
   end   
end


end

    