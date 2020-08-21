% Generate json metafile for questionnaire

% note: for older version than matlab 2017, the toolbox to write and read
% json files can be downloaded here: 
% https://ch.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% input variable

% where to save the metafile
where = '/Users/evapool/switchdrive/SIGNGOAL/DATA/STUDY/phenotype'; % specify the path to where you want the metafile to be saved
%where = '/Users/evapool/switchdrive/PAVSTRESS/DATA/STUDY/phenotype';
MeasurementToolName = 'PSS.json';

% descriptors
% always present
txt.description = 'PSS: Perceived Stress Scale';
txt.TermURL     = 'http:--mindgarden.com-documents-PerceivedStressScale.pdf';
txt.notes       = '10-items scale; score: 0 = Never, 1 = Almost never, 2 = Sometimes, 3 = Fairly often, 4 = Very often; items 4, 5, 7 and 8 are reversed';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data in a json object
j = savejson('', struct('PSS', struct('Description', {txt.description}, 'TermURL', {txt.TermURL}, 'Notes', {txt.notes})));

% write the jsonfile in the function folder
cd (where)

fid = fopen(MeasurementToolName,'wt');
fprintf (fid, j);
fclose(fid);

