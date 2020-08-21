%
%
% convert fixation data (eye track) to acquisition data referenced timestamps
%
%
% periodsToUse: each row [trialNr beginTime EndTime]  ; beginTime is start of trial
% offsetBaseline: after how many us did the stimulus onset occur (added to beginTime)
%  
% gazeEventType: 1 fixation start, 2 saccade start
%
% Return
% fixTimes: [fixNr trialNr fixTime ]
% fixTime is when the fixation happened, Acq system timeframe
%
%urut/nov13
function fixTimes = convertGazeEvents_toAcqTime ( gazeDataTrials, trialsToUse, periodsToUse, offsetBaseline, gazeEventType  )

fixTimes = [];

fixCounter = 0;

for trialNr=trialsToUse
    
    gData = gazeDataTrials(trialNr);
    fixInfo = gData.fixInfo;
    saccInfo = gData.saccInfo;
    
    tStart = gData.tStart;    % stim onset time, in units of eye tracker time [ms]

    if gazeEventType==1
        infoToUse = fixInfo;
    else
        infoToUse = saccInfo;
    end
    
    % take each fixation that occured during this trial
    for j=1:size(infoToUse,1)
       
        fixPos = infoToUse(j,1:2);

        if gazeEventType==1
            eventStart_time = infoToUse(j,3);   % in units of eye tracker
            eventStop_time = infoToUse(j,4);   % in units of eye tracker
        else
            eventStart_time = infoToUse(j,5);   % in units of eye tracker
            eventStop_time = infoToUse(j,6);   % in units of eye tracker
        end

        
        %if (eventStop_time-eventStart_time)<300
        %    continue;
       % end
        
        fixTime_rel = (eventStart_time - tStart);    % from stim onset in ms

        if fixTime_rel>0   % ignore the fixation if it started before stim onset
        
        
        %if fixTime_rel<0  % only include fix that started shortly before stim onset
            % convert this time to neural timestamp timeframe
            fixTimeAbs = periodsToUse(trialNr,2)+offsetBaseline*1000 + fixTime_rel*1000;    % absolute fixation time in neural time, in [us]
            fixCounter = fixCounter+1;
            
            fixTimes(fixCounter,:) = [ fixCounter trialNr fixTimeAbs  ];
            
        end
    end
end