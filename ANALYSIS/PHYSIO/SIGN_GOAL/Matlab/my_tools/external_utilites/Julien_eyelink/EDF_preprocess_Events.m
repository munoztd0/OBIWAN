%
% pre-process EDF data to analyze together with spiking data
%
% for format of events, see http://download.sr-support.com/dispdoc/page25.html
%
%urut/nov13
function [eventsTask, eventsGaze, eventsInfo] = EDF_preprocess_Events( fevent )
eventsTask=[];
c=0;

eventsGaze=[]; % time EventType origInd
eventsInfo=[];

% EventType 1 StartFix, 2 EndFix, 3 StartSacc, 4 EndSacc, 5 StartBlink, 6 EndBlink

c2=0;
c3=0;
for k=1:length(fevent)
   
    if strcmp(fevent(k).codestring, 'MESSAGEEVENT')
       
        if strfind( fevent(k).message, 'TTL=' )
           
            TTLstr = fevent(k).message(5:end);
            
            TTLnr = str2num( TTLstr );
            
            
            TTLtime = fevent(k).sttime;
            
            c=c+1;
            eventsTask(c,:) = [ TTLtime TTLnr k ];
        end
        
        if strfind( fevent(k).message, 'TRIALID ' )
            infoStr = fevent(k).message(9:end);
            
            pos = strfind(upper(infoStr),'C:\');
            
            filenameStr = infoStr(pos:end);
            
            trialIDStr = infoStr(1:pos-1);
            
            c3=c3+1;
            eventsInfo(c3).filenameStr = filenameStr;
            eventsInfo(c3).trialID     = str2num(trialIDStr);
            
            
        end
    end
    
    if strcmp(fevent(k).codestring, 'STARTFIX')
        c2=c2+1;
        eventsGaze(c2,:) = [fevent(k).sttime 1 k];
    end
    if strcmp(fevent(k).codestring, 'ENDFIX')
        c2=c2+1;
        eventsGaze(c2,:) = [fevent(k).entime 2 k];
    end
    
    if strcmp(fevent(k).codestring, 'STARTSACC')
        c2=c2+1;
        eventsGaze(c2,:) = [fevent(k).sttime 3 k];        
    end
    if strcmp(fevent(k).codestring, 'ENDSACC')
        c2=c2+1;
        eventsGaze(c2,:) = [fevent(k).entime 4 k];        
    end

    if strcmp(fevent(k).codestring, 'STARTBLINK')
        c2=c2+1;
        eventsGaze(c2,:) = [fevent(k).sttime 5 k];        
    end
    if strcmp(fevent(k).codestring, 'ENDBLINK')
        c2=c2+1;
        eventsGaze(c2,:) = [fevent(k).entime 6 k];
    end
    
end