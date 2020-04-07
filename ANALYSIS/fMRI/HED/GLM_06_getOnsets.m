function GLM_06_getOnsets()

% intended for REWOD HED  FOR CONN !! IN SCANS not in SECS
% get onsets for model with 1st level modulators
% Duration =1 
% Model on ONSETs (start, 3*odor + 2*questions)
% last modified on JULY 2019 by David Munoz

%% define paths

cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/ANALYSIS');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-06';
%session       = {'second'};
task          = {'hedonic'};
subj          = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};

TR            = 2.4;

%% create folder
mkdir (fullfile (mdldir, char(task), ana_name)); 

%% extract and save data
%for j = 1:length(task) % this is only because we have one run per task

    taskX      = char(task(1));
    %sessionX  = char(session(j));

    for  i=1:length(subj)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load participants data
        subjX=char(subj(i));
        nscans        = get_N_scans(subj(i), task);
        
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
        onsets.trialstart       = (onsets.trialstart  * nscans) / (nscans * TR) ;
        durations.trialstart    = DURATIONS.trialstart;
        durations.trialstart     = (durations.trialstart  * nscans) / (nscans * TR) ;
        modulators.trialstart   = ones (length(onsets.trialstart),1); 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for odor valveopen
        onsets.odor.reward      = ONSETS.sniffSignalOnset(strcmp ('chocolate', CONDITIONS));
        onsets.odor.neutral     = ONSETS.sniffSignalOnset(strcmp ('neutral', CONDITIONS));
        onsets.odor.control     = ONSETS.sniffSignalOnset(strcmp ('empty', CONDITIONS));
        onsets.odor.conc        = vertcat(onsets.odor.reward, onsets.odor.neutral, onsets.odor.control);
        
        [onsets.odor.conc, Idx] = sort(onsets.odor.conc);
        onsets.odor.conc = (onsets.odor.conc * nscans) / (nscans * TR) ;

        %get durations
        durations.odor.reward     = DURATIONS.trialstart(strcmp ('chocolate', CONDITIONS));
        durations.odor.neutral    = DURATIONS.trialstart(strcmp ('neutral', CONDITIONS));
        durations.odor.control    = DURATIONS.trialstart(strcmp ('empty', CONDITIONS));
        durations.odor.conc       = vertcat(durations.odor.reward, durations.odor.neutral, durations.odor.control);
        
        durations.odor.conc = durations.odor.conc(Idx,:);
        durations.odor.conc = (durations.odor.conc * nscans) / (nscans * TR) ;
        
        %mod for liking 
        modulators.odor.reward.lik  = BEHAVIOR.liking (strcmp ('chocolate', CONDITIONS));
        modulators.odor.neutral.lik = BEHAVIOR.liking (strcmp ('neutral', CONDITIONS));
        modulators.odor.control.lik = BEHAVIOR.liking (strcmp ('empty', CONDITIONS));
        
        modulators.odor.conc.lik = vertcat(modulators.odor.reward.lik, modulators.odor.neutral.lik, modulators.odor.control.lik);
        
        %mean_centering mod
        cent_lik  = mean(modulators.odor.conc.lik);
     
        for j = 1:length(modulators.odor.conc.lik)
            modulators.odor.conc.lik(j)  = modulators.odor.conc.lik(j) - cent_lik;
        end
        

        modulators.odor.conc.lik = modulators.odor.conc.lik(Idx,:);
        
        
        %mod for intensity
        modulators.odor.reward.int  = BEHAVIOR.intensity (strcmp ('chocolate', CONDITIONS));
        modulators.odor.neutral.int = BEHAVIOR.intensity (strcmp ('neutral', CONDITIONS));
        modulators.odor.control.int = BEHAVIOR.intensity (strcmp ('empty', CONDITIONS));
        
        modulators.odor.conc.int = vertcat(modulators.odor.reward.int, modulators.odor.neutral.int, modulators.odor.control.int);
       
        %mean_centering mod
        cent_int  = mean(modulators.odor.conc.int);
     
        for j = 1:length(modulators.odor.conc.int)
            modulators.odor.conc.int(j)  = modulators.odor.conc.int(j) - cent_int;
        end
              
              
        modulators.odor.conc.int = modulators.odor.conc.int(Idx,:);
        
        

        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and duration questions
        onsets.liking            = ONSETS.liking;
        onsets.liking            = (onsets.liking  * nscans) / (nscans * TR) ;
        durations.liking         = DURATIONS.liking;
        durations.liking         = (durations.liking * nscans) / (nscans * TR) ;
        modulators.liking        = ones (length(onsets.liking),1);

        onsets.intensity         = ONSETS.intensity;
        onsets.intensity         = (onsets.intensity * nscans) / (nscans * TR) ;
        durations.intensity      = DURATIONS.intensity;
        durations.intensity      = (durations.intensity * nscans) / (nscans * TR) ;
        modulators.intensity     = ones (length(onsets.intensity),1);

        %%% ONE GIANT PM  FOR LIKING %%
        
        onsets.conc = vertcat(onsets.trialstart, onsets.odor.conc, onsets.liking, onsets.intensity);
        [onsets.conc, Idx] = sort(onsets.conc);
        
        durations.conc = vertcat(durations.trialstart, durations.odor.conc, durations.liking, durations.intensity);
        durations.conc = durations.conc(Idx,:) + onsets.conc ; 
        
        modulators.conc = vertcat(modulators.trialstart, modulators.odor.conc.lik, modulators.liking, modulators.intensity);
        modulators.conc = modulators.conc(Idx,:);
     
        
        
        CONC = horzcat( onsets.conc, durations.conc, modulators.conc) ;
        x = CONC(:,3)';
        MOD_LIK =imresize(x, [1,nscans]);  %sketchy resampling
        
        
        
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
                subsubstr = {'lik'; 'int'}; % specify the subsubstructures names 
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
        
        
        
       



        MOD_LIK = num2cell(MOD_LIK);
        % save the database in a txt file
        fid = fopen ([ana_name '_task-' taskX '_MOD_LIK.txt'],'wt');
        %formatSpec = '%f\t%f\t%f\n';
        formatSpec = '%f\n';
        [nrows,~] = size(MOD_LIK);
        for row = 1:nrows
            fprintf(fid,formatSpec,MOD_LIK{row,:});
        end
        fclose(fid);

              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        mat_name = [ana_name '_task-' taskX '_onsets'];
        save (mat_name, 'onsets', 'durations', 'modulators')
    end



end

