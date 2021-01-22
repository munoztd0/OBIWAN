function GLM_17_getOnsets()

% intended for REWOD HED
% get onsets for model with 1st level modulators and EMG REVERSE
% Duration =1 
% Model on ONSETs (start, 3*odor + 2*questions)
% last modified on JULY 2019 by David Munoz

%% define paths

cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/ANALYSIS');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-17';
%session       = {'second'};
task          = {'hedonic'};
subj          = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%% create folder
mkdir (fullfile (mdldir, char(task), ana_name)); 

%% extract and save data
%for j = 1:length(task) % this is only because we have one run per task

    taskX      = char(task(1));
    %sessionX  = char(session(j));

    for  i=1:length(subj)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load participants data
        subjX=[char(subj(i))];

        subjdir=fullfile(mdldir, char(task), ana_name,  ['sub-' subjX],'timing');
        mkdir (subjdir)

        cd (fullfile(sourcefiles,['sub-' subjX], 'ses-second', 'func')); 
        behavfile = ['sub-' num2str(subjX) '_ses-second' '_task-' taskX '_run-01_events.mat'];
        fprintf('participant number: %s task: %s \n', subj{i}, task{1})
        disp(['file ' num2str(i) ' ' behavfile]);
        load (behavfile);


        %% FOR SPM

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for start
        onsets.trialstart       = ONSETS.trialstart;
        durations.trialstart    = DURATIONS.trialstart;
        modulators.trialstart   = ones (length(onsets.trialstart),1); 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for odor valveopen
        onsets.odor.reward      = ONSETS.sniffSignalOnset(strcmp ('chocolate', CONDITIONS));
        onsets.odor.neutral     = ONSETS.sniffSignalOnset(strcmp ('neutral', CONDITIONS));
        onsets.odor.control     = ONSETS.sniffSignalOnset(strcmp ('empty', CONDITIONS));
        onsets.odor.conc        = vertcat(onsets.odor.reward, onsets.odor.neutral);
        
        [onsets.odor.conc, Idx] = sort(onsets.odor.conc);
        
        %get durations
        durations.odor.reward   = DURATIONS.trialstart(strcmp ('chocolate', CONDITIONS));
        durations.odor.neutral   = DURATIONS.trialstart(strcmp ('neutral', CONDITIONS));
        durations.odor.control   = DURATIONS.trialstart(strcmp ('empty', CONDITIONS));
        durations.odor.conc       = vertcat(durations.odor.reward, durations.odor.neutral);
        
        durations.odor.conc = durations.odor.conc(Idx,:);
        
        %mod for liking 
        modulators.odor.reward.lik  = BEHAVIOR.liking (strcmp ('chocolate', CONDITIONS));
        modulators.odor.neutral.lik = BEHAVIOR.liking (strcmp ('neutral', CONDITIONS));
        modulators.odor.control.lik = BEHAVIOR.liking (strcmp ('empty', CONDITIONS));
        
        %         %mean_centering mod
%         cent_rew  = mean(modulators.odor.reward.lik);
%                 cent_neu  = mean(modulators.odor.neutral.lik);
%                         cent_con = mean(modulators.odor.control.lik);
%         
%         modulators.odor.reward.lik  = modulators.odor.reward.lik - cent_rew;
%         modulators.odor.neutral.lik = modulators.odor.neutral.lik - cent_neu;
%         modulators.odor.control.lik = modulators.odor.control.lik - cent_con;   


        
        modulators.odor.conc.lik = vertcat(modulators.odor.reward.lik, modulators.odor.neutral.lik);
        
        %mean_centering mod
        cent_lik  = mean(modulators.odor.conc.lik);
     
        for j = 1:length(modulators.odor.conc.lik)
            modulators.odor.conc.lik(j)  = modulators.odor.conc.lik(j) - cent_lik;
        end
        

        modulators.odor.conc.lik = modulators.odor.conc.lik(Idx,:);
        %modulators.odor.conc.lik = zscore(modulators.odor.conc.lik);
        
        %mod for intensity
        modulators.odor.reward.int  = BEHAVIOR.intensity (strcmp ('chocolate', CONDITIONS));
        modulators.odor.neutral.int = BEHAVIOR.intensity (strcmp ('neutral', CONDITIONS));
        modulators.odor.control.int = BEHAVIOR.intensity (strcmp ('empty', CONDITIONS));
        
        
                %         %mean_centering mod
%         cent_rew  = mean(modulators.odor.reward.int);
%                 cent_neu  = mean(modulators.odor.neutral.int);
%                         cent_con = mean(modulators.odor.control.int);
%         
%         modulators.odor.reward.int  = modulators.odor.reward.int - cent_rew;
%         modulators.odor.neutral.int = modulators.odor.neutral.int - cent_neu;
%         modulators.odor.control.int = modulators.odor.control.int - cent_con;   
        
        modulators.odor.conc.int = vertcat(modulators.odor.reward.int, modulators.odor.neutral.int);

%         %mean_centering mod
        cent_int  = mean(modulators.odor.conc.int);
     
        for j = 1:length(modulators.odor.conc.int)
            modulators.odor.conc.int(j)  = modulators.odor.conc.int(j) - cent_int;
        end
              
          
        modulators.odor.conc.int = modulators.odor.conc.int(Idx,:);
        %modulators.odor.conc.int = zscore(modulators.odor.conc.int) ;  
        
        
        % EMG as mod
        modulators.odor.reward.EMG  = PHYSIO.EMG(strcmp ('chocolate', CONDITIONS));
        modulators.odor.neutral.EMG = PHYSIO.EMG(strcmp ('neutral', CONDITIONS));
        modulators.odor.control.EMG = PHYSIO.EMG(strcmp ('empty', CONDITIONS));
        
        
                        %         %mean_centering mod
%         cent_rew  = mean(modulators.odor.reward.EMG);
%                 cent_neu  = mean(modulators.odor.neutral.EMG);
%                         cent_con = mean(modulators.odor.control.EMG);
%         
%         modulators.odor.reward.EMG  = modulators.odor.reward.EMG - cent_rew;
%         modulators.odor.neutral.EMG = modulators.odor.neutral.EMG - cent_neu;
%         modulators.odor.control.EMG = modulators.odor.control.EMG - cent_con;   
        
        modulators.odor.conc.EMG = vertcat(modulators.odor.reward.EMG, modulators.odor.neutral.EMG);
       
%         %mean_centering mod
        cent_EMG  = mean(modulators.odor.conc.EMG);
     
        for j = 1:length(modulators.odor.conc.EMG)
            modulators.odor.conc.EMG(j)  = modulators.odor.conc.EMG(j) - cent_EMG;
        end
              
              
        modulators.odor.conc.EMG = -1 * (modulators.odor.conc.EMG(Idx,:));
        %modulators.odor.conc.EMG = zscore(modulators.odor.conc.EMG);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and duration questions
        onsets.liking            = ONSETS.liking;
        durations.liking         = DURATIONS.liking;
        modulators.liking        = ones (length(onsets.liking),1);

        onsets.intensity         = ONSETS.intensity;
        durations.intensity      = DURATIONS.intensity;
        modulators.intensity     = ones (length(onsets.intensity),1);


         % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) % let's save all info in the participant directory

        
        %% FOR FSL #uncoment if you want to use FSL#
        % create text file with 3 colons: onsets, durations and 2
        % parametric modulators for each parameter
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = {'trialstart'; 'odor'; 'liking'; 'intensity'}; 

        for ii = 1:length(name)

            nameX = char(name(ii));

            if strcmp (nameX, 'odor')  % for structure that contains substuctures
                substr = {'conc'};% specify the substructures names 
                subsubstr = {'lik'; 'int'; 'EMG'}; % specify the subsubstructures names 
                for iii = 1:length(substr)
                    substrX = char(substr(iii));
                    for iiii =  1:length(subsubstr)
                        subsubstrX = char(subsubstr(iiii));
                        nameXX  = [nameX '_' substrX '_' subsubstrX]; % name that combines the structure and the substructures
                        % database with three rows of interest
                        %database.(nameXX) = [num2cell(onsets.(nameX).(substrX)), num2cell(durations.(nameX).(substrX)), num2cell(modulators.(nameX).(substrX).(subsubstrX))];
                        database.(nameXX) = num2cell(modulators.(nameX).(substrX).(subsubstrX));
                        % save the database in a txt file
                        fid = fopen ([ana_name '_task-' taskX '_' nameX '_' substrX '_' subsubstrX '.txt'],'wt');
                        %formatSpec = '%f\t%f\t%f\n';
                        formatSpec = '%f\n';
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
                formatSpec = '%f\t%f\t%f\n';
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

