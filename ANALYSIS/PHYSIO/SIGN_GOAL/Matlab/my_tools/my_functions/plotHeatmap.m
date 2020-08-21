function gaze_plot  = plotHeatmap (GazeX, GazeY)


gaze_plot = figure;
    
[~,~,scene,heatmapRGB] = getMeanSceneGaze (GazeX, GazeY);
imshow(scene);
hold on
h = fspecial('gaussian',5,3);
heatmapRGB = flipud(heatmapRGB);% reset y that was rescaled to the bmp scene and thus invereted
imshow(imfilter(heatmapRGB,h,'replicate'));

alpha(0.6)
set(gca,'YDir','reverse');
    
set(gcf, 'Position', [50 700 1000 300]);
set(gcf, 'Color', 'w');
box off


%% AUXILIARY FUNCTION
    function [meangazeX,meangazeY,scene,heatmapRGB] = getMeanSceneGaze (gazeX, gazeY)
        
        % first aggregate across all participants
        mean_x= cat(3,gazeX (:,:));
        mean_y = cat(3,gazeY (:,:));
        
        % then we aggreate all items in a vector
        meangazeX = mean_x(:);
        meangazeY = mean_y(:);
        
        [heatmapRGB,~,scene] = heatmap_generator([meangazeX, meangazeY],'Background.bmp',0.100,1,1,5,3);
        
    end


end