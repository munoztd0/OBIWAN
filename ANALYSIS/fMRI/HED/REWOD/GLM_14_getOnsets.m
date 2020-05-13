function GLM_14_getOnsets()

% intended for REWOD HED
% get onsets for model with 1st level modulators time : MINI-block
% Duration =1 
% Model on ONSETs (start, 3*odor + 2*questions)
% last modified on JULY 2019 by David Munoz

%% define paths

cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/ANALYSIS');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-14';
%session       = {'second'};
task          = {'hedonic'};
subj          = {'01'} %;'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'24';'25';'26'};


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
        
        miniblocks = reshape(repmat ([1: 6], 9,1), 1, [])';

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
        onsets.odor.conc        = vertcat(onsets.odor.reward, onsets.odor.neutral, onsets.odor.control);
        

        
        %get durations
        durations.odor.reward   = DURATIONS.trialstart(strcmp ('chocolate', CONDITIONS));
        durations.odor.neutral   = DURATIONS.trialstart(strcmp ('neutral', CONDITIONS));
        durations.odor.control   = DURATIONS.trialstart(strcmp ('empty', CONDITIONS));

        
        %mod for liking 
        modulators.odor.reward.lik  = BEHAVIOR.liking (strcmp ('chocolate', CONDITIONS));
        modulators.odor.neutral.lik = BEHAVIOR.liking (strcmp ('neutral', CONDITIONS));
        modulators.odor.control.lik = BEHAVIOR.liking (strcmp ('empty', CONDITIONS));
        

        %mean_centering mod
        cent_lik  = mean(modulators.odor.reward.lik);
     
        for j = 1:length(modulators.odor.reward.lik)
            modulators.odor.reward.lik(j)  = modulators.odor.reward.lik(j) - cent_lik;
        end
        
        cent_neut  = mean(modulators.odor.neutral.lik);
     
        for j = 1:length(modulators.odor.neutral.lik)
            modulators.odor.neutral.lik(j)  = modulators.odor.neutral.lik(j) - cent_neut;
        end
        
        

        
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
                substr = {'reward'; 'neutral'};% specify the substructures names 
                subsubstr = {'lik'}; % specify the subsubstructures names 
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

