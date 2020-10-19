function GLM_01_getOnsets()

% intended for OBIWAN hedonic reactivity run

% get onsets for first control model (reward vs neutral)
% Stick functions
% Simplified model on ONSETs 7 (STARTTRIAL, 2*TASTE with modulator (liking
% ratings) 3*questions 1 RINSE)
% last modified on MARCH 2018

%% define paths

%homedir = '/home/OBIWAN/';
homedir = '/Users/evapool/mountpoint/';

mdldir        = fullfile (homedir, '/DATA/STUDY/MODELS/SPM');
sourcefiles   = fullfile(homedir, '/DATA/STUDY/DERIVED/PIT_HEDONIC');
addpath (genpath(fullfile(homedir,'/ANALYSIS/my_tools')));

ana_name      = 'GLM-01';
session       = {'second'};
runs          = {'hedonicreactivity'};
subj          = {'105'; '106'};     % subject ID
group         = {'control'; 'control'}; % control or obsese

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
        onsets.taste.reward      = ONSETS.liquid(strcmp ('MilkShake', CONDITIONS));
        onsets.taste.control     = ONSETS.liquid(strcmp ('Empty', CONDITIONS));
        
        durations.taste.reward   = zeros (length(onsets.taste.reward),1);
        durations.taste.control  = zeros (length(onsets.taste.control),1);
        
        modulators.taste.reward  = BEHAVIOR.liking (strcmp ('MilkShake', CONDITIONS));
        modulators.taste.control = BEHAVIOR.liking (strcmp ('Empty', CONDITIONS));
        
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
            
            if strcmp (nameX, 'taste')  % for structure that contains substuctures
                substr = {'reward'; 'control'};% specify the substructures names
                
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