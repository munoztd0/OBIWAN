function [RT] = cleanRT (RT_row)

%last modified by Eva may 2016

%remove non-response

RT = RT_row;

% remove anticipations
RT(RT<0.100) = nan; % RT smaller than 50 ms

% % remove extram value
% RT_m = nanmedian(RT); %mean
% RT_sd = iqr(RT); % Std
% outlyer = RT_m + (3*RT_sd);
% 
% RT(RT>outlyer) = nan;  % remove RT bigger and smaller than 3 std from the mean
% 
% outlyer = RT_m - (3*RT_sd);
% RT(RT>outlyer) = nan;  % remove

end