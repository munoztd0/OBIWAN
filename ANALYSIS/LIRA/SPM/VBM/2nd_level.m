% List of open inputs
% Factorial design specification: Directory - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/home/davidM/OBIWAN/CODE/ANALYSIS/fMRI/SPM/VBM/2nd_level_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
