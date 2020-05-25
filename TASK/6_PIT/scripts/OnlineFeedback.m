function [ft] = OnlineFeedback (var,val, wPtr)
        
        % Determine max and min high of the mercury
        maxhight = var.hight/18.6047;
        minhight = var.hight/1.2739;
        
        if val > var.ValMax
            val = var.ValMax;
        end
        
        if val < var.minimalforce
            val = var.minimalforce;
        end
        
        beta = (maxhight - minhight)/(var.ValMax-var.minimalforce);
        ft = ((val-var.minimalforce)*beta)+ minhight;
        
        if ft > var.tb % just in case to be sure to avoid each possible bug
            ft = var.tb - 10;
        end;
        
    end %% modified on the 5.03.2015