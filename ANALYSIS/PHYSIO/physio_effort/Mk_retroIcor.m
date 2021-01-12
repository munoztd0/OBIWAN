% Script that executes pulse oximetry (PPU) 3T GE logfiles.
%
%
% Note:
% - This is the input script to the PhysIO toolbox. Only this file has to be adapted for your study.
% - For documentation of any of the defined substructures here, please
% see also tapas_physio_new.m or the Manual_PhysIO-file.
%
% Copyright (C) 2013, Institute for Biomedical Engineering, ETH/Uni Zurich.
%
% This file is part of the PhysIO toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.
%%
% INFORMATION FOR MYSELF (EVA) ATTENTION: 
% for run 1 the physiologogy of participants 18 and 22 and for run 2 for participant 1 stopped
% before the end of last TR. Thus I have computed the same script but with
% Nscan = Nscan -1 and them manually added an empty line to their multiple
% regrssors text file
%%
tic
clear all
% This File has been adapted by Eva on the 14.04.2015 from: example_main_PPU_GE.m 645 2015-01-15 20:41:00Z kasperla $
% and then changed again 
MRIdir = '/Volumes/LaCie/Dropbox/REWOD/REWOD/DATA/Brain/Population/subcor_norm/Apply_DispFields';
run = {'R2'}; 
home = pwd;
%subj={'S1';'S2';'S3'; 'S4'; 'S5'; 'S6'; 'S7'; 'S9'; 'S10'; 'S11'; 'S12';'S13'; 'S14'; 'S15'; 'S16'; 'S17'; 'S18'; 'S20'; 'S21'; 'S22'; 'S23'; 'S24'; 'S25'; 'S26'};
subj={'S15'};


%% 0. Put code directory into path; for some options, SPM should also be in the path
%pathRETROICORcode = fullfile(fileparts(mfilename('/Users/admin/spm12/toolbox/TAPAS physIO toolbox/PhysIO/code')), ...
%    '../../../code');
pathRETROICORcode = '/Users/evapool/Documents/programs/MATLAB/spm12/toolbox/PhysIO';

addpath(genpath(pathRETROICORcode));

physio      = tapas_physio_new();
log_files   = physio.log_files;
%thresh      = physio.thresh;
%sqpar       = physio.sqpar;
model       = physio.model;
verbose     = physio.verbose;

for  i=1:length(subj)
    subjX=subj(i,1);
    subjX=char(subjX); % subj{i,1}
    subjdir=fullfile(MRIdir, subjX); % subj{i,1}
    rundir = fullfile(subjdir, char(run)); % run
    run1 = cell2mat(strfind (run, 'R1')); % some input variables change from run 1 to run 2
    
    fprintf('participant number: %s \n', subj{i})
    %% 0. Preliminary down sampling
    cardiac = 'heartEPI_';
    resp = 'respEPI_';
    if run1
        % do not down sample
    else
        cd (rundir)
        % down sample to 500 hz the original file that are sampled at
        % 10'000 hz
        load ([cardiac, subjX]);
        load ([resp, subjX]);
        
        respEPI = downsample (respEPI, 20); %reduce of 20 time the number of measures
        heartEPI = downsample (heartEPI, 20);
        
        save (['drespEPI_' subjX '.mat'], 'respEPI');% remplace the old file with the new one
        save (['dheartEPI_' subjX '.mat'], 'heartEPI');
        
        save (['drespEPI_' subjX '.txt'], 'respEPI', '-ascii');% r
        save (['dheartEPI_' subjX '.txt'], 'heartEPI', '-ascii');
        cardiac = 'dheartEPI_'; % select the downloaded sample for the rest of the analysis
        resp = 'drespEPI_';

        cd (home)
    end
    
   
    %% 1. Define Input Files
    
    log_files.vendor = 'custom';
    
    % Simple case
    %log_files.cardiac           = 'heartEPI_S14.txt';
    %log_files.cardiac           = [cardiac, subjX]; %%%
    log_files.cardiac           = [cardiac, subjX, '.txt']; %%%
    %log_files.respiration       = 'respEPI_S14.txt';
    %log_files.respiration       = [resp, subjX]; %%%%%%
    log_files.respiration       = [resp, subjX, '.txt'];
    
    log_files.align_scan        = 'first'; % align the regressor to the first scan (to the scanner trigger in our case as done in hte compute_InputVar file)
    log_files.sampling_interval = 20e-4; % 1 / the sampeling frequence (number of measure per 1 s)
   
    
    %% 2. Define Nominal Sequence Parameter (Scan Timing)
    
    % 2.1. Counting scans and dummy volumes from end of run, i.e. logfile
    sqpar.Nslices           = 26;
    sqpar.NslicesPerBeat    = 26;% typically equivalent to Nslices; exception: heartbeat-triggered sequence
    sqpar.TR                = 2.400;
    sqpar.Ndummies          = 0;
    cd (rundir)
    nscans= dir (fullfile(rundir, 'RL*.nii'));
    cd (home)
    sqpar.Nscans = length(nscans);
    sqpar.onset_slice = 13; %%EVA: I do not understand this parametr at all %default: Nslices/2; reference slice for timing within a volume; slice whose scan onset determines the adjustment of theregressor timing to a particular slice for the whole volum
    sqpar.time_slice_to_slice = sqpar.TR/sqpar.Nslices; % equidistant slice spacing
    sqpar.Nprep = 0; % start counting from beginning, not end of file
    
    
    %% 3. Order of RETROICOR-expansions for cardiac, respiratory and
    %% interaction terms. Option to orthogonalise regressors
    
    model.type = 'RETROICOR'; % 'RETROICOR';
    % model.type = 'RETROICOR+HRV+RVT'; % 'RETROICOR';
    model.retroicor.order = struct('c',3,'r',4,'cr',1, 'orthogonalise', 'none');
    model.input_other_multiple_regressors = ''; % either txt-file or mat-file with variable R
    model.output_multiple_regressors = 'multiple_regressors.txt';
    
    %% 4. Define Gradient Thresholds to Infer Gradient Timing (Philips only)
    thresh.scan_timing.method = 'nominal';
    physio.scan_timing.sync.method = 'nominal';
    
    %% 5. Define which Cardiac Data Shall be Used
    
    %% 4.1. Using plethysmograph curve with peak thresholding
    thresh.cardiac.modality = 'OXY'; % 'ECG' or 'OXY' (for pulse oximetry)
    physio.preproc.cardiac.modality = 'OXY';
    thresh.cardiac.initial_cpulse_select.min = 0.4;
    physio.preproc.cardiac.initial_cpulse_select.min = 0.4;
    thresh.cardiac.initial_cpulse_select.method = 'auto_matched';
    physio.preproc.cardiac.initial_cpulse_select.method = 'auto_matched';
    
    %% 6. Output Figures to be generated
    
    verbose.level = 2;
    % 0 = none;
    % 1 = main plots (default);
    % 2 = debugging plots: for missed slice/volume events, missed heartbeats, 1D time series of created regressors
    % 3 = all plots, incl. cardiac/respiratory phase estimation,
    %     slice-to-volume assignment
    verbose.fig_output_file = 'PhysIO_output.fig';
    
    %% 7. Run the main script with defined parameters
    
    physio.log_files                     = log_files;
    physio.thresh                        = thresh;
    physio.scan_timing.sqpar             = sqpar;
    physio.model                         = model;
    physio.verbose                       = verbose;
    
    cd (rundir)
    %cd ('/Users/evapool/Desktop/')
    [physio_out, R, ons_secs] = tapas_physio_main_create_regressors(physio);
    processing_time = toc;
    fprintf ('processing time: %s, secs \n', processing_time);
    cd(home)
end