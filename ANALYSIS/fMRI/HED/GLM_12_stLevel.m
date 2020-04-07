function GLM_12_stLevel(subID) 

% intended for REWOD HED
% get onsets for model with 1st level modulators and miniblocks
% GLM for odor.run1, run2 ,run3, mod by intensity and liking
% Durations =1 
% Model on ONSETs (start, 3*odor + 2*questions)
% 6 contrast odor*liking & odor*intensity * each of 3 runs
% last modified on Novemeber 2019 by David Munoz

%% What to do
firstLevel    = 1;
contrasts     = 1;
copycontrasts = 1;

%% define task variable
%sessionX = 'second';
task = 'hedonic';

%% define path

cd ~
home = pwd;
homedir = [home '/REWOD/'];


mdldir   = fullfile(homedir, '/DERIVATIVES/ANALYSIS/', task);% mdl directory (timing and outputs of the analysis)
funcdir  = fullfile(homedir, '/DERIVATIVES/PREPROC');% directory with  post processed functional scans
name_ana = 'GLM-12'; % output folder for this analysis
groupdir = fullfile (mdldir,name_ana, 'group/');

addpath('/usr/local/external_toolboxes/spm12/');
%addpath /usr/local/MATLAB/R2018a/spm12 ;

%% specify fMRI parameters
param.TR = 2.4;
param.im_format = 'nii'; 
param.ons_unit = 'secs'; 
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% define experiment setting parameters
subj       = subID ; %{'01'};%'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26';}; %subID;
param.task = {'hedonic'};

%% define experimental design parameters
param.Cnam     = cell (length(param.task), 1);
param.duration = cell (length(param.task), 1);
param.onset    = cell (length(param.task), 1);

for i = 1:length(param.task)
    
    % Specify each conditions of your desing matrix separately for each session. The sessions
    % represent a line in Cnam, and the conditions correspond to a item in the line
    % these names must correspond identically to the names from your ONS*mat.
    param.Cnam{i} = {'start',... %1
        'reward1_1',...
        'reward2_1',... 
        'reward3_1',... 
        'reward1_2',...
        'reward2_2',... 
        'reward3_2',... 
        'neutral1_1',...
        'neutral2_1',... 
        'neutral3_1',... 
        'neutral1_2',...
        'neutral2_2',... 
        'neutral3_2',... 
        'control1_1',...
        'control2_1',... 
        'control3_1',... 
        'control1_2',...
        'control2_2',... 
        'control3_2',...
        'liking',...%5 
        'intensity'};%6

        
     param.onset{i} = {'ONS.onsets.trialstart',... %1
        'ONS.onsets.odor.reward1_1',...
        'ONS.onsets.odor.reward2_1',... 
        'ONS.onsets.odor.reward3_1',... 
        'ONS.onsets.odor.reward1_2',...
        'ONS.onsets.odor.reward2_2',... 
        'ONS.onsets.odor.reward3_2',... 
        'ONS.onsets.odor.neutral1_1',...
        'ONS.onsets.odor.neutral2_1',... 
        'ONS.onsets.odor.neutral3_1',... 
        'ONS.onsets.odor.neutral1_2',...
        'ONS.onsets.odor.neutral2_2',... 
        'ONS.onsets.odor.neutral3_2',... 
        'ONS.onsets.odor.control1_1',...
        'ONS.onsets.odor.control2_1',... 
        'ONS.onsets.odor.control3_1',... 
        'ONS.onsets.odor.control1_2',...
        'ONS.onsets.odor.control2_2',... 
        'ONS.onsets.odor.control3_2',...
        'ONS.onsets.liking',...%5 
        'ONS.onsets.intensity'};%6

    
    % duration of the blocks (if events, put '0'). Specify it for each condition of each session
    % the values must be included in your onsets in seconds
    param.duration{i} = {'ONS.durations.trialstart',...
        'ONS.durations.odor.reward1_1',...
        'ONS.durations.odor.reward2_1',... 
        'ONS.durations.odor.reward3_1',... 
        'ONS.durations.odor.reward1_2',...
        'ONS.durations.odor.reward2_2',... 
        'ONS.durations.odor.reward3_2',... 
        'ONS.durations.odor.neutral1_1',...
        'ONS.durations.odor.neutral2_1',... 
        'ONS.durations.odor.neutral3_1',... 
        'ONS.durations.odor.neutral1_2',...
        'ONS.durations.odor.neutral2_2',... 
        'ONS.durations.odor.neutral3_2',... 
        'ONS.durations.odor.control1_1',...
        'ONS.durations.odor.control2_1',... 
        'ONS.durations.odor.control3_1',... 
        'ONS.durations.odor.control1_2',...
        'ONS.durations.odor.control2_2',... 
        'ONS.durations.odor.control3_2',...
        'ONS.durations.liking',...
        'ONS.durations.intensity'};

    
    % parametric modulation of your events or blocks (ex: linear time, or emotional value, or pupillary size, ...)
    % If you have a parametric modulation
    param.modulName{i} = {'none',...%1
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3                                          
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none'}; %6
    
    param.modul{i} = {'none',...%1
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3                                          
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',...%3
        'none',... %3
        'none'}; %6
    
    % value of the modulators, If you have a parametric modulation
    param.time{i} = {'0',... %1
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3
        '0',... %3                                                                                              
        '0',... %3
        '0'};%6
    
    
end

%% apply design for first level analysis for each participant

for i = 1:length(subj)
    
    % participant's specifics
    subjX = char(subj(i));
    subjoutdir =fullfile(mdldir,name_ana, [ 'sub-' subjX]); % subj{i,1}
    subjfuncdir=fullfile(funcdir, [ 'sub-' subjX], 'ses-second'); % subj{i,1}
    fprintf('participant number: %s \n', subj{i});
    cd (subjoutdir)
    
    if ~exist('output','dir')
        mkdir ('output');
    end
    
    %%%%%%%%%%%%%%%%%%%%% DO FIRST LEVEL ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%
    if firstLevel == 1
        [SPM] = doFirstLevel(subjoutdir,subjfuncdir,name_ana,param,subjX);
    else
        cd (fullfile(subjoutdir,'output'));
        load SPM
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%  DO CONTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contrasts == 1
        doContrasts(subjoutdir,param, SPM);
    end
    
    %%%%%%%%%%%%%%%%%%%%% COPY CONTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if copycontrasts == 1
        
        mkdir (groupdir); % make the group directory where contrasts will be copied
        cd (fullfile(subjoutdir,'output'))
        
        list_dir = dir(fullfile(subjoutdir,'output', 'con*'));
        list_files = '';
        for ii = 1:length(list_dir)
            copyfile(list_dir(ii).name, [groupdir, 'sub-' subjX '_' list_dir(ii).name])
        end
        
        
        list_dir = dir(fullfile(subjoutdir,'output', 'ess*'));
        list_files = '';
        for iii = 1:length(list_dir)
            copyfile(list_dir(iii).name, [groupdir, 'sub-' subjX '_' list_dir(iii).name])
        end
        
        display('contrasts copied!');
    end
    
end

%% function section
    function [SPM] = doFirstLevel(subjoutdir,subjfuncdir, name_ana, param, ~)
        
        % variable initialization
        ntask = size(param.task,1);
        im_style = 'sub'; % ['sub-'subjX '_task-'];
        nscans = [];
        scanID = [];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %-----------------------------
        % select post processed images for each Session
        %for 
        ses = 1:ntask;
        taskX = char(param.task(ses));
        
        smoothfolder       = [subjfuncdir '/func'];
        targetscan         = dir (fullfile(smoothfolder, [im_style '*' taskX '*' param.im_format]));
        tmp{ses}           = spm_select('List',smoothfolder,targetscan.name);
        
        
        Maskimage = [subjfuncdir '/anat/sub-' subjX '_ses-second_run-01_T1w_reoriented_brain_mask.nii'];


        % get the number of EPI for each session
        cd (smoothfolder);
        V         = dir(fullfile(smoothfolder, targetscan.name));
        [p,n,e]   = spm_fileparts(V(1).name);
        Vn        = spm_vol(fullfile(p,[n e]));
        nscans    = [nscans numel(Vn)];

        for j = 1:nscans(ses)
            scanID    = [scanID; {[smoothfolder,'/', V.name, ',', num2str(j)]}];
        end
            
        %end
        
        SPM.xY.P    = char(scanID);
        SPM.nscan   = nscans;
        
        
        %-----------------------------
        % building matrix
        for ses = 1:ntask
            
            taskX = char(param.task(ses));
            
            ONSname = spm_select('List',[subjoutdir '/timing/'],[name_ana '_task-' taskX '_onsets.mat']);
            cd([subjoutdir '/timing/']) % path
            ONS = load(ONSname);
            cd([subjoutdir '/output/'])
            
            nconds=length(param.Cnam{ses});
            
            
            %%%%%%%%%%%%%%%%%%%%%% !!!!!!!!!!!!!!!! %%%%%%%%%%%%%%%%%%%%%%%
            % ATTENTION HERE WE NEED TO INITALIZE c for every new session 
         
            c = 0; % we need a counter because we include only condition that are non empty
            
            for cc=1:nconds
                
                if ~ std(eval(param.onset{ses}{cc}))== 0 % only if the onsets are not all 0
               
                    c = c+1; % update counter
                    
                    SPM.Sess(ses).U(c).name      = {param.Cnam{ses}{cc}};
                    SPM.Sess(ses).U(c).ons       = eval(param.onset{ses}{cc});
                    SPM.Sess(ses).U(c).dur       = eval(param.duration{ses}{cc});
                    
                    SPM.Sess(ses).U(c).P(1).name = 'none';
                    SPM.Sess(ses).U(c).orth = 0;
                    
                    
                    if isfield (param, 'modul') % this parameters are specified only if modulators are defined in the design
                        
                        if ~ strcmp(param.modul{ses}{cc}, 'none')
                            
                            if isstruct (eval(param.modul{ses}{cc}))
                                SPM.Sess(ses).U(c).orth = 0; %!! no ortho BUT be careful
                                mod_names = fieldnames (eval(param.modul{ses}{cc}));
                                nc = 0; % intialize the modulators count
                                
                                for nmod = 1:length(mod_names)
                                    
                                    nc = nc+1;
                                    mod_name = char(mod_names(nmod));
                                    
                                    if  ~ round(std(eval([param.modul{ses}{cc} '.' mod_name])),10)== 0  %verify that there is variance in mod
                                      
                                    
                                        SPM.Sess(ses).U(c).P(nc).name  = mod_name;
                                        SPM.Sess(ses).U(c).P(nc).P     = eval([param.modul{ses}{cc} '.' mod_name]);
                                        SPM.Sess(ses).U(c).P(nc).h     = 1;
                                        
                                    else

                                       SPM.Sess(ses).U(c).P(nc).name  = [];
                                       SPM.Sess(ses).U(c).P(nc).P     = [];
                                       SPM.Sess(ses).U(c).P(nc).h     = []; 
                                    end

                                end
                                

                            else
                                
                                SPM.Sess(ses).U(c).P(1).name  = char(param.modulName{ses}{cc});
                                SPM.Sess(ses).U(c).P(1).P     = eval(param.modul{ses}{cc});
                                SPM.Sess(ses).U(c).P(1).h     = 1; 
                           
                            end
                        end
                    end
                end
            end
        end
        
        %-----------------------------
        %multiple regressors for mvts parameters ( no movement regressor after ICA)
        
        %rnam = {'X','Y','Z','x','y','z'};
        for ses=1:ntask
            
            SPM.Sess(ses).C.C = [];
            SPM.Sess(ses).C.name = {};
            
            %movement
                        %targetfile         = dir (fullfile(smoothfolder, ['rp_*' taskX '*.txt']));

                        %fn = spm_select('List',smoothfolder,targetfile.name);% path
                        %[r1,r2,r3,r4,r5,r6] = textread([smoothfolder '/' fn(1,:)],'%f%f%f%f%f%f'); % path
                        %SPM.Sess(ses).C.C = [r1 r2 r3 r4 r5 r6];
                        %SPM.Sess(ses).C.name = rnam;
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % basis functions and timing parameters
        
        % OPTIONS: TR in seconds
        %--------------------------------------------------------------------------
        SPM.xY.RT          = param.TR;
        
        % OPTIONS: % 'hrf (with time derivative)'
        %--------------------------------------------------------------------------
        SPM.xBF.name       = 'hrf';
        
        % OPTIONS: % 2 = hrf (with time derivative)
        %--------------------------------------------------------------------------
        SPM.xBF.order      = 1;
        
        % OPTIONS: % length in seconds
        %--------------------------------------------------------------------------
        SPM.xBF.length     = 0;
        
        % OPTIONS: microtime time resolution and microtime onsets (this paramter
        % should not be change according to the spm 12 manual (unless very long TR)
        %-------------------------------------------------------------------------
        %         V  = spm_vol(SPM.xY.P(1,:));
        %         if iscell(V)
        %             nslices = V{1}{1}.dim(3);
        %         else
        %             nslices = V(1).dim(3);
        %         end
        %         ref_slice          = floor(nslices/2);  % middle slice in time
        %         SPM.xBF.T          = nslices;           % do not change unless long TR (spm12 manual)
        %         SPM.xBF.T0         = ref_slice;		    % middle slice/timebin          % useless? cf. defaults above
        %
        % OPTIONS: 'scans'|'secs' for onsets
        %--------------------------------------------------------------------------
        SPM.xBF.UNITS      = param.ons_unit;
        
        % % OPTIONS: 1|2 = order of convolution: du haut--> bas tete ou l'inverse
        %--------------------------------------------------------------------------
        SPM.xBF.Volterra   = 1;
        
        % global normalization: OPTIONS:'Scaling'|'None'
        %--------------------------------------------------------------------------
        SPM.xGX.iGXcalc    = 'None';
        
        % low frequency confound: high-pass cutoff (secs) [Inf = no filtering] 
        %--------------------------------------------------------------------------
        SPM.xX.K(1).HParam = 128;
        
        % intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
        %--------------------------------------------------------------------------
        SPM.xVi.form       = 'AR'; %AR(0.2)? SOSART ?
        
        % specify SPM working dir for this sub
        %==========================================================================
        SPM.swd = pwd;
        
        % set threshold of mask!!
        %==========================================================================
        SPM.xM.gMT =  0.1;%!! NOPE set -inf if we want to use explicit masking 0.8 is the spm default
        SPM.xM.VM  =  spm_vol(Maskimage);
        SPM.xM.I   =  0.1;
        

        % Configure design matrix
        %==========================================================================
        SPM = spm_fmri_spm_ui(SPM);
        
        % Estimate parameters
        %==========================================================================
        disp ('estimating model')
        SPM = spm_spm(SPM); %SPM = spm_rwls_spm(SPM);
        
        disp ('first level done');
    end

 
    function [] = doContrasts(subjoutdir, param, SPM)
        
        % define the SPM.mat that contains the design of the first level analysis
        %------------------------------------------------------------------
        path_ana = fullfile(subjoutdir, 'output'); % path for the first level analysis
        [files]=spm_select('List',path_ana,'SPM.mat');
        jobs{1}.stats{1}.con.spmmat = {fullfile(path_ana,files)};
        
        % define  T contrasts in a human friendly readable way
        %------------------------------------------------------------------
        
        % | GET THE NAMES FROM THE ONSETS PARAMETERS OF THE SPM MODEL
        ncondition = size(SPM.xX.name,2);
        
        for j = 1:ncondition
            
            %taskN = SPM.xX.name{j} (4);
            task  = 'task-hed.'; %taskN in the middle
            conditionName{j} = strcat(task,SPM.xX.name{j} (7:end-6)); %this cuts off the useless parts of the names
            
        end
        conditionName{ncondition} = strcat(task,'constant'); %just for the last condition
        
         Ct = []; Ctnames = []; ntask = size(param.task,1);
        
        % | contrasts FOR T-TESTS
        
        %%
        
%         'task-hed.odor.reward1_1';'task-hed.odor.reward2_1'; 'task-hed.odor.reward3_1'; 
%         'task-hed.odor.reward1_2';'task-hed.odor.reward2_2'; 'task-hed.odor.reward3_2';
%         'task-hed.odor.neutral1_1';'task-hed.odor.neutral2_1'; 'task-hed.odor.neutral3_1'; 
%         'task-hed.odor.neutral1_2';'task-hed.odor.neutral2_2'; 'task-hed.odor.neutral3_2';
%         'task-hed.odor.control1_1';'task-hed.odor.control2_1'; 'task-hed.odor.control3_1';
%         'task-hed.odor.control1_2';'task-hed.odor.control2_2'; 'task-hed.odor.control3_2' 
%         
        %Run1
        Ctnames{1} = 'run1_reward1-neutral1';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1'}) * 1; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_1'})* -1;%
        Ct(1,:)    = weightPos+weightNeg;
        

        Ctnames{2} = 'run1_reward1-neutral2';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1'}) * 1; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_2'})* -1;%
        Ct(2,:)    = weightPos+weightNeg;
        
        
        %Run1&2
        Ctnames{3} = 'run1&2_reward1-neutral1';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1','task-hed.reward2_1' }) * 1; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_1', 'task-hed.neutral2_1'})* -1;%
        Ct(3,:)    = weightPos+weightNeg;
        

        Ctnames{4} = 'run1&2_reward1-neutral2';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1', 'task-hed.reward2_1'}) * 1; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_2', 'task-hed.neutral2_2'})* -1;%
        Ct(4,:)    = weightPos+weightNeg;
        
        
        
        %Run1&2&3
        Ctnames{5} = 'run1&2&3_reward1-neutral1';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1','task-hed.reward2_1', 'task-hed.reward3_1'  }) * 1; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_1', 'task-hed.neutral2_1', 'task-hed.neutral3_1'})* -1;%
        Ct(5,:)    = weightPos+weightNeg;
        

        Ctnames{6} = 'run1&2&3_reward1-neutral2';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1', 'task-hed.reward2_1', 'task-hed.reward3_1' }) * 1; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_2', 'task-hed.neutral2_2', 'task-hed.neutral3_2'})* -1;%
        Ct(6,:)    = weightPos+weightNeg;
        
        
        
        
        %R_No_R
        
        %Run1
        Ctnames{7} = 'run1_Reward1_NoReward1';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1'}) * 2; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_1', 'task-hed.control1_1'})* -1;%
        Ct(7,:)    = weightPos+weightNeg;
        

        Ctnames{8} = 'run1_Reward1_NoReward';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1'}) * 2; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_2', 'task-hed.control1_2'})* -1;%
        Ct(8,:)    = weightPos+weightNeg;
        
        
        %Run1&2
        Ctnames{9} = 'run1&2_Reward1_NoReward1';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1','task-hed.reward2_1' }) * 2; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_1', 'task-hed.neutral2_1', 'task-hed.control1_1', 'task-hed.control2_1'})* -1;%
        Ct(9,:)    = weightPos+weightNeg;
        

        Ctnames{10} = 'run1&2_Reward1_NoReward2';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1', 'task-hed.reward2_1'}) * 2; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_2', 'task-hed.neutral2_2', 'task-hed.control1_2', 'task-hed.control2_2'})* -1;%
        Ct(10,:)    = weightPos+weightNeg;
        
        
        
        %Run1&2&3
        Ctnames{11} = 'run1&2&3_Reward1_NoReward1';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1','task-hed.reward2_1', 'task-hed.reward3_1'  }) * 2; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_1', 'task-hed.neutral2_1', 'task-hed.neutral3_1', 'task-hed.control1_1', 'task-hed.control2_1',  'task-hed.control3_1'})* -1;%
        Ct(11,:)    = weightPos+weightNeg;
        

        Ctnames{12} = 'run1&2&3_Reward1_NoReward2';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1', 'task-hed.reward2_1', 'task-hed.reward3_1' }) * 2; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_2', 'task-hed.neutral2_2', 'task-hed.neutral3_2', 'task-hed.control1_2', 'task-hed.control2_2',  'task-hed.control3_2'})* -1;%
        Ct(12,:)    = weightPos+weightNeg;
        
        
        Ctnames{13} = 'run1&2&3_reward1&2_neutral1&2';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1', 'task-hed.reward2_1', 'task-hed.reward3_1', 'task-hed.reward1_2', 'task-hed.reward2_2', 'task-hed.reward3_2' }) * 1; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_2', 'task-hed.neutral2_2', 'task-hed.neutral3_2','task-hed.neutral1_1', 'task-hed.neutral2_1', 'task-hed.neutral3_1',})* -1;%
        Ct(13,:)    = weightPos+weightNeg;
        
        
        Ctnames{14} = 'run1&2&3_Reward1&2_NoReward2';
        weightPos  = ismember(conditionName, {'task-hed.reward1_1', 'task-hed.reward2_1', 'task-hed.reward3_1', 'task-hed.reward1_2', 'task-hed.reward2_2', 'task-hed.reward3_2' }) * 1; %
        weightNeg  = ismember(conditionName, {'task-hed.neutral1_2', 'task-hed.neutral2_2', 'task-hed.neutral3_2', 'task-hed.control1_2', 'task-hed.control2_2',  'task-hed.control3_2'})* -1;%
        Ct(14,:)    = weightPos+weightNeg;
        


       
        


        % define F contrasts
        %------------------------------------------------------------------
        Cf = []; Cfnames = [];
        
        Cfnames{end+1} = 'F_HED';
        
        %create a identidy matrix (nconditionXncondition) 
        F_hedonic = eye(ncondition);
  
        
        Cf = repmat(F_hedonic,1,ntask);
        
        % put the contrast matrix
        %------------------------------------------------------------------
        
        % t contrasts
        for icon = 1:size(Ct,1)
            jobs{1}.stats{1}.con.consess{icon}.tcon.name = Ctnames{icon};
            jobs{1}.stats{1}.con.consess{icon}.tcon.convec = Ct(icon,:);
        end
        
         % F contrats
         for iconf = 1:1 % until the number of F contrast computed
             jobs{1}.stats{1}.con.consess{iconf+icon}.fcon.name = Cfnames{iconf};
             jobs{1}.stats{1}.con.consess{iconf+icon}.fcon.convec = Cf(iconf);
         end
        
        
        % run the job
        spm_jobman('run',jobs)
        
        disp ('contrasts created!')
    end


end