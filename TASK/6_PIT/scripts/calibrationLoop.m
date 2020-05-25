function [mobforce,Nloops] = calibrationLoop (var,a,wPtr)
        tic;
        mfexp = 0;
        mobforce = [];
        
        while toc <= a % until the time at is reached
            
            mfexp = mfexp + 1;
            
            %read and record mobilized force
            val = readAD();
            mobforce(mfexp) = val;
            
            %to set the maximal value as a value that change randomly
            % between 50% and 70%
            idxv = randperm(numel(var.v));
            var.ValMax = var.v (idxv (1:1));
            
            % compute variable for online feedback and display
            ft = OnlineFeedback(var,val);
            displayFeedback(var,ft,wPtr);
            
        end
        
        mobforce = mobforce'; % I need the values to be stored in a colon instead of a line
        Nloops = mfexp; % value of interest (how many loops does the computer ran in 1 s)
    end