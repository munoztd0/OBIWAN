% Generate json metafile for questionnaire

% note: for older version than matlab 2017, the toolbox to write and read
% json files can be downloaded here: 
% https://ch.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% input variable

% where to save the metafile
where = '/Users/evapool/switchdrive/SIGNGOAL/DATA/STUDY/phenotype'; % specify the path to where you want the metafile to be saved
%where = '/Users/alessiogiarrizzo/switchdrive/PAVSTRESS/DATA/STUDY/phenotype';
MeasurementToolName = 'STAI_T.json';

% descriptors
% always present
txt.description = 'STAI_T: State-Trait Anxiety Inventory-Trait';
txt.notes = '20-items scale; score: 1 = Almost never, 2 = Sometimes, 3 = Often, 4 = Almost always; items 1, 3, 6, 7, 10, 13, 14, 16, and 19 are reversed';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data in a json object
j = savejson('', struct('STAI_T', struct('Description', {txt.description}, 'Notes', {txt.notes})));

% write the jsonfile in the function folder
cd (where)

fid = fopen(MeasurementToolName,'wt');
fprintf (fid, j);
fclose(fid);

