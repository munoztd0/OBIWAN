
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT EYEDATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by David


dbstop if error
clear all

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN/'];

addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));
addpath /usr/local/MATLAB/R2020a/Ilab/
%% DEFINE POPULATION
control = [homedir 'SOURCEDATA/physio/control*'];
obese = [homedir 'SOURCEDATA/physio/obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);
session = {'second'; 'third'}; 

for j = 1:length(session)
    for i = 1:length(subj)

        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        number = subjX(end-2:end);
        

        fileX = dir([homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/*.eyd']);
        
        if length(fileX) == 0 
           continue
        end
        
        if length(fileX) > 1 
           fileX(1).name = fileX(2).name; %when the first one fails
        end
        
        file = fileX(1).name;
        %folder = '/home/cisa/OBIWAN/SOURCEDATA/physio/control100/ses-second/';
        folder = [homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/'];
        %EYD = ilabConvertASL(folder, file, 6);

        cd(folder)
        data = EYD;
        
        if j == 1 
            
            %data = data.data;
            %save([ number], 'data') 
            
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.datafile = {[homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/' number '.mat']};
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.pupil.chan_nr.chan_nr_spec = 4;
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.pupil.sample_rate = 60;
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{2}.marker.chan_nr.chan_nr_spec = 3;
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{2}.marker.sample_rate = 60;
            matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = true;
            
          
            matlabbatch{2}.pspm{1}.prep{1}.trim.datafile(1) = cfg_dep('Import: Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.from.mrval = '16';
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.from.mrksec = 0;
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.to.mrval = '48';
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.to.mrksec = 0;
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.mrk_chan.chan_def = 0;
            matlabbatch{2}.pspm{1}.prep{1}.trim.overwrite = true;



            pspm_jobman('run',matlabbatch)
        else
            %data = data.data;
            %save(['2' number], 'data')
            
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.datafile = {[homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/2' number '.mat']};
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.pupil.chan_nr.chan_nr_spec = 4;
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.pupil.sample_rate = 60;
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{2}.marker.chan_nr.chan_nr_spec = 3;
            matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{2}.marker.sample_rate = 60;
            matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = true;
            
            matlabbatch{2}.pspm{1}.prep{1}.trim.datafile(1) = cfg_dep('Import: Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.from.mrval = '16';
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.from.mrksec = 0;
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.to.mrval = '48';
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.to.mrksec = 0;
            matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk_vals.mrk_chan.chan_def = 0;
            matlabbatch{2}.pspm{1}.prep{1}.trim.overwrite = true;

            pspm_jobman('run',matlabbatch)
            

        end
       disp(['done_sub-' subjX])
        
    end
end