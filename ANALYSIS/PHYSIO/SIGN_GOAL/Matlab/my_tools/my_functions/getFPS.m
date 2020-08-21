function [FPS, FPS_all] = getFPS (timestamps)


%sprintf ('%.16f\n', timestamp(1))

s_timestamps = (timestamps)/1000; % remove ms to count how many time stamp per second

% find the first change
for i = 2:length(s_timestamps);
   
    change = s_timestamps(i) - s_timestamps (i-1);
    if change ~= 0
        start = i;
    break
    end
    
end

cmpt = 1; % count
n = 1; % to put the count in a vector
for i = start+1:length(s_timestamps)
    
    change = s_timestamps(i) - s_timestamps (i-1);
    
    if change ==0
        
        cmpt = cmpt+ 1;
        
    elseif change ~= 0
        
       FPS_all (n,1) = cmpt;  
       cmpt = 1; % restart cmpt
       n = n + 1; % update n
       
    end
    
end

FPS = median (FPS_all);
   

end