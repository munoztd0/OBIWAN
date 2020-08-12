function countDown(wPtr)
      
        % Show the warning message 'Attention'
        showInstruction(wPtr, 'Attention !');
        WaitSecs(1);
        
        for count = 3:-1:1 % We need to put a step of -1 to go from 3 to 1
            showInstruction(wPtr, int2str(count));
            WaitSecs(1);
        end
        
    end