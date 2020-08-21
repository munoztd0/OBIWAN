%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compile questionnaires (total and subscales)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified on JAN 2020

close all; clear all;

%% INPUT VARIABLE

analysis_name     = 'Questionnaires-SIGNGOAL-imputed';


%% participants
subj              = {'01';'02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '10'; '11'; '12'; '13'; '14'; '16'; '17';'18'; '19'; '20'; '21'; '22'; '23'; '24'; '25'; '26'; '27'; '28'; '29'; '30' ; '31'; '32'; '33'; '34';  '35'; '36'; '37'; '38'; '39'; '41'; '42'; '43'; '44'; '45'; '46'; '47'; '48'; '49'; '50'; '51'; '52'; '53'; '54'; '55'; '56'; '57'; '58'; '59'; '60'; '61'; '63'; '64'; '65'; '66'; '67'; '68'; '69'; '70'; '71'; '72'; '74'; '75'; '76'; '77'; '78'; '80'; '81'; '82'; '83'; '84'; '85'; '86'; '87'; '88'; '89'; '90'; '91'; '92'; '93'; '94'; '95'; '96'; '97'; '98'; '99'; '100'; '101'; '102'; '103'; '104'; '105'; '106'; '107'; '108'; '109'; '110'; '111'; '112'; '113'; '114'; '115'; '116'; '117'; '118'; '119'; '120'; '121'; '122'; '123'; '124'; '125'; '126'; '127'; '128'; '129'; '130'; '131'; '132'; '133'; '134'; '135'; '136'; '137'; '138'; '139'; '141'; '142'; '143'; '144'; '145'; '146'; '147'; '148'; '149'; '150'; '151'; '152'; '153'; '154'; '155'; '156'; '157'; '158'};

   
%% PATH

% get homedirectory
current_dir       = pwd;
where_to_cut      = (regexp (pwd, 'ANALYSIS') -1);
homedir           = current_dir(1:where_to_cut);


questionnaire_dir = fullfile(homedir,'DATA','STUDY','phenotype');
analysis_dir      = fullfile(homedir,'ANALYSIS');

%outputs
databases_dir     = fullfile(analysis_dir, 'R');

%tools
addpath (genpath(fullfile(analysis_dir,'Matlab','my_tools')));

%% BIS 11

filename = fullfile(questionnaire_dir, 'BIS_11_full.csv');
delimiterIn = ';';
headerlinesIn = 1;
BIS = importdata(filename,delimiterIn,headerlinesIn);
BIS.colheaders = BIS.textdata(1,2:end); % for our databases we also want to individual items (we might wanna do a ACP analysis on all the questionnaires at end)

B = BIS.data; % we do not need to exclude the first colon because we wrote the participant id as a string so the .data field does not reads it (:,2:end);

reverse_list = [1, 7, 8, 9, 12, 13, 20, 30];

for i = 1:length(reverse_list)
    
    ii = reverse_list(i); 
    B(:,ii) = B(:,ii) * -1 + 5;
    
end


list_all   = [{[5 9 11 29 28 6 24 26]}; {[2 3 4 17 19 22 25 16 21 23 30]}; {[1 7 8 12 13 14 10 15 18 27 29]}];
scaleNames = {'BIS_attentional'       ;                     'BIS_motor';          'BIS_nonplanning'};
 
for i = 1:length(scaleNames)
    
    list = cell2mat(list_all(i));
    name = char(scaleNames(i));
    
    subscale.(name) = zeros(size(B,1),1);
    
    for ii = 1:length(list)
        
        item = list (ii);
        subscale.(name) = (subscale.(name) + B(:,item));
    end
       
end


subscale.BIS_total       = subscale.BIS_attentional + subscale.BIS_motor + subscale.BIS_nonplanning;

BIS.all.data             = num2cell ([B,        subscale.BIS_attentional, subscale.BIS_motor,  subscale.BIS_nonplanning,  subscale.BIS_total]);
BIS.all.headers          = [BIS.colheaders, 'BIS_attentional',          'BIS_motor',         'BIS_nonplanning', 'BIS_total'];




%% OCI-R

filename = fullfile(questionnaire_dir, 'OCI_R_full.csv');
delimiterIn = ';';
headerlinesIn = 1;
OCI_R = importdata(filename,delimiterIn,headerlinesIn);

OCI_R.colheaders = OCI_R.textdata(1,2:end); % for our databases we also want to individual items (we might wanna do a ACP analysis on all the questionnaires at end)

B = OCI_R.data; % we do not need to exclude the first colon because we wrote the participant id as a string so the .data field does not reads it (:,2:end);

OCIR_total = sum(B,2);

OCIR.all.data = num2cell ([B, OCIR_total]);
OCIR.all.headers = [OCI_R.colheaders, 'OCIR_total'];% check does the score makes sense according to the norms

%% STAI-T

filename = fullfile(questionnaire_dir, 'STAI_T_full.csv');
delimiterIn = ';';
headerlinesIn = 1;
STAI_T = importdata(filename,delimiterIn,headerlinesIn);

STAI_T.colheaders = STAI_T.textdata(1,2:end); % for our databases we also want to individual items (we might wanna do a ACP analysis on all the questionnaires at end)

B = STAI_T.data; % we do not need to exclude the first colon because we wrote the participant id as a string so the .data field does not reads it (:,2:end);

reverse_list = [1, 3, 6, 7, 10, 13, 14, 16, 19];

for i = 1:length(reverse_list)
    
    ii = reverse_list(i); 
    B(:,ii) = B(:,ii) * -1 + 5;
    
end

STAI_T_total = sum(B,2); % is the total here or only some of the items? does the score makes sense according to the norms

STAI_T.all.data = num2cell ([B, STAI_T_total]);
STAI_T.all.headers = [STAI_T.colheaders, 'STAI_T_total'];

%% CAST

filename = fullfile(questionnaire_dir, 'CAST_full.csv');
delimiterIn = ';';
headerlinesIn = 1;
CAST = importdata(filename,delimiterIn,headerlinesIn);

CAST.colheaders = CAST.textdata(1,2:end); % for our databases we also want to individual items (we might wanna do a ACP analysis on all the questionnaires at end)

B = CAST.data; % we do not need to exclude the first colon because we wrote the participant id as a string so the .data field does not reads it (:,2:end);
CAST_total = sum(B,2);

CAST.all.data = num2cell ([B, CAST_total]);
CAST.all.headers = [CAST.colheaders, 'CAST_total'];

%% PSS

filename = fullfile(questionnaire_dir, 'PSS.csv');
delimiterIn = ';';
headerlinesIn = 1;
PSS = importdata(filename,delimiterIn,headerlinesIn);

PSS.colheaders = PSS.textdata(1,2:end); % for our databases we also want to individual items (we might wanna do a ACP analysis on all the questionnaires at end)

B = PSS.data; % we do not need to exclude the first colon because we wrote the participant id as a string so the .data field does not reads it (:,2:end);
B = B+1; % we need to change the scale from 1-5 to 0-4 (to compare the scores to the normative values)


reverse_list = [4, 5, 7, 8];

for i = 1:length(reverse_list)

    ii = reverse_list(i); 
    B(:,ii) = B(:,ii) * -1 + 5;

end

PSS_total = sum(B,2); % check all item or only some of them ?

PSS.all.data = num2cell ([B, PSS_total]);
PSS.all.headers = [PSS.colheaders, 'PSS_total'];

%% AUDIT

filename = fullfile(questionnaire_dir, 'AUDIT_full.csv');
delimiterIn = ';';
headerlinesIn = 1;
AUDIT = importdata(filename,delimiterIn,headerlinesIn);

AUDIT.colheaders = AUDIT.textdata(1,2:end); % for our databases we also want to individual items (we might wanna do a ACP analysis on all the questionnaires at end)

B = AUDIT.data; % we do not need to exclude the first colon because we wrote the participant id as a string so the .data field does not reads it (:,2:end);
AUDIT_total = sum(B,2); % all or only some??

AUDIT.all.data = num2cell ([B, AUDIT_total]);
AUDIT.all.headers = [AUDIT.colheaders, 'AUDIT_total'];

%% CDS-12 --> to be done

filename = fullfile(questionnaire_dir, 'CDS_12_full.csv');
delimiterIn = ';';
headerlinesIn = 1;
CDS_12 = importdata(filename,delimiterIn,headerlinesIn);
 
CDS_12.colheaders = CDS_12.textdata(1,2:end); % for our databases we also want to individual items (we might wanna do a ACP analysis on all the questionnaires at end)
 
B = CDS_12.data; % we do not need to exclude the first colon because we wrote the participant id as a string so the .data field does not reads it (:,2:end);

CDS_12_total = sum(B,2);
 
CDS_12.all.data = num2cell ([B, CDS_12_total]);
CDS_12.all.headers = [CDS_12.colheaders, 'CDS_12_total'];

%% BISBAS

filename = fullfile(questionnaire_dir, 'BISBAS_full.csv');
delimiterIn = ';';
headerlinesIn = 1;
BISBAS = importdata(filename,delimiterIn,headerlinesIn);
BISBAS.colheaders = BISBAS.textdata(1,2:end); % for our databases we also want to individual items (we might wanna do a ACP analysis on all the questionnaires at end)

B = BISBAS.data; % we do not need to exclude the first colon because we wrote the participant id as a string so the .data field does not reads it (:,2:end);

reverse_list = [2, 22];

for i = 1:length(reverse_list)
    
    ii = reverse_list(i); 
    B(:,ii) = B(:,ii) * -1 + 5;
    
end

list_all   = [{[3 9 12 21]}; {[5 10 15 20]}; {[4 7 14 18 23]}; {[2 8 13 6 19 22 24]}];
scaleNames = {'BAS_drive';'BAS_Fun_seeking';'BAS_reward_responsivness';'BIS'};
 
for i = 1:length(scaleNames)
    
    list = cell2mat(list_all(i));
    name = char(scaleNames(i));
    
    subscale.(name) = zeros(size(B,1),1);
    
    for ii = 1:length(list)
        
        item = list (ii);
        subscale.(name) = (subscale.(name) + B(:,item));
    end
       
end

subscale.BISBAS_total       = subscale.BAS_drive + subscale.BAS_Fun_seeking + subscale.BAS_reward_responsivness;


BISBAS.all.data             = num2cell ([B,        subscale.BAS_drive, subscale.BAS_Fun_seeking,  subscale.BAS_reward_responsivness,  subscale.BIS, subscale.BISBAS_total]);
BISBAS.all.headers          = [BISBAS.colheaders, 'BAS_drive',          'BAS_Fun_seeking',         'BAS_reward_responsivness',           'BAS_BIS',       'BAS_total'];

%% print the newid and the compiled questionnaires

% create the ID variable
ID = BISBAS.textdata(2:end,1); 


% open database
fid = fopen(fullfile(databases_dir, [analysis_name '.txt']), 'wt');

% print headers
headers    = ['ID', BIS.all.headers,  STAI_T.all.headers, OCIR.all.headers, CAST.all.headers, PSS.all.headers, AUDIT.all.headers, CDS_12.all.headers, BISBAS.all.headers];
formatSpec = repmat('%s    ',1, length(headers));

fprintf(fid, [formatSpec '\n'], headers {:});

% print data
Rdatabase  = [ID, BIS.all.data,  STAI_T.all.data, OCIR.all.data, CAST.all.data, PSS.all.data, AUDIT.all.data, CDS_12.all.data, BISBAS.all.data];
formatSpec = ['%s   ', repmat('% d    ',1, size(Rdatabase,2)-1)];
[nrows,~] = size(Rdatabase);
for row = 1:nrows
    fprintf(fid,[formatSpec '\n'],Rdatabase{row,:});
end

fclose(fid);
