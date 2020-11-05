function GLM_HTD_01_getOnsets()

% Hybrid preparatory model based regressors for the preparatory
% model only: value on CS and ANT prediction error on US. reward presence (01) as modulator on US and left and right as
% non-interest modulators.
% uses stick functions

% last modified on April 2018

%% define paths

%homedir = '/home/eva/PAVMOD/';
homedir = '/Users/evapool/mountpoint/';

mdldir        = fullfile (homedir, '/DATA/brain/MODELS/SPM');
sourcefiles   = fullfile(homedir, '/DATA/behavior');
addpath (genpath(fullfile(homedir,'/ANALYSIS/my_tools')));

ana_name      = 'GLM-HTD-01';
runs          = {'01'; '02'};

subj          = {'01'; '03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'};
%subj         = {'01'};

%% population estimated for the model free parameters

%alpha0.PREP   = 0.6539;
%alpha0.CONS_L = 0.5160;
%alpha0.CONS_R = 0.6166;

K.PREP   = 0.4744;
%K.CONS_L = 0.5589;
%K.CONS_R = 0.6228;

S.PREP   = 0.4436;
%S.CONS_L = 0.3957;
%S.CONS_R = 0.4362;

%% create folder
mkdir (fullfile (mdldir, ana_name))

%% extract and save data


for  i=1:length(subj)
    
    for j = 1:length(runs)
        
        runX      = char(runs(j));
        clear data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load participants data
        subjX=char(subj(i));
        
        subjdir=fullfile(mdldir, ana_name,  ['sub-' subjX],'timing');
        mkdir (subjdir)
        
        cd (sourcefiles)
        behavfile = ['PAV_fMRI_', subjX, '_' runX(end) '.mat'];
        fprintf('participant number: %s run number:  %s \n', subj{i}, runs{j})
        disp(['file ' num2str(i) ' ' behavfile]);
        load (behavfile);
        
        %% MODEL BASED REGRESSORS
        
        if strcmp(runX, '01')
            
            v0.PREP.AL  = 0.5; v0.PREP.AR  = 0.5; v0.PREP.BL  = 0.5; v0.PREP.BR  = 0.5; v0.PREP.M  = 0.5; v0.PREP.iti = 0;
            alpha0.PREP.AL = 0.6539; alpha0.PREP.AR = 0.6539; alpha0.PREP.BL = 0.6539; alpha0.PREP.BR = 0.6539; alpha0.PREP.M = 0.6539; alpha0.PREP.iti = 0.6539;
            
        end
        
        data_task = data; % we want to up data for the current block after having comuputed the VV by condition to initialize the second run
        
        data_task.whichMDL = 1; %1  = preparatory RW model (tracks all rewards indistictivly)
        [VV.prep.ant, PE.prep.us, VV.prep.iti, PE.prep.cs, alpha.PREP, v0.PREP, alpha0.PREP] = simulate_HTD_MRI (alpha0.PREP, K.PREP, S.PREP, data_task, 0, v0.PREP);
        
        
        %% FOR SPM
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS
        onsets.CS              = data.onsets.CS;
        durations.CS           = zeros(length(data.durations.CS),1);
        modulators.CS.PEcs     = zscore(PE.prep.cs);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for ANT
        onsets.ANT             = data.onsets.anticipation;
        durations.ANT          = zeros(length(data.durations.anticipation),1);
        modulators.ANT.VV      = zscore(VV.prep.ant);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets duration for US   
        onsets.US             = data.onsets.US;
        durations.US          = zeros(length(data.durations.US),1);
        
        modulators.US.PEus    = zscore(PE.prep.us);
        
        data.US_side(data.US_side==2)= 1; % code 1 reward
        data.US_side(data.US_side==0)= 0; % code 0 no reward
        modulators.US.reward  = data.US_side;
      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets for the actual modor response
        
        onsets.ACTION_left     = data.onsets.US(strcmp('9(', data.behavior.USbutton)==1) + data.behavior.USRT(strcmp('9(', data.behavior.USbutton)==1);
        durations.ACTION_left  = zeros(length(onsets.ACTION_left),1);
        modulators.ACTION_left = ones(length(onsets.ACTION_left),1);
        
        onsets.ACTION_right    = data.onsets.US(strcmp('6^', data.behavior.USbutton)==1) + data.behavior.USRT(strcmp('6^', data.behavior.USbutton)==1);
        durations.ACTION_right = zeros(length(onsets.ACTION_right),1);
        modulators.ACTION_right= ones(length(onsets.ACTION_right),1);
        
        
        %% FOR FSL
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) % let's save all info in the participant directory
        
        % create text file with 3 colons: onsets, durations, parametric modulators
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = {'CS'; 'ANT'; 'US'; 'ACTION_left'; 'ACTION_right'};
        
        for ii = 1:length(name)
            
            nameX = char(name(ii));
            
            if strcmp (nameX, 'US') % for structure that contains modulators
                
                % first register the onset only (this will be the variable
                % the modulators will be orthogonalized to
                database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(ones(length(onsets.(nameX)),1))]; % put one as a modulator
                % save the database in a txt file
                fid = fopen ([ana_name '_run-' runX '_' nameX '.txt'],'wt');
                formatSpec = '%d   %d   %d\n';
                [nrows,~] = size(database.(nameX));
                for row = 1:nrows
                    fprintf(fid,formatSpec,database.(nameX){row,:});
                end
                fclose(fid);
                
                
                substr = {'PEus';'reward'};% specify the substructures names
                
                for iii = 1:length(substr)
                    
                    substrX = char(substr(iii));
                    nameXX  = [substrX]; % name that combines the structure and the substructures
                    
                    % database with three rows of interest
                    database.(nameXX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX).(nameXX))]; % change the modulators value only
                    % save the database in a txt file
                    fid = fopen ([ana_name '_run-' runX '_' nameXX '.txt'],'wt');
                    formatSpec = '%d   %d   %d\n';
                    [nrows,~] = size(database.(nameX));
                    for row = 1:nrows
                        fprintf(fid,formatSpec,database.(nameXX){row,:});
                    end
                    fclose(fid);
                end
                
                
            elseif  strcmp (nameX, 'CS') % for structure that contains modulators
                
                % first register the onset only (this will be the variable
                % the modulators will be orthogonalized to
                database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(ones(length(onsets.(nameX)),1))]; % put one as a modulator
                % save the database in a txt file
                fid = fopen ([ana_name '_run-' runX '_' nameX '.txt'],'wt');
                formatSpec = '%d   %d   %d\n';
                [nrows,~] = size(database.(nameX));
                for row = 1:nrows
                    fprintf(fid,formatSpec,database.(nameX){row,:});
                end
                fclose(fid);
                
                
                substr = {'PEcs'};% specify the substructures names
                
                for iii = 1:length(substr)
                    
                    substrX = char(substr(iii));
                    nameXX  = [substrX]; % name that combines the structure and the substructures
                    
                    % database with three rows of interest
                    database.(nameXX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX).(nameXX))]; % change the modulators value only
                    % save the database in a txt file
                    fid = fopen ([ana_name '_run-' runX '_' nameXX '.txt'],'wt');
                    formatSpec = '%d   %d   %d\n';
                    [nrows,~] = size(database.(nameX));
                    for row = 1:nrows
                        fprintf(fid,formatSpec,database.(nameXX){row,:});
                    end
                    fclose(fid);
                end
                
            elseif  strcmp (nameX, 'ANT') % for structure that contains modulators
                
                % first register the onset only (this will be the variable
                % the modulators will be orthogonalized to
                database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(ones(length(onsets.(nameX)),1))]; % put one as a modulator
                % save the database in a txt file
                fid = fopen ([ana_name '_run-' runX '_' nameX '.txt'],'wt');
                formatSpec = '%d   %d   %d\n';
                [nrows,~] = size(database.(nameX));
                for row = 1:nrows
                    fprintf(fid,formatSpec,database.(nameX){row,:});
                end
                fclose(fid);
                
                
                substr = {'VV'};% specify the substructures names
                
                for iii = 1:length(substr)
                    
                    substrX = char(substr(iii));
                    nameXX  = [substrX]; % name that combines the structure and the substructures
                    
                    % database with three rows of interest
                    database.(nameXX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX).(nameXX))]; % change the modulators value only
                    % save the database in a txt file
                    fid = fopen ([ana_name '_run-' runX '_' nameXX '.txt'],'wt');
                    formatSpec = '%d   %d   %d\n';
                    [nrows,~] = size(database.(nameX));
                    for row = 1:nrows
                        fprintf(fid,formatSpec,database.(nameXX){row,:});
                    end
                    fclose(fid);
                end
                
                
            else
                
                % database with three rows of interest
                database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX))];
                % save the database in a txt file
                fid = fopen ([ana_name '_run-' runX '_' nameX '.txt'],'wt');
                formatSpec = '%d   %d   %d\n';
                [nrows,~] = size(database.(nameX));
                for row = 1:nrows
                    fprintf(fid,formatSpec,database.(nameX){row,:});
                end
                fclose(fid);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        mat_name = [ana_name '_run-' runX '_onsets'];
        save (mat_name, 'onsets', 'durations', 'modulators')
        
    end
    
end

end