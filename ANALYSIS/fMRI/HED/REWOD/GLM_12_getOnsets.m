function GLM_12_getOnsets()

% intended for REWOD HED
% get onsets for model with 1st level modulators and miniblocks
% Duration =1 
% Model on ONSETs (start, 3*odor + 2*questions) * 3 mini runs
% last modified on JULY 2019 by David Munoz

%% define paths
dbstop if error
cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/ANALYSIS');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-12';
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
        %onsets.odor.conc        = vertcat(onsets.odor.reward, onsets.odor.neutral, onsets.odor.control);
        
        %[onsets.odor.conc, Idx] = sort(onsets.odor.conc);
        
                
         run1 = [1 0 0];
         run2 = [0 1 0];
         run3 = [0 0 1];
         
         run1=logical(repmat(run1,1,6))';
         run2=logical(repmat(run2,1,6))';
         run3=logical(repmat(run3,1,6))';
         
         
                %mod for liking 
        modulators.odor.reward.lik  = BEHAVIOR.liking (strcmp ('chocolate', CONDITIONS));
        modulators.odor.neutral.lik = BEHAVIOR.liking (strcmp ('neutral', CONDITIONS));
        modulators.odor.control.lik = BEHAVIOR.liking (strcmp ('empty', CONDITIONS));
        
        %modulators.odor.conc.lik = vertcat(modulators.odor.reward.lik, modulators.odor.neutral.lik, modulators.odor.control.lik);
        
        
        modulators.odor.reward1.lik = modulators.odor.reward.lik(run1);
        modulators.odor.reward2.lik = modulators.odor.reward.lik(run2);
        modulators.odor.reward3.lik = modulators.odor.reward.lik(run3);
         
        modulators.odor.neutral1.lik = modulators.odor.neutral.lik(run1);
        modulators.odor.neutral2.lik = modulators.odor.neutral.lik(run2);
        modulators.odor.neutral3.lik = modulators.odor.neutral.lik(run3);
         
        modulators.odor.control1.lik = modulators.odor.control.lik(run1);
        modulators.odor.control2.lik = modulators.odor.control.lik(run2);
        modulators.odor.control3.lik = modulators.odor.control.lik(run3);
        
        
        %mean_centering mod
        cent_lik.reward1.lik  = mean(modulators.odor.reward1.lik);
        cent_lik.reward2.lik  = mean(modulators.odor.reward2.lik);
        cent_lik.reward3.lik  = mean(modulators.odor.reward3.lik);
        
        cent_lik.neutral1.lik  = mean(modulators.odor.neutral1.lik);
        cent_lik.neutral2.lik  = mean(modulators.odor.neutral2.lik);
        cent_lik.neutral3.lik  = mean(modulators.odor.neutral3.lik);
        
        
        cent_lik.control1.lik  = mean(modulators.odor.control1.lik);
        cent_lik.control2.lik  = mean(modulators.odor.control2.lik);
        cent_lik.control3.lik  = mean(modulators.odor.control3.lik);
     
        for j = 1:length(modulators.odor.reward1.lik)
            modulators.odor.reward1.lik(j)  = modulators.odor.reward1.lik(j) - cent_lik.reward1.lik;
            modulators.odor.reward2.lik(j)  = modulators.odor.reward2.lik(j) - cent_lik.reward2.lik;
            modulators.odor.reward3.lik(j)  = modulators.odor.reward3.lik(j) - cent_lik.reward3.lik;
            
            modulators.odor.neutral1.lik(j)  = modulators.odor.neutral1.lik(j) - cent_lik.neutral1.lik;
            modulators.odor.neutral2.lik(j)  = modulators.odor.neutral2.lik(j) - cent_lik.neutral2.lik;
            modulators.odor.neutral3.lik(j)  = modulators.odor.neutral3.lik(j) - cent_lik.neutral3.lik;
            
            modulators.odor.control1.lik(j)  = modulators.odor.control1.lik(j) - cent_lik.control1.lik;
            modulators.odor.control2.lik(j)  = modulators.odor.control2.lik(j) - cent_lik.control2.lik;
            modulators.odor.control3.lik(j)  = modulators.odor.control3.lik(j) - cent_lik.control3.lik;
        end
         
        Idxreward1 = modulators.odor.reward1.lik  >= median(modulators.odor.reward1.lik);
        
        if mean(Idxreward1) ~= 0.5
            [A,IdxA] = sort(modulators.odor.reward1.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxreward1 = logical(A1(newIdx));
            if mean(Idxreward1) ~= 0.5
                disp('errror')
            end
        end
        
        Idxreward2 = modulators.odor.reward2.lik  >= median(modulators.odor.reward2.lik);
        
        if mean(Idxreward2) ~= 0.5
            [A,IdxA] = sort(modulators.odor.reward2.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxreward2 = logical(A1(newIdx));
            if mean(Idxreward2) ~= 0.5
                disp('errror')
            end
        end
        
       Idxreward3 = modulators.odor.reward3.lik  >= median(modulators.odor.reward3.lik);
        
        if mean(Idxreward3) ~= 0.5
            [A,IdxA] = sort(modulators.odor.reward3.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxreward3 = logical(A1(newIdx));
            if mean(Idxreward3) ~= 0.5
                disp('errror')
            end
        end
        
        
        
         Idxneutral1 = modulators.odor.neutral1.lik  >= median(modulators.odor.neutral1.lik);
        
        if mean(Idxneutral1) ~= 0.5
            [A,IdxA] = sort(modulators.odor.neutral1.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxneutral1 = logical(A1(newIdx));
            if mean(Idxneutral1) ~= 0.5
                disp('errror')
            end
        end
        
        Idxneutral2 = modulators.odor.neutral2.lik  >= median(modulators.odor.neutral2.lik);
        
        if mean(Idxneutral2) ~= 0.5
            [A,IdxA] = sort(modulators.odor.neutral2.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxneutral2 = logical(A1(newIdx));
            if mean(Idxneutral2) ~= 0.5
                disp('errror')
            end
        end
        
       Idxneutral3 = modulators.odor.neutral3.lik  >= median(modulators.odor.neutral3.lik);
        
        if mean(Idxneutral3) ~= 0.5
            [A,IdxA] = sort(modulators.odor.neutral3.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxneutral3 = logical(A1(newIdx));
            if mean(Idxneutral3) ~= 0.5
                disp('errror')
            end
        end
        
        
       Idxcontrol1 = modulators.odor.control1.lik  >= median(modulators.odor.control1.lik);
        
        if mean(Idxcontrol1) ~= 0.5
            [A,IdxA] = sort(modulators.odor.control1.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxcontrol1 = logical(A1(newIdx));
            if mean(Idxcontrol1) ~= 0.5
                disp('errror')
            end
        end
        
        Idxcontrol2 = modulators.odor.control2.lik  >= median(modulators.odor.control2.lik);
        
        if mean(Idxcontrol2) ~= 0.5
            [A,IdxA] = sort(modulators.odor.control2.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxcontrol2 = logical(A1(newIdx));
            if mean(Idxcontrol2) ~= 0.5
                disp('errror')
            end
        end
        
       Idxcontrol3 = modulators.odor.control3.lik  >= median(modulators.odor.control3.lik);
        
        if mean(Idxcontrol3) ~= 0.5
            [A,IdxA] = sort(modulators.odor.control3.lik);
            A1 = [0 0 0 1 1 1]' ;
            unsort = 1:length(A);
            newIdx(IdxA) = unsort;
            Idxcontrol3 = logical(A1(newIdx));
            if mean(Idxcontrol3) ~= 0.5
                disp('errror')
            end
        end
        
        
        modulators.odor.reward1_1.lik = modulators.odor.reward1.lik(Idxreward1);
        modulators.odor.reward1_2.lik = modulators.odor.reward1.lik(~Idxreward1);
        
        modulators.odor.reward2_1.lik = modulators.odor.reward2.lik(Idxreward2);
        modulators.odor.reward2_2.lik = modulators.odor.reward2.lik(~Idxreward2);
        
        modulators.odor.reward3_1.lik = modulators.odor.reward3.lik(Idxreward3);
        modulators.odor.reward3_2.lik = modulators.odor.reward3.lik(~Idxreward3);
        
                
        modulators.odor.neutral1_1.lik = modulators.odor.neutral1.lik(Idxneutral1);
        modulators.odor.neutral1_2.lik = modulators.odor.neutral1.lik(~Idxneutral1);
        
        modulators.odor.neutral2_1.lik = modulators.odor.neutral2.lik(Idxneutral2);
        modulators.odor.neutral2_2.lik = modulators.odor.neutral2.lik(~Idxneutral2);
        
        modulators.odor.neutral3_1.lik = modulators.odor.neutral3.lik(Idxneutral3);
        modulators.odor.neutral3_2.lik = modulators.odor.neutral3.lik(~Idxneutral3);
        
                
        modulators.odor.control1_1.lik = modulators.odor.control1.lik(Idxcontrol1);
        modulators.odor.control1_2.lik = modulators.odor.control1.lik(~Idxcontrol1);
        
        modulators.odor.control2_1.lik = modulators.odor.control2.lik(Idxcontrol2);
        modulators.odor.control2_2.lik = modulators.odor.control2.lik(~Idxcontrol2);
        
        modulators.odor.control3_1.lik = modulators.odor.control3.lik(Idxcontrol3);
        modulators.odor.control3_2.lik = modulators.odor.control3.lik(~Idxcontrol3);
        
         
        
        %onsets
         
        onsets.odor.reward1 = onsets.odor.reward(run1);
        onsets.odor.reward2 = onsets.odor.reward(run2);
        onsets.odor.reward3 = onsets.odor.reward(run3);
         
        onsets.odor.neutral1 = onsets.odor.neutral(run1);
        onsets.odor.neutral2 = onsets.odor.neutral(run2);
        onsets.odor.neutral3 = onsets.odor.neutral(run3);
         
        onsets.odor.control1 = onsets.odor.control(run1);
        onsets.odor.control2 = onsets.odor.control(run2);
        onsets.odor.control3 = onsets.odor.control(run3);
        
        
        
        onsets.odor.reward1_1 = onsets.odor.reward1(Idxreward1);
        onsets.odor.reward1_2 = onsets.odor.reward1(~Idxreward1);
        
        onsets.odor.reward2_1 = onsets.odor.reward2(Idxreward1);
        onsets.odor.reward2_2 = onsets.odor.reward2(~Idxreward1);
        
        onsets.odor.reward3_1 = onsets.odor.reward3(Idxreward1);
        onsets.odor.reward3_2 = onsets.odor.reward3(~Idxreward1);
        
        
        onsets.odor.neutral1_1 = onsets.odor.neutral1(Idxneutral1);
        onsets.odor.neutral1_2 = onsets.odor.neutral1(~Idxneutral1);
        
        onsets.odor.neutral2_1 = onsets.odor.neutral2(Idxneutral1);
        onsets.odor.neutral2_2 = onsets.odor.neutral2(~Idxneutral1);
        
        onsets.odor.neutral3_1 = onsets.odor.neutral3(Idxneutral1);
        onsets.odor.neutral3_2 = onsets.odor.neutral3(~Idxneutral1);
        
         
         
        onsets.odor.control1_1 = onsets.odor.control1(Idxcontrol1);
        onsets.odor.control1_2 = onsets.odor.control1(~Idxcontrol1);
        
        onsets.odor.control2_1 = onsets.odor.control2(Idxcontrol1);
        onsets.odor.control2_2 = onsets.odor.control2(~Idxcontrol1);
        
        onsets.odor.control3_1 = onsets.odor.control3(Idxcontrol1);
        onsets.odor.control3_2 = onsets.odor.control3(~Idxcontrol1);
        
        %get durations
        durations.odor.reward   = DURATIONS.trialstart(strcmp ('chocolate', CONDITIONS));
        durations.odor.neutral   = DURATIONS.trialstart(strcmp ('neutral', CONDITIONS));
        durations.odor.control   = DURATIONS.trialstart(strcmp ('empty', CONDITIONS));
        %durations.odor.conc       = vertcat(durations.odor.reward, durations.odor.neutral, durations.odor.control);
        
        %durations.odor.conc = durations.odor.conc(Idx,:);
        
        
        durations.odor.reward1 = durations.odor.reward(run1);
        durations.odor.reward2 = durations.odor.reward(run2);
        durations.odor.reward3 = durations.odor.reward(run3);
         
        durations.odor.neutral1 = durations.odor.neutral(run1);
        durations.odor.neutral2 = durations.odor.neutral(run2);
        durations.odor.neutral3 = durations.odor.neutral(run3);
         
        durations.odor.control1 = durations.odor.control(run1);
        durations.odor.control2 = durations.odor.control(run2);
        durations.odor.control3 = durations.odor.control(run3);
        
        
        durations.odor.reward1_1 = durations.odor.reward1(Idxreward1);
        durations.odor.reward1_2 = durations.odor.reward1(~Idxreward1);
        
        durations.odor.reward2_1 = durations.odor.reward2(Idxreward1);
        durations.odor.reward2_2 = durations.odor.reward2(~Idxreward1);
        
        durations.odor.reward3_1 = durations.odor.reward3(Idxreward1);
        durations.odor.reward3_2 = durations.odor.reward3(~Idxreward1);
        
        
        durations.odor.neutral1_1 = durations.odor.neutral1(Idxneutral1);
        durations.odor.neutral1_2 = durations.odor.neutral1(~Idxneutral1);
        
        durations.odor.neutral2_1 = durations.odor.neutral2(Idxneutral1);
        durations.odor.neutral2_2 = durations.odor.neutral2(~Idxneutral1);
        
        durations.odor.neutral3_1 = durations.odor.neutral3(Idxneutral1);
        durations.odor.neutral3_2 = durations.odor.neutral3(~Idxneutral1);
        
         
         
        durations.odor.control1_1 = durations.odor.control1(Idxcontrol1);
        durations.odor.control1_2 = durations.odor.control1(~Idxcontrol1);
        
        durations.odor.control2_1 = durations.odor.control2(Idxcontrol1);
        durations.odor.control2_2 = durations.odor.control2(~Idxcontrol1);
        
        durations.odor.control3_1 = durations.odor.control3(Idxcontrol1);
        durations.odor.control3_2 = durations.odor.control3(~Idxcontrol1);
        
        
 
        %modulators.odor.conc.lik = modulators.odor.conc.lik(Idx,:);
        
        %modulators.odor.run1.lik = modulators.odor.conc.lik(run1);
        %modulators.odor.run2.lik = modulators.odor.conc.lik(run2);
        %modulators.odor.run3.lik = modulators.odor.conc.lik(run3);
        
        
%         %mod for intensity
%         modulators.odor.reward.int  = BEHAVIOR.intensity (strcmp ('chocolate', CONDITIONS));
%         modulators.odor.neutral.int = BEHAVIOR.intensity (strcmp ('neutral', CONDITIONS));
%         modulators.odor.control.int = BEHAVIOR.intensity (strcmp ('empty', CONDITIONS));
%         
%         %modulators.odor.conc.int = vertcat(modulators.odor.reward.int, modulators.odor.neutral.int, modulators.odor.control.int);
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
%         
%         
%          modulators.odor.run1.int = modulators.odor.conc.int(run1);
%          modulators.odor.run2.int = modulators.odor.conc.int(run2);
%          modulators.odor.run3.int = modulators.odor.conc.int(run3);
        
        
        
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
                substr = {'reward1_1';'reward2_1'; 'reward3_1'; 'reward1_2';'reward2_2'; 'reward3_2'; 'neutral1_1';'neutral2_1'; 'neutral3_1'; 'neutral1_2';'neutral2_2'; 'neutral3_2'; 'control1_1';'control2_1'; 'control3_1'; 'control1_2';'control2_2'; 'control3_2' };% specify the substructures names 
                %subsubstr = {'lik'; 'int'}; % specify the subsubstructures names 
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

