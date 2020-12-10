function covariate(task, name_ana, name_soft, covariateNames, remove)

% intended for REWOD hedonic reactivity GROUP X COND
% 2nd level behavioral covariate demeaned by groups
% last modified on July 2020 by David Munoz

%variables
task = 'hedonicreactivity';
name_ana = 'GLM-01_OB'; % output folder for this analysis
name_soft = 'SPM'; % output folder for this analysis
covariateNames = {'rew_lik'; 'con_lik'}; %'con_int';'age_cov'; 'bmi_cov'}; %9
%covariateNames = {'bmi_cov'}; %; 'age_cov'}; %9
conImage = {'con_0001'; 'con_0002'};
remove = 0;
cova = 1;
group = 0;

dbstop if error
%does t-test and full_factorial

%removesub = {'sub-23'} ;
%removedsub = 'no variance neutral';


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
conImageX = 'con-0001'; %any of them would work actually


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
    if group
        if contains(covariateX, 'bmi') 
            for i = 1:length(cov(c).dataX)
                cd([groupdir '/group/'])
                bmi = cov(c).dataX(i);
                if bmi >= 25 && bmi < 35
                    fileX = dir(['*' num2str(cov(c).IDX(i)) '*.nii' ]);
                    for ii = 1:length(fileX)
                        name = ['sub-obeseL_' num2str(cov(c).IDX(i)) '_con-000' num2str(ii) '.nii'];
                        movefile(fileX(ii).name, name)
                    end
                elseif bmi >= 35 
                    fileX = dir(['*' num2str(cov(c).IDX(i)) '*.nii' ]);
                    for ii = 1:length(fileX)
                        name = ['sub-obeseH_' num2str(cov(c).IDX(i)) '_con-000' num2str(ii) '.nii'];
                        movefile(fileX(ii).name, name)
                    end
                end
            end         
        end
    end
    %x =cov(c).dataX == 0
    %sum(double(x))
    msg = 'Error occurred.';
    if contains(covariateX, 'hw') 
        x = dir ([groupdir '/group/*control*' conImageX '*.nii' ]);
        sizeHW = length(x);
        meanHW = mean(cov(c).dataX(1:sizeHW));
        cov(c).dataX(1:sizeHW) = cov(c).dataX(1:sizeHW) - meanHW;
        if  0.01 < abs(mean(cov(c).dataX(end-sizeHW+1:end)));
            error(msg)
        end
    elseif contains(covariateX, 'ob')   
        x = dir ([groupdir '/group/*control*' conImageX '*.nii' ]);
        sizeOB = length(x);
        meanOB = mean(cov(c).dataX(end-sizeOB+1:end));
        cov(c).dataX(end-sizeOB+1:end) = cov(c).dataX(end-sizeOB+1:end) - meanOB; 
        if  0.01 < abs(mean(cov(c).dataX(end-sizeOB+1:end)));
            error(msg)
        end
    else
        if group
            if ~contains(covariateX, 'bmi')  
                meanX = mean(cov(c).dataX);
                cov(c).dataX = cov(c).dataX - meanX; 
                if  0.01 < abs(mean(cov(c).dataX));
                    error(msg)
                end
            end
        else
            meanX = mean(cov(c).dataX);
            cov(c).dataX = cov(c).dataX - meanX; 
            if  0.01 < abs(mean(cov(c).dataX));
                error(msg)
            end
        end
    end
      
    cd(covdir)
    fid = fopen([covariateNames{c} '_clean.txt'],'w');
    for x = 1:length(cov(c).dataX)
        fprintf(fid,'%.2f\n',cov(c).dataX(x));
    end
    fclose(fid);
    
    if cova 
        if contains(covariateX, 'rew')  || contains(covariateX, 'con')
           contrastX =  conImage{c};
           for i = 1:length(cov(c).IDX)
               cd(groupdir)
               o = dir(['*' num2str(cov(c).IDX(i))]);
               cd([o.name '/output'] )
               HeaderInfo = spm_vol([pwd '/' contrastX '.nii']);
               vol = spm_read_vols(HeaderInfo);
               cof = vol .* cov(c).dataX(i);
               idx = 5 + c;
               HeaderInfo.fname = ['con_000' num2str(idx) '.nii'];  % This is where you fill in the new filename
               HeaderInfo.private.dat.fname = HeaderInfo.fname;
               spm_write_vol(HeaderInfo,cof);
           end   
        end 
    end
end


end

    