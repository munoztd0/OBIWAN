function beta_mvpa_04(subID)

% like mvpa_04
% last modified on JUNE 2020 by David

disp 'running beta_everytrial_mvpa_01'


%subID = {'01'}; 

cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/ANALYSIS');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');


addpath('/usr/local/external_toolboxes/spm12/');



%% specify fMRI parameters
param.TR = 2.4;
param.im_format = 'UnsmoothedBold.nii'; 
param.ons_unit = 'secs'; 
spm('Defaults','fMRI');
spm_jobman('initcfg');
addpath(genpath('/usr/local/external_toolboxes/spm12/'))


% | define path

ana_name          = 'MVPA-04';
task          = {'hedonic'};
subID = char(subID);

in_dir = fullfile(homedir,'DERIVATIVES','ANALYSIS','MVPA','hedonic',ana_name,['sub-' subID],'timing');
out_dir       = fullfile(homedir,'DERIVATIVES','ANALYSIS','MVPA','hedonic',ana_name,['sub-' subID],'output');
%func_dir      = fullfile(homedir,'DATA','brain','cleanBIDS',['sub-' subID], 'func');
func_dir  = fullfile(homedir, '/DERIVATIVES/PREPROC', [ 'sub-' subID], 'ses-second', 'func');
mkdir(out_dir)


% | initialize batch
clear matlabbatch % Every preprocessing step needs this line
%matlabbatch{1}.spm.stats.fmri_spec.dir = {out_dir};
%matlabbatch{1}.spm.stats.fmri_spec.timing.units = param.ons_unit;
%matlabbatch{1}.spm.stats.fmri_spec.timing.RT = param.TR;
%matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
%matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;


% | define batch

ses = 1;
taskX = char(task);
im_style = 'sub';
nscans = [];
scanID = [];

%load matlab file with regressors
load([in_dir,'/' ana_name '_task-' taskX '_onsets.mat'])

%get scans and concatenate scans from All runs
%run_scans = spm_select('ExtFPList', func_dir,['sub-',subID,'_task-Pavmod_run-0',num2str(run),'_nosmoothBold.nii'], Inf);

targetscan    = dir (fullfile(func_dir, [im_style '*' taskX '*' param.im_format]));
tmp           = spm_select('List',func_dir,targetscan.name);


cd (func_dir);
V         = dir(fullfile(func_dir, targetscan.name));
[p,n,e]   = spm_fileparts(V(1).name);
Vn        = spm_vol(fullfile(p,[n e]));
nscans    = [nscans numel(Vn)];

for j = 1:nscans(ses)
    scanID    = [scanID; {[func_dir,'/', V.name, ',', num2str(j)]}];
end


SPM.xY.P    = char(scanID); %matlabbatch{1}.spm.stats.fmri_spec.sess(ses).scans = cellstr([ses_scans]);
SPM.nscan   = nscans;
%start creating matlab batch

num_trials = length(onsets.All);

%anticipation phase
for t=1:num_trials
    %separate regressor for each trial
    SPM.Sess(ses).U(t).name = {['Trial ',num2str(t)]};
    SPM.Sess(ses).U(t).ons = onsets.All(t);
    SPM.Sess(ses).U(t).dur = durations.All(t);
    %matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(t).tmod = 0;
    %matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(t).pmod = struct('name', {}, 'param', {}, 'poly', {});
    SPM.Sess(ses).U(t).orth = 0; %no ortho!!
    SPM.Sess(ses).U(t).P(1).name = 'none';
    % if std(modulators.US.reward) ~= 0
%     matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(t+cmpt).pmod(1).name = 'Reward';
%     matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(t+cmpt).pmod(1).param = modulators.US.reward;
%     matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(t+cmpt).pmod(1).poly = 1;
%     end
    
end

cd (fullfile(out_dir));
% initalize counter for control regressors
%cmpt = 0;

%trialstart
t = t + 1;
SPM.Sess(ses).U(t).name = {'trialstart'};
SPM.Sess(ses).U(t).ons = onsets.trialstart;
SPM.Sess(ses).U(t).dur = durations.trialstart;
SPM.Sess(ses).U(t).orth = 0; %no ortho!!
SPM.Sess(ses).U(t).P(1).name = 'none'; 


%liking
t = t + 1;
SPM.Sess(ses).U(t).name = {'q_liking'};
SPM.Sess(ses).U(t).ons = onsets.liking;
SPM.Sess(ses).U(t).dur = durations.liking;
SPM.Sess(ses).U(t).orth = 0; %no ortho!!
SPM.Sess(ses).U(t).P(1).name = 'none'; 

%liking
t = t + 1;
SPM.Sess(ses).U(t).name = {'q_intensity'};
SPM.Sess(ses).U(t).ons = onsets.intensity;
SPM.Sess(ses).U(t).dur = durations.intensity;
SPM.Sess(ses).U(t).orth = 0; %no ortho!!
SPM.Sess(ses).U(t).P(1).name = 'none'; 

        
%high pass filter
SPM.xX.K(1).HParam = 128;

% basis functions and timing parameters

% OPTIONS: TR in seconds
%--------------------------------------------------------------------------
SPM.xY.RT          = param.TR;

% OPTIONS: % 'hrf (with time derivative)'
%--------------------------------------------------------------------------
SPM.xBF.name       = 'hrf';

% OPTIONS: % 2 = hrf (with time derivative)
%--------------------------------------------------------------------------
SPM.xBF.order      = 1;

% OPTIONS: % length in seconds
%--------------------------------------------------------------------------
SPM.xBF.length     = 0;


SPM.Sess(ses).C.C = [];
SPM.Sess(ses).C.name = {};


% matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
% matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
% matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
% matlabbatch{1}.spm.stats.fmri_spec.global = 'None';

% set threshold of mask!!
%==========================================================================
%SPM.xM.gMT = -Inf;%!! set -inf if we want to use explicit masking 0.8 is the spm default
Maskimage =  fullfile (homedir,'DERIVATIVES','PREPROC', ['sub-' subID],'ses-second', 'anat', ['sub-' subID '_ses-second_run-01_T1w_reoriented_brain_mask.nii']);
SPM.xM.gMT =  0.1;%!! NOPE set -inf if we want to use explicit masking 0.8 is the spm default
SPM.xM.VM  =  spm_vol(Maskimage);
SPM.xM.I   =  0.1;
%matlabbatch{1}.spm.stats.fmri_spec.mask = {[standard_mask,',1']}; % here enter the mask based on the subject anatomical
     
 % OPTIONS: microtime time resolution and microtime onsets (this paramter
% should not be change according to the spm 12 manual (unless very long TR)
%-------------------------------------------------------------------------
%         V  = spm_vol(SPM.xY.P(1,:));
%         if iscell(V)
%             nslices = V{1}{1}.dim(3);
%         else
%             nslices = V(1).dim(3);
%         end
%         ref_slice          = floor(nslices/2);  % middle slice in time
%         SPM.xBF.T          = nslices;           % do not change unless long TR (spm12 manual)
%         SPM.xBF.T0         = ref_slice;		    % middle slice/timebin          % useless? cf. defaults above
%
% OPTIONS: 'scans'|'secs' for onsets
%--------------------------------------------------------------------------
SPM.xBF.UNITS      = param.ons_unit;

% % OPTIONS: 1|2 = order of convolution: du haut--> bas t?te ou l'inverse
%--------------------------------------------------------------------------
SPM.xBF.Volterra   = 1;

% global normalization: OPTIONS:'Scaling'|'None'
%--------------------------------------------------------------------------
SPM.xGX.iGXcalc    = 'None';

% low frequency confound: high-pass cutoff (secs) [Inf = no filtering]
%--------------------------------------------------------------------------
SPM.xX.K(1).HParam = 128;

% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
%--------------------------------------------------------------------------
SPM.xVi.form       = 'AR(1)'; 

% specify SPM working dir for this sub
%==========================================================================
SPM.swd = pwd;

% matlabbatch{2}.spm.stats.fmri_est.spmmat = {[out_dir,'/SPM.mat']};
% matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
% matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;  

% Configure design matrix
%==========================================================================
SPM = spm_fmri_spm_ui(SPM);

% Estimate parameters
%==========================================================================
disp ('estimating model')


SPM = spm_spm(SPM);

disp ('first level done');
% save([out_dir,'/batch_model-',subID,'.mat'],'SPM');
% spm_jobman('run',SPM)

end    
    