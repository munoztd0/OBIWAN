function [ROI_L, ROI_R, ROI_U, ROI_D, ROI_matrix_toolbox] = defineROI ()

%last modified oct


ROIsdim = 1/6; % base of the ROI rectangle
ROI_from_center = ROIsdim/2; %
unit = 0.001;

small_vector = getVector (0.15,unit,ROI_from_center);
big_vector = getVector (0.85,unit,ROI_from_center);
center_vector = getVector (0.50,unit,ROI_from_center);

ROI_L = getROI (small_vector, center_vector); % vector x_center vector y_center
ROI_R = getROI (big_vector, center_vector); % vector x_center vector y_center
ROI_U = getROI (center_vector, small_vector); % vector x_center vector y_center
ROI_D = getROI (center_vector, big_vector); % vector x_center vector y_center

% The Y axis of hte screen is inverted (0 is up left) compared with the euclidian xy space of the analyis thus we reverse the Up and Down ROI computed with Y axis of the computer screen
tmp1 = ROI_U;
tmp2 = ROI_D;
ROI_U = tmp2;
ROI_D = tmp1;

ROI_L_toolbox = getROImatrix (ROI_L,1); % number of ROI from left to right clockwise
ROI_R_toolbox = getROImatrix (ROI_R,3);
ROI_U_toolbox = getROImatrix (ROI_U,2);
ROI_D_toolbox = getROImatrix (ROI_D,4);


ROI_matrix_toolbox = [ROI_L_toolbox;ROI_U_toolbox;ROI_R_toolbox;ROI_D_toolbox];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUXILIARY FUNCTIONS

    function [vector] = getVector (center_coordinate,unit,ROI_from_center)
        
        % input
        % center_coordinate = center coordinate of the vector of interest
        % unit              = decimal precision of the output data (e.g., 0.01, 0.001..)
        % ROI_from_center   = half of the side defining the square ROI (distance
        % from ROI the center)
        
        % output
        % semiBase_upper and lower = first and second half (from the center) of the vector
        
        semiBase_upper = center_coordinate:unit:(center_coordinate+ROI_from_center);
        semiBase_lower = ((center_coordinate-ROI_from_center):unit:(center_coordinate-unit));
        semiBase_upper = semiBase_upper';
        semiBase_lower = semiBase_lower';
        vector = [semiBase_lower;semiBase_upper];
        
    end

    function [ROI]    = getROI (vectorX, vectorY)
        
        %y = zeros (length(vectorX),length(vectorX)); % do note initialize or
        %matrix dimension will not correspond during the for loop
        
        for i = 1:length(vectorX)
            y (:,i) = repmat (vectorY (i),length(vectorY),1);
            Y = cat(1,y(:));
            X = repmat (vectorX,i,1);
            ROI = [X,Y];
        end
        
    end

    function [ROI_for_toolbox] = getROImatrix (ROI,roiID)
        
        % last modified by Eva feb 2016
        
        % this function creates the ROI matrix for the eyeMMV ROI analysis Toolbox
        
        x_up_left = min(ROI(:,1)); % x
        y_up_left = max (ROI (:,2));
        
        x_down_right = max (ROI(:,1));
        y_down_right = min (ROI(:,2));
        
        ROI_for_toolbox = [x_up_left,y_up_left,x_down_right,y_down_right,roiID];
        
    end

end