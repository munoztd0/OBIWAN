function pupilm = removeArtefact(pupil,timestamps, subjX, dispPlot)

%last modified june 2018

% inputs:

% pupil = raw pupil
% preproc = structures containing the preprocessed data (in this case
% downsampled edf file)
% subjX = subject ID
% display plot or not

% attention if you want ot use this, do not down sample too much (we need at least 2 datapoints every 20ms)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET THE SAMPLING RATE AND CONTROL THAT IS ENOUGH
FPS = getFPS (timestamps);

if FPS < 100
    warning('you need a sampling rate of 100 datapoint per second or bigger to apply this function reliably')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRANFORM PUPIL in mm
pupil = pupil'/1000; %put in a vector and transfor in mm
pupil_raw = pupil;
subj = str2double(subjX);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE LOSS OF SIGNAL
badDataIndexes = pupil <0.2; % remove pupil report as being smaller than 0.2 mm
pupil(badDataIndexes) = NaN; % Remove bad data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE VARIATION BIGGERE THAN 0.38 mm WITHIN a 20-ms INTERVAL
% from Snowed et al., Psychophysiology (2016)

interval = 20; %20-ms interval
np = interval*(FPS/1000); %number of data points to cover the interval
indsToRemove = zeros(length(pupil),1);

for i = 1:length(pupil)-np
    
    change = abs(pupil(i+np) - pupil(i));
    
    if change > 0.38
        indsToRemove(i:i+np) = 1;
        %collect indices to remove in a vector, otherwise if values are
        %replaced by NaN right now then the following 10 change values will
        %be NaNs as well (Caroline Charpentier)
    end
    
end

pupil(logical(indsToRemove)) = NaN; %then remove all the values


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SMOOTH DATA

N = 4; % Order of polynomial fit
F = 31; % Window length

[~,g] = sgolay(N,F); % Calculate S-G coefficients

y = pupil;
HalfWin  = ((F+1)/2) -1;
pupilm = zeros (length(y),1);

for n = (F+1)/2:length(y)-(F+1)/2,
    
    pupilm(n) = dot(g(:,1),y(n - HalfWin:n + HalfWin));% Zeroth derivative (smoothing only)
    
end

missing1 = sum(isnan(pupilm))/length(pupilm)* 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTRAPOLATE MISSING DATA

window = 5000; %we use a 5-second window to intrapolate
np2 = window*(FPS/1000); %number of data points to cover the window

%instead of rolling the 5-sec window at every single datapoint, the window
%can move much quicker, e.g. every 2.5 sec?
for i = 1:floor(length(pupilm)/(np2/2))-1
    
    start_i = (i-1)*np2/2+1; %this will place the start of the window at t=0, 2.5s, 5s, 7.5s, 10s, etc
    pupil_woi = pupilm(start_i:start_i+np2);
    
    mask  = ~isnan(pupil_woi);
    times = 1:length(pupil_woi);
    
    if sum(mask) > 20; % intrapolate only if we have at least 20 valid datapoints in the time window of interest
        intrapolated  = interp1(times(mask),pupil_woi(mask), times(~mask));
        pupil_woi(~mask) = intrapolated;
    end
    
    pupilm(start_i:start_i+np2) = pupil_woi;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT ROW AND POST PROCESSED PUPIL AS SANITY CHECK
if dispPlot == 1
    figure
    plot(pupil_raw)
    hold
    plot(pupilm, 'lineWidth', 3)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUANTIFY MISSING DATA
missing2 = sum(isnan(pupilm))/length(pupilm)* 100;

disp (['missing data of participant ' num2str(subj) ' before intrapolation: ' num2str(missing1) ' %']);
disp (['missing data of participant ' num2str(subj) ' after intrapolation: '  num2str(missing2) ' %']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DETREND DATA: ALLOW FOR SUBJECT FATIGUE
% from Wolfgang and Akshai

pupilm= detrend_nan(pupilm);
