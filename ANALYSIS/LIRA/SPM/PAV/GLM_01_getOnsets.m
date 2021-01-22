function GLM_01_getOnsets()

% intended for OBIWAN pavlovian learning task

% get onsets for first control model (reward vs neutral)
% Stick functions
% Simplified model on ONSETs 7 2*CS 1*ACTION 2*REWARD 1*SWALLOW 1*BASELINE
% last modified on APRIL 2018

%% define paths

dbstop if error
clear all


%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/SPM');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');
addpath (genpath(fullfile(homedir,'/CODE/ANALYSIS/fMRI/dependencies')));

ana_name      = 'GLM-01';
task          = {'pav'}; 


control = [homedir '/sub-control*'];
obese = [homedir '/sub-obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);

session = {'second';'third'};

%subj          = {'129'    ;'131'    ;'132'    ;'133'    ;'213'  ;'216'  ;'219'  ;'220'  ;'221'  };     % subject ID
%group         = {'control';'control';'control';'control';'obese';'obese';'obese';'obese';'obese'}; % control or obsese

%% create folder  
mkdir (fullfile (mdldir, char(task), ana_name)); % this is only because we have one task per task

%% extract and save data
for j = 1:length(task)
    
    taskX      = char(task(j));
    sessionX  = char(session(j));
    
    for  i=1:length(subj)
        
        %subjX=subj(i,1);
        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        sub = subjX(end-2:end);
        %conditionX=char(group(i,1));
        sessionX=char(session(j)); 
        sess=['ses-' sessionX];

            
        path = fullfile(sourcefiles, subjX,['ses-' sessionX],'func');
        behav_file = [num2str(subjX) '_ses-' sessionX '_task-' taskX '_events.mat'];
        full_path = fullfile(path, behav_file);
            

        %load behavioral file
        if strcmp(sessionX, 'third')
            
            %missing trials
            %if strcmp(subjX(end-2:end), '214')  
                %continue
            %end
            
            %missing PIT sess
            %if  strcmp(subjX(end-2:end), '212')  || strcmp(subjX(end-2:end), '245') || strcmp(subjX(end-2:end), '249')
                %continue
            %end
            
            if exist(full_path, 'file')
                cd (path)
                load (behav_file);
            else 
                continue
            end
        else
            
            %old structure
            if strcmp(subjX(end-2:end), '101') || strcmp(subjX(end-2:end), '103')
                continue
            end

            %missing trials
            %if strcmp(subjX(end-2:end), '110') || strcmp(subjX(end-2:end), '218') %|| strcmp(subjX(end-2:end), '234')
                %continue
            %end

            %missing PIT sess
            %if strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '224')
                %continue
            %end
%             if strcmp(subjX(end-2:end), '230')
%                 w = 1;
%             end
            if exist(full_path, 'file')
                cd (path)
                load (behav_file);
            else 
                continue
            end
        end
        
        
        disp (['****** PARTICIPANT: ' subjX ' **** session ' sessionX ' ****' ]);
        
        subjdir = fullfile(mdldir, char(task), ana_name,  subjX,'timing');
        if ~exist(subjdir, 'dir')
            mkdir (subjdir)
        end
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
        modulators.action        = BEHAVIOR.RT1;
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
                    fid = fopen ([ana_name '_task-' taskX '_' nameX '_' substrX '.txt'],'wt');
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
                    fid = fopen ([ana_name '_task-' taskX '_' nameX '_' substrX '.txt'],'wt');
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
                fid = fopen ([ana_name '_task-' taskX '_' nameX '.txt'],'wt');
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
        mat_name = [ana_name '_task-' taskX '_onsets'];
        save (mat_name, 'onsets', 'durations', 'modulators')
        
    end
    
end

end