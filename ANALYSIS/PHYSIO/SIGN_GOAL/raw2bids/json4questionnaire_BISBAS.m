% Generate json metafile for questionnaire

% note: for older version than matlab 2017, the toolbox to write and read
% json files can be downloaded here: 
% https://ch.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% input variable

% where to save the metafile
where = '/Users/evapool/switchdrive/SIGNGOAL/DATA/STUDY/phenotype'; % specify the path to where you want the metafile to be saved
MeasurementToolName = 'BISBAS.json';

% descriptors
% always present
txt.description = 'BISBAS: Behavior Inhibition, Behavioral Activation Scales';
txt.TermURL     = 'http:--www.psy.miami.edu-faculty-ccarver-sclBISBAS.html'; % I still need to find a solution to use / json


% if subscales exisits in this example there 4 subscales (BAS_drive;
% BAS_fun; BAS_resp; BIS
subscale1 = 'BAS_drive';
txt.subscale1.description   = 'BAS drive subscale: 3,9,12,21';
subscale2 = 'BAS_Fun_seeking';
txt.subscale2.description   = 'BAS Fun seeking; 5,10,15,20';
subscale3 = 'BAS_reward_responsivness';
txt.subscale3.description   = 'BAS reward responsiveness, 4,7,14,18,23';
subscale4 = 'BIS';
txt.subscale4.description   = 'BIS: 2(inverted),8,13,6,19,22(inverted),24';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data in a json object
j = savejson('', struct('BISBAS', struct('Description', {txt.description}, 'TermURL', {txt.TermURL}),...
    subscale1, struct('Description', {txt.subscale1.description}),...
    subscale2, struct('Description', {txt.subscale2.description}),...
    subscale3, struct('Description', {txt.subscale3.description}),...
    subscale4, struct('Description', {txt.subscale4.description})));

% write the jsonfile in the function folder
cd (where)

fid = fopen(MeasurementToolName,'wt');
fprintf (fid, j);
fclose(fid);

