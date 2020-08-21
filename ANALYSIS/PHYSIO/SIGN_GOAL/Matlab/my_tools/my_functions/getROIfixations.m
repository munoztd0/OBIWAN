function [mean_number_duration] = getROIfixations(ROI_matrix_toolbox,variableX,variableY,timestamp,roiID)

% define the parameters and create the analysis matrix that are necessary 
% for the toolbox extracting the fixations and performing the ROI analysis 
% uses EyeMMV toolbox of Krassanakis, 2014.
% last modified on Jan 2017

% fixed parameters
maxx   = 1;     % max in tracker unit that are in percentages
maxy   = 1;     % max in tracker unit that are in percentages
minDur = 0.050; % min duration in ms
t1     = 0.100; % spatial constained to define a fixation in tracker unit
t2     = 0.200;

% initialize matrix 
mean_number_duration = zeros (size(variableX,1),3); %3 values are collected: mean_duration of the the fixations in the ROI, percentages of the roi fixations across all fixations during item, percentage of time spend fixating the ROI across the duration of the other fixations
for i = 1:size(variableX,1)
    
    % matrix by item
    x      = variableX (i,:)';
    y      = variableY (i,:)';
    t      = timestamp(i,:)';
    
    gaze_f = [x,y,t]; % data in a matrix x y and time
    
    % detect fixations
    [fixation_list_t2,fixation_list_3s]=fixation_detection(gaze_f,t1,t2,minDur,maxx,maxy,0); % last argument of the function 0 = do not display plots and do not print messages
    %visualizations(gaze_f,fixation_list_t2,0.1); % remove this after if you dont want a plot invasion
    
    % perform ROI analysis
    [fixations_in_roi]         = ROI_analysis(fixation_list_t2,ROI_matrix_toolbox,roiID,0);
    mean_number_duration (i,:) = fixations_in_roi.item_average;
    
    % perform ROI analysis
    [fixations_in_roi]         = ROI_analysis(fixation_list_t2,ROI_matrix_toolbox,roiID,0);
    mean_number_duration (i,:) = fixations_in_roi.item_average;
    
end