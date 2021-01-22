% Exctract betas to .txt FOR REWOD

% create text file with colons: ID, & Betas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbstop if error

%% def path
cd ~
home = pwd;
homedir = [home '/REWOD'];

%% def var
task = 'PIT'; %
glm = 'GLM-04';

list_roi = {'shell-core', 'cmOFC'};

for k = 1:length(list_roi)
    ROI_name = list_roi{k};

    con_name_orig  = 'CSp_CSm';


    %% create database
    in_dir        = fullfile (homedir, '/DERIVATIVES/GLM/', task, 'ROI', ROI_name, 'betas');
    out_dir   = fullfile(homedir, '/DERIVATIVES/GLM/', task, 'ROI');


    ID     = {'ID';'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};

    cd (in_dir)

    %% ROI NAMES
    roi_list = dir('*.mat');

    for i = 1:length(roi_list)
        load(roi_list(i).name);
        eval(['result{1,:} = roi_list(i).name(1:end-4);']);
        database(:,i) = result;
    end

    database = horzcat(ID, database);

    cd (out_dir)
    % Convert cell to a table and use first row as variable names
    T = cell2table(database(2:end,:),'VariableNames',database(1,:));

    % Write the table to a CSV file
    writetable(T, ['extracted_betas_' ROI_name '.txt'],'Delimiter','\t');
end

clear all