function save_figures (name, figure_dir, current_dir)


cd (figure_dir)
saveas(gcf, [name '.png']);
export_fig ([name '.png']);
print([name '.pdf'], '-dpdf');
    
cd (current_dir)
