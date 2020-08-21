% Generate json metafile for questionnaire

% note: for older version than matlab 2017, the toolbox to write and read
% json files can be downloaded here: 
% https://ch.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% input variable

% where to save the metafile
where = '/Users/evapool/switchdrive/SIGNGOAL/DATA/STUDY/phenotype'; % specify the path to where you want the metafile to be saved
MeasurementToolName = 'CAST.json';

% descriptors
% always present
txt.description = 'CAST: Questionnaire d?auto-?valuation consommation de cannabis';
txt.TermURL     = 'https:--loireadd.org-boite-a-outils-questionnaires-dauto-evaluation-'; % I still need to find a solution to use / json
txt.notes       = '6-items scale; score: 0 = No, 1 = Yes';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data in a json object
j = savejson('', struct('CAST', struct('Description', {txt.description}, 'TermURL', {txt.TermURL}, 'Notes', {txt.notes})));

% write the jsonfile in the function folder
cd (where)

fid = fopen(MeasurementToolName,'wt');
fprintf (fid, j);
fclose(fid);

