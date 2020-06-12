function eff_regressor(subID)

% Create physiological regressors

% comment to my dataset: atttention participants 12 and 10 14 16 need to be
% processed by their own because the physiology stops slighlty before the
% end of the last EPI acquisition

task = 'PIT';
session = 'second';

%clc

dbstop if error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTING THE PATH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define paths

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

%subj   = subID;
%subj = {'02'};


physiodir   = fullfile(homedir, '/SOURCEDATA/physio');
outdir = fullfile(homedir, '/DERIVATIVES/PHYSIO');
addpath([homedir  '/CODE/ANALYSIS/PHYSIO'])
addpath(genpath('/usr/local/MATLAB/R2018a/eeglab'))
run = {'*task-PIT_run-01_bold.nii.gz'}; %PIT

%subj={subID};
subj={'control100'};%;'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26';}; %subID;
%physioID = {'s11'; 's13'; 's14'; 's15'; 's16'; 's17'; 's18'; 's20'; 's21'; 's22'; 's23'; 's24'; 's25'; 's26''s10'; 's11'; 's13'; 's14'; 's15'; 's16'; 's17'; 's18'; 's20'; 's21'; 's22'; 's23'; 's24'; 's25'; 's26'};
%10';'12';'14'; '16';


for i=1:length(subj)
    subjX = subj{i,1};
    subjX=char(subjX); % subj{i,1}
   
    
    fprintf('participant number: %s \n', subj{i})
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % OPEN FILE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subjdir = fullfile(physiodir, subj{1}, ['ses-' session]);
    cd (subjdir)
    
    file = dir('*.acq');
    %physio = load_acq(file.name); %load and transform acknoledge file
    rundir = fullfile(homedir, 'ses-second','func'); % run{k}
    %nouveau canal = (CH28x1+CH29x2+CH30x4+CH31x8+CH32x16+CH33x32+CH34x64)/5
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SET PARAMETERS ACCORDING TO THE SCANNER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    % ENTER VARIABLES PARAMETERS for the PIT
    sampling_rate = 500; % number of measures per sec
    TR = 2;
%     EPI1 = get_N_scans(subj{1}, 'instrumentallearning', session);
%     EPI2 = get_N_scans(subj{1}, 'pavlovianlearning', session);
%     EPI3 = get_N_scans(subj{1}, 'PIT', session);
%     EPI4 = get_N_scans(subj{1}, 'hedonicreactivity', session);
%     
    grip_channel = 4; %
    suck_channel = 5; %ACC1-z
    MRI_volumeALL = 13; %??
    MRI_volumeHED = 9; %?? HED
    %num_channel = 4; %channels of interest ??


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % EXTRACT SIGNAL FOR TAPAS TOOLBOX AND SAVE INPUT VARIABLES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Sycronize the physiological data to the MRI session %not two 5 in X (sampling rate * TR) 
    start_1 = find((physio.data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger start_INST = find((physio.data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
    end_4 = find((physio.data (:,MRI_volumeALL)) == 5, 1, 'last'); % First MRI volume trigger start_INST = find((physio.data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
    %(CH28x1+CH29x2+CH30x4+CH31x8+CH32x16+CH33x32+CH34x64)/5
    nouveau_canal = (physio.data (:,6)*1+physio.data (:,7)*2+physio.data (:,8)*4+physio.data (:,9)*8+physio.data (:,10)*16+physio.data (:,11)*32+physio.data (:,12)*64+physio.data (:,13)*128)/5;
    %nouveau_canal = (physio.data (:,6)+physio.data (:,7)+physio.data (:,8)+physio.data (:,9)+physio.data (:,10)+physio.data (:,11)+physio.data (:,12))/5;

    %remove useless parts
    %physio.data = physio.data (start_1:end_4,:);
    
    time_1 = (EPI1 * TR) * sampling_rate;
    time_2 = (EPI2 * TR) * sampling_rate;
    time_3 = (EPI3 * TR) * sampling_rate;
    time_4 = (EPI4 * TR) * sampling_rate;
    
    
    %cut cut cut
    
    physio1.data = physio.data (start_1:start_1+time_1+1000,:);
    

    pyhsio_end = length(physio.data); %%% HERE INSERT THE LENGHT OF THE PHYSIO FILE: Physiotoolbox will calculate the exact length !!
    
%     respEPI = physio.data (scanner_start:pyhsio_end,resp_channel); % resp belt wave form
%     heartEPI = physio.data (scanner_start:pyhsio_end,heart_channel); % SpO wave form
%     
    
%     %cd (subjdir) % we save these variables in the subject directory with the nii images
%     save (['respEPI_' subjX '.mat'], 'respEPI');
%     save (['heartEPI_' subjX '.mat'], 'heartEPI');

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CREATE AND SAVE THE EFFORT REGRESSOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    mxEPI = (TR*sampling_rate); %n of physio point measure per EPI
    %scanner_end = max (find((physio.data (:,MRI_volume)) == 5)) + mxEPI;% we need to add + mxEPI because the trigger is at the begining of TR not at the end
    scanner_end = length(physio.data);
    gripEPI = physio.data (scanner_start:scanner_end,grip_channel); %exact length of the pyhsiological during the scanning session
    effort_reg = nan (length(EPI),1);% initialize an empty vector
    cmpt = 1;

    for j= 1:length(EPI)
        %disp ([num2str(cmpt)]);
        if cmpt+mxEPI > length (gripEPI) % this should prevent matlab to crash if the physio is shorter than the scanning run
            x = length(gripEPI);
        else
            x = cmpt+mxEPI;
        end
        mean_effort = mean (gripEPI(cmpt:x));
        cmpt = cmpt+mxEPI;
        effort_reg (j) = mean_effort;
    end

    
    % save the reg as a file text in the participant directory
    fid = fopen('regressor_effort.txt','wt');
    for ii = 1:length(effort_reg)
        fprintf(fid,'%g\t',effort_reg(ii));
        fprintf(fid,'\n');
    end
    fclose(fid);


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DISPLAY PLOT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    num_channel = [4 5 9 10 13]; %channels of interest ??
    if displayPlot
        % Variable for Figure1
        Start = scanner_start;
        End = pyhsio_end;
            i = 0;
            % Figure run1
            figure
            for j = [4 5 9 10 13]
                i = i + 1;
                subplot(length(num_channel),1,i);
                plot(physio.data (Start:End,j));
                switch j
                    %case 1
                        %title('ACC1-X');
                    %case 2
                        %title('ACC1-Y');
                    %case 3
                        %title('ACC1-Z');
                    case 4
                        title ('Handgrip');
                    case 5
                        title('Licking');
                    case 6
                        title('DG input 1');
                    case 7
                        title('DG input 2');
                    case 8
                        title('DG input 3');
                    case 9
                        title('DG input 4');
                    case 10
                        title('DG input 5');
                    case 11
                        title('DG input 6');
                    case 12
                        title('DG input 7');
                    case 13
                        title('DG input 8');
                    case 14
                        title('SumAbsAcc');
                    case 15
                        title('SumAbsAccInt');
                end
            end
        end
%             figure
%             for j = 1:num_channel
%                 subplot(num_channel,1,j);
%                 plot(physio.data (Start:End,j));
%                 switch j
%                     %case 1
%                         %title('ACC1-X');
%                     %case 2
%                         %title('ACC1-Y');
%                     %case 3
%                         %title('ACC1-Z');
%                     case 4
%                         title ('Handgrip');
%                     case 5
%                         title('Licking');
%                     case 6
%                         title('DG input 1');
%                     case 7
%                         title('DG input 2');
%                     case 8
%                         title('DG input 3');
%                     case 9
%                         title('DG input 4');
%                     case 10
%                         title('DG input 5');
%                     case 11
%                         title('DG input 6');
%                     case 12
%                         title('DG input 7');
%                     case 13
%                         title('DG input 8');
%                     case 14
%                         title('SumAbsAcc');
%                     case 15
%                         title('SumAbsAccInt');
%                 end
%             end
%         end
end 
    
end

