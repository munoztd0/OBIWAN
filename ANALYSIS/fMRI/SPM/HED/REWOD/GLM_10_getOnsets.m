function GLM_10_getOnsets()

% intended for REWOD HED
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

ana_name      = 'GLM-10';
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
        subjX=char(subj(i));

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
        %mod for liking 
        modulators.odor.reward.lik  = BEHAVIOR.liking (strcmp ('chocolate', CONDITIONS));
        [A,IdxA] = sort(modulators.odor.reward.lik);
        A1 = [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1]' ;
        A2 = [1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0]' ;
        unsort = 1:length(A);
        newIdx(IdxA) = unsort;
        IdxRew = logical(A1(newIdx));
        IdxRewNot = logical(A2(newIdx));
        if mean(IdxRew) ~= 1/3
            disp('errror')
        end
        
        
        modulators.odor.reward1.lik = modulators.odor.reward.lik(IdxRew);
        modulators.odor.reward2.lik = modulators.odor.reward.lik(IdxRewNot);
        
        modulators.odor.neutral.lik = BEHAVIOR.liking (strcmp ('neutral', CONDITIONS));
        IdxNeu = modulators.odor.neutral.lik  > median(modulators.odor.neutral.lik);
        A1 = [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1]' ;
        A2 = [1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0]' ;
        unsort = 1:length(A);
        newIdx(IdxA) = unsort;
        IdxNeu = logical(A1(newIdx));
        IdxNeuNot = logical(A2(newIdx));
        if mean(IdxNeu) ~= 1/3
            disp('errror')
        end
        modulators.odor.neutral1.lik = modulators.odor.neutral.lik(IdxNeu);
        modulators.odor.neutral2.lik = modulators.odor.neutral.lik(IdxNeuNot);
        
        modulators.odor.control.lik = BEHAVIOR.liking (strcmp ('empty', CONDITIONS));
        IdxCon = modulators.odor.control.lik  > median(modulators.odor.control.lik);
        A1 = [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1]' ;
        A2 = [1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0]' ;
        unsort = 1:length(A);
        newIdx(IdxA) = unsort;
        IdxCon = logical(A1(newIdx));
        IdxConNot = logical(A2(newIdx));
        if mean(IdxCon) ~= 1/3
            disp('errror')
        end
        modulators.odor.control1.lik = modulators.odor.control.lik(IdxCon);
        modulators.odor.control2.lik = modulators.odor.control.lik(IdxConNot);
        
        
        
        %modulators.odor.conc1.lik = vertcat(modulators.odor.reward1.lik, modulators.odor.neutral1.lik, modulators.odor.control1.lik);
        %modulators.odor.conc2.lik = vertcat(modulators.odor.reward2.lik, modulators.odor.neutral2.lik, modulators.odor.control2.lik);
        
        % Get onsets and durations for odor valveopen
        onsets.odor.reward      = ONSETS.sniffSignalOnset(strcmp ('chocolate', CONDITIONS));
        onsets.odor.reward1      = onsets.odor.reward(IdxRew);
        onsets.odor.reward2      =   onsets.odor.reward(IdxRewNot);
        onsets.odor.neutral     = ONSETS.sniffSignalOnset(strcmp ('neutral', CONDITIONS));
        onsets.odor.neutral1      = onsets.odor.neutral(IdxNeu);
        onsets.odor.neutral2      = onsets.odor.neutral(IdxNeuNot);
        onsets.odor.control     = ONSETS.sniffSignalOnset(strcmp ('empty', CONDITIONS));
        onsets.odor.control1      = onsets.odor.control(IdxCon);
        onsets.odor.control2      = onsets.odor.control(IdxConNot);
        
        %onsets.odor.conc1        = vertcat(onsets.odor.reward1, onsets.odor.neutral1, onsets.odor.control1);
        %onsets.odor.conc2        = vertcat(onsets.odor.reward2, onsets.odor.neutral2, onsets.odor.control2);
        %[onsets.odor.conc1, Idx1] = sort(onsets.odor.conc1);
        %[onsets.odor.conc2, Idx2] = sort(onsets.odor.conc2);
        
        %get durations
        durations.odor.reward    = DURATIONS.trialstart(strcmp ('chocolate', CONDITIONS));
        durations.odor.reward1   = durations.odor.reward(IdxRew);
        durations.odor.reward2   = durations.odor.reward(IdxRewNot);
        
        durations.odor.neutral   = DURATIONS.trialstart(strcmp ('neutral', CONDITIONS));
        durations.odor.neutral1  = durations.odor.neutral(IdxNeu);
        durations.odor.neutral2   = durations.odor.neutral(IdxNeuNot);
        
        durations.odor.control   = DURATIONS.trialstart(strcmp ('empty', CONDITIONS));
        durations.odor.control1  = durations.odor.control(IdxCon);
        durations.odor.control2  = durations.odor.control(IdxConNot);     
                
        %durations.odor.conc1       = vertcat(durations.odor.reward1, durations.odor.neutral1, durations.odor.control1);

        %durations.odor.conc1 = durations.odor.conc1(Idx1,:);
        
        %durations.odor.conc2       = vertcat(durations.odor.reward2, durations.odor.neutral2, durations.odor.control2);

        %durations.odor.conc2 = durations.odor.conc2(Idx2,:);
        
       
        
        %mean center at the en dor at the beigning
        
%         %mean_centering mod
%         cent_lik  = mean(modulators.odor.reward1.lik);
%      
%         for j = 1:length(modulators.odor.reward1.lik)
%             modulators.odor.conc1.lik(j)  = modulators.odor.conc1.lik(j) - cent_lik;
%         end
%         
% 
%         modulators.odor.conc1.lik = modulators.odor.conc1.lik(Idx1,:);
%         
%         
%         %mean_centering mod
%         cent_lik  = mean(modulators.odor.conc2.lik);
%      
%         for j = 1:length(modulators.odor.conc2.lik)
%             modulators.odor.conc2.lik(j)  = modulators.odor.conc2.lik(j) - cent_lik;
%         end
%         
% 
%         modulators.odor.conc2.lik = modulators.odor.conc2.lik(Idx2,:);
%         
        
        
        
%         
%         %mod for intensity
%         modulators.odor.reward.int  = BEHAVIOR.intensity (strcmp ('chocolate', CONDITIONS));
%         modulators.odor.neutral.int = BEHAVIOR.intensity (strcmp ('neutral', CONDITIONS));
%         modulators.odor.control.int = BEHAVIOR.intensity (strcmp ('empty', CONDITIONS));
%         
%         modulators.odor.conc.int = vertcat(modulators.odor.reward.int, modulators.odor.neutral.int, modulators.odor.control.int);
%        
%         %mean_centering mod
%         cent_int  = mean(modulators.odor.conc.int);
%      
%         for j = 1:length(modulators.odor.conc.int)
%             modulators.odor.conc.int(j)  = modulators.odor.conc.int(j) - cent_int;
%         end
%               
%               
%         modulators.odor.conc.int = modulators.odor.conc.int(Idx,:);
        
        
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
                substr = {'reward1'; 'neutral1'; 'control1'; 'reward2'; 'neutral2'; 'control2'};% specify the substructures names 
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

