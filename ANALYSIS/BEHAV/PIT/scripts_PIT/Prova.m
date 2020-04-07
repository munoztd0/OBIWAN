function all_gripsOnsets =  gripsOnsets(threshold,nlines,ncolons,force,trialOnset,reward1,reward2)



% This function compute the time of each grips based on the fact that each
% vector is calibrated for 12 s plus possibles pauses of variable duration
% when the reward is obtained.

% exemple of the inputs

% force = ResultsRimind.mobilizedforce;
% trialOnset = ResultsRimind.TrialOnset;
% threshold = seuil;
% reward1 = ResultsRimind.RewardWindowDuration1;
% reward2 = ResultsRimind.RewardWindowDuration2;

%initializin variables;
rewardtime = 0;
countReward = 0;

for l = 1:ncolons
    
    grips = 0;
    gripsOnsets = 0;
    countReward = 0;
    rewardtime = 0;
    
    for i = 1:nlines - 2
        
        x = force (:,l);
        
        if x(i) < threshold && x (i+1) > threshold;
            
            grips = grips + 1;
            gripsOnsets (grips) = trialOnset(l) + (i*((12/nlines))+ rewardtime); % the onset of the grips is equal to the onset of the trial + the time that has passed (the vector has been calibrated to record values for 12 s)
                      
        end
        
        if isnan(x(i)) == 1  && isnan(x(i-1)) == 0%% if there are NaN value it means that the scripts stopped to deliver the odor, we must account for this time to comupte the onsets
            countReward = countReward + 1;
            if countReward == 1
                rewardtime = reward1(l);
            elseif countReward == 2
                rewardtime = reward1(l)+reward2(l);
            end
        end    
        
    end
    
 gripsOnsets = gripsOnsets';
    
    
tmp(l) = {gripsOnsets}; % we want to concatenate all grips Onsets in a single vector for that we have to create a temporary cell vector that contains the onsets for each trial that have different length
all_gripsOnsets = vertcat(tmp{:});

end

%end

