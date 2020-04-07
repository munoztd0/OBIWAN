function  [Results_RT, ResultsLiking] = PavBehavFilter ()

% this function create the database for the analysis of the pavolovian
% conditioning
% created by Eva on 30.09.2015


Results_RT = []; % initialize variable
ResultsLiking = [];

matfilePath = fullfile(pwd,'matfiles'); % eventually change the
matfiles = dir(fullfile(matfilePath, '*.mat'));
workingdir = pwd;

for i = 1:size(matfiles,1)
    
    
    cd matfiles
    name = matfiles(i).name;
    load(name);
    disp(['file ' num2str(i) ' ' name ]); %that allows to see which file does
    %not work
    
    
    cd (workingdir);
    
    rounds = num2cell (dataPav.rounds); % concert to cell to be put the same amtrix as the other variables
    RT = num2cell (responseTimes);
    
    matrix = [rounds, dataPav.csNames, keysPressed, RT];
    matrix = sortrows (matrix,1);
    
    part = size(matrix,1)/3;
    
    % matrix for repetition time
    matrix_1 = matrix (1: part,:); % matrix for the first round
    matrix_2 = matrix ((part+1): (part*2),:);
    matrix_3 = matrix (((part*2)+1):(part*3),:);%%%%%%%%%%%% HERE
    
    % compute extrame value
    
    ALLRT = cell2mat (matrix (:,4));
    ALLRT (find(ALLRT  ==1)) = nan; % remove nonreponse to compute the overa all mean
    
    totalMean = nanmean(ALLRT);
    stdError = nanstd (ALLRT);
    threshold = 3*stdError+totalMean;
    
    % extract RT and ACC for each repertition
    [RT_CSminus1, RT_CSplus1, ACC_CSminus1, ACC_CSplus1] = extractRT (matrix_1,threshold);
    [RT_CSminus2, RT_CSplus2, ACC_CSminus2, ACC_CSplus2] = extractRT (matrix_2,threshold);
    [RT_CSminus3, RT_CSplus3, ACC_CSminus3, ACC_CSplus3] = extractRT (matrix_3,threshold);
    
    Results_RT (i,:) = [RT_CSminus1, RT_CSplus1, ACC_CSminus1, ACC_CSplus1,RT_CSminus2, RT_CSplus2, ACC_CSminus2, ACC_CSplus2,RT_CSminus3, RT_CSplus3, ACC_CSminus3, ACC_CSplus3];
    
    %extract auto report data
    
    [basLiking,CSminusLiking,CSplusLiking] = extractLiking (PavCheck);
    ResultsLiking (i,:) = [basLiking,CSminusLiking,CSplusLiking];
end

end