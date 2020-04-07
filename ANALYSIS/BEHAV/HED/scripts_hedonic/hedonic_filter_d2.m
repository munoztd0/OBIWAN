%function hedonic_filter_d2();

load('hedonic26_day2.mat')

matrix = [data.odorLabel,num2cell(data.liking),num2cell(data.liking)];


% find chocolate
chocolatePosition = findLabelPosition('chocolate',data.odorLabel);
chocolateLiking = nan(1,size(chocolatePosition,2));
chocolateIntensity = nan (1,size(chocolatePosition,2));
chocolateOnset = nan (size(chocolatePosition,2),1);

for i = 1:size(chocolatePosition,2)
    chocolateLiking (i) = data.liking(chocolatePosition(i));
end

for i = 1: size(chocolatePosition,2)
    chocolateIntensity (i)= data.intensity(chocolatePosition(i));
end 

for i = 1:size(chocolatePosition,2)
    chocolateOnset (i) = data.sniffSignalOnset(chocolatePosition(i));
end


%find empty
emptyPosition = findLabelPosition ('empty',data.odorLabel);
emptyLiking = nan(1,size(emptyPosition,2));
emptyIntensity = nan (1,size(emptyPosition,2));
emptyOnset = nan (size(emptyPosition,2),1);

for i = 1:size(emptyPosition,2)
    emptyLiking (i) = data.liking(emptyPosition(i));
end

for i = 1: size(emptyPosition,2)
    emptyIntensity(i) = data.intensity(emptyPosition(i));
end

for i = 1: size(emptyPosition,2)
    emptyOnset (i) = data.sniffSignalOnset(emptyPosition(i));
end

% find neutral
otherPosition = [chocolatePosition,emptyPosition];
allPosition = 1:size(data.odorLabel,1);

neutralPosition = ismember(allPosition,otherPosition); % the position is coded = 0
neutralPosition = find(neutralPosition == 0); % this gave teh actual position of the neutral odor in the vector
neutralLiking = nan(1,size(neutralPosition,2));
neutralIntensity = nan(1,size(neutralPosition,2));
neutralOnset = nan (size(neutralPosition,2),1);

for i = 1: size(neutralPosition,2)
    neutralLiking (i) = data.liking(neutralPosition(i));
end

for i = 1:size(neutralPosition,2)
    neutralIntensity(i) = data.intensity(neutralPosition(i));
end

for i = 1:size(neutralPosition,2)
    neutralOnset(i) = data.sniffSignalOnset(neutralPosition(i));
end

% Onset of no interest

trialStartOnset = data.tTrialStart;
%likingOnset = data.likingOnset; attention here the script need to be
%modified at the bbl
likingOnset = data.sniffSignalOnset+data.duration.asterix1+data.duration.oCommitISI+ data.duration.asterix2+data.duration.jitter;

%intensityOnset = data.intensityOnset;attention here the script need to be
%modified at the bbl
intensityOnset = data.sniffSignalOnset+data.duration.asterix1+data.duration.oCommitISI+ data.duration.asterix2+data.duration.jitter+data.duration.Liking+data.duration.IQCross;
ITIOnset = data.sniffSignalOnset+data.duration.asterix1+data.duration.oCommitISI+ data.duration.asterix2+data.duration.jitter+data.duration.Liking+data.duration.IQCross+data.duration.Intensity;

behavioralResults = [chocolateLiking,neutralLiking,emptyLiking,chocolateIntensity,neutralIntensity,emptyIntensity];

% to transform the value in a scale from 0 to 100
rescaledBehavioralResults = rescale(behavioralResults);

%end