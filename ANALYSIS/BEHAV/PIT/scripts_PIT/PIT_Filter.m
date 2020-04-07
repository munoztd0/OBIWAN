%% Count the grip frequency for the PIT phases
%function Results = PIT_filter(matfile)

%matfile = ('/Users/admin/Documents/REWOD/REWOD/DATA/Behavior/PIT/');
%mat = dir([matfile '*.mat']);

%Results = [];

%for k = 1:size(mat,1)

%clear CSplus CSminus Baseline
% name = [matfile mat(k).name];

%load(name);

%disp(['fichier ' num2str(k) ' ' name ]);

%load ('PIT_S1.mat')

%load (matfile)

% Compute the trashold to determine what we consider as a response (50%
%of the maximal force)

seuil = data.maximalforce/100*50;% value

% Instrumental Rimind: count the grip frenquency

nlines = size(ResultsRimind.mobilizedforce,1);
ncolons = size(ResultsRimind.mobilizedforce,2);
rimindOnset = ResultsRimind.TrialOnset';
rimindDuration = ResultsRimind.TrialDuration';
rimindOnsetITI = ResultsRimind.OnsetITI';
rimindOnsetITIDuration = ResultsRimind.ITI';

gripsFrequenceRimind = countgrips(seuil,nlines,ncolons,ResultsRimind.mobilizedforce);
gripsOnsetsRimind = gripsOnsets(seuil,nlines,ncolons,ResultsRimind.mobilizedforce,ResultsRimind.TrialOnset)%,ResultsRimind.RewardWindowDuration1,ResultsRimind.RewardWindowDuration2);


% Intrumental partial extinction: Count the grip frequency

nlines = size(ResultsPartialExtinction.mobilizedforce,1);
ncolons = size(ResultsPartialExtinction.mobilizedforce,2);
PEOnset = ResultsPartialExtinction.TrialOnset';
rimindDuration = ResultsPartialExtinction.TrialDuration';
PEonsetITI = ResultsPartialExtinction.onsetITI';
PEOnsetITIDuration = ResultsPartialExtinction.ITI';
gripsFrequencePE = countgrips(seuil,nlines,ncolons,ResultsPartialExtinction.mobilizedforce);
gripsOnsetsPE = gripsOnsets(seuil,nlines,ncolons,ResultsPartialExtinction.mobilizedforce,ResultsPartialExtinction.TrialOnset,ResultsPartialExtinction.RewardWindowDuration1, 0);

%% PIT part

%% Step 1: create the matrix

% *read the labels*
cmp = 0;
for i = 1:5
    for n = 1:9
        cmp = cmp + 1;
        Image{cmp}= ResultsPIT.Image{:,n,i};%first dimension of the matrix
    end
end


% read the value of the mobilized effort
first = ResultsPIT.force(:,:,1);% for the first dimension of the matrix
second = ResultsPIT.force(:,:,2);% for the second dimension of the matrix
third = ResultsPIT.force(:,:,3);
fourth = ResultsPIT.force(:,:,4);
fifth = ResultsPIT.force(:,:,5);

f = [first,second,third,fourth,fifth];
% *Put the label and the value in one matrix*
matrix = [Image;num2cell(f)];

%read onsets

PITonsets = horzcat (ResultsPIT.Onset(:));
PITonsetITI = horzcat (ResultsPIT.OnsetITI(:));
PITdurations = horzcat (ResultsPIT.ItemDuration(:));
PITdurationsITI = horzcat (ResultsPIT.ITI(:));
%% Step 2: divide the item by condition by keeping the time information
labelVector = matrix(1,:)'; % this is useful to used the function findlabelPosition

% CSplus
CSplusPosition = findLabelPosition ('CSplus.jpg',labelVector);
CSplusOnset = nan (size(CSplusPosition,2),1);
CSplusDuration = nan (size(CSplusPosition,2),1);

%mobilized effort raw
for i = 1:size(CSplusPosition,2)
    CSplus(:,i) = matrix(2:(size(matrix,1)),CSplusPosition(i));
end
CSplus = cell2mat(CSplus);

%onset
for i = 1: size(CSplusPosition,2)
    CSplusOnset (i) = PITonsets(CSplusPosition(i));
    CSplusDuration (i) = PITdurations(CSplusPosition(i));
end


% CSminus
CSminusPosition = findLabelPosition ('CSminu.jpg',labelVector);
CSminusOnset = nan (size(CSminusPosition,2),1);
CSminusDuration = nan (size(CSminusPosition,2),1);

%mobilized effort raw
for i = 1:size(CSminusPosition,2)
    CSminus(:,i) = matrix(2:(size(matrix,1)),CSminusPosition(i));%clean from nan value
end
CSminus = cell2mat(CSminus);

%onset
for i = 1: size(CSminusPosition,2)
    CSminusOnset (i) = PITonsets(CSminusPosition(i));
    CSminusDuration (i) = PITdurations(CSminusPosition(i));
end


% Baseline
BaselinePosition = findLabelPosition ('Baseli.jpg',labelVector);
BaselineOnset = nan (size(BaselinePosition,2),1);
BaselineDuration = nan (size(BaselinePosition,2),1);

%mobilized effort raw
for i = 1:size(BaselinePosition,2)
    Baseline(:,i) = matrix(2:(size(matrix,1)),BaselinePosition(i));
end
Baseline = cell2mat(Baseline);

%onset
for i = 1: size(BaselinePosition,2)
    BaselineOnset (i) = PITonsets(BaselinePosition(i));
    BaselineDuration (i) = PITdurations(BaselinePosition(i));
end

%% Step 3: count the press frequency for each condition

% CSplus
nlines = size(ResultsPIT.force,1);
ncolons = size(CSplus,2);

gripsFrequenceCSplus = countgrips(seuil,nlines,ncolons,CSplus);


gripsCSplus_block1 = gripsFrequenceCSplus (1:3);
gripsCSplus_block2 = gripsFrequenceCSplus (4:6);
gripsCSplus_block3 = gripsFrequenceCSplus (7:9);
gripsCSplus_block4 = gripsFrequenceCSplus (10:12);
gripsCSplus_block5 = gripsFrequenceCSplus (13:15);

% CSminus
nlines = size(ResultsPIT.force,1);
ncolons = size(CSminus,2);

gripsFrequenceCSminus = countgrips(seuil,nlines,ncolons,CSminus);

gripsCSminus_block1 = gripsFrequenceCSminus(1:3);
gripsCSminus_block2 = gripsFrequenceCSminus (4:6);
gripsCSminus_block3 = gripsFrequenceCSminus (7:9);
gripsCSminus_block4 = gripsFrequenceCSminus (10:12);
gripsCSminus_block5 = gripsFrequenceCSminus (13:15);

% Baseline
nlines = size(ResultsPIT.force,1);
ncolons = size(Baseline,2);

gripsFrequenceBaseline = countgrips(seuil,nlines,ncolons,Baseline);

gripsBaseline_block1 = gripsFrequenceBaseline(1:3);
gripsBaseline_block2 = gripsFrequenceBaseline(4:6);
gripsBaseline_block3 = gripsFrequenceBaseline (7:9);
gripsBaseline_block4 = gripsFrequenceBaseline(10:12);
gripsBaseline_block5 = gripsFrequenceBaseline (13:15);

%% Step 4: all condition togheter to check if the extinction processes was taking place

All = matrix(2:(size(matrix,1)),:);
All = cell2mat(All);

nlines = size(All,1);
ncolons = size (All,2);

gripsFrequenceAll = countgrips(seuil,nlines,ncolons,All);
gripsOnsetsPITALL = gripsOnsets (seuil,nlines,ncolons,All,PITonsets,0,0);

%% final result
GripsFrequenceAll = num2cell(gripsFrequenceAll); % to concatenate conditions name and value
PITFrequenceGrip = [Image;GripsFrequenceAll];

%Results  = [gripsFrequenceRimind, gripsFrequencePE, gripsFrequenceCSplus,gripsFrequenceCSminus,gripsFrequenceBaseline];
Results  = [gripsFrequenceCSplus;gripsFrequenceCSminus;gripsFrequenceBaseline];


%%% in case it does not show the all digit use
%fprintf('%.4f\n ', CSminusOnset')
%end