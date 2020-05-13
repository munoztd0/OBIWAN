function GLM_02_getOnsets()

% intended for REWOD PIT
% get onsets for main model
% Durations =1 (except grips)
% Model on ONSETs 3*CS with modulator
% No modulators
% 4 contrasts (CSp-CSm, CSp-Base,  CSp-CSm&Base,  CSm-Base)
% last modified on JULY 2019 by David Munoz

%% define paths

cd ~
home = pwd;
homedir = [home '/REWOD/'];


mdldir        = fullfile (homedir, '/DERIVATIVES/ANALYSIS');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-02';
%session       = {'second'};
task          = {'PIT'};
subj          = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%% create folder  
mkdir (fullfile (mdldir, char(task), ana_name));

%% extract and save data
for j = 1:length(task)
    
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
        % Get onsets and durations for CS FOR RIM 
        onsets.CS.REM         = RIM.ONSETS.trialstart;
        durations.CS.REM      = RIM.DURATIONS.trialstart;
        modulators.CS.REM     = RIM.BEHAVIOR.mobilized_effort;
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips %%
        onsets.grips.REM          = RIM.ONSETS.grips;
        durations.grips.REM      = zeros(length(onsets.grips.REM),1);
        modulators.grips.REM     = ones(length(onsets.grips.REM),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PE
        onsets.CS.PE          = PE.ONSETS.trialstart;
        durations.CS.PE       = PE.DURATIONS.trialstart;
        modulators.CS.PE      = PE.BEHAVIOR.mobilized_effort;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips %%
        onsets.grips.PE           = PE.ONSETS.grips;
        durations.grips.PE       = zeros (length(onsets.grips.PE),1);
        modulators.grips.PE      = ones  (length(onsets.grips.PE),1);

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PIT
        onsets.CS.CSp          = PIT.ONSETS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        onsets.CS.CSm          = PIT.ONSETS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        onsets.CS.Baseline     = PIT.ONSETS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        
        durations.CS.CSp       = PIT.DURATIONS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        durations.CS.CSm       = PIT.DURATIONS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        durations.CS.Baseline  = PIT.DURATIONS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        
        %replaced grip_frq by mob_effort
        modulators.CS.CSp      = BEHAVIOR.mobilized_effort(strcmp ('CSplus', PIT.CONDITIONS));
        modulators.CS.CSm      = BEHAVIOR.mobilized_effort(strcmp ('CSminus', PIT.CONDITIONS));
        modulators.CS.Baseline = BEHAVIOR.mobilized_effort(strcmp ('Baseline', PIT.CONDITIONS));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips %%?
        onsets.grips.PIT           = PIT.ONSETS.grips;
        durations.grips.PIT       = zeros (length(onsets.grips.PIT),1);
        modulators.grips.PIT      = ones  (length(onsets.grips.PIT),1);


        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) %save all info in the participant directory
        
%         %% FOR FSL #uncoment if you want to use FSL#
%         % create text file with 3 colons: onsets, durations, parametric modulators
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         name = {'CS'; 'grips'};
%         
%         for ii = 1:length(name)
%             
%             nameX = char(name(ii));
%             
%             if strcmp (nameX, 'CS')  % for structure that contains substuctures
%                 substr = {'CSp'; 'CSm'; 'Baseline'; 'REM'; 'PE'};% specify the substructures names
%                 
%                 for iii = 1:length(substr)
%                     substrX = char(substr(iii));
%                     nameXX  = [nameX '_' substrX]; % name that combines the structure and the substructures
%                     % database with three rows of interest
%                     database.(nameXX) = [num2cell(onsets.(nameX).(substrX)), num2cell(durations.(nameX).(substrX)), num2cell(modulators.(nameX).(substrX))];
%                     % save the database in a txt file
%                     fid = fopen ([ana_name '_task-' taskX '_' nameX '_' substrX '.txt'],'wt');
%                     formatSpec = '%f\t%f\t%f\n';
%                     [nrows,~] = size(database.(nameXX));
%                     for row = 1:nrows
%                         fprintf(fid,formatSpec,database.(nameXX){row,:});
%                     end
%                     fclose(fid);
%                 end
%                 
%             elseif strcmp (nameX, 'grips')  % for structure that contains substuctures
%                      substr = {'PIT'; 'PE'; 'REM'};% specify the substructures names
% 
%                 for iii = 1:length(substr)
%                     substrX = char(substr(iii));
%                     nameXX  = [nameX '_' substrX]; % name that combines the structure and the substructures
%                     % database with three rows of interest
%                     database.(nameXX) = [num2cell(onsets.(nameX).(substrX)), num2cell(durations.(nameX).(substrX)), num2cell(modulators.(nameX).(substrX))];
%                     % save the database in a txt file
%                     fid = fopen ([ana_name '_task-' taskX '_'  nameX '_' substrX '.txt'],'wt');
%                     formatSpec = '%f\t%f\t%f\n';
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
%                 formatSpec = '%f\t%f\t%f\n';
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
    
end