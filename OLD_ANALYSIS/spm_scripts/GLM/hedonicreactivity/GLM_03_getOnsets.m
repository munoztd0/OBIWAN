function GLM_03_getOnsets()

% intended for OBIWAN hedonic reactivity run

% get onsets for first control model (reward vs neutral)
% Stick functions
% Simplified model on ONSETs 7 (STARTTRIAL, TASTE with modulators intesity liking familiartiy 3*questions 1 RINSE)
% last modified on MARCH 2018

%% define paths

homedir = '/home/OBIWAN/';
%homedir = '/Users/evapool/mountpoint2/';

mdldir        = fullfile (homedir, '/DATA/STUDY/MODELS/SPM');
sourcefiles   = fullfile(homedir, '/DATA/STUDY/DERIVED/PIT_HEDONIC');
addpath (genpath(fullfile(homedir,'/ANALYSIS/my_tools')));

ana_name      = 'GLM-03-control';
session       = {'second'};
runs          = {'hedonicreactivity'};

subj          = {'100'    ;'102'    ;'105'    ;'106'    ;'107'    ;'108'    ;'109'    ;'110'    ;'112'    ;'113'    ;'114'    ;'115'    ;'116'    ;'118'    ;'119'    ;'120'    ;'121'    ;'122'    ;'124'    ;'125'    ;'126'    ;'127'    ;'128'    ;'129'    ;'130'    ;'131'    ;'132'    ;'133'    };     % subject ID
group         = {'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control'}; % control or obsese

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
        % Get onsets and durations for start
        onsets.trialstart    = ONSETS.trialstart;
        durations.trialstart = zeros (length(onsets.trialstart),1);
        modulators.trialstart = ones (length(onsets.trialstart),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for taste
        onsets.taste               = ONSETS.liquid;
        durations.taste            = zeros (length(onsets.taste),1);
        modulators.taste.liking    = BEHAVIOR.liking;
        modulators.taste.intesity  = BEHAVIOR.intensity;
        modulators.taste.familiarity= BEHAVIOR.familiarity;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and duration questions
        onsets.liking            = ONSETS.liking;
        durations.liking         = DURATIONS.liking;
        modulators.liking        = ones (length(onsets.liking),1);
        
        onsets.intensity         = ONSETS.intensity;
        durations.intensity      = DURATIONS.intensity;
        modulators.intensity     = ones (length(onsets.intensity),1);
        
        onsets.familiarity       = ONSETS.familiarity;
        durations.familiarity    = DURATIONS.familiarity;
        modulators.familiarity   = ones (length(onsets.familiarity),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and duration for rinse
        onsets.rinse             = ONSETS.rince;
        durations.rinse          = DURATIONS.rince;
        modulators.rinse         = ones (length(onsets.rinse),1);
        
        %% FOR FSL
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) % let's save all info in the participant directory
        
        % create text file with 3 colons: onsets, durations, paretric modulators
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = {'trialstart'; 'taste'; 'liking'; 'intensity'; 'familiarity'; 'rinse'};
        
        for ii = 1:length(name)
            
            nameX = char(name(ii));
            
            if strcmp (nameX, 'taste') % for structure that contains modulators
                
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
                
                
                substr = {'liking';'intesity'; 'familiarity'};% specify the substructures names
                
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