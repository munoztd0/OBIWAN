function gripsFrequence =  countgrips (threshold,nlines,ncolons,force)
 
%threshold is 50% of the maximal force
%nlines and ncolons are the colon and lines of the matrix containing the
%row data on the handgrip (from the avatch device)
%force is the enitre matrix of interest from which the pics will be counted
 
gripsFrequence = zeros (1,ncolons);
 
for l = 1:ncolons
     
    grips = 0;
     
    for i = 1:nlines - 2
         
        x = force (:,l);
         
        if x(i) < threshold && x (i+1) > threshold;
            grips = grips + 1;
        end
         
    end
     
    gripsFrequence (l) = grips; % DV of interest
     
end
 
end