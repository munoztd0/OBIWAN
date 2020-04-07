function [RT_CSminus, RT_CSplus, ACC_CSminus, ACC_CSplus] = extractRT(matrix,threshold)

% created by Eva on 30.09.2015

matrix = matrix(:,2:(size(matrix,2))); % remove the colon of non-interest
matrix= sortrows(matrix,1); % sort according to experimental condition


part = size(matrix,1)/2 ; % how many item per experimental condition

%compute row RT
RT_CSminus = cell2mat(matrix(1:part,(size(matrix,2)))); % extract RT for CS plus
RT_CSplus = cell2mat(matrix(part+1: (2*part), (size(matrix,2)))); %extract RT for CS minus

% find percentage accuracy
ACC_CSminus = 100 -((length(find (RT_CSminus ==1)))*100/(length(RT_CSminus)));
ACC_CSplus = 100 -((length(find (RT_CSplus ==1)))*100/(length(RT_CSplus)));

% remove the error from the RT
RT_CSminus(find(RT_CSminus ==1)) = nan;
RT_CSplus(find(RT_CSplus ==1)) = nan;

% remove too slow response
%RT_CSminus (find (RT_CSminus > threshold)) = nan;
%RT_CSplus (find (RT_CSplus > threshold)) = nan;

%compute mean
RT_CSminus = nanmean(RT_CSminus);
RT_CSplus = nanmean(RT_CSplus);

end