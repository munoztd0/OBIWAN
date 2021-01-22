% List of open inputs
% Factorial design specification: Levels - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'/Users/davidmunoz/OBIWAN/CODE/ANALYSIS/fMRI/HED/full_fact_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Levels - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
