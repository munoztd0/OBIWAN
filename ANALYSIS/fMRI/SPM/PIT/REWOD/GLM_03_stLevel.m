function GLM_03_stLevel(subID)

% intended for REWOD PIT
% get onsets for model with 1st level modulators
% Durations =1 (except grips)
% Model on ONSETs 3*CS with modulator
% 4 simple contrasts (CSp-CSm, CSp-Base,  CSp-CSm&Base,  CSm-Base)
% + 4 modulated contrast (*eff)
% Ortho = 0 & modulator is mean centered
% last modified on JULY 2019 by David Munoz


%% What to do
firstLevel    = 1;
constrasts    = 1;
copycontrasts = 1;

%% define task variable
task = 'PIT';
%% define path

cd ~
home = pwd;
homedir = [home '/REWOD/'];


mdldir   = fullfile(homedir, 'DERIVATIVES/ANALYSIS/PIT');% mdl directory (timing and outputs of the analysis)
funcdir  = fullfile(homedir, 'DERIVATIVES/PREPROC');% directory with  post processed functional scans
name_ana = 'GLM-03'; % output folder for this analysis
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
subj       =  {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26';}; %subID;
param.task = {'PIT'};

%% define experimental design parameters
param.Cnam     = cell (length(param.task), 1);
param.duration = cell (length(param.task), 1);
param.onset = cell (length(param.task), 1);

for i = 1:length(param.task)
    
    % Specify each conditions of your desing matrix separately for each session. The sessions
    % represent a line in Cnam, and the conditions correspond to a item in the line
    % these names must correspond identically to the names from your ONS*mat.
    param.Cnam{i} = {'REM',...%1
        'PE',...%2
        'CSplus',...%3
        'CSminus',...%4
        'Baseline'};%5
    
    param.onset{i} = {'ONS.onsets.CS.REM',...%1
        'ONS.onsets.CS.PE',...%2
        'ONS.onsets.CS.CSp',...%3
        'ONS.onsets.CS.CSm',...%4
        'ONS.onsets.CS.Baseline'};%5

    
    
    % the values must be included in your onsets in seconds
    param.duration{i} = {'ONS.durations.CS.REM',...
        'ONS.durations.CS.PE',...
        'ONS.durations.CS.CSp',...
        'ONS.durations.CS.CSm',...
        'ONS.durations.CS.Baseline'};
    
    
    % parametric modulation of your events or blocks (ex: linear time, or emotional value, or pupillary size, ...)
    % If you have a parametric modulation
    param.modulName{i} = {'effort',...%1
        'effort',...%2
        'effort',...%3
        'effort',...%4
        'effort'};%5
    
    param.modul{i} = {'ONS.modulators.CS.REM',...%1
        'ONS.modulators.CS.PE',...%2
        'ONS.modulators.CS.CSp',...%3
        'ONS.modulators.CS.CSm',... %4
        'ONS.modulators.CS.Baseline'}; %5
    
    % value of the modulators, If you have a parametric modulation
    param.time{i} = {'1',... %1
        '1',... %2
        '1',... %3
        '1',... %4
        '1'};%5
    
end

%% apply design for first level analysis for each participant

for i = 1:length(subj)
    
    % participant's specifics
    subjX = char(subj(i));
    subjoutdir =fullfile(mdldir,name_ana, [ 'sub-' subjX]); % subj{i,1}
    subjfuncdir=fullfile(funcdir, [ 'sub-' subjX], 'ses-second', 'func'); % subj{i,1}
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
    
    %%%%%%%%%%%%%%%%%%%%%%%  DO CONSTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if constrasts == 1
        doContrasts(subjoutdir,param, SPM);
    end
    
    %%%%%%%%%%%%%%%%%%%%% COPY CONSTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    function [SPM] = doFirstLevel(subjoutdir,subjfuncdir, name_ana, param, subjX)
        
        % variable initialization
        ntask = size(param.task,1);
        im_style = 'sub';
        nscans = [];
        scanID = [];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %-----------------------------
        % select post processed images for each Session
        %for 
        ses = 1:ntask;

        taskX = char(param.task(ses));
        targetscan         = dir (fullfile(subjfuncdir, [im_style '*' taskX '*' param.im_format]));
        tmp{ses}           = spm_select('List',subjfuncdir,targetscan.name);

        % get the number of EPI for each session
        cd (subjfuncdir);
        V         = dir(fullfile(subjfuncdir, targetscan.name));
        [p,n,e]   = spm_fileparts(V(1).name);
        Vn        = spm_vol(fullfile(p,[n e]));
        nscans    = [nscans numel(Vn)];

        for j = 1:nscans(ses)
            scanID    = [scanID; {[subjfuncdir,'/', V.name, ',', num2str(j)]}];
        end

        
        
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
                    
                    SPM.Sess(ses).U(c).orth = 0; %no ortho
                    SPM.Sess(ses).U(c).P(1).name = 'none';
                    
                    if isfield (param, 'modul') % this parameters are specified only if modulators are defined in the design
                        
                        if ~ strcmp (param.modul{ses}{cc}, 'none')
                            
                            if isstruct (eval(param.modul{ses}{cc}))
                                SPM.Sess(ses).U(c).orth = 0; %!! no ortho
                                mod_names = fieldnames (eval(param.modul{ses}{cc}));
                                nc = 0; % intialize the modulators count
                                
                                for nmod = 1:length(mod_names)
                                    
                                    nc = nc+1;
                                    mod_name = char(mod_names(nmod));
                                    if  ~ round(std(eval([param.modul{ses}{cc} '.' mod_name])),10)== 0
                                      
                                    
                                        SPM.Sess(ses).U(c).P(nc).name  = mod_name;
                                        SPM.Sess(ses).U(c).P(nc).P     = eval([param.modul{ses}{cc} '.' mod_name]);
                                        SPM.Sess(ses).U(c).P(nc).h     = 1;
                                    else

                                       SPM.Sess(ses).U(c).P(1).name  = [];
                                       SPM.Sess(ses).U(c).P(1).P     = [];
                                       SPM.Sess(ses).U(c).P(1).h     = []; 
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
  
        for ses=1:ntask
            
            SPM.Sess(ses).C.C = [];
            SPM.Sess(ses).C.name = {};
            
            %multiple regressors for mvts parameters ( no movement regressor after FIX denosing)

        
        
        
           %rnam = {'X','Y','Z','x','y','z'};
           rnam = {'effort'};
           physio        = fullfile('~/REWOD',['sub-' subjX], 'ses-second', 'physio');
        
           cd (physio)
        
           effort = dlmread('regressor_effort.txt');
           
           SPM.Sess(ses).C.C = effort;
           SPM.Sess(ses).C.name = rnam;
           
           
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
        
        % % OPTIONS: 1|2 = order of convolution: du haut--> bas t?te ou l'inverse
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
        SPM.xVi.form       = 'AR(1)'; 
        
        % specify SPM working dir for this sub
        %==========================================================================
        SPM.swd = pwd;
        
        % set threshold of mask!!
        %==========================================================================
        SPM.xM.gMT = -Inf;% !!set -inf if we want to use explicit masking 0.8 is the spm default
        
        % Configure design matrix
        %==========================================================================
        SPM = spm_fmri_spm_ui(SPM);
        
        % Estimate parameters
        %==========================================================================
        disp ('estimating model')
        SPM = spm_spm(SPM);
        
        disp ('first level done');
    end


    function [] = doContrasts(subjoutdir, param, SPM)
        
        % define the SPM.mat that contains the design of the first level analysis
        %------------------------------------------------------------------
        path_ana = fullfile(subjoutdir, 'output'); % path for the first level analysis
        [files]=spm_select('List',path_ana,'SPM.mat');
        jobs{1}.stats{1}.con.spmmat = {fullfile(path_ana,files)};
        
        % define  T constrasts in a human friendly readable way
        %------------------------------------------------------------------
        
        % | GET THE NAMES FROM THE ONSETS PARAMETERS OF THE SPM MODEL
        ncondition = size(SPM.xX.name,2);
        
        for j = 1:ncondition
            
            %taskN = SPM.xX.name{j} (4);
            task  = 'task-PIT.'; 
            conditionName{j} = strcat(task,SPM.xX.name{j} (7:end-6)); %this cuts off the useless parts of the names
            
        end
        
        conditionName{ncondition} = strcat(task,'constant'); %just for the last condition
        conditionName(:,11) = [];
        Ct = []; Ctnames = []; ntask = size(param.task,1);
        
        % | CONSTRASTS FOR T-TESTS
        
        % con1
        Ctnames{1} = 'CSp-CSm';
        weightPos  = ismember(conditionName, {'task-PIT.CSplus'}) * 1;
        weightNeg  = ismember(conditionName, {'task-PIT.CSminus'}) * -1;
        Ct(1,:)    = weightPos+weightNeg;

        % con2
        Ctnames{2} = 'CSp-Baseline';
        weightPos  = ismember(conditionName, {'task-PIT.CSplus'}) * 1;
        weightNeg  = ismember(conditionName, {'task-PIT.Baseline'}) * -1;
        Ct(2,:)    = weightPos+weightNeg;

        % con3
        Ctnames{3} = 'CSp-CSm&Baseline';
        weightPos  = ismember(conditionName, {'task-PIT.CSplus'}) * 2;
        weightNeg  = ismember(conditionName, {'task-PIT.CSminus', 'task-PIT.Baseline'}) * -1;
        Ct(3,:)    = weightPos+weightNeg;
               
        %con4
        Ctnames{4} = 'CSm-Baseline';
        weightPos  = ismember(conditionName, {'task-PIT.CSminus'}) * 1;
        weightNeg  = ismember(conditionName, {'task-PIT.Baseline'}) * -1;
        Ct(4,:)    = weightPos+weightNeg;
        
        
        %% Contrast * mob effort
        % con5
        Ctnames{5} = 'CSp_eff_CSm_eff';
        weightPos  = ismember(conditionName, {'task-PIT.CSplusxeffort^1'}) * 1;
        weightNeg  = ismember(conditionName, {'task-PIT.CSminusxeffort^1'}) * -1;
        Ct(5,:)    = weightPos+weightNeg;
        
        % con6
        Ctnames{6} = 'CSp_eff_Baseline_eff';
        weightPos  = ismember(conditionName, {'task-PIT.CSplusxeffort^1'}) * 1;
        weightNeg  = ismember(conditionName, {'task-PIT.Baselinexeffort^1'}) * -1;
        Ct(6,:)    = weightPos+weightNeg;
        
        % con7 
        Ctnames{7} = 'CSp_eff_CSm_eff&Baseline_eff'; 
        weightPos  = ismember(conditionName, {'task-PIT.CSplusxeffort^1'}) * 2;
        weightNeg  = ismember(conditionName, {'task-PIT.CSminusxeffort^1', 'task-PIT.Baselinexeffort^1'}) * -1;
        Ct(7,:)    = weightPos+weightNeg;
                     
        % con8
        Ctnames{8} = 'CSm_eff_Baseline_eff';
        weightPos  = ismember(conditionName, {'task-PIT.CSminusxeffort^1'}) * 1;
        weightNeg  = ismember(conditionName, {'task-PIT.Baselinexeffort^1'}) * -1;
        Ct(8,:)    = weightPos+weightNeg;
        
        
        

        
        % define F constrasts
        %------------------------------------------------------------------
        Cf = []; Cfnames = [];
        
        Cfnames{end+1} = 'F_PIT';
        
        %create a identidy matrix (nconditionXncondition) 
        F_PIT = eye(ncondition);

        
        Cf = repmat(F_PIT,1,ntask);
        
        % put the contrast matrix
        %------------------------------------------------------------------
        
        % t contrasts
        for icon = 1:size(Ct,1)
            jobs{1}.stats{1}.con.consess{icon}.tcon.name = Ctnames{icon};
            jobs{1}.stats{1}.con.consess{icon}.tcon.convec = Ct(icon,:);
        end
        
        % F constrats
        for iconf = 1:1 % until the number of F constrast computed
            jobs{1}.stats{1}.con.consess{iconf+icon}.fcon.name = Cfnames{iconf};
            jobs{1}.stats{1}.con.consess{iconf+icon}.fcon.convec = Cf(iconf);
        end
        
        
        % run the job
        spm_jobman('run',jobs)
        
        disp ('contrasts created!')
    end


end