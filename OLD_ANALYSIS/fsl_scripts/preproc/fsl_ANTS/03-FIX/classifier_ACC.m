% script to compare the ACC of classifier (OBIWAN FIX classifier) with
% hand classification

%% input variable
clear all
myclassification = 0;

subX  = 'obese202';
sesX = 'third';
%taskX = 'pavlovianlearning';
%taskX = 'PIT';
taskX = 'hedonicreactivity';


cd ~
home = pwd;
homePath = [home '/OBIWAN/'];


%% define path
% homePath = '/home/cisa/mountpoint/';
homePath = '/Users/lavinia/mountpoint';

runPath  = fullfile(homePath,'DATA/STUDY/DERIVED/ICA_ANTS/', ['sub-' subX ], ['ses-' sesX ], '/func/', ['task-' taskX '.ica/']);


%% load Jeff and Giovanni classification (here OBIWAN FIX classifier)
cd (runPath);

%thr = {'10';'15';'20'};
thr = {'20'};
for i = 1:length(thr)
    
    thrX = char(thr(i));
    
%    fid = fopen(['fix4melview_FIX_obiwan_thr' thrX '.txt']);
    fid = fopen(['fix4melview_FIX_obiwan_02_thr' thrX '.txt']);
    indata = textscan(fid,'%d %q %s','Delimiter', ',','HeaderLines',1);
    fclose(fid);
    
    % get how may components
    n_comp   = (indata{1}); % this is always the same we do not need to modify it
    class.(['class' thrX])    = (indata{2});
    decision.(['class' thrX]) = (indata{3});
    
end

%% load my modifed classification

% fid = fopen(['fix_modified_obiwan_01_thr20.txt']);
fid = fopen(['fix_modified_obiwan_02_thr20.txt']);
%fid = fopen(['hand_labels_noise_lavinia.txt']);
%fid = fopen(['hand_labels_noise.txt']);
indata = textscan(fid,'%d %q %s','Delimiter', ',','HeaderLines',1);
fclose(fid);

% get how may components
class.modified    = (indata{2});
decision.modified  = (indata{3});

% compute signal to noise ratio based on my classification
signal = zeros (length(decision.modified),1);
for ii = 1:length(decision.modified)
    if strcmp(decision.modified(ii),'False')
        signal(ii) =1;
    end
end
classifier_modification.SNR = sum(signal) * 100 / length(signal);
%% load my classification

if myclassification
    
    fid = fopen(['test.txt']);
    indata = textscan(fid,'%d %q %s','Delimiter', ',','HeaderLines',1);
    fclose(fid);
    
    % get how may components
    class.('eva')    = (indata{2});
    decision.('eva') = (indata{3});
    
    % compute signal to ratio based on my classification
    signal = zeros (length(decision.eva),1);
    for ii = 1:length(decision.eva)
        if strcmp(decision.eva(ii),'False')
            signal(ii) =1;
        end
    end
    
    Classifier_validation.SNR = sum(signal) * 100 / length(signal);
    
    % compute agreement value
    
    for i = 1:length(thr)
        
        thrX = char(thr(i));
        for ii = 1:length(decision.eva)
            
            agreement.(['eva_class' thrX]) (ii)= strcmp(decision.eva(ii),decision.(['class' thrX])(ii));
            
        end
        
        missclassified.compID               = double(n_comp((agreement.(['eva_class' thrX]) == 0)));
        missclassified.compID               = num2cell (missclassified.compID);
        missclassified.label_eva            = class.eva((agreement.(['eva_class' thrX]) == 0));
        missclassified.(['label' thrX])     = class.(['class' thrX]) ((agreement.(['eva_class' thrX]) == 0));
        missclassified.decision_eva         = decision.eva((agreement.(['eva_class' thrX]) == 0));
        missclassified.(['decision' thrX])  = decision.(['class' thrX]) ((agreement.(['eva_class' thrX]) == 0));
        
        % specify if false alarm or missed signal
        missed.(['class' thrX]) = 0;
        falseAlarm.(['class' thrX]) = 0;
        for iii =1:length(missclassified.compID)
            
            if strcmp(missclassified.decision_eva(iii),'True') % if I say signal
                if strcmp(missclassified.(['decision' thrX])(iii),'False') % and the classifier says signal
                    falseAlarm.(['class' thrX]) = falseAlarm.(['class' thrX]) + 1;
                end
                
            elseif strcmp(missclassified.decision_eva(iii),'False') % if I say signal
                if strcmp(missclassified.(['decision' thrX])(iii),'True') % and the classifier says no signal
                    missed.(['class' thrX]) = missed.(['class' thrX]) + 1;
                end
                
            end
            
        end
        
        
        classifier_validation.globalACC.(['eva_class' thrX])      =  sum(agreement.(['eva_class' thrX]))*100/length(agreement.(['eva_class' thrX]));
        classifier_validation.missed.(['eva_class' thrX])         =  sum(missed.(['class' thrX]))*100/length(agreement.(['eva_class' thrX]));
        classifier_validation.falseAlarm.(['eva_class' thrX])     =  sum(falseAlarm.(['class' thrX]))*100/length(agreement.(['eva_class' thrX]));
        classifier_validation.missclassDetails.(['class' thrX])   = [missclassified.compID, missclassified.label_eva, missclassified.(['label' thrX])];
    end
    
end
%% compute agreement value for modified daty


for ii = 1:length(decision.modified)
    
    agreement.modified_class20 (ii)= strcmp(decision.modified(ii),decision.(['class' thrX])(ii));
    
end

missclassified.compID               = double(n_comp((agreement.modified_class20 == 0)));
missclassified.compID               = num2cell (missclassified.compID);
missclassified.label_modified       = class.modified((agreement.modified_class20 == 0));
missclassified.label20              = class.class20 ((agreement.modified_class20 == 0));
missclassified.decision_modified    = decision.modified((agreement.modified_class20 == 0));
missclassified.decision20           = decision.class20 ((agreement.modified_class20 == 0));

% specify if false alarm or missed signal
missed.class20 = 0;
falseAlarm.class20 = 0;
for iii =1:length(missclassified.compID)
    
    if strcmp(missclassified.decision_modified(iii),'True') % if I say signal
        if strcmp(missclassified.decision20 (iii),'False') % and the classifier says signal
            falseAlarm.class20 = falseAlarm.class20 + 1;
        end
        
    elseif strcmp(missclassified.decision_modified(iii),'False') % if I say signal
        if strcmp(missclassified.decision20(iii),'True') % and the classifier says no signal
            missed.class20 = missed.class20 + 1;
        end
        
    end
    
end


classifier_modification.globalACC          =  sum(agreement.modified_class20*100/length(agreement.modified_class20));
classifier_modification.missed             =  sum(missed.class20)*100/length(agreement.modified_class20);
classifier_modification.falseAlarm         =  sum(falseAlarm.class20)*100/length(agreement.modified_class20);
classifier_modification.modified_data      =  100 -classifier_modification.globalACC ;
classifier_modification.missclassDetails   = [missclassified.compID, missclassified.label_modified, missclassified.label20];


%% save validation data
if myclassification
save ('Classifier_validation.mat', 'classifier_validation')
end

save ('classifier_modification.mat', 'classifier_modification')