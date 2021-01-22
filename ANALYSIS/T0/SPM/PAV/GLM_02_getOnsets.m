function GLM_02_getOnsets()

% intended for OBIWAN PAV task

% get onsets 
% Simplified model on ONSETs (STARTTRIAL, 3*CS with modulator AUC)
% last modified on MARCH 2020
    
    
dbstop if error
clear all


%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/SPM');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');
addpath (genpath(fullfile(homedir,'/CODE/ANALYSIS/fMRI/dependencies')));

ana_name      = 'GLM-02';
task          = {'pav'}; 


control = [homedir '/sub-control*'];
obese = [homedir '/sub-obese*'];

controlX = dir(control);
obeseX = dir(obese);

%subj = controlX; 
subj = vertcat(controlX, obeseX);

session = {'second'};

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
            
%             %old structure
%             if strcmp(subjX(end-2:end), '101') || strcmp(subjX(end-2:end), '103')
%                 continue
%             end

            %missing trials
            %if strcmp(subjX(end-2:end), '110') || strcmp(subjX(end-2:end), '218') %|| strcmp(subjX(end-2:end), '234')
                %continue
            %end

            %missing PIT sess
            %if strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '224')
                %continue
            %end
            
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
        
        %% FOR SPM
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS signal 9stimuli presentation)
        
        onsets.CS.CSp          = ONSETS.CS(strcmp ('CSplus', CONDITIONS.CS));
        onsets.CS.CSm          = ONSETS.CS(strcmp ('CSminus', CONDITIONS.CS));
        
        onsets.Baseline         = ONSETS.baseline;
        
        durations.CS.CSp       = DURATIONS.CS(strcmp ('CSplus', CONDITIONS.CS));
        durations.CS.CSm       = DURATIONS.CS(strcmp ('CSminus', CONDITIONS.CS));
        
        durations.Baseline      = DURATIONS.baseline;
        
        %change here
        %modulators.CS.CSp.liking   = BEHAVIOR.liking.CSp;
        %modulators.CS.CSm.liking   = BEHAVIOR.liking.CSm;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for reward delivery
        
        onsets.CS.CSp          = ONSETS.CS(strcmp ('CSplus', CONDITIONS.CS));
        onsets.CS.CSm          = ONSETS.CS(strcmp ('CSminus', CONDITIONS.CS));
        
        onsets.Baseline         = ONSETS.baseline;
        
        durations.CS.CSp       = DURATIONS.CS(strcmp ('CSplus', CONDITIONS.CS));
        durations.CS.CSm       = DURATIONS.CS(strcmp ('CSminus', CONDITIONS.CS));
        
        durations.Baseline      = DURATIONS.baseline;
        
        %change here
        %modulators.CS.CSp.liking   = BEHAVIOR.liking.CSp;
        %modulators.CS.CSm.liking   = BEHAVIOR.liking.CSm;
        
        %modulators.Baseline        = BEHAVIOR.liking.b;
       
        modulators.CS.CSp   = BEHAVIOR.RT.CSp;
        modulators.CS.CSm   = BEHAVIOR.RT.CSm;
        
        modulators.Baseline = ones (length(onsets.Baseline),1);
        
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for ITI
        
        %onsets.ITI             = ONSETS.ITI;
        %durations.ITI          = DURATIONS.ITI;
        %modulators.ITI         = ones  (length(onsets.ITI),1);
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for swallow signal
        
        onsets.deliver.rew           = ONSETS.reward(strcmp ('CSplus', CONDITIONS.CS));
        onsets.deliver.emp           = ONSETS.reward(strcmp ('CSminus', CONDITIONS.CS));
        durations.deliver.rew        = DURATIONS.reward(strcmp ('CSplus', CONDITIONS.CS));
        durations.deliver.emp        = DURATIONS.reward(strcmp ('CSminus', CONDITIONS.CS));
        modulators.deliver.rew           = ones(length(onsets.deliver.emp ),1);
        modulators.deliver.emp           = ones(length(onsets.deliver.emp ),1);
        
        % Get onsets and durations for reward
        
        onsets.swallow             = ONSETS.swallow;
        durations.swallow          = DURATIONS.swallow;
        modulators.swallow         = ones(length(onsets.swallow),1);
        
        
        %% FOR FSL
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) % let's save all info in the participant directory
        
        % create text file with 3 colons: onsets, durations, paretric modulators
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = { 'CS'; 'Baseline'; 'deliver'; 'swallow'};
        
        for ii = 1:length(name)
            
            nameX = char(name(ii));
            
            if strcmp (nameX, 'CS')  % for structure that contains substuctures
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
            elseif   strcmp (nameX, 'deliver')  % for structure that contains substuctures
                substr = {'rew'; 'emp'};% specify the substructures names
                
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