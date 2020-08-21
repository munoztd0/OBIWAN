% Generate json metafile for questionnaire

% note: for older version than matlab 2017, the toolbox to write and read
% json files can be downloaded here: 
% https://ch.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% input variable

% where to save the metafile
where = '/Users/evapool/switchdrive/SIGNGOAL/DATA/STUDY/phenotype'; % specify the path to where you want the metafile to be saved
MeasurementToolName = 'CDS-12.json';

% descriptors
% always present
txt.description = 'CDS-12: Cigarette Dependence Scale';
txt.TermURL     = 'https:--www.stop-dependance.ch-tabac-pdf-Depend.pdf'; % I still need to find a solution to use / json
txt.notes       = sprintf(['12-items scale; \n '...
    '                item 1: 1 = 0-20, 2 = 21-40, 3 = 41-60, 4 = 61-80, 5 = 81-100\n',...
    '                item 2: 1 = 0-5, 2 = 6-10, 3 = 11-20, 4 = 21-29, 5 = 30+\n',...
    '                item 3: 1 = 61+, 2 = 21-60, 3 = 16-30, 4 = 6-15, 5 = 0-5\n',...
    '                item 4: score: 1 = Very easy, 2 = Fairly easy, 3 = Fairly difficult, 4 = Very difficult, 5 = Impossible\n',...
    '                item 5,6,7,8,9,10,11,12: score: 1 = Totally disagree, 2 = Somewhat disagree, 3 = Neither agree nor disagree, 4 = Somewhat agree, 5 = Fully agree']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data in a json object
j = savejson('', struct('CDS_12', struct('Description', {txt.description},'TermURL', {txt.TermURL}, 'Notes', {txt.notes})));

% write the jsonfile in the function folder
cd (where)

fid = fopen(MeasurementToolName,'wt');
fprintf (fid, j);
fclose(fid);

