function beta_everytrial_mvpa_08(subID)

% like mvpa_03 but extracts betas on both cs and ant
% created by Logan
% last modified on JUNE 2019 by Eva  to get the beta on the onsets of the
% anticipation phase only

disp 'running beta_everytrial_mvpa_08'

cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/ANALYSIS');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

% | add spm12 to matlab path
addpath(genpath('/usr/local/external_toolboxes/spm12/'))
spm('defaults','FMRI');
spm_jobman('initcfg');

TR = 1.0; %specify TR (in secs)

% | define path

ana_name = 'MVPA-08';
subID = char(subID);

time_file_dir = fullfile(homedir,'DATA','brain','MODELS','RSA',ana_name,['sub-' subID],'glm','timing');
spm_dir       = fullfile(homedir,'DATA','brain','MODELS','RSA',ana_name,['sub-' subID],'glm','beta_everytrial_pav');
func_dir      = fullfile(homedir,'DATA','brain','cleanBIDS',['sub-' subID], 'func');
 
mkdir(spm_dir)


% | initialize batch
clear matlabbatch % Every preprocessing step needs this line
matlabbatch{1}.spm.stats.fmri_spec.dir = {spm_dir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

% | define batch

for run=1:3

    %load matlab file with regressors
    load([time_file_dir,'/' ana_name '_run-0',num2str(run),'_onsets.mat'])
    
    %get scans and concatenate scans from all runs
    run_scans = spm_select('ExtFPList', func_dir,['sub-',subID,'_task-Pavmod_run-0',num2str(run),'_nosmoothBold.nii'], Inf);
    
    %start creating matlab batch
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = cellstr([run_scans]);
    num_trials = length(onsets.ALL);
   
    %anticipation phase
    for trial=1:num_trials
        %separate regressor for each trial
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial).name = ['Trial ',num2str(trial)];
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial).onset = onsets.ALL(trial);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial).duration = durations.ALL(trial);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial).orth = 0;
    end
    
    % initalize counter for control regressors
    cmpt = 0;
    
    %US
    cmpt = cmpt+ 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).name = 'US';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).onset = onsets.US;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).duration = durations.US;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).pmod = struct('name', {}, 'param', {}, 'poly', {});
    if std(modulators.US.reward) ~= 0
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).pmod(1).name = 'Reward';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).pmod(1).param = modulators.US.reward;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).pmod(1).poly = 1;
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+1).orth = 0;
    
    %Action left
    if sum(onsets.ACTION_left) ~= 0
        cmpt = cmpt+1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).name = 'Action Left';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).onset = onsets.ACTION_left;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).duration = durations.ACTION_left;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).orth = 0;
    end
    
    %Action right
    if sum(onsets.ACTION_right) ~= 0
        cmpt = cmpt+1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).name = 'Action Right';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).onset = onsets.ACTION_right;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).duration = durations.ACTION_right;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(trial+cmpt).orth = 0;
    end
        
    %high pass filter
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf = 128;
end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';

standard_mask =  fullfile (homedir,'DATA','brain','CANONICALS','averaged_T1w_mask.nii');
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf; % set -inf if we want to use explicit masking
matlabbatch{1}.spm.stats.fmri_spec.mask = {[standard_mask,',1']}; % here enter the mask based on the subject anatomical
     
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

matlabbatch{2}.spm.stats.fmri_est.spmmat = {[spm_dir,'/SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;  

save([spm_dir,'/batch_model-',subID,'.mat'],'matlabbatch');
spm_jobman('run',matlabbatch)

end    
    