function [t, gazeDataAll, s] = load_EDF (param, dataGaze, data, subjX) 

% last modified on APRIL 2018 by Eva for SIGNGOAL PROJECT

% for this to work Julien EDF_preprocess functions and removeartifact need 
% to in the path and the edf-convert needs to be in the framework libraries

% triggercode : 
% 1 = CS onset
% 2 = ANTICIPATION onset
% 3 = US onset

tic
% Plot edf data to make sure data are correctly loaded
if param.dispPlot == 1
    plot(dataGaze); % lot raw data functions Edf2mat
end


%% preprocess pupil data (before downs sampling because we need as many data point as possible for a good preprocessing)
timestamps = dataGaze.RawEdf.FSAMPLE.time;
pupil      = dataGaze.RawEdf.FSAMPLE.pa (param.whichEye,:);

pupil_clean = removeArtefact(pupil,timestamps, subjX, param.dispPlot);

%% preprocess gazedata

% sample down according to what analysis you are doing (--> do not down
% sample if you want extract saccadic reaction times and other high
% precision idexes)

if param.FSP > 950
    DSF = 20; % downsample factors
    disp('----------- down sampling ------------')
else 
    DSF = 10; % do not down sample if acquisition is already at 500
end

raw.gx = downsample(dataGaze.RawEdf.FSAMPLE.gx (param.whichEye,:),DSF);
raw.gy = downsample(dataGaze.RawEdf.FSAMPLE.gy (param.whichEye,:),DSF);

indsInvalid = find (raw.gx == 100000000 |...
                    raw.gy == 100000000);

raw.gx(indsInvalid) = nan;
raw.gy(indsInvalid) = nan;


preproc.FSAMPLE.gx (param.whichEye,:) = raw.gx/param.screendim(3); % value from 0:1
preproc.FSAMPLE.gy (param.whichEye,:) = raw.gy/param.screendim(4); % value from 0:1
preproc.FSAMPLE.time                  = downsample(dataGaze.RawEdf.FSAMPLE.time,DSF);
preproc.FSAMPLE.pa (param.whichEye,:) = downsample(pupil_clean,DSF);


%% save the entire timeline
gazeDataAll.gx    = preproc.FSAMPLE.gx (param.whichEye,:);
gazeDataAll.gy    = preproc.FSAMPLE.gy (param.whichEye,:);
gazeDataAll.pa    = preproc.FSAMPLE.pa (param.whichEye,:);
gazeDataAll.times = preproc.FSAMPLE.time;


%% extract events from triggers(TTLs) and eye movements
[eventsTask, eventsGaze, ~] = EDF_preprocess_Events(dataGaze.RawEdf.FEVENT);


%% Get baseline corrected pupil for both CS image and US videos
Trigger    = [   1;    3];
Event_name = {'CS'; 'US'};

for i = 1:length(Trigger)
    
    name        = char(Event_name(i));
    trialsToUse = find( eventsTask(:,2) == Trigger(i));
    
    offsets = [500  0];
    [Trial.(name).baseline] = EDF_preprocess_Data (preproc.FSAMPLE, dataGaze.RawEdf.FEVENT, eventsTask, eventsGaze, trialsToUse, param.whichEye, offsets);
    
    offsets = [0 1800];
    [Trial.(name).reflex] = EDF_preprocess_Data (preproc.FSAMPLE, dataGaze.RawEdf.FEVENT, eventsTask, eventsGaze, trialsToUse, param.whichEye, offsets);
    
    offsets = [0 3000];
    [Trial.(name).plot]  = EDF_preprocess_Data (preproc.FSAMPLE, dataGaze.RawEdf.FEVENT, eventsTask, eventsGaze, trialsToUse, param.whichEye, offsets);
    
    t.(name).pa.x        = nan(length(trialsToUse), length(Trial.(name).reflex(1).gx)); % some times there is plus minus 1 mismatch
    t.(name).pa.y        = nan(length(trialsToUse), length(Trial.(name).reflex(1).gy)); 
    t.(name).pa.reflex   = nan(length(trialsToUse), length(Trial.(name).reflex(1).pa)); 
    t.(name).pa.plot     = nan(length(trialsToUse), length(Trial.(name).plot(1).pa));
    t.(name).pa.plotTime = nan(length(trialsToUse), length(Trial.(name).plot(1).times)); %to use as x label (time) for the plot

    for k = 1:length(trialsToUse)
        
        corrFactor                   = nanmean(Trial.CS.baseline(k).pa);
        tmp                          = size(Trial.(name).reflex(k).pa,2);
        t.(name).pa.reflex (k,1:tmp) = Trial.(name).reflex(k).pa - corrFactor;
        t.(name).pa.x (k,1:tmp)      = Trial.(name).reflex(k).gx;
        t.(name).pa.y (k,1:tmp)      = Trial.(name).reflex(k).gy;
        tmp                          = size(Trial.(name).plot(k).pa,2);
        t.(name).pa.plot (k,1:tmp)   = Trial.(name).plot(k).pa  - corrFactor;
        t.(name).pa.plotTime(k,1:tmp)= Trial.(name).plot(k).times;

    end
    
end


%% Gaze
Trigger         = [   1;     2;   3];
Event_name      = {'CS'; 'ANT'; 'US'};
offsets_list    = {[zeros(length(data.durations.CS),1), data.durations.CS*1000],[0 2800], [0 3000]};

for i = 1:length(Trigger)
    
    name        = char(Event_name(i));
    trialsToUse = find( eventsTask(:,2) == Trigger(i));
    offsets     = cell2mat(offsets_list(i));

    [Trial.(name).gaze] = EDF_preprocess_Data (preproc.FSAMPLE, dataGaze.RawEdf.FEVENT, eventsTask, eventsGaze, trialsToUse, param.whichEye, offsets);
    
    
    for k = 1:length(trialsToUse) % get max n of samples to initialize matrix
        tmp(k)    = size(Trial.(name).gaze(k).gx,2);  
    end
    maxLength = max(tmp);
    
    t.(name).time = nan(length(trialsToUse), maxLength);
    t.(name).x    = nan(length(trialsToUse), maxLength); % some times there is plus minus 1 mismatch
    t.(name).y    = nan(length(trialsToUse), maxLength);
    for k = 1:length(trialsToUse)
        tmp                     = size(Trial.(name).gaze(k).gx,2);
        t.(name).x (k,1:tmp)    = Trial.(name).gaze(k).gx;
        t.(name).y (k,1:tmp)    = Trial.(name).gaze(k).gy;
        t.(name).time (k,1:tmp) = Trial.(name).gaze(k).times;
    end
        
end

%% saccades and fixations

Trigger         =  1;
Event_name      = {'CS'};
offsets_list    = {[zeros(length(data.durations.CS),1), (data.durations.CS*1000)+2800]};

for i = 1:length(Trigger)
    
    name        = char(Event_name(i));
    trialsToUse = find( eventsTask(:,2) == Trigger(1));
    offsets     = cell2mat(offsets_list(i));

    [s.(name)] = EDF_preprocess_Data (preproc.FSAMPLE, dataGaze.RawEdf.FEVENT, eventsTask, eventsGaze, trialsToUse, param.whichEye, offsets);
    
end

elapsed = toc;
fprintf('--- EDF loaded in %.2fs\n',elapsed);

