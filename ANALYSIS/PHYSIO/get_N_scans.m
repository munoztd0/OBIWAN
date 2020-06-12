
function nscans = get_N_scans(subj, task, sess)

dbstop if error


cd ~
home = pwd;
homedir = [home '/OBIWAN/'];

param.task = task;

subjX = char(subj);
subjfuncdir=fullfile(homedir, [ 'sub-' subjX], ['ses-' sess]); % subj{i,1}

param.TR = 2.0;
param.im_format = 'nii.gz'; 
param.ons_unit = 'scans'; 
spm('Defaults','fMRI');
spm_jobman('initcfg');
im_style = 'sub'; % ['sub-'subjX '_task-'];
nscans = [];



%% define experimental design parameters
param.Cnam     = cell (length(param.task), 1);
param.duration = cell (length(param.task), 1);
param.onset = cell (length(param.task), 1);


taskX = char(param.task);
smoothfolder       = [subjfuncdir '/func'];
targetscan         = dir (fullfile(smoothfolder, [im_style '*' taskX '*' param.im_format]));

cd (smoothfolder);
V         = dir(fullfile(smoothfolder, targetscan.name));
[p,n,e]   = spm_fileparts(V(1).name);
Vn        = spm_vol(fullfile(p,[n e]));
nscans    = [nscans numel(Vn)];