% last modified 11 janv 2015

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
analysis_name = 'EMG_BS_1000ms';
analysisdir = fullfile (physiodir, analysis_name);
run = {'R2'};
onsets = {'behavior'};

cd (physiodir)
if ~exist(analysis_name,'dir');
    mkdir(analysis_name)
end
analysis_dir = fullfile(physiodir, analysis_name);

%subj={'S10'; 'S11';'S13'; 'S14'; 'S15'; 'S16'; 'S17'; 'S18'; 'S20'; 'S21'; 'S22'; 'S23'; 'S24'; 'S25'; 'S26'};
%physioID = {'s10'; 's11'; 's13'; 's14'; 's15'; 's16'; 's17'; 's18'; 's20'; 's21'; 's22'; 's23'; 's24'; 's25'; 's26'};
subj = {'S2';'S3';'S4';'S5';'S6';'S7';'S9';'S10';'S11';'S12';'S13';'S14';'S15';'S16';'S17';'S18';'S20';'S21';'S22';'S23';'S24';'S25';'S26'};
physioID = {'s02';'s03';'s04';'s05';'s06';'s07';'s09';'s10';'s11';'s12';'s13';'s14';'s15';'s16';'s17';'s18';'s20';'s21';'s22';'s23';'s24';'s25';'s26'};
%subj = {'S2'};
%physioID = {'s02'};

%%% input variables
total_epoch = 4;
bins = 0.1;
sampling_rate = 10000;
    

for  i=1:length(physioID)
    cd (physiodir)
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
    filename = [num2str(participantID) '_clean.acq'];
    physio = load_acq(filename);%load and transform acknoledge file
    
    % ENTER VARIABLES PARAMETERS for the EVAL (run2)
    %sampling_rate = 10000;
    TR = 2.4;
    cd (rundir) % count the EPI
    EPI = dir (fullfile(rundir, 'RL*.nii'));
    num_EPI = length(EPI);
    
    corr_channel = 1;
    zyg_channel = 2;
    resp_channel = 4;
    MRI_volume = 5;
    num_channel = 4; %channels of interest
    
    %Sycronize the physiological data to the MRI session
    scanner_start = find((physio.data (:,MRI_volume)) == 5, 1 ); % First MRI volume trigger
    time_Physio = (length(physio.data (scanner_start:length(physio.data))))/sampling_rate; % The last image is acquired
    scanner_end = (num_EPI * TR) * sampling_rate;
    pyhsio_end = length(physio.data); %%% HERE INSERT THE LENGHT OF THE PHYSIO FILE we will use onsets to cut the time window
    corrEPI = physio.data (scanner_start:pyhsio_end,corr_channel); % row corr
    zygEPI = physio.data (scanner_start:pyhsio_end,zyg_channel); % row zyg
    respEPI = physio.data (scanner_start:pyhsio_end,resp_channel); % row zyg
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SEGMENT THE DATA ACCORDING TO THE ONSETS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % load the onset from the participants folder
    onsetsdir = fullfile(rundir, char(onsets)); 
    cd(onsetsdir)
    load('onsets_hedonic1.mat')
    
    % extract epoch window of interst (based on Aline's 2015 paper)
    % 1 s baseline + 4 s divided in 100 ms bins (Kentch and Wied papers)
    % compute the percentage of increase compared with the baseline
    
    % input variables
    %total_epoch = 4;
    %bins = 0.1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %A. Get all the positions
    
    %%% Chocolate
    choco_onset = round(chocolate_o*sampling_rate);
    choco_baseline = choco_onset - (1*sampling_rate); % 1 s before the the onset
    choco_total = choco_onset + (total_epoch*sampling_rate); % 4 s after onset (extract this for graphic illustrations)
    
    for ii = 1:(total_epoch/bins)
        choco_bins.(sprintf('bin%d', ii)) = choco_onset + ii*(bins*sampling_rate); % divide the 4 s in 40 bin of 100 ms and store the variables ina structure
    end
    
    %%% Neutral odor
    neutral_onset = round(neutral_o*sampling_rate);
    neutral_baseline = neutral_onset - (1*sampling_rate); % 1 s before the the onset
    neutral_total = neutral_onset + (total_epoch*sampling_rate); % 4 s after onset (extract this for graphic illustrations)
    
    for ii = 1:(total_epoch/bins)
        neutral_bins.(sprintf('bin%d', ii)) = neutral_onset + ii*(bins*sampling_rate); % divide the 4 s in 40 bin of 100 ms and store the variables ina structure
    end
    
    %%% Empty odor
    empty_onset = round(empty_o*sampling_rate);
    empty_baseline = empty_onset - (1*sampling_rate); % 1 s before the the onset
    empty_total = empty_onset + (total_epoch*sampling_rate); % 4 s after onset (extract this for graphic illustrations)
    
    for ii = 1:(total_epoch/bins)
        empty_bins.(sprintf('bin%d', ii)) = empty_onset + ii*(bins*sampling_rate); % divide the 4 s in 40 bin of 100 ms and store the variables ina structure
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %B. Use this positions to extract the signal from the channel of interest
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% zygomaticus %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Chocolate
    [choco_baseline_zyg,choco_total_zyg,choco_bins_zyg] = extractSignal(zygEPI,choco_baseline, choco_onset,choco_total,choco_bins,total_epoch,bins);
    
    %%% Neutral
    [neutral_baseline_zyg,neutral_total_zyg,neutral_bins_zyg] = extractSignal(zygEPI,neutral_baseline, neutral_onset,neutral_total, neutral_bins,total_epoch,bins);

    %%% Empty
    [empty_baseline_zyg,empty_total_zyg,empty_bins_zyg] = extractSignal(zygEPI,empty_baseline,empty_onset,empty_total, empty_bins,total_epoch,bins);

    %%%%%%%%%%%%%%%%%%%%%%%%%% corrugator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Chocolate
    [choco_baseline_corr,choco_total_corr,choco_bins_corr] = extractSignal(corrEPI,choco_baseline, choco_onset,choco_total,choco_bins,total_epoch,bins);
    
    %%% Neutral
    [neutral_baseline_corr,neutral_total_corr,neutral_bins_corr] = extractSignal(corrEPI,neutral_baseline, neutral_onset,neutral_total, neutral_bins,total_epoch,bins);

    %%% Empty
    [empty_baseline_corr,empty_total_corr,empty_bins_corr] = extractSignal(corrEPI,empty_baseline,empty_onset,empty_total, empty_bins,total_epoch,bins);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% resp belt  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    %%% Chocolate
    [choco_baseline_resp,choco_total_resp,choco_bins_resp] = extractSignal(respEPI,choco_baseline, choco_onset,choco_total,choco_bins,total_epoch,bins);
    
    %%% Neutral
    [neutral_baseline_resp,neutral_total_resp,neutral_bins_resp] = extractSignal(respEPI,neutral_baseline, neutral_onset,neutral_total, neutral_bins,total_epoch,bins);

    %%% Empty
    [empty_baseline_resp,empty_total_resp,empty_bins_resp] = extractSignal(respEPI,empty_baseline,empty_onset,empty_total, empty_bins,total_epoch,bins);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTE THE PERCENTAGE CHANGE OF THE MEAN AMPLITUDE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % derive root mean square to get the mean amplitude of the EMG
    
    time_window = bins*sampling_rate; % time_window of 100 ms (40 times in the 4 s)
   
    %%%%%%%%%%%%%%%%%%%%%%%%%% zygomaticus %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Chocolate
    [zyg_choco_pctchg_0_1s,zyg_choco_pctchg_1_2s,zyg_choco_pctchg_2_3s,zyg_choco_pctchg_3_4s] = pct_chg_rms_4s(choco_total_zyg,choco_baseline_zyg,time_window);
    zyg_choco_pctchg = [zyg_choco_pctchg_0_1s,zyg_choco_pctchg_1_2s,zyg_choco_pctchg_2_3s,zyg_choco_pctchg_3_4s];
    %%% Neutral
    [zyg_neutral_pctchg_0_1s,zyg_neutral_pctchg_1_2s,zyg_neutral_pctchg_2_3s,zyg_neutral_pctchg_3_4s] = pct_chg_rms_4s(neutral_total_zyg,neutral_baseline_zyg,time_window);
    zyg_neutral_pctchg = [zyg_neutral_pctchg_0_1s,zyg_neutral_pctchg_1_2s,zyg_neutral_pctchg_2_3s,zyg_neutral_pctchg_3_4s];
    %%% Empty
    [zyg_empty_pctchg_0_1s,zyg_empty_pctchg_1_2s,zyg_empty_pctchg_2_3s,zyg_empty_pctchg_3_4s] = pct_chg_rms_4s(empty_total_zyg,empty_baseline_zyg,time_window);
    zyg_empty_pctchg = [zyg_empty_pctchg_0_1s,zyg_empty_pctchg_1_2s,zyg_empty_pctchg_2_3s,zyg_empty_pctchg_3_4s];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% corrugator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Chocolate
    [corr_choco_pctchg_0_1s,corr_choco_pctchg_1_2s,corr_choco_pctchg_2_3s,corr_choco_pctchg_3_4s] = pct_chg_rms_4s(choco_total_corr,choco_baseline_corr,time_window);
    corr_choco_pctchg = [corr_choco_pctchg_0_1s,corr_choco_pctchg_1_2s,corr_choco_pctchg_2_3s,corr_choco_pctchg_3_4s];
    %%% Neutral
    [corr_neutral_pctchg_0_1s, corr_neutral_pctchg_1_2s,corr_neutral_pctchg_2_3s,corr_neutral_pctchg_3_4s] = pct_chg_rms_4s(neutral_total_corr,neutral_baseline_corr,time_window);
    corr_neutral_pctchg = [corr_neutral_pctchg_0_1s, corr_neutral_pctchg_1_2s,corr_neutral_pctchg_2_3s,corr_neutral_pctchg_3_4s];
    %%% Empty
    [corr_empty_pctchg_0_1s, corr_empty_pctchg_1_2s,corr_empty_pctchg_2_3s,corr_empty_pctchg_3_4s] = pct_chg_rms_4s(empty_total_corr,empty_baseline_corr,time_window);
    corr_empty_pctchg =  [corr_empty_pctchg_0_1s, corr_empty_pctchg_1_2s,corr_empty_pctchg_2_3s,corr_empty_pctchg_3_4s];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SAVE OUTPUT DATA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd (analysisdir);
    
    %save corr data
    save(num2str(['corr_choco_pctchg' subjX]), 'corr_choco_pctchg')
    save(num2str(['corr_neutral_pctchg' subjX]), 'corr_neutral_pctchg')
    save(num2str(['corr_empty_pctchg' subjX]), 'corr_empty_pctchg')
    
    %save resp data
    save(num2str(['zyg_choco_pctchg' subjX]), 'zyg_choco_pctchg')
    save(num2str(['zyg_neutral_pctchg' subjX]), 'zyg_neutral_pctchg')
    save(num2str(['zyg_empty_pctchg' subjX]), 'zyg_empty_pctchg')
    
    % resp data
    save(num2str(['resp_choco' subjX]), 'choco_total_resp')
    save(num2str(['resp_neutral' subjX]), 'neutral_total_resp')
    save(num2str(['resp_empty' subjX]), 'empty_total_resp')
   clear physio
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute overall mean and graphs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd (analysisdir)

%%% initialize variables
corr_choco = zeros ((length(subj)),(total_epoch/bins));
corr_neutral = zeros ((length(subj)),(total_epoch/bins));
corr_empty = zeros ((length(subj)),(total_epoch/bins));

zyg_choco = zeros ((length(subj)),(total_epoch/bins));
zyg_neutral = zeros ((length(subj)),(total_epoch/bins));
zyg_empty = zeros ((length(subj)),(total_epoch/bins));

resp_choco = zeros (((total_epoch*sampling_rate)+1),(length(subj)));
resp_neutral = zeros (((total_epoch*sampling_rate)+1),(length(subj)));
resp_empty = zeros (((total_epoch*sampling_rate)+1),(length(subj)));

for i = 1:length(subj)
    
     subjX=subj(i,1);
     subjX=char(subjX);
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%% corrugator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     name = ['corr_choco_pctchg' (subjX) '.mat'];
     load (name);
     corr_choco (i,:) = corr_choco_pctchg;
     m_corr_choco = mean(corr_choco,1);% mean across participants
     std_corr_choco = std(corr_choco,0,1);% std across participants
     sem_corr_choco = std_corr_choco/(sqrt(i)); %non adapted within SEM
     
     name = ['corr_neutral_pctchg' (subjX) '.mat'];
     load (name);
     corr_neutral (i,:) = corr_neutral_pctchg;
     m_corr_neutral = mean (corr_neutral,1);
     std_corr_neutral = std (corr_neutral,0,1);
     sem_corr_neutral = std_corr_neutral/(sqrt(i)); %non adapted within SEM
     
     name = ['corr_empty_pctchg' (subjX) '.mat'];
     load (name);
     corr_empty (i,:) = corr_empty_pctchg;
     m_corr_empty = mean (corr_empty,1);
     std_corr_empty = std (corr_empty,0,1);
     sem_corr_empty = std_corr_empty/(sqrt(i)); %non adapted within SEM
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%% zygmaticous %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     name = ['zyg_choco_pctchg' (subjX) '.mat'];
     load (name);
     zyg_choco (i,:) = zyg_choco_pctchg;
     m_zyg_choco = mean(zyg_choco,1);% mean across participants
     std_zyg_choco = std(zyg_choco,0,1);% std across participants
     sem_zyg_choco = std_zyg_choco/(sqrt(i)); %non adapted within SEM
     
     name = ['zyg_neutral_pctchg' (subjX) '.mat'];
     load (name);
     zyg_neutral (i,:) = zyg_neutral_pctchg;
     m_zyg_neutral = mean (zyg_neutral,1);
     std_zyg_neutral = std (zyg_neutral,0,1);
     sem_zyg_neutral = std_zyg_neutral/(sqrt(i)); %non adapted within SEM
     
     name = ['zyg_empty_pctchg' (subjX) '.mat'];
     load (name);
     zyg_empty (i,:) = zyg_empty_pctchg;
     m_zyg_empty = mean (zyg_empty,1);
     std_zyg_empty = std (zyg_empty,0,1);
     sem_zyg_empty = std_zyg_empty/(sqrt(i));
     %%%%%%%%%%%%%%%%%%%%%%%%%%% respiration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     name = ['resp_choco' (subjX) '.mat'];
     load (name);
     resp_choco (:,i) = choco_total_resp;
     m_resp_choco = mean(resp_choco,2);% mean across participants
     std_resp_choco = std(resp_choco,0,2);% std across participants
     sem_resp_choco = std_resp_choco/(sqrt(i));
     
     name = ['resp_neutral' (subjX) '.mat'];
     load (name);
     resp_neutral (:,i) = neutral_total_resp;
     m_resp_neutral = mean(resp_neutral,2);% mean across participants
     std_resp_neutral = std(resp_neutral,0,2);% std across participants
     sem_resp_neutral = std_resp_neutral/(sqrt(i));
     
     name = ['resp_empty' (subjX) '.mat'];
     load (name);
     resp_empty (:,i) = empty_total_resp;
     m_resp_empty = mean(resp_empty,2);% mean across participants
     std_resp_empty = std(resp_empty,0,2);% std across participants
     sem_resp_empty = std_resp_empty/(sqrt(i));
      
end

% plot graph


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% respiration  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
title('Breathing Waveform');
xlabel ('Time')
ylabel ('Amplitude')

u = 1:length(m_resp_choco);
[hl,~] = boundedline(u,m_resp_empty',sem_resp_empty,':k','alpha','transparency',0.1);
set(hl,'LineWidth',2);

[hl1,~] =boundedline(u,m_resp_neutral',sem_resp_neutral,'--b','alpha','transparency',0.1);
set(hl1,'LineWidth',2,'Color',[0.1 0.1 0.80]);

[hl3,~]= boundedline(u,m_resp_choco',sem_resp_choco,'-r','alpha','transparency',0.1);
set(hl3,'LineWidth', 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% corrugator  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
o = 1:length(m_corr_choco);
figure
title('Increase of Percentage (1s baseline) of the Corrugator');
xlabel ('Time (100ms bins)')
ylabel ('Percentage of Change')

[hl4,~] = boundedline(o,m_corr_empty,sem_corr_empty,':b','alpha','transparency',0.1);
set(hl4,'LineWidth',2);

[hl5,~] = boundedline(o,m_corr_neutral,sem_corr_neutral,'--b','alpha','transparency',0.1);
set(hl5,'LineWidth',2,'Color',[0.1 0.1 0.80]);

[hl6,~] = boundedline(o,m_corr_choco,sem_corr_choco,'-r','alpha','transparency',0.1);
set(hl6,'LineWidth', 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% zygomaticus  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
o = 1:length(m_zyg_choco);
figure
title('Increase of Percentage (1s baseline) of the Zygomaticus');
xlabel ('Time (100ms bins)')
ylabel ('Percentage of Change')

[hl7,~] = boundedline(o,m_zyg_empty,sem_zyg_empty,':b','alpha','transparency',0.1);
set(hl7,'LineWidth',2);

[hl5,~] = boundedline(o,m_zyg_neutral,sem_zyg_neutral,'--b','alpha','transparency',0.1);
set(hl5,'LineWidth',2,'Color',[0.1 0.1 0.80]);

[hl6,~] = boundedline(o,m_zyg_choco,sem_zyg_choco,'-r','alpha','transparency',0.1);
set(hl6,'LineWidth', 2);