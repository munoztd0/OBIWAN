function GLM_14_getOnsets()

% intended for OBIWAN hedonic reactivity task

% control 124 is missing (I dont get what happend with that participants ->
% only 18 ITI but 40 liquids?)


% get onsets for first control model (reward vs neutral)
% Stick function for swallow
% Simplified model on ONSETs 7 (STARTTRIAL, TASTE with modulators intesity liking familiartiy 3*questions 1 RINSE)

% last modified on JULY 2019
dbstop if error
clear all

ana_name      = 'GLM-14-control';


%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

mdldir        = fullfile (homedir, '/DERIVATIVES/GLM');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');
addpath (genpath(fullfile(homedir,'/CODE/ANALYSIS/fMRI/dependencies')));

ana_name      = 'GLM-14-control';
task          = {'hedonicreactivity'}; 


control = [homedir '/sub-control*'];
%obese = [homedir '/sub-obese*'];

controlX = dir(control);
%obeseX = dir(obese);

subj = controlX; %vertcat(controlX, obeseX);

session = {'second'}; % 'third'};
%subj          = {'100'};
%group         = {'control'};
%subj          = {'100'    ;'102'    ;'105'    ;'106'    ;'107'    ;'108'    ;'109'    ;'110'    ;'112'    ;'113'    ;'114'    ;'115'    ;'116'    ;'118'    ;'119'    ;'120'    ;'121'    ;'122'    ;'125'    ;'126'    ;'127'    ;'128'    ;'129'    ;'130'    ;'131'    ;'132'    ;'133'    };     % subject ID
%group         = {'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control';'control'}; % control or obsese

%% create folder  
mkdir (fullfile (mdldir, char(task), ana_name)); % this is only because we have one task per task

%% extract and save data
for j = 1:length(task)
    
    taskX      = char(task(j));
    sessionX  = char(session(j));
    
    for  i=1:length(subj)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load participants data
        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        sub = subjX(end-2:end);
        %conditionX=char(group(i,1));
        sessionX=char(session(j));
        %subjX=[char(group(i)) char(subj(i))];
        sess=['ses-' sessionX];               
                
        path = fullfile(sourcefiles, subjX,['ses-' sessionX],'func');
        behav_file = [num2str(subjX) '_ses-' sessionX '_task-' taskX '_events.mat'];
        full_path = fullfile(path, behav_file);
            

        %load behavioral file
        if strcmp(sessionX, 'third') %session third exceptions
                
            %missing trials
            if strcmp(subjX(end-2:end), '201')  || strcmp(subjX(end-2:end), '214') 
                continue
            end
            
            %missing hedonic sess
            if  strcmp(subjX(end-2:end), '208') || strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '245') || strcmp(subjX(end-2:end), '249')
                continue
            end
            if exist(full_path, 'file')
                cd (path)
                load (behav_file);
            else 
                continue
            end
        else   %session second exceptions
            
            %old structure
            if strcmp(subjX(end-2:end), '101') || strcmp(subjX(end-2:end), '103')
                continue
            end

            %missing trials
            if strcmp(subjX(end-2:end), '123') || strcmp(subjX(end-2:end), '124') || strcmp(subjX(end-2:end), '234')
                continue
            end

            %missing hedonic sess
            if strcmp(subjX(end-2:end), '212')
                continue
            end
        
            if exist(full_path, 'file')
                cd (path)
                load (behav_file);
            else 
                continue
            end
        end
        
        disp (['****** PARTICIPANT: ' subjX ' **** session ' sessionX ' ****' ]);

        
        subjdir = fullfile(mdldir, char(task), ana_name,  subjX,'timing');
        mkdir (subjdir)
       
        %cd (fullfile(sourcefiles, subjX,['ses-' sessionX],'func'));
        %fprintf('participant number: %s task: %s \n', subj(i).name, task{j})
        %disp(['file ' num2str(i) ' ' behav_file]);
        
        
        %% FOR SPM
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for start
        onsets.trialstart    = ONSETS.trialstart;
        durations.trialstart = DURATIONS.trialstart;
        modulators.trialstart = ones (length(onsets.trialstart),1);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for swallow
        onsets.swallow                 = ONSETS.break;
        durations.swallow              = zeros (length(onsets.swallow),1);
        modulators.swallow.liking      = BEHAVIOR.liking;
        modulators.swallow.intensity   = BEHAVIOR.intensity;
        modulators.swallow.familiarity = BEHAVIOR.familiarity;

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
        
        % create text file with 3 columns: onsets, durations, parametric modulators
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = {'trialstart'; 'swallow'; 'liking'; 'intensity'; 'familiarity'; 'rinse'};
        
        for ii = 1:length(name)
            
            nameX = char(name(ii));
            
            if strcmp (nameX, 'swallow') % for structure that contains modulators
                
                % first register the onset only (this will be the variable
                % the modulators will be orthogonalized to
                database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(ones(length(onsets.(nameX)),1))]; % put one as a modulator
                % save the database in a txt file
                fid = fopen ([ana_name '_task-' taskX '_' nameX '.txt'],'wt');
                formatSpec = '%d   %d   %d\n';
                [nrows,~] = size(database.(nameX));
                for row = 1:nrows
                    fprintf(fid,formatSpec,database.(nameX){row,:});
                end
                fclose(fid);
                
                
                substr = {'liking';'intensity';'familiarity'};% specify the substructures names
                
                for iii = 1:length(substr)
                    
                    substrX = char(substr(iii));
                    nameXX  = [substrX]; % name that combines the structure and the substructures
                    
                    % database with three rows of interest
                    database.(nameXX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX).(nameXX))]; % change the modulators value only
                    % save the database in a txt file
                    fid = fopen ([ana_name '_task-' taskX '_' nameXX '.txt'],'wt');
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