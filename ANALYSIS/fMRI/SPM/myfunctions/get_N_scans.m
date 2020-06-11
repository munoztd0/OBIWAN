
function nscans = get_N_scans(subj, task)

cd ~
home = pwd;
homedir = [home '/REWOD/'];

param.task = task;

funcdir  = fullfile(homedir, '/DERIVATIVES/PREPROC');% directory with  post processed functional scans

subjX = char(subj);
subjfuncdir=fullfile(funcdir, [ 'sub-' subjX], 'ses-second'); % subj{i,1}

param.TR = 2.4;
param.im_format = 'nii'; 
param.ons_unit = 'scans'; 
spm('Defaults','fMRI');
spm_jobman('initcfg');
im_style = 'sub'; % ['sub-'subjX '_task-'];
nscans = [];



%% define experimental design parameters
param.Cnam     = cell (length(param.task), 1);
param.duration = cell (length(param.task), 1);
param.onset = cell (length(param.task), 1);

ses = 1;

taskX = char(param.task(ses));
smoothfolder       = [subjfuncdir '/func'];
targetscan         = dir (fullfile(smoothfolder, [im_style '*' taskX '*' param.im_format]));
tmp{ses}           = spm_select('List',smoothfolder,targetscan.name);

cd (smoothfolder);
V         = dir(fullfile(smoothfolder, targetscan.name));
[p,n,e]   = spm_fileparts(V(1).name);
Vn        = spm_vol(fullfile(p,[n e]));
nscans    = [nscans numel(Vn)];