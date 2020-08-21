% Generate json metafile for questionnaire

% note: for older version than matlab 2017, the toolbox to write and read
% json files can be downloaded here: 
% https://ch.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% input variable

% where to save the metafile
where = '/Users/evapool/switchdrive/SIGNGOAL/DATA/STUDY/phenotype'; % specify the path to where you want the metafile to be saved
MeasurementToolName = 'AUDIT.json';

% descriptors
% always present
txt.description = 'AUDIT: Alcohol Use Disorders Identification Test';
txt.TermURL     = 'https://www.alcoolassistance.net/files/AUDIT.pdf'; % I still need to find a solution to use / json
txt.notes       = sprintf(['10-items scale; \n '...
    '                item 3,4,5,6,7,8: score: 0 = Never, 1 = Less than monthly, 2 = Monthly, 3 = Weekly, 4 = Daily or almost daily  \n',...
    '                item 1: score: 0 = Never, 1 = Monthly or less, 2 = 2 to 4 times a month, 3 = 2 to 3 times a week, 4 = 4 or more times a week  \n',...
    '                item 2: score: 0 = 1 or 2, 1 = 3 or 4, 2 = 5 or 6, 3 = 7,8,or 9, 4 = 10 or more  \n',...
    '                item 9,10: score: 0 = No, 2 = Yes, but not in the last year, 4 = Yes, during the last year  \n']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data in a json object
j = savejson('', struct('AUDIT', struct('Description', {txt.description}, 'Notes', {txt.notes})));

% write the jsonfile in the function folder
cd (where)

fid = fopen(MeasurementToolName,'wt');
fprintf (fid, j);
fclose(fid);

