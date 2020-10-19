function all_gripsOnsets =  gripsOnsets(threshold,nlines,ncolons,force,trialOnset)
 
 
% This function compute the time of each grips based on the fact that each
% vector is calibrated for 12 s. We cannot preallocate the tmp and gripsOnsets
% variables because their size depends on the participants performances and
% cannot be predicted in advance. (Eva, 14.06.2015).
 
% exemple of the inputs
 
% force = ResultsRimind.mobilizedforce;
% trialOnset = ResultsRimind.TrialOnset;
% threshold = seuil;

 
 
for l = 1:ncolons
     
    grips = 0;
    gripsOnsets = 0;

    for i = 1:nlines - 2
         
        x = force (:,l);
         
        if x(i) < threshold && x (i+1) > threshold;
             
            grips = grips + 1;
            gripsOnsets (grips) = trialOnset(l) + (i*((12/nlines))); % the onset of the grips is equal to the onset of the trial + the time that has passed (the vector has been calibrated to record values for 12 s)
             
        end
        
         
    end
     
    gripsOnsets = gripsOnsets';
     
    tmp(l) = {gripsOnsets}; % we want to concatenate all grips Onsets in a single vector for that we have to create a temporary cell vector that contains the onsets for each trial that have different length
    all_gripsOnsets = vertcat(tmp{:});
     
end
 
end