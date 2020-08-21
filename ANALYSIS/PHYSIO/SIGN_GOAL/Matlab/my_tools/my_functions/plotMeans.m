function graph = plotMeans (pattern, data, CSnamesList, CSlables)

% last modified dec 2017


means = structfun(@nanmean,  data);
%sems = structfun(@(x) nanstd(x)/sqrt(length(x)), data);

% adjust sems for within design
mean_variable     = nanmean ([data.(CSnamesList{1});data.(CSnamesList{2});data.(CSnamesList{3})],1);
big_mean          = nanmean (mean_variable);
adjustment_factor = repmat(big_mean,1,size(data.(CSnamesList{1}),2)) - mean_variable;

adjusted.(CSnamesList{1}) = data.(CSnamesList{1}) + adjustment_factor;
adjusted.(CSnamesList{2}) = data.(CSnamesList{2}) + adjustment_factor;
adjusted.(CSnamesList{3}) = data.(CSnamesList{3}) + adjustment_factor;

sems = structfun(@(x) nanstd(x)/sqrt(length(x)), adjusted);

color.means.(CSnamesList{1}) = [0.1 0.8 0.8]; % light blue (CS+L)
color.edge.(CSnamesList{1}) = [0 0.6 0.6];

color.means.(CSnamesList{2}) = [0.7 0.1 0.5]; % violet (CS+R)
color.edge.(CSnamesList{2}) = [0.5 0 0.2];

color.means.(CSnamesList{3}) = [0.25 0.25 0.25]; % dark gray (CS-)
color.edge.(CSnamesList{3}) = [0.1 0.1 0.1];


graph = figure;

y = means ((1:length(means)));
bars = sems (1:length(sems));

hold on

% adjust individual data for within design
mean_vector = nanmean([data.(CSnamesList{1})', data.(CSnamesList{2})', data.(CSnamesList{3})'],2);
big_mean = nanmean (mean_vector);
adjust_factor = big_mean - mean_vector;

for i = 1:length(CSnamesList)

    CSname = char(CSnamesList(i));  
    adj.(CSname) = data.(CSnamesList{i})' + adjust_factor;

end


for i = 1:length(CSnamesList)
    
    CSname = char(CSnamesList(i));
    bar(i,y(i), 0.5, 'faceColor', color.means.(CSname), 'EdgeColor', color.edge.(CSname), 'LineWidth', 1);  
    e = errorbar(i,y(i),bars(i),'.k', 'LineWidth', 1);
    set(e,'Color',color.edge.(CSname));
    s = scatter(i*ones(1,length(adj.(CSnamesList{i}))),adj.(CSnamesList{i}),[],'k', 'jitter','on', 'jitterAmount',0.05);
    set(s,'MarkerEdgeColor',color.edge.(CSname),'linewidth',0.5, 'MarkerEdgeAlpha', 0.3, 'LineWidth', 0.3);
    
end


set(gca, 'XTickLabel', '');
ylabel(pattern,'FontSize',16);
ypos = min(ylim)-0.002;

labelx = {CSlables{1},CSlables{2},CSlables{3}};
text([0.85  1.85  2.9],repmat(ypos,length(means),1), ...
    labelx,'verticalalignment','cap','FontSize',18)


set(gcf, 'Position', [50 250 380 250]);
set(gcf, 'Color', 'w');
box off
