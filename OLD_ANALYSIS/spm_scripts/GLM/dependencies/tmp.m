% try to simplfy constrasts creation

% This will be what I have
param.runs = {'01'; '02'; '03'};

for i = 1:3
    
    param.Cnam{i} = {'ONS.onsets.CS.deval_L',...
        'ONS.onsets.CS.deval_R',...
        'ONS.onsets.CS.val_L',...
        'ONS.onsets.CS.val_R',...
        'ONS.onsets.CS.CSm',...
        'ONS.onsets.ANT',...
        'ONS.onsets.US',...
        'ONS.onsets.ITI'}; 
end




%%%%%%%%%%%%%%%%

ncondition = length(param.Cnam{1});
conditionName = [];
        
for i = 1:length(param.runs);
    
    run = ['run' num2str(i) '.'];
    
    for ii = 1:ncondition
        
        conditionName{i} {ii} (:) = strcat ( run, param.Cnam{i} {ii} (12:end));
        
    end
    
end
    
 conditionName = cat(2, conditionName{:});
 

% do my constrasts in a human friendly readable way

% | CONSTRASTED IMAGES FOR FLEXIBLE FACTORIAL


% | CONSTRASTS FOR T-TESTS

% con1
label{1}   = 'all.P-M';
weightPos  = ismember(conditionName, {'run1.CS.deval_L', 'run1.CS.deval_R','run1.CS.val_L','run2.CS.val_R','run2.CS.deval_L', 'run2.CS.deval_R','run2.CS.val_L','run2.CS.val_R', 'run3.CS.deval_L', 'run3.CS.deval_R','run3.CS.val_L','run3.CS.val_R'}) * 1;
weightNeg  = ismember(conditionName, {'run1.CS.CSm','run2.CS.CSm','run3.CS.CSm'})* -4;
c(1,:)     = weightPos+weightNeg;

% con2
label{2}   = 'learning.P-M';
weightPos  = ismember(conditionName, {'run1.CS.deval_L', 'run1.CS.deval_R','run1.CS.val_L','run2.CS.val_R','run2.CS.deval_L', 'run2.CS.deval_R','run2.CS.val_L','run2.CS.val_R'}) * 1;
weightNeg  = ismember(conditionName, {'run1.CS.CSm','run2.CS.CSm'})* -4;
c(2,:)     = weightPos+weightNeg;

% con3
label{3}   = 'run1.P-M';
weightPos  = ismember(conditionName, {'run1.CS.deval_L', 'run1.CS.deval_R','run1.CS.val_L','run1.CS.val_R'}) * 1;
weightNeg  = ismember(conditionName, {'run1.CS.CSm'})* -4;
c(3,:)     = weightPos+weightNeg;

% con4
label{4}   = 'run2.P-M';
weightPos  = ismember(conditionName, {'run2.CS.deval_L', 'run2.CS.deval_R','run2.CS.val_L','run2.CS.val_R'}) * 1;
weightNeg  = ismember(conditionName, {'run2.CS.CSm'})* -4;
c(4,:)     = weightPos+weightNeg;

% con5
label{5}   = 'run3.P-M';
weightPos  = ismember(conditionName, {'run3.CS.deval_L', 'run3.CS.deval_R','run3.CS.val_L','run3.CS.val_R'}) * 1;
weightNeg  = ismember(conditionName, {'run3.CS.CSm'})* -4;
c(5,:)     = weightPos+weightNeg;

% con6
label{6}   = 'run2.value-deval';
weightPos  = ismember(conditionName, {'run2.CS.deval_L', 'run2.CS.deval_R'}) * 1;
weightNeg  = ismember(conditionName, {'run2.CS.val_L','run2.CS.val_R'})* -1;
c(6,:)     = weightPos+weightNeg;

% con7
label{7}   = 'run3.value-deval';
weightPos  = ismember(conditionName, {'run3.CS.deval_L', 'run3.CS.deval_R'}) * 1;
weightNeg  = ismember(conditionName, {'run3.CS.val_L','run3.CS.val_R'})* -1;
c(7,:)     = weightPos+weightNeg;

%con8
label{8}   = 'interValue.run-2run3';
weightPos  = ismember(conditionName, {'run2.CS.val_L', 'run2.CS.val_R', 'run3.CS.deval_L', 'run3.CS.deval_R'}) * 1;
weightNeg  = ismember(conditionName, {'run2.CS.deval_L','run2.CS.deval_R','run3.CS.val_L', 'run3.CS.val_R'})* -1;
c(8,:)     = weightPos+weightNeg;

%con9
label{9}   = 'interValue.learning-run3';
weightPos  = ismember(conditionName, {'run1.CS.val_L', 'run1.CS.val_R','run2.CS.val_L', 'run2.CS.val_R', 'run3.CS.deval_L', 'run3.CS.deval_R'}) * 1;
weightNeg  = ismember(conditionName, {'run1.CS.deval_L','run1.CS.deval_R', 'run2.CS.deval_L','run2.CS.deval_R','run3.CS.val_L', 'run3.CS.val_R'})* -1;
c(9,:)     = weightPos+weightNeg;

%con10
label{10}   = 'all.left-right';
weightPos  = ismember(conditionName, {'run1.CS.val_L', 'run1.CS.deval_L','run2.CS.val_L', 'run2.CS.deval_L', 'run3.CS.deval_L', 'run3.CS.deval_L'}) * 1;
weightNeg  = ismember(conditionName, {'run1.CS.deval_R','run1.CS.val_R', 'run2.CS.val_R','run2.CS.deval_R','run3.CS.val_R', 'run3.CS.deval_R'})* -1;
c(10,:)     = weightPos+weightNeg;

%con11
label{11}   = 'learning.left-right';
weightPos  = ismember(conditionName, {'run1.CS.val_L', 'run1.CS.deval_L','run2.CS.val_L', 'run2.CS.deval_L'}) * 1;
weightNeg  = ismember(conditionName, {'run1.CS.deval_R','run1.CS.val_R', 'run2.CS.val_R','run2.CS.deval_R'})* -1;
c(11,:)     = weightPos+weightNeg;

%con12
label{12}   = 'run1.left-right';
weightPos  = ismember(conditionName, {'run1.CS.val_L', 'run1.CS.deval_L'}) * 1;
weightNeg  = ismember(conditionName, {'run1.CS.deval_R','run1.CS.val_R'})* -1;
c(12,:)     = weightPos+weightNeg;

%con13
label{13}   = 'run3.left-right';
weightPos  = ismember(conditionName, {'run2.CS.val_L', 'run2.CS.deval_L'}) * 1;
weightNeg  = ismember(conditionName, {'run2.CS.deval_R','run2.CS.val_R'})* -1;
c(13,:)     = weightPos+weightNeg;

%con14
label{14}   = 'run3.left-right';
weightPos  = ismember(conditionName, {'run3.CS.val_L', 'run3.CS.deval_L'}) * 1;
weightNeg  = ismember(conditionName, {'run3.CS.deval_R','run3.CS.val_R'})* -1;
c(14,:)     = weightPos+weightNeg;


















    