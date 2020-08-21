% Generate json metafile for questionnaire

% note: for older version than matlab 2017, the toolbox to write and read
% json files can be downloaded here: 
% https://ch.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% input variable

% where to save the metafile
where = '/Users/evapool/switchdrive/SIGNGOAL/DATA/STUDY/phenotype'; % specify the path to where you want the metafile to be saved
MeasurementToolName = 'BIS_11.json';

% descriptors
% always present
txt.description = 'BIS-11: Barratt Impulsiveness Scale';
txt.TermURL     = 'https:--tdahbe.files.wordpress.com-2013-02-bis-11.pdf'; % I still need to find a solution to use / json
txt.notes       = '30-items scale; score: 1 = Rarely/Never, 2 = Occasionally, 3 = Often, 4 = Almost Always/Always; items 9, 20, 7, 30, 1, 10, 12, 13, 15, 29 and 8 are reversed';

% if subscales exisits in this example there 3 subscales 
subscale1 = 'Attentional_Impulsiveness';
txt.subscale1.description   = 'Attentional Impulsiveness: 6,5,9(inverted),11,20(inverted),24,26,28';
subscale2 = 'Motor_Impulsiveness';
txt.subscale2.description   = 'Motor Impulsiveness; 2,3,4, 16, 17, 19,21,22,23,25,30(inverted)';
subscale3 = 'Nonplanning_Impulsiveness';
txt.subscale3.description   = 'Nonplanning Impulsiveness, 1(inverted),7(inverted),8(inverted),10(inverted),12(inverted),13(inverted),14,15(inverted),18,27,29(inverted)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data in a json object
j = savejson('', struct('BIS_11', struct('Description', {txt.description}, 'TermURL', {txt.TermURL}),...
    subscale1, struct('Description', {txt.subscale1.description}),...
    subscale2, struct('Description', {txt.subscale2.description}),...
    subscale3, struct('Description', {txt.subscale3.description})));

% write the jsonfile in the function folder
cd (where)

fid = fopen(MeasurementToolName,'wt');
fprintf (fid, j);
fclose(fid);

