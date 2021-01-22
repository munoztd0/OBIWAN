function GLM_03_getOnsets()

% intended for OBIWAN PIT run

% get onsets for first control model (reward vs neutral)
% Stick functions
% Simplified model on ONSETs 3*CS with modulator and grips as control
% last modified on APRIL 2018

%% define paths

%homedir = '/home/OBIWAN/';
homedir = '/home/cisa/mountpoint/';
%homedir = '/Users/lavinia/mountpoint/';
%homedir = '/home/cisa/mountpoint/OBIWAN/';

mdldir        = fullfile (homedir, '/DATA/STUDY/MODELS/SPM');
sourcefiles   = fullfile(homedir, '/DATA/STUDY/DERIVED/PIT_HEDONIC');
addpath (genpath(fullfile(homedir,'/ANALYSIS/my_tools')));

ana_name      = 'GLM-03';
session       = {'second'};
runs          = {'PIT'};
subj          = {'225'  ;'226'  ;'227'  };     % subject ID
group         = {'obese';'obese';'obese'}; % control or obsese
%subj          = {    '100';    '102';    '105';    '106';    '107';    '108';    '109';    '112';    '113';    '114';    '115';    '116';    '118';    '119';    '120';    '122';    '123';    '124';    '125';  '200';  '201';  '202';  '203';  '204';  '205';  '206';  '207';  '208';  '209'};     % subject ID
%group         = {'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'obese';'obese';'obese';'obese';'obese';'obese';'obese';'obese';'obese';'obese'}; % control or obsese

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
%         onsets.CS.CSp          = ONSETS.trial(strcmp ('CSplus', CONDITIONS.CS));
%         onsets.CS.CSm          = ONSETS.trial(strcmp ('CSminus', CONDITIONS.CS));
%         onsets.CS.Baseline     = ONSETS.trial(strcmp ('BL', CONDITIONS.CS));
        
        onsets.trials            = ONSETS.trial;
        
%         durations.CS.CSp       = DURATIONS.trial(strcmp ('CSplus', CONDITIONS.CS))';
%         durations.CS.CSm       = DURATIONS.trial(strcmp ('CSminus', CONDITIONS.CS))';
%         durations.CS.Baseline  = DURATIONS.trial(strcmp ('BL', CONDITIONS.CS))';
        
        durations.trials         = DURATIONS.trial';
        
%         modulators.CS.CSp      = BEHAVIOR.gripFreq(strcmp ('CSplus', CONDITIONS.CS))';
%         modulators.CS.CSm      = BEHAVIOR.gripFreq(strcmp ('CSminus', CONDITIONS.CS))';
%         modulators.CS.Baseline = BEHAVIOR.gripFreq(strcmp ('BL', CONDITIONS.CS))';
%         
        modulators.trials        = BEHAVIOR.gripFreq';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips
        onsets.grips           = ONSETS.grips;
        durations.grips       = zeros (length(onsets.grips),1);
        modulators.grips      = ones  (length(onsets.grips),1);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips
        onsets.ITI          = ONSETS.ITI;
        %durations.ITI       = zeros (length(onsets.ITI),1);
        durations.ITI       = DURATIONS.ITI';
        modulators.ITI      = ones  (length(onsets.ITI),1);
       
        %% FOR FSL
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) % let's save all info in the participant directory
        
        % create text file with 3 colons: onsets, durations, paretric modulators
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = { 'trials'; 'grips'; 'ITI'};
        
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