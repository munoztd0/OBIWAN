
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT EYEDATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by David


dbstop if error
clear all

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN/'];

addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));
addpath /usr/local/MATLAB/R2019a/toolobix/ilab/
addpath /usr/local/MATLAB/R2019a/toolbox/eeglab/
addpath /usr/local/MATLAB/R2019a/toolbox/spm12/toolbox/pspm


%% DEFINE POPULATION
control = [homedir 'SOURCEDATA/physio/control*'];
obese = [homedir 'SOURCEDATA/physio/obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);
session = {'second'; 'third'}; 
x = [];
for j = 1:length(session)
    for i = 1:length(subj)

        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        number = subjX(end-2:end);
        

        fileX = dir([homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/*.eyd']);
        
        if length(fileX) == 0 
           continue
        end
        
        if length(fileX) > 1 
           fileX(1).name = fileX(2).name; %when the first one fails
        end
        
        file = fileX(1).name;

        folder = [homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/'];
        %EYD = ilabConvertASL(folder, file, 6);

        cd(folder)
        %data = EYD;
        
        if j == 1             
            ses = 1;
            num = number;
            %data = data.data;
            %save([ number], 'data') 
            %load([ number '.mat']) 
        else
            ses =2;
            num = number;
            number = ['2' number];
            %data = data.data;
            %save([ number], 'data') 
            %load([ number '.mat'])
        end   
        
        EEG.etc.eeglabvers = '2020.0'; % this tracks which version of EEGLAB is being used, you may ignore it
        EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',[homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/' number '.mat'],'setname',number,'srate',60,'subject',number,'pnts',0,'xmin',0,'session',1,'group','1');
        EEG = eeg_checkset( EEG );

        first = find(EEG.data(3,:) == 5, 1, 'last');
        last = find(EEG.data(3,:) == 64, 1, 'last');

        EEG.data = EEG.data(:,[first-60:last+600]);
        EEG.times = EEG.times(:,[first-60:last+600]);

        EEG.data(5,:) = str2num(num);
        EEG.data(6,:) = ses;
        EEG.data(7,:) = 0;
        
        EEG.data(3,:) = circshift(EEG.data(3,:),-6); %revert 100 sec back

        l = 0;
        for k  = 1:length(EEG.data(6,:)) 
            if EEG.data(3,k) == 16 ||  EEG.data(3,k) == 32 || EEG.data(3,k) == 64
                if EEG.data(3,k-1) ~= 16 ||  EEG.data(3,k-1) ~= 32 || EEG.data(3,k-1) ~= 64
                   l = l+ 1;
                   EEG.data(7,k) = l ;
                end
            end
        end

        EEG.data(1,:) = []; %remove X
        EEG.data(1,:) = []; %remove Y
        EEG.times = EEG.times - (EEG.times(1,find(EEG.data(5,:) == 1, 1, 'first')) +100);
        EEG.data(6,:) =  EEG.times;
        

        if str2num(num) > 199
            EEG.data(7,:) =  1;
        else 
            EEG.data(7,:) =  0;
        end


        df = EEG.data';
        
        % basic preproc
        pupil_raw = df(:,2);

        pupil_raw = pupil_raw/100; % transform pupil in mm
        %plot(pupil_raw)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 1. REMOVE EVIDENT BLINK A

        %badDataIndexes = pupil < 0.5 | pupil > 10; % remove the evident blinks and evident artifacts
        badDataIndexes = pupil_raw < 0.15 | pupil_raw > 0.6; % remove the evident blinks and evident artifacts
        pupil = pupil_raw;
        pupil(badDataIndexes) = NaN; % Remove bad data

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 2. REMOVE EXTREME VALUES

        SD = 3;
        interQuartile = iqr(pupil);

        %-------------------------------------------------------------------------%
        % option 1: median filter on the overall signal

        meanValue = nanmedian(pupil);

        maxAllowablePupilDiameter = meanValue + SD*interQuartile;
        minAllowablePupilDiameter = meanValue - SD*interQuartile;

        badDataIndexes = pupil > maxAllowablePupilDiameter;
        pupil(badDataIndexes) = NaN; % Remove bad data

        badDataIndexes = pupil < minAllowablePupilDiameter;
        pupil(badDataIndexes) = NaN; % Remove bad data

        %%% quantify the amoung of data that have been removed
        missingdata = sum (isnan(pupil)); % row
        missingdata = (missingdata*100)/ length(pupil); % missing data in percentage

        %%% substitue NaN with the closest non NaN value

        for lineIndex = 1:size(pupil,2)
            for rowIndex = size(pupil,1):-1:2
                CurrentValue = pupil(rowIndex, lineIndex);
                if ~isnan(CurrentValue) && isnan(pupil(rowIndex-1, lineIndex))
                    pupil(rowIndex-1, lineIndex) = CurrentValue;
                end
            end
        end

         pupil1 = pupil;
        %-------------------------------------------------------------------------%
        dispPlot = 0;
        
        if  missingdata > 75.00 
            debug = 'attention'
            number
            session{j}
            missingdata
            dispPlot = 1;
        end
        
        if dispPlot == 1
            figure
            plot(pupil_raw)
            hold on
            plot(pupil1, 'lineWidth', 3)
            hold off
            debug = 1;
        end
        
        %removed
        %ses 1 115 132 210 249
        %ses 2 205 221 249 266
        
        
        if dispPlot == 0
            df(:,2) = pupil1;
            x = [x; df];
        end
        
        %the rest of the processing is done in R
        
        
        disp(['done_sub-' subjX ' ses-' num2str(ses)])
        
    end
    
    cd ([homedir 'DERIVATIVES/BEHAV'])
    filename = 'PAV_pup.txt';
    fid = fopen(filename, 'wt');
    fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'marker', 'pupil', 'ID', 'session', 'trial', 'time', 'group');  % header
    fclose(fid);
    dlmwrite(filename,x,'delimiter','\t','-append');
    
end