%Created by Eva last modified june 2020 by david

% pupil = raw pupil

dbstop if error
clear all

%% DEFINE PATH %bad 101 - 207- 210 - 212 - 216  -224 -230 - 249 -269 / 2249 - 2266?

cd ~
home = pwd;
homedir = [home '/OBIWAN/'];

addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));

%% DEFINE POPULATION
control = [homedir 'SOURCEDATA/physio/control*'];
obese = [homedir 'SOURCEDATA/physio/obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);
session = {'second';'third'}; 
FPS = 60;


for j = 1:length(session)
    for i = 1:length(subj)

        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        number = subjX(end-2:end);
        
        folder = [homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/'];
        
        if exist(folder)
            cd(folder)
        else
            continue
        end
        
        if j == 1 %change 1
            if exist([ 'tpspm_' number '.mat'])
                load([ 'tpspm_' number '.mat'])
            else
                continue
            end
        else
            if exist([ 'tpspm_2' number '.mat'])
                load(['tpspm_2' number '.mat'])
            else
                continue
            end   
        end
            
        dispPlot = 0;
        
        %last modified june 2020 by david
        pupil_raw = data{1, 1}.data  ;
        pupil_raw = pupil_raw/100; % transform pupil in mm
        %plot(pupil_raw)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 1. REMOVE EVIDENT BLINK A

        %badDataIndexes = pupil < 0.5 | pupil > 10; % remove the evident blinks and evident artifacts
        badDataIndexes = pupil_raw < 0.15 | pupil_raw > 0.6; % remove the evident blinks and evident artifacts
        pupil = pupil_raw;
        pupil(badDataIndexes) = NaN; % Remove bad data

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 2. REMOVE EXTRAM VALUES

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
        % using local window using hampel to smooth more and remove more striclty extream values data of problematic
        % subjects (we dont want data that have been intrapolate for more than 40%
        % of the time to have a big impact on our analysis)
        if  missingdata > 70.00 
            x =  'attention'
            dispPlot = 1;
        end
        
        disp (['missing data of participant ' subjX  ' ' num2str(missingdata) ' %']);
          
        if  missingdata > 42.00 
            dispPlot = 1;
            X = 1:length(pupil); % time
            DX = 201; %number of neighbours points to consider in the window (each side)
            nsigma = 1; % number of standard deviations

            Y = pupil';

            %[~,~,Y0] = hampel(X,Y,DX,nsigma);
            [~,~,Y0] = hampel(Y,DX,nsigma);

            pupil1 = Y0;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 3. REMOVE SUDDEN VARIATIONS DUE TO NOISE

        x = zeros (length(pupil1),1);

        for lineIndex = 2:size(pupil1,1) % we start from the second value to have a previous value

            CurrentValue = pupil1(lineIndex,1);
            PreviousValue = pupil1(lineIndex-1,1);

            if abs(CurrentValue - PreviousValue) > SD*interQuartile % big sudden variation given the participant variability
                pupil1(lineIndex,1) = PreviousValue;
            end

            if CurrentValue  == PreviousValue
                x (lineIndex) = 8; % this for plotting purposing
            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 4. SMOOTH DATA

        %N = 4; % Order of polynomial fit
        %F = 101; % Window frame length
        %F = 15; % Window length
        
        
        N = 4; % Order of polynomial fit
        F = 15; % Window length
        
        NN = 4; % Order of polynomial fit
        FF = 101; % Window length

%         [~,g] = sgolay(N,F); % Calculate S-G coefficients
% 
%         y = pupil1';
%         HalfWin  = ((F+1)/2) -1;
%         pupilm = zeros (length(y),1);
% 
%         for n = (F+1)/2:length(y)-(F+1)/2
% 
%             pupilm(n) = dot(g(:,1),y(n - HalfWin:n + HalfWin));% Zeroth derivative (smoothing only)
% 
%         end 

        pupilX = sgolayfilt(pupil1,N,F); %S-G coeficients easier 
        pupilm = sgolayfilt(pupil1,NN,FF); %S-G coeficients easier 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % QUANTIFY MISSING DATA
        missing1 = sum(isnan(pupilX))/length(pupil)* 100;
        %missing2 = sum(isnan(pupilX))/length(pupil)* 100;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %5. INTRAPOLATE MISSING DATA
% 
%         window = 5000; %we use a 5-second window to intrapolate
%         np2 = window*(FPS/1000); %number of data points to cover the window
% 
%         %instead of rolling the 5-sec window at every single datapoint, the window
%         %can move much quicker, e.g. every 2.5 sec?
%         for i = 1:floor(length(pupilm)/(np2/2))-1
% 
%             start_i = (i-1)*np2/2+1; %this will place the start of the window at t=0, 2.5s, 5s, 7.5s, 10s, etc
%             pupil_woi = pupilm(start_i:start_i+np2);
% 
%             mask  = ~isnan(pupil_woi);
%             times = 1:length(pupil_woi);
% 
%             if sum(mask) > 20; % intrapolate only if we have at least 20 valid datapoints in the time window of interest
%                 intrapolated  = interp1(times(mask),pupil_woi(mask), times(~mask));
%                 pupil_woi(~mask) = intrapolated;
%             end
% 
%             pupilm(start_i:start_i+np2) = pupil_woi;
% 
%         end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % QUANTIFY MISSING DATA
        %missing2 = sum(isnan(pupilm))/length(pupilm)* 100;


      
        disp (['missing data of participant ' subjX ' after 1: '  num2str(missing1) ' %']);
        %disp (['missing data of participant ' subjX ' after 2: '  num2str(missing2) ' %']);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  DETREND DATA: ALLOW FOR SUBJECT FATIGUE

        %pupilmd= detrend(pupilm,'omitnan');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % PLOT ROW AND POST PROCESSED PUPIL AS SANITY CHECK
        %dispPlot =1
        if dispPlot == 1
            figure
            plot(pupil_raw)
            hold on
            plot(pupilm, 'lineWidth', 3)
            plot(pupilX, 'lineWidth', 2, 'Color',[0,0.7,0.9])
            hold off
        end
        
        
        data{1, 1}.data = pupilX;
        
        onsets.CSp          = data{2, 1}.data(data{2, 1}.markerinfo.value == 32);
        onsets.CSm          = data{2, 1}.data(data{2, 1}.markerinfo.value == 16);
        onsets.Baseline     = data{2, 1}.data(data{2, 1}.markerinfo.value == 64);
        
        onsets.rew          = data{2, 1}.data(data{2, 1}.markerinfo.value == 2);
        onsets.norew          = data{2, 1}.data(data{2, 1}.markerinfo.value == 4);
        
        if j == 1 
            save([ 'ptpspm_' number '.mat'], 'data', 'infos')
             save([ 'onsets_' number '.mat'], 'onsets')
        else
            save(['ptpspm_2' number '.mat'], 'data', 'infos')
            save(['onsets_2' number '.mat'], 'onsets')
        end
        
        
    end
end
