% Generate json metafile for questionnaire

% note: for older version than matlab 2017, the toolbox to write and read
% json files can be downloaded here: 
% https://ch.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% input variable

% where to save the metafile
where = '/Users/evapool/switchdrive/SIGNGOAL/DATA/STUDY/phenotype'; % specify the path to where you want the metafile to be saved
MeasurementToolName = 'OCI-R.json';

% descriptors
% always present
txt.description = 'OCI-R: Obsessive Compulsive Inventory-Revised';
txt.TermURL     = 'http:--www.em-consulte.com-en-article-53148'; % I still need to find a solution to use / json
txt.notes       = '18-items scale; score: 0 = Pas du tout, 1 = Peu, 2 = Moyennement, 3 = Beaucoup, 4 = Extremement';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data in a json object
j = savejson('', struct('OCI_R', struct('Description', {txt.description}, 'TermURL', {txt.TermURL}, 'Notes', {txt.notes})));

% write the jsonfile in the function folder
cd (where)

fid = fopen(MeasurementToolName,'wt');
fprintf (fid, j);
fclose(fid);

