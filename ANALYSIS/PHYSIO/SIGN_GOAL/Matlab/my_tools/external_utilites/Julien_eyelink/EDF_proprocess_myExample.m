% EDF_proprocess_myExample

% example for myself jan 13

%% read edf (function compatible with mac)
dataGaze = Edf2Mat('Thomas.edf');
plot(dataGaze); % lot raw data functions Edf2mat)

%% define parameters
 offsets = [0 4000]; % ms
 whichEye = 2;  % which eye was tracked
 screendim = [0 0  1024 768]; % enter the rect coordinates of the task

 
 %% extract events from triggers and eye movemnts
 [eventsTask, eventsGaze, eventsInfo] = EDF_preprocess_Events( dataGaze.RawEdf.FEVENT);
 
 %% which kind of events are we interested in ?
trialsToUse = find( eventsTask(:,2) == 1);
[gazeDataAll, gazeDataTrials] = EDF_preprocess_Data (dataGaze.RawEdf.FSAMPLE, dataGaze.RawEdf.FEVENT, eventsTask, eventsGaze, trialsToUse, whichEye, offsets);

%% quick plot to see if data are present

% one trial
figure
 plot(gazeDataTrials(80).gx,gazeDataTrials(80).gy)
 figure
 plot(gazeDataTrials(80).pa)
 
 
 %% from pixels in 100%
 
 
x = gazeDataAll.gx/screendim(3);
y = gazeDataAll.gy/screendim(4);

plot(x,y, 'o');
xlim([0 1])
ylim([0 1])

for k = 1:length(gazeDataTrials)

     gazeDataTrials(k).gx =  gazeDataTrials(k).gx/screendim(3);
     gazeDataTrials(k).gy =  gazeDataTrials(k).gy/screendim(4);
     
end

figure
plot(gazeDataTrials(1).gx,gazeDataTrials(1).gy, 'o')
xlim([0 1])
ylim([0 1])
