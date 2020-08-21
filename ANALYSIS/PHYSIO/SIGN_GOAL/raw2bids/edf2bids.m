% change file name of the eyelink in bids format


%% input variables

subjects = {'145'}
runs     = {'01'; '02'; '03'};
%my_computer   = '/Users/kseniasmirnova/'; % insert the path to switchdrive of your computer
%my_computer   = '/Users/lance/';
my_computer   = '/Users/evapool/';

%% DEFINE PATH

% where are the edfile to be converted?
where        = fullfile (my_computer, 'switchdrive/SIGNGOAL/DATA/STUDY/'); % specify the path to where you want the metafile to be saved
homedir      = fullfile (my_computer, 'switchdrive/SIGNGOAL');
analysis_dir = fullfile(homedir, 'ANALYSIS', 'Matlab');

% add tools
addpath (genpath(fullfile(analysis_dir,'/my_tools'))); % attention add framework

%% DO THE CONVERSION
for i = 1:length(subjects)
    
    subject = char(subjects(i));
    
    for ii =1:length(runs)
        
        run = char(runs(ii));
        
        subj_dir     = fullfile (where, ['sub-' subject]);

        %******************************************************************
        %* BEHAVIOURAL DATA
        
        % build the names of the files with specifics of the run and the
        % participant
        original_name_behav = fullfile(subj_dir, ['sub-' subject '_task-SIGNGOAL_run-' run '.mat']);
        bids_name_behav     = fullfile(subj_dir, ['sub-' subject '_task-SIGNGOAL_run-' run '_events.mat']);
        
        
        % rename file
        if exist(bids_name_behav, 'file') ~= 2 % we rename file only if they have not been renamed yet
            movefile (original_name_behav, bids_name_behav)
        end
        
        % load file for quick prepoc
        load (bids_name_behav);
        %******************************************************************
        %* EYES DATA
        
        % build the names of the files with specifics of the run and the
        % participant
        original_name = ['P' subject '_' run(end) '.edf'];
        bids_name    = ['sub-' subject '_task-SIGNGOAL_run-' run '_eyes'];
        
        % transform the edf file in matfile with the correspondent bids
        % name
        cd (subj_dir) % go into the subject directory
        
        dataGaze = Edf2Mat(original_name); % tranform
        
        param.dispPlot   = 1;
        param.whichEye   = 1; % attention if the wrong eye is tracked you will not see the pupil data in the second plot
        param.screendim  = [0 0 1920 1080]; % get this from data
        param.FSP        = getFPS(dataGaze.RawEdf.FSAMPLE.time);
        [t, allEye, s]   = load_EDF(param, dataGaze, data, subject);
        
        save(bids_name, 'dataGaze'); % save the transformed file with the corrsponding bids name
        
    end
    
    
end
