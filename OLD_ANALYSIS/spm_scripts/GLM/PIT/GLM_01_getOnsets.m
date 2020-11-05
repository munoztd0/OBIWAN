function GLM_01_getOnsets()

% intended for OBIWAN PIT run

% get onsets for first control model (reward vs neutral)
% Stick functions
% Simplified model on ONSETs 3*CS with modulator and grips as control
% last modified on APRIL 2018

%% define paths

%homedir = '/home/OBIWAN/';
%homedir = '/home/cisa/mountpoint/';
homedir = '/home/cisa/mountpoint/OBIWAN/';

mdldir        = fullfile (homedir, '/DATA/STUDY/MODELS/SPM');
sourcefiles   = fullfile(homedir, '/DATA/STUDY/DERIVED/PIT_HEDONIC');
addpath (genpath(fullfile(homedir,'/ANALYSIS/my_tools')));

ana_name      = 'GLM-01';
session       = {'second'};
runs          = {'PIT'};
subj          = {'129'    ;'131'    ;'132'    ;'133'    ;'213'  ;'216'  ;'219'  ;'220'  ;'221'  };     % subject ID
group         = {'control';'control';'control';'control';'obese';'obese';'obese';'obese';'obese'}; % control or obsese

%% create folder  
mkdir (fullfile (mdldir, char(runs), ana_name)); % this is only because we have one run per task

%% extract and save data
for j = 1:length(runs)
    
    runX      = char(runs(j));
    sessionX  = char(session(j));
    
    for  i=1:length(subj)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load participants data
        subjX=[char(group(i)) char(subj(i))];
        
        subjdir=fullfile(mdldir, char(runs), ana_name,  ['sub-' subjX],'timing');
        mkdir (subjdir)
       
        cd (fullfile(sourcefiles,['sub-' subjX],['ses-' sessionX],'func'));
        behavfile = ['sub-' num2str(subjX) '_ses-' sessionX '_task-' runX '_run-01_events.mat'];
        fprintf('participant number: %s run: %s \n', subj{i}, runs{j})
        disp(['file ' num2str(i) ' ' behavfile]);
        load (behavfile);
        
        %% FOR SPM
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS
        onsets.CS.CSp          = ONSETS.trial(strcmp ('CSplus', CONDITIONS.CS));
        onsets.CS.CSm          = ONSETS.trial(strcmp ('CSminus', CONDITIONS.CS));
        onsets.CS.Baseline     = ONSETS.trial(strcmp ('BL', CONDITIONS.CS));
        
        durations.CS.CSp       = DURATIONS.trial(strcmp ('CSplus', CONDITIONS.CS))';
        durations.CS.CSm       = DURATIONS.trial(strcmp ('CSminus', CONDITIONS.CS))';
        durations.CS.Baseline  = DURATIONS.trial(strcmp ('BL', CONDITIONS.CS))';
        
        modulators.CS.CSp      = BEHAVIOR.gripFreq(strcmp ('CSplus', CONDITIONS.CS))';
        modulators.CS.CSm      = BEHAVIOR.gripFreq(strcmp ('CSminus', CONDITIONS.CS))';
        modulators.CS.Baseline = BEHAVIOR.gripFreq(strcmp ('BL', CONDITIONS.CS))';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips
        onsets.grips           = ONSETS.grips;
        durations.grips       = zeros (length(onsets.grips),1);
        modulators.grips      = ones  (length(onsets.grips),1);
        
       
        %% FOR FSL
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) % let's save all info in the participant directory
        
        % create text file with 3 colons: onsets, durations, paretric modulators
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = { 'CS'; 'grips'};
        
        for ii = 1:length(name)
            
            nameX = char(name(ii));
            
            if strcmp (nameX, 'CS')  % for structure that contains substuctures
                substr = {'CSp'; 'CSm'; 'Baseline'};% specify the substructures names
                
                for iii = 1:length(substr)
                    substrX = char(substr(iii));
                    nameXX  = [nameX '_' substrX]; % name that combines the structure and the substructures
                    % database with three rows of interest
                    database.(nameXX) = [num2cell(onsets.(nameX).(substrX)), num2cell(durations.(nameX).(substrX)), num2cell(modulators.(nameX).(substrX))];
                    % save the database in a txt file
                    fid = fopen ([ana_name '_run-' runX '_' nameX '_' substrX '.txt'],'wt');
                    formatSpec = '%d   %d   %d\n';
                    [nrows,~] = size(database.(nameXX));
                    for row = 1:nrows
                        fprintf(fid,formatSpec,database.(nameXX){row,:});
                    end
                    fclose(fid);
                end
                
          else
                % database with three rows of interest %%%% ADD MODULATORS
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