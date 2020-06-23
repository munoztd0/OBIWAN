function GLM_01_getOnsets()

% intended for OBIWAN pavlovian learning run

% get onsets for first control model (reward vs neutral)
% Stick functions
% Simplified model on ONSETs 7 2*CS 1*ACTION 2*REWARD 1*SWALLOW 1*BASELINE
% last modified on APRIL 2018

%% define paths

%homedir = '/home/OBIWAN/';
%homedir = '/Users/evapool/mountpoint/';
homedir = '/home/cisa/mountpoint/';
%homedir = '/home/cisa/mountpoint/OBIWAN/';

mdldir        = fullfile (homedir, '/DATA/STUDY/MODELS/SPM');
sourcefiles   = fullfile(homedir, '/DATA/STUDY/DERIVED/PIT_HEDONIC');
addpath (genpath(fullfile(homedir,'/ANALYSIS/my_tools')));

ana_name      = 'GLM-01';
session       = {'second'};
runs          = {'pavlovianlearning'};
subj          = {'224'  ;'225'  ;'226'  ;'227'  };     % subject ID
group         = {'obese';'obese';'obese';'obese'}; % control or obsese
%subj          = {    '100';    '102';    '105';    '106';    '107';    '108';    '109';    '110';    '112';    '113';    '114';    '115';    '116';    '118';    '119';    '120';    '122';    '123';    '124';    '125';  '200';  '201';  '202';  '203';  '204';  '205';  '206';  '207';  '208';  '209'};     % subject ID
%group         = {'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'obese';'obese';'obese';'obese';'obese';'obese';'obese';'obese';'obese';'obese'}; % control or obsese

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
        onsets.CS.CSp      = ONSETS.CS(strcmp ('CSplus', CONDITIONS.CS));
        onsets.CS.CSm      = ONSETS.CS(strcmp ('CSminus', CONDITIONS.CS));
        
        durations.CS.CSp   = zeros (length(onsets.CS.CSp),1);
        durations.CS.CSm   = zeros (length(onsets.CS.CSm),1);
        
        modulators.CS.CSp  = ones (length(onsets.CS.CSp),1);
        modulators.CS.CSm  = ones (length(durations.CS.CSm),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and duration action
        onsets.action            = ONSETS.action;
        durations.action         = DURATIONS.action;
        modulators.action        = BEHAVIOR.RT;
        modulators.action        = modulators.action(1:length(ONSETS.action));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets reward and control liquid
        
        onsets.taste.reward      = ONSETS.reward(strcmp ('CSplus', CONDITIONS.CS));
        onsets.taste.control     = ONSETS.reward(strcmp ('CSminus', CONDITIONS.CS));
        
        durations.taste.reward   = zeros (length(onsets.taste.reward),1);
        durations.taste.control  = zeros (length(onsets.taste.reward),1);
        
        modulators.taste.reward  = ones (length(onsets.taste.reward),1);
        modulators.taste.control = ones (length(onsets.taste.control),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets for swallow signal
        onsets.swallow           = ONSETS.swallow;
        durations.swallow        = zeros (length(onsets.swallow),1);
        modulators.swallow       = ones (length(onsets.swallow),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets for baseline
        onsets.baseline          = ONSETS.baseline;
        durations.baseline       = zeros (length(onsets.baseline),1);
        modulators.baseline      = ones (length(onsets.baseline),1);
        
        %% FOR FSL
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) % let's save all info in the participant directory
        
        % create text file with 3 colons: onsets, durations, parametric modulators
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = { 'CS'; 'action'; 'taste'; 'swallow'; 'baseline'};
        
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
                
            elseif strcmp (nameX, 'CS')  % for structure that contains substuctures
                substr = {'CSp'; 'CSm'};% specify the substructures names
                
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