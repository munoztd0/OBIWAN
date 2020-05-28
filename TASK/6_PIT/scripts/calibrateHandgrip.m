    function [var] = calibrateHandgrip(var,wPtr)
        
        %%%initialize variables
        var.minimalforce = [];
        var.maximalforce = [];
        var.v = [];
        var.ValMax = [];
        var.ValMin = [];
        
        %%% Minimal force
        
        % First instruction
        showInstructionSimple(wPtr, var.instructionA);
        WaitSecs(0.4);
        KbWait(-1);
        
        %countDown(wPtr);% Execute the countdown before the mesuration of the force
        DrawFormattedText(wPtr, var.tenez, 'center', 'center', 0);
        Screen(wPtr, 'Flip');
        tic;
        mf = 0;
        
        while toc < 4
            mf = mf + 1;
            if var.experimentalSetup
                val = readAD(); % define the number according to the value that is displayed with no force in order to have it at 0
            else
                val = rand([1]);
            end % define the number according to the value that is displayed with no force in order to have it at 0
            minforce(mf) = val; % at this point is impossible to initialize a variable since we don know how many cycle loops this particular system run
        end
        
        %%% Maximal force
        
        % First instruction
        showInstructionSimple(wPtr, var.instructionB);
        WaitSecs(0.4);
        KbWait(-1);
        
        %countDown(wPtr);% Execute the countdown before the mesuration of the force
        DrawFormattedText(wPtr, var.pressez, 'center', 'center', 0);
        Screen(wPtr, 'Flip');
        tic;
        mf = 0;
        
        while toc < 4
            mf = mf + 1;
            if var.experimentalSetup
                val = readAD(); % define the number according to the value that is displayed with no force in order to have it at 0
            else
                val = rand([1]);
            end; % define the number according to the value that is displayed with no force in order to have it at 0
            maxforce(mf) = val;
        end
        
        % Calibrate the proportional maximal force
        var.maximalforce = max(maxforce);
        var.minimalforce = min(minforce);
        forceRange = abs(var.maximalforce - var.minimalforce);
        max1 = var.minimalforce + 70*forceRange/100;
        max2 = var.minimalforce + 50*forceRange/100;
        var.v = [max1; max2];
        var.ValMin = var.minimalforce;
        var.ValMax = var.maximalforce;
        
        showInstructionSimple(wPtr, var.calibrationEnd);
        WaitSecs(2);
        
    end