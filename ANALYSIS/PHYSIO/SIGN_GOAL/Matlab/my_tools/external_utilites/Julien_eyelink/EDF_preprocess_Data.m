%
% preprocess get gaze data on screen, split it up into trials
%
%
% offsets: how much to include relative to the trial onset timestamp [before after] (in ms)
%
% Modified by Eva and Carolina on may 2017
function [gazeDataTrials] = EDF_preprocess_Data( fsample, fevent, eventsTask, eventsGaze, trialsToUse, whichEye, offsets )

gx = fsample.gx(whichEye,:);
gy = fsample.gy(whichEye,:);
pa = fsample.pa(whichEye,:);

time = fsample.time;

        
gazeDataTrials=[];
for k=1:length(trialsToUse)
    tStart = eventsTask( trialsToUse(k), 1);
    
    if size(offsets,1) == 1 % timewindow is the same for all trials
        indsToUse = find( time>tStart-offsets(1) & time<tStart+offsets(2) );
    else % each trial has its own timewidow
       indsToUse = find( time>tStart-offsets(k,1) & time<tStart+offsets(k,2) ); %
    end
    
    
    if ~isempty(indsToUse)
        
        gazeDataTrials(k).tStart = tStart;
        gazeDataTrials(k).gx = gx(indsToUse);
        gazeDataTrials(k).gy = gy(indsToUse);
        gazeDataTrials(k).pa = pa(indsToUse);
        gazeDataTrials(k).times = time(indsToUse);
        
    end
    
    % find the events that belong to this trial
    if size(offsets,1) == 1 % timewindow is the same for all trial
        indsToUseEvents = find ( eventsGaze(:,1)>tStart-offsets(1) & eventsGaze(:,1)<tStart+offsets(2) );   
    else % each trial has its own timewidow
        indsToUseEvents = find ( eventsGaze(:,1)>tStart-offsets(k,1) & eventsGaze(:,1)<tStart+offsets(k,2) ); 
    end
    
    if ~isempty(indsToUseEvents)
        gazeDataTrials(k).gazeEvents = eventsGaze( indsToUseEvents, :);
        
        % add info for specific events
        
        %--------- fixations
        indsFixEnd = find ( eventsGaze(indsToUseEvents,2)==2  );  % end fixation events
        indsOrig = eventsGaze(indsToUseEvents(indsFixEnd),3);
        fixInfo=[];
        for j=1:length(indsOrig)
            fixInfo(j,:) = [ double(fevent(indsOrig(j)).gavx) double(fevent(indsOrig(j)).gavy) fevent(indsOrig(j)).sttime fevent(indsOrig(j)).entime ];
        end
        gazeDataTrials(k).fixInfo = fixInfo;
        
        %---------- saccades
        indsSaccEnd = find ( eventsGaze(indsToUseEvents,2)==4  );  % end saccade events
        indsOrig = eventsGaze(indsToUseEvents(indsSaccEnd),3);
        saccInfo=[];
        for j=1:length(indsOrig)
            saccInfo(j,:) = [ double(fevent(indsOrig(j)).gstx) double(fevent(indsOrig(j)).gsty) double(fevent(indsOrig(j)).genx) double(fevent(indsOrig(j)).geny) fevent(indsOrig(j)).sttime fevent(indsOrig(j)).entime ];
        end
        gazeDataTrials(k).saccInfo = saccInfo;
        
        
    end
    
    
    
    
end