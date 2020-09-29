
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
addpath /usr/local/MATLAB/R2019a/Ilab/
addpath /usr/local/MATLAB/R2019a/eeglab/


%% DEFINE POPULATION
control = [homedir 'SOURCEDATA/physio/control*'];
obese = [homedir 'SOURCEDATA/physio/obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);
session = {'second'; 'third'}; 
x = [];
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
        %data = EYD;
        
        if j == 1 
            ses = 1;
            num = number;
        else      
            ses = 2;
            num = number;
            number = ['2' number];

        end

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



        %pspm_jobman('run',matlabbatch)

        EEG.etc.eeglabvers = '2020.0'; % this tracks which version of EEGLAB is being used, you may ignore it
        EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',[homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/' number '.mat'],'setname',number,'srate',60,'subject',number,'pnts',0,'xmin',0,'session',1,'group','1');
        EEG = eeg_checkset( EEG );
        EEG = pop_chanevent(EEG, 3,'edge','leading','edgelen',0,'delchan','off');
        EEG = eeg_checkset( EEG );
        EEG = pop_rmdat( EEG, {'16','32','64'},[-1 10] ,0);
        EEG = eeg_checkset( EEG );
        EEG.data(5,:) = str2num(num);
        EEG.data(6,:) = ses;
        EEG.data(7,:) = 0;
        l = 0;
        for k  = 1:length(EEG.data(6,:)) 
            if EEG.data(3,k) == 16 ||  EEG.data(3,k) == 32 || EEG.data(3,k) == 64
                if EEG.data(3,k-1) ~= 16 ||  EEG.data(3,k-1) ~= 32 || EEG.data(3,k-1) ~= 64
                   l = l+ 1;
                   EEG.data(7,k) = l ;
                end
            end
        end
            
                    
        pupil_raw = EEG{1, 1}.data  ;
        pupil_raw = pupil_raw/100; % transform pupil in mm
        %plot(pupil_raw)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 1. REMOVE EVIDENT BLINK A

        %badDataIndexes = pupil < 0.5 | pupil > 10; % remove the evident blinks and evident artifacts
        badDataIndexes = pupil_raw < 0.15 | pupil_raw > 0.6; % remove the evident blinks and evident artifacts
        pupil = pupil_raw;
        pupil(badDataIndexes) = NaN; % Remove bad data

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 2. REMOVE EXTRAM VALUES

        SD = 3;
        interQuartile = iqr(pupil);

        %-------------------------------------------------------------------------%
        % option 1: median filter on the overall signal

        meanValue = nanmedian(pupil);

        maxAllowablePupilDiameter = meanValue + SD*interQuartile;
        minAllowablePupilDiameter = meanValue - SD*interQuartile;

        badDataIndexes = pupil > maxAllowablePupilDiameter;
        pupil(badDataIndexes) = NaN; % Remove bad data

        badDataIndexes = pupil < minAllowablePupilDiameter;
        pupil(badDataIndexes) = NaN; % Remove bad data

        %%% quantify the amoung of data that have been removed
        missingdata = sum (isnan(pupil)); % row
        missingdata = (missingdata*100)/ length(pupil); % missing data in percentage

        %%% substitue NaN with the closest non NaN value

        for lineIndex = 1:size(pupil,2)
            for rowIndex = size(pupil,1):-1:2
                CurrentValue = pupil(rowIndex, lineIndex);
                if ~isnan(CurrentValue) && isnan(pupil(rowIndex-1, lineIndex))
                    pupil(rowIndex-1, lineIndex) = CurrentValue;
                end
            end
        end

         pupil1 = pupil;
        %-------------------------------------------------------------------------%
        % using local window using hampel to smooth more and remove more striclty extream values data of problematic
        % subjects (we dont want data that have been intrapolate for more than 40%
        % of the time to have a big impact on our analysis)
        if  missingdata > 75.00 
            continue
        else
            pop_export(EEG,[number '.txt'],'transpose','on','precision',4);

            % Setup the Import Options and import the data
            opts = delimitedTextImportOptions("NumVariables", 6);
            opts.DataLines = [2, Inf];
            opts.Delimiter = "\t";
            opts.VariableNames = ["time", "x", "y", "marker", "pupil", "ID", "session", 'trial'];
            opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double"];
            opts.ExtraColumnsRule = "ignore";

            % Import the data
            df = readtable([homedir 'SOURCEDATA/physio/' subjX '/ses-' session{j} '/' number '.txt'], opts);

            x = [x; df];    
        end
        
        
        disp(['done_sub-' subjX])
        
    end
    
    cd ([homedir 'DERIVATIVES/BEHAV'])
    filename = 'PAV_pup.txt';
    fid = fopen(filename, 'wt');
    fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'time', 'x', 'y', 'marker', 'pupil', 'ID', 'session', 'trial');  % header
    fclose(fid);
    dlmwrite(filename,x.Variables,'delimiter','\t','-append');
    
end