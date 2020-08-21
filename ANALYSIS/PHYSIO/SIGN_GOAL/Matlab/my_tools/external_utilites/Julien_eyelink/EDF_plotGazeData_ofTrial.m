%
% plot fixations, saccades of a given trial
%
%
% posImgAll: list of positions at which images are presented. each row is [x1 y1 x2 y2]
% categoryOfStims: category for each image listed in posImgAll.
%
%urut/nov13
function EDF_plotGazeData_ofTrial(ax, gazeDataTrials, k, posImgAll, categoryOfStims)
axes(ax);

if nargin<3
    posImgAll=[];
end

    hold on
    plot( gazeDataTrials(k).gx, gazeDataTrials(k).gy, '.','MarkerSize', 10 );
    hold off



% mark fixations
if ~isempty(gazeDataTrials(k).fixInfo)
    hold on
    plot( gazeDataTrials(k).fixInfo(:,1), gazeDataTrials(k).fixInfo(:,2), 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r' );
    
    %mark first fixation
    plot( gazeDataTrials(k).fixInfo(1,1), gazeDataTrials(k).fixInfo(1,2), 'mo', 'MarkerSize', 20, 'MarkerFaceColor', 'm' );    
    hold off

    %-- 
    
    % mark if fixations fall on stimuli
    if ~isempty(posImgAll)
        for jj=1:size(gazeDataTrials(k).fixInfo,1)
            
            fixPos = gazeDataTrials(k).fixInfo(jj,[1 2]);
            
            fixLocation = determineFixationPos_inArray( fixPos, posImgAll );
            
            if fixLocation>-1
                
                %text( fixPos(1), fixPos(2), ['C=' num2str(categoryOfStims( fixLocation )) ]);
            else
                %text( fixPos(1), fixPos(2), ['C=out']);
                
            end
        end
    end
    
    % mark saccades
if ~isempty(gazeDataTrials(k).saccInfo)
    hold on
    for j=1:size(gazeDataTrials(k).saccInfo,1)
        plot( gazeDataTrials(k).saccInfo(j,[1 3]), gazeDataTrials(k).saccInfo(j,[2 4]), 'g-d','Linewidth',2 );
    end
    hold off
end
    

end

