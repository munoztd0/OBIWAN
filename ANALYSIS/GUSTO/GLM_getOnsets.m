function GLM_getOnsets()

% intended for OBIWAN hedonic reactivity task

% get onsets 
% Simplified model on ONSETs 7 (STARTTRIAL, 2*TASTE,  3*questions 1 RINSE)
% last modified on MARCH 2021

dbstop if error
clear all
ana_name  = 'GLM_GUSTO';
session = {'second'};

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/SPM');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');
addpath (genpath(fullfile(homedir,'/CODE/ANALYSIS/fMRI/dependencies')));

task          = {'hedonicreactivity'}; 


control = [homedir '/sub-control*'];
obese = [homedir '/sub-obese*'];

controlX = dir(control);
obeseX = dir(obese);


subj = vertcat(controlX, obeseX);



%% create folder  
mkdir (fullfile (mdldir, char(task), ana_name)); % this is only because we have one task per task

%% extract and save data
for s = 1:length(session)
    
    taskX      = char(task(s));
    sessionX  = char(session(s));
    
    for  i=1:length(subj)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load participants data
        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        sub = subjX(end-2:end);
        %conditionX=char(group(i,1));
        sessionX=char(session{s});
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
        durations.trialstart = zeros (length(onsets.trialstart),1);
        modulators.trialstart = ones (length(onsets.trialstart),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for taste
        onsets.taste.reward      = ONSETS.break(strcmp ('MilkShake', CONDITIONS));
        onsets.taste.control     = ONSETS.break(strcmp ('Empty', CONDITIONS));
        
        onsets.taste.conc        = vertcat(onsets.taste.reward, onsets.taste.control);
        [onsets.taste.conc, Idx] = sort(onsets.taste.conc);
        
        durations.taste.reward   = zeros (length(onsets.taste.reward),1);
        durations.taste.control  = zeros (length(onsets.taste.control),1);
        durations.taste.conc       = vertcat(durations.taste.reward, durations.taste.control);
        
        durations.taste.conc = durations.taste.conc(Idx,:);
        
        modulators.taste.reward.lik  = BEHAVIOR.liking (strcmp ('MilkShake', CONDITIONS));
        modulators.taste.control.lik = BEHAVIOR.liking (strcmp ('Empty', CONDITIONS));
        
        modulators.taste.conc.lik = vertcat(modulators.taste.reward.lik, modulators.taste.control.lik);
        
        %mean_centering mod
        cent_lik  = mean(modulators.taste.conc.lik);
     
        for j = 1:length(modulators.taste.conc.lik)
            modulators.taste.conc.lik(j)  = modulators.taste.conc.lik(j) - cent_lik;
        end
        

        modulators.taste.conc.lik = modulators.taste.conc.lik(Idx,:);
        
         
        %mod for intensity
        modulators.taste.reward.int  = BEHAVIOR.intensity (strcmp ('MilkShake', CONDITIONS));
        modulators.taste.control.int = BEHAVIOR.intensity (strcmp ('Empty', CONDITIONS));

        modulators.taste.conc.int = vertcat(modulators.taste.reward.int, modulators.taste.control.int);
       
        %mean_centering mod
        cent_int  = mean(modulators.taste.conc.int);
     
        for j = 1:length(modulators.taste.conc.int)
            modulators.taste.conc.int(j)  = modulators.taste.conc.int(j) - cent_int;
        end
              
              
        modulators.taste.conc.int = modulators.taste.conc.int(Idx,:);
        
        
        %mod for familiarity
        modulators.taste.reward.fam  = BEHAVIOR.familiarity (strcmp ('MilkShake', CONDITIONS));
        modulators.taste.control.fam = BEHAVIOR.familiarity (strcmp ('Empty', CONDITIONS));

        modulators.taste.conc.fam = vertcat(modulators.taste.reward.fam, modulators.taste.control.fam);
       
        %mean_centering mod
        cent_int  = mean(modulators.taste.conc.fam);
     
        for j = 1:length(modulators.taste.conc.fam)
            modulators.taste.conc.fam(j)  = modulators.taste.conc.fam(j) - cent_int;
        end
              
              
        modulators.taste.conc.fam = modulators.taste.conc.fam(Idx,:);
        
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
                substr = {'conc'};% specify the substructures names 
                subsubstr = {'lik'; 'int'; 'fam'}; % specify the subsubstructures names 
                for iii = 1:length(substr)
                    substrX = char(substr(iii));
                    for iiii =  1:length(subsubstr)
                        subsubstrX = char(subsubstr(iiii));
                        nameXX  = [nameX '_' substrX '_' subsubstrX];% name that combines the structure and the substructures
                        % database with three rows of interest
                        database.(nameXX) = [num2cell(onsets.(nameX).(substrX)), num2cell(durations.(nameX).(substrX)), num2cell(modulators.(nameX).(substrX).(subsubstrX))];
                        % save the database in a txt file
                        fid = fopen ([ana_name '_task-' taskX '_' nameX '_' substrX '_' subsubstrX '.txt'],'wt');
                        formatSpec = '%d   %d   %d\n';
                        [nrows,~] = size(database.(nameXX));
                        for row = 1:nrows
                            fprintf(fid,formatSpec,database.(nameXX){row,:});
                        end
                        fclose(fid);
                    end
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