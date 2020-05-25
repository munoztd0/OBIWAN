function [ioObj]= SetParallelPort()
    ioObj = io32;
    status = io32(ioObj);
    
    if status ~= 0
        disp('inpout32 installation failed!')
    else
        disp('inpout32 (re)installation successful.')
    end
    
    io32(ioObj,hex2dec('CFF8'),0); % Set condition code to zero, adress =
    hex2dec('CFF8')
end