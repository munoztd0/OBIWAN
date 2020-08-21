function raw_pupil_plot = plotRawPupil (Pupil_plot, CSnamesList, CSlabels)

% last modified oct 2016

%%% conditions: 1 = all; 2 = ID; 3 = SIDE

tmp = fieldnames(Pupil_plot);

means = NaN (size(tmp,1),size(Pupil_plot.(char(tmp(1))),2));
stds = NaN (size(tmp,1),size(Pupil_plot.(char(tmp(1))),2));

for ii = 1:length(CSnamesList)
    
    CSname                = char(CSnamesList(ii));
    xplot.(CSname)        = nanmean(Pupil_plot.(CSname),3);
    mean_variable(:,:,ii) = xplot.(CSname);
    average.(CSname)      = nanmean(xplot.(CSname),1);
    means(ii,:)           = average.(CSname);
    n                     = size(Pupil_plot.(CSname),1);
    std.(CSname)          = nanstd (xplot.(CSname), [],1) /sqrt(n); % adapt this for within designs
    stds(ii,:)            = std.(CSname);
    
end

% adapt error bars for within designs
mean_variable     = nanmean(mean_variable,3);
big_mean          = nanmean(mean_variable);
adjustment_factor = repmat(big_mean,size(mean_variable,1),1) - mean_variable;

for ii = 1:length(CSnamesList)
    
    CSname                = char(CSnamesList(ii));
    adjusted.(CSname)     = Pupil_plot.(CSname) + adjustment_factor;
    n                     = size(Pupil_plot.(CSname),1);
    std.(CSname)          = nanstd (adjusted.(CSname), [],1) /sqrt(n); % adapt this for within designs
    stds(ii,:)            = std.(CSname);
    
end

means(:,any(isnan(means),1)) = []; % remove nans
stds(:,any(isnan(stds),1)) = []; % remove nans

raw_pupil_plot = create_pupil_plot(means, stds, CSnamesList, CSlabels);

    function h = create_pupil_plot (means, stds, CSnamesList, CSlabels)
             
        
        color.means.(CSnamesList{1}) = [0.1 0.8 0.8]; % light blue (CS+L)
        color.stds.(CSnamesList{1}) = [0.1 0.8 0.8];
        
        color.means.(CSnamesList{2}) = [0.7 0.1 0.5]; % violet (CS+R)
        color.stds.(CSnamesList{2}) = [0.7 0.1 0.5];
        
        color.means.(CSnamesList{3}) = [0.2 0.2 0.2]; % dark gray (CS-)
        color.stds.(CSnamesList{3}) = [0.2 0.2 0.2];
        
        
        
        h = figure;
        xlabel ('Time (s) ', 'FontSize',24)
        ylabel ('Pupil baseline-corrected (mm)','FontSize',24);
        
        for iii = 1:size(means,1)
            average_line = means(iii,:);
            sdt_shade = stds(iii, :);
            name = char(CSnamesList(iii));
            
            u = 1:length(average_line) ;
            [hl.(['f' (num2str(iii))]),~] = boundedline(u,average_line',sdt_shade,'alpha','transparency',0.1,'cmap', color.means.(name));
            set(hl.(['f' (num2str(iii))]),'LineWidth',2,'Color', color.stds.(name));
            
        end
        
        % set legend according to the condition
        LEG = legend([hl.f1 hl.f2 hl.f3], CSlabels{1}, CSlabels{2}, CSlabels{3});
 
        
        set(LEG,'FontSize',22) % font size of the legend
        legend boxoff
        
        
        xright = length(average_line);
        step = ceil(xright/length([0.5 1 1.5 2 2.5 3]));
        xlim([1 xright])
        set(gca,'XTick',[0:step:xright]);% This automatically sets the.
        set(gca, 'XTickLabel', [0 0.5 1 1.5 2 2.5 3])
        
        
        set(gcf, 'Position', [50 750 380 750])
        set(gcf, 'Color', 'w')
        box off
        
    end


end