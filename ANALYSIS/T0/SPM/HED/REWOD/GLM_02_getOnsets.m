function GLM_02_getOnsets()

% intended for REWOD HED
% get onsets for main model
% Durations =1 
% Simplified model on ONSETs (start, 3*odor + 2*questions)
% last modified on MARCH 2019 by David Munoz


%% define paths

cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/ANALYSIS');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-02';
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

        
        %get durations
        durations.odor.reward   = DURATIONS.trialstart(strcmp ('chocolate', CONDITIONS));
        durations.odor.neutral   = DURATIONS.trialstart(strcmp ('neutral', CONDITIONS));
        durations.odor.control   = DURATIONS.trialstart(strcmp ('empty', CONDITIONS));
       
        
        modulators.odor.reward  = ones (length(onsets.odor.reward),1);
        modulators.odor.neutral = ones (length(onsets.odor.neutral),1);
        modulators.odor.control = ones (length(onsets.odor.control),1);

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
        cd (subjdir) %save all info in the participant directory
        
        
        %% FOR FSL #uncoment if you want to use FSL#
        
        % create text file with 3 colons: onsets, durations, paretric
        % modulators % for each parameter
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         name = {'trialstart'; 'odor'; 'liking'; 'intensity'}; 
% 
%         for ii = 1:length(name)
% 
%             nameX = char(name(ii));
% 
%             if strcmp (nameX, 'odor')  % for structure that contains substuctures
%                 substr = {'reward'; 'control'; 'neutral'};% specify the substructures names
% 
%                 for iii = 1:length(substr)
%                     substrX = char(substr(iii));
%                     nameXX  = [nameX '_' substrX]; % name that combines the structure and the substructures
%                     % database with three rows of interest
%                     database.(nameXX) = [num2cell(onsets.(nameX).(substrX)), num2cell(durations.(nameX).(substrX)), num2cell(modulators.(nameX).(substrX))];
%                     % save the database in a txt file
%                     fid = fopen ([ana_name '_task-' taskX '_' nameX '_' substrX '.txt'],'wt');
%                     formatSpec = '%f\t%f\t%d\n';
%                     [nrows,~] = size(database.(nameXX));
%                     for row = 1:nrows
%                         fprintf(fid,formatSpec,database.(nameXX){row,:});
%                     end
%                     fclose(fid);
%                 end
% 
%           else
%                 % database with three rows of interest 
%                 database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX))];
%                 % save the database in a txt file
%                 fid = fopen ([ana_name '_task-' taskX '_' nameX '.txt'],'wt');
%                 formatSpec = '%f\t%f\t%d\n';
%                 [nrows,~] = size(database.(nameX));
%                 for row = 1:nrows
%                     fprintf(fid,formatSpec,database.(nameX){row,:});
%                 end
%                 fclose(fid);
%             end
% 
%         end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        mat_name = [ana_name '_task-' taskX '_onsets'];
        save (mat_name, 'onsets', 'durations', 'modulators')

    end
    
end
