
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTING DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setting the path
computerpath = '/Volumes/LaCie/Dropbox';
MRIdir = '/REWOD/REWOD/DATA/Brain/Population/subcor_norm/Apply_DispFields';
MRIdir = fullfile (computerpath,MRIdir);
physiodir = '/REWOD/REWOD/DATA/Physiology';
physiodir = fullfile (computerpath, physiodir);
popdir = '/REWOD/REWOD/DATA/Brain/Population/subcor_norm/Apply_DispFields/';
popdir = fullfile (computerpath,popdir);
analysis_name = 'EMG';
run = {'R2'};
onsets = {'behavior'};

cd (physiodir)
if ~exist(analysis_name,'dir');
    mkdir(analysis_name)
end
analysis_dir = fullfile(physiodir, analysis_name);

%subj={'S10'; 'S11';'S13'; 'S14'; 'S15'; 'S16'; 'S17'; 'S18'; 'S20'; 'S21'; 'S22'; 'S23'; 'S24'; 'S25'; 'S26'};
%physioID = {'s10'; 's11'; 's13'; 's14'; 's15'; 's16'; 's17'; 's18'; 's20'; 's21'; 's22'; 's23'; 's24'; 's25'; 's26'};
subj = {'S2'};
physioID = {'s02'};


for  i=1:length(physioID)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % EXTRACT AND SYNC THE DATA FROM THE ACQ FILE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % bulid path for the participant
    subjX=subj(i,1);
    subjX=char(subjX); % subj{i,1}
    physioIDX = physioID (i,1);
    physioIDX = char(physioIDX);
    physioRunID = '_EVAL';
    participantID = [physioIDX,physioRunID];
    subjdir=fullfile(MRIdir, subjX); % subj{i,1}
    rundir = fullfile(subjdir, char(run)); % run{k}
    
    % load acq file (attention this takes time)
    filename = [num2str(participantID) '.acq'];
    physio = load_acq(filename);%load and transform acknoledge file
    
    % ENTER VARIABLES PARAMETERS for the EVAL (run2)
    sampling_rate = 10000;
    TR = 2.4;
    cd (rundir) % count the EPI
    EPI = dir (fullfile(rundir, 'RL*.nii'));
    num_EPI = length(EPI);
    
    corr_channel = 1;
    zyg_channel = 2;
    MRI_volume = 5;
    num_channel = 3; % N of channels of interest
    
    %Sycronize the physiological data to the MRI session
    scanner_start = find((physio.data (:,MRI_volume)) == 5, 1 ); % First MRI volume trigger
    time_Physio = (length(physio.data (scanner_start:length(physio.data))))/sampling_rate; % The last image is acquired
    scanner_end = (num_EPI * TR) * sampling_rate;
    physio_end = length(physio.data); %%% HERE INSERT THE LENGHT OF THE PHYSIO FILE we will use onsets to cut the time window
    corrEPI = physio.data (scanner_start:physio_end,corr_channel); % row corr
    zygEPI = physio.data (scanner_start:physio_end,zyg_channel); % row zyg
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HIGH PASS FILTER 30 Hz
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %digitally high-pass filtered at 30 Hz using a least-square FIR (finite impulse response)
    % filter (24 dB/Oct, created using the firls function in Matlab)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INSERT SLICE ONSET MARKERS IN THE EMG DATA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % UPSAMPLE DATA WITH AN INTRAPOLATION OF 10 (up to 20.48kHz)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % APPLY FARM
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DOWM SAMPLE 10
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % LOW PASS 250 HZ
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
end
