function GLM_02_stLevel(subID)

% compute first level model contrasts CSp-CSm
% no PM -> covariate 2nd level

dbstop if error
%subj       =   %subID;

%% define task variable
sessionX = 'second';
task = 'PIT';
name_ana = 'GLM-02'; % output folder for this analysis

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

control = [homedir '/DERIVATIVES/GLM/SPM/' task '/' name_ana '/sub-control*'];
obese = [homedir '/DERIVATIVES/GLM/SPM/' task '/' name_ana '/sub-obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);

%% What to do
firstLevel    = 1;
constrasts    = 1;
copycontrasts = 1;

funcdir  = fullfile(homedir, '/DERIVATIVES/PREPROC');% directory with  post processed functional scans
mdldir   = fullfile (homedir, '/DERIVATIVES/GLM/SPM', task);% mdl directory (timing and outputs of the analysis)
groupdir = fullfile (mdldir,name_ana, 'group/');

addpath('/usr/local/external_toolboxes/spm12/');

%% specify fMRI parameters
param.TR = 2;
param.im_format = 'nii'; %'img' or 'nii';
param.ons_unit = 'secs'; % 'scans' or 'secs';
spm('Defaults','fMRI');
spm_jobman('initcfg');


% for i=1:length(subj)
%     str{i} = extractAfter(subj(i).name,"sub-")
% end
%% define experimental design parameters
param.task = {task};
param.Cnam     = cell (length(param.task), 1);
param.duration = cell (length(param.task), 1);
%106 & 110 FAILS why? '100'    ;'102'    ;'105' ;   '107'    ;'108'    ;'109'    ;'110'  
%subjCON = { '112'    ;'113'    ;'114'    ;'115'    ;'116'    ;'118'    ;'119'    ;'120'    ;'121'    ;'122'    ;'125'    ;'126'    ;'127'    ;'128'    ;'129'    ;'130'    ;'131'    ;'132'    ;'133'    };     % subject ID
%subj  = {'200';'201';'202';'203';'204';'205';'206';'207';'208';'209';'210';'211';'212';'213';'214';'215';'216';'217';'218';'219';'220';'221';'222';'223';'224';'225';'226';'227';'228';'229';'230';'231';'232';'233';'234';'235';'236';'237';'238';'239';'240';'241';'242';'244';'245';'246';'247';'248';'249';'250';'251';'252';'253';'254';'256';'258';'259';'261';'262';'263';'264';'265';'266';'267';'268';'269';'270'};
%subj ={'control100';'control101';'control102';'control103';'control104';'control105';'control106';'control107';'control108';'control109';'control110';'control111';'control112';'control113';'control114';'control115';'control116';'control117';'control118';'control119';'control120';'control121';'control122';'control123';'control124';'control125';'control126';'control127';'control128';'control129';'control130';'control131';'control132';'control133';'obese200';'obese201';'obese202';'obese203';'obese204';'obese205';'obese206';'obese207';'obese208';'obese209';'obese210';'obese211';'obese212';'obese213';'obese214';'obese215';'obese216';'obese217';'obese218';'obese219';'obese220';'obese221';'obese222';'obese223';'obese224';'obese225';'obese226';'obese227';'obese228';'obese229';'obese230';'obese231';'obese232';'obese233';'obese234';'obese235';'obese236';'obese237';'obese238';'obese239';'obese240';'obese241';'obese242';'obese244';'obese245';'obese246';'obese247';'obese248';'obese249';'obese250';'obese251';'obese252';'obese253';'obese254';'obese256';'obese258';'obese259';'obese261';'obese262';'obese263';'obese264';'obese265';'obese266';'obese267';'obese268';'obese269';'obese270'};

for i = 1:length(param.task)
    
    % Specify each conditions of your desing matrix separately for each session. The sessions
    % represent a line in Cnam, and the conditions correspond to a item in the line
    % these names must correspond identically to the names from your ONS*mat.
    param.Cnam{i} = {'ONS.onsets.CS.CSp',...%1
        'ONS.onsets.CS.CSm',...%2
        'ONS.onsets.CS.Baseline',...%3
        'ONS.onsets.ITI'};%4      %'ONS.onsets.grips',...%5
    
    % duration of the blocks (if events, put '0'). Specify it for each condition of each session
    % the values must be included in your onsets in seconds
    param.duration{i} = {'ONS.durations.CS.CSp',...
        'ONS.durations.CS.CSm',...
        'ONS.durations.CS.Baseline',...
        'ONS.durations.ITI'};         %'%ONS.durations.grips',...
    
    % parametric modulation of your events or blocks (ex: linear time, or emotional value, or pupillary size, ...)
    % If you have a parametric modulation
    param.modulName{i} = {'none',...%1
        'none',...%2
        'none',...%3
        'none'};    
    
    param.modul{i} = {'none',...%1
        'none',... %2
        'none',... %3
        'none'};
    
    % value of the modulators, If you have a parametric modulation
    param.time{i} = {'0',... %1
        '0',... %2
        '0',... %3
        '0'};
    
end

%% apply design for first level analysis for each participant
subj = subj([91],:); %60 -> 233 234 91 -> 269
%subj = subj([91],:); %60 -> 233 91 -> 269

for i = 1:length(subj)
    
    if i ==  42 || i == 66 || i ==69 %fails at 213 239 242 ??
        continue
    end %still have to redo 123 124 233
    
    
    %subjT       =  [group subj{i}];
    subjT = subj(i).name;
    
    % participant's specifics
    subjX = char(subjT);
    
    subjoutdir =fullfile(mdldir,name_ana, subjT); % subj{i,1}
    subjfuncdir=fullfile(funcdir, subjT, ['ses-' sessionX]); % subj{i,1}
    subjanatdir=fullfile(funcdir, subjT, 'ses-first/anat/');
    fprintf('participant : %s \n', subjT);
    cd (subjoutdir)
    
    if ~exist('output','dir');
        mkdir ('output');
    end
    
    %%%%%%%%%%%%%%%%%%%%% DO FIRST LEVEL ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%
    if firstLevel == 1
        [SPM] = doFirstLevel(subjoutdir,subjfuncdir,name_ana,param,subjX, sessionX);
    else
        cd (fullfile(subjoutdir,'output'));
        load SPM
        delete('con_*')
        delete('spmT_*')
        SPM.xCon=[];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%  DO CONSTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if constrasts == 1
        doContrasts(subjoutdir,param, SPM);
    end
    
    %%%%%%%%%%%%%%%%%%%%% COPY CONSTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if copycontrasts == 1
        
        mkdir (groupdir); % make the group directory where contrasts will be copied
        
        cd (fullfile(subjoutdir,'output'))
        
        % copy images T
        Timages = ['01'; '02'; '03'; '04']; % '05'; '06'; '07'];% constrasts of interest
        for y =1:size(Timages,1)
            copyfile(['con_00' (Timages(y,:)) '.nii'],[groupdir, subjX '_con-00' (Timages(y,:)) '.nii'])
        end
        
        % copy images F
%         Fimages = '03';% constrasts of interest
%         for y =1:size(Fimages,1)
%             copyfile(['ess_00' (Fimages(y,:)) '.nii'],[groupdir, subjX '_ess-00' (Timages(y,:)) '.nii'])
%         end
        
        display('contrasts copied!');
    end
    
end

%% function section
    function [SPM] = doFirstLevel(subjoutdir,subjfuncdir, name_ana, param, subjX, sessionX)
        
        subjO = subjX(5:end);
        % variable initialization
        ntasks = size(param.task,1);
        nscans = [];
        scanID = [];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %-----------------------------
        % select post processed images for each Session
        for ses = 1:ntasks
            
            taskX = char(param.task(ses));
            smoothfolder       = [subjfuncdir '/func'];
            targetscan         = dir (fullfile(smoothfolder, ['*' taskX '*smoothBold*' param.im_format]));
            tmp{ses}           = spm_select('List',smoothfolder,targetscan.name);

            % get the number of EPI for each session
            cd (smoothfolder);
            V         = dir(fullfile(smoothfolder, targetscan.name));
            [p,n,e]   = spm_fileparts(V(1).name);
            Vn        = spm_vol(fullfile(p,[n e]));
            nscans    = [nscans numel(Vn)];
            
            for j = 1:nscans(ses)
                scanID    = [scanID; {[smoothfolder,'/', V.name, ',', num2str(j)]}];
            end
            
        end
        
        SPM.xY.P    = char(scanID);
        SPM.nscan   = nscans;
        
        
        %-----------------------------
        % building matrix
        for ses = 1:ntasks
            
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
                
                if ~ isempty(eval(param.Cnam{ses}{cc})) % only if the onsets are not all 0
                
                    c = c+1; % update counter
                    
                    SPM.Sess(ses).U(c).name      = {param.Cnam{ses}{cc}};
                    SPM.Sess(ses).U(c).ons       = eval(param.Cnam{ses}{cc});
                    SPM.Sess(ses).U(c).dur       = eval(param.duration{ses}{cc});
                    
                    SPM.Sess(ses).U(c).P(1).name = 'none';
                    
                    if isfield (param, 'modul') % this parameters are specified only if modulators are defined in the design
                        
                        if ~ strcmp (param.modul{ses}{cc}, 'none')
                            
                            if isstruct (eval(param.modul{ses}{cc}))
                                
                                mod_names = fieldnames (eval(param.modul{ses}{cc}));
                                nc = 0; % intialize the modulators count
                                
                                for nmod = 1:length(mod_names)
                                    
                                    nc = nc+1;
                                    mod_name = char(mod_names(nmod));
                                    
                                    SPM.Sess(ses).U(c).P(nc).name  = mod_name;
                                    SPM.Sess(ses).U(c).P(nc).P     = eval([param.modul{ses}{cc} '.' mod_name]);
                                    SPM.Sess(ses).U(c).P(nc).h     = 1;
                                    
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).name       = {param.Cnam{ses}{cc}};
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).onset      = eval(param.Cnam{ses}{cc});
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).duration   = eval(param.duration{ses}{cc});
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).tmod       = 0;
                                    
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod(nc).name  = mod_name;
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod(nc).param = eval([param.modul{ses}{cc} '.' mod_name]);
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod(nc).poly  = 1;
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).orth = 0;
                                end
                                
                                
                            else
                                SPM.Sess(ses).U(c).P(1).name  = char(param.modulName{ses}{cc});
                                SPM.Sess(ses).U(c).P(1).P     = eval(param.modul{ses}{cc});
                                SPM.Sess(ses).U(c).P(1).h     = 1;
                                
                                matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).name       = {param.Cnam{ses}{cc}};
                                matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).onset      = eval(param.Cnam{ses}{cc});
                                matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).duration   = eval(param.duration{ses}{cc});
                                matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).tmod       = 0;
                                
                                matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod.name  = char(param.modulName{ses}{cc});
                                matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod.param = eval(param.modul{ses}{cc});
                                matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod.poly  = 1;
                                
                            end
                        end
                    end
                end
            end
        end
        
        %-----------------------------
        if  strcmp(subjX(end-2:end), '101')  || strcmp(subjX(end-2:end), '103')%because we dont the triggers for the two first participant
             SPM.Sess(ses).C.C = [];
             SPM.Sess(ses).C.name = {};
        else
            for ses=1:length(param.task)
               
               %rnam = {'X','Y','Z','x','y','z'};
               rnam = {'effort'};
               physio        = fullfile('~/OBIWAN/SOURCEDATA/physio/', subjO, ['ses-' sessionX]);

               cd (physio)
               filename = strcat(param.task{ses}, '_regressor_effort.txt'); %because dlmread is stupid af

               effort = dlmread(filename);
               
               if any(isnan(effort(:))) % corrupt Effort files || strcmp(subjX(end-2:end), '113') || strcmp(subjX(end-2:end), '120')
                     SPM.Sess(ses).C.C = [];
                     SPM.Sess(ses).C.name = {};
               else
                    SPM.Sess(ses).C.C = effort;
                    SPM.Sess(ses).C.name = rnam;
               end

            end
        end
        cd([subjoutdir '/output/'])
        
        SPM.xsDes = length(ONS.onsets.ITI); %or whatever is just to have the number of trials
        
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
        SPM.xVi.form       = 'AR(1)'; %AR(0.2)???? SOSART
        
        % specify SPM working dir for this sub
        %==========================================================================
        SPM.swd = pwd;
        
        % Configure design matrix
        %==========================================================================
        SPM = spm_fmri_spm_ui(SPM);
        
        % *After* configuration but before *estimation* we need to specify the explicit mask
        %--------------------------------------------------------------------------
        SPM.xM.VM  = spm_vol(char({[subjanatdir '/' subjX '_ses-first_acq-ANTsNorm_T2w.nii']})); % here enter the mask based on the subject anatomical

        
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
            
            taskN = SPM.xX.name{j} (4);
            task  = ['task' taskN '.'];
            conditionName{j} = strcat(task,SPM.xX.name{j} (18:end-6));
            
        end
        
        Ct = []; Ctnames = []; ntask = size(param.task,1);
        
        % | CONSTRASTS FOR T-TESTS

        
        % con1
        Ctnames{1} = 'CSp_CSm';
        weightPos  = ismember(conditionName, {'task1.CS.CSp'}) * 1;
        weightNeg  = ismember(conditionName, {'task1.CS.CSm'})* -1;
        Ct(1,:)    = weightPos+weightNeg;
        
                     
        % con2
        Ctnames{2} = 'CSp&CSm_Baseline';
        weightPos  = ismember(conditionName, {'task1.CS.CSp', 'task1.CS.CSm'}) * 1;
        weightNeg  = ismember(conditionName, { 'task1.CS.Baseline'})* -2;
        Ct(2,:)    = weightPos+weightNeg;
        
        % con3
        Ctnames{3} = 'CSp_Baseline';
        weightPos  = ismember(conditionName, {'task1.CS.CSp'}) * 1;
        weightNeg  = ismember(conditionName, {'task1.CS.Baseline'})* -1;
        Ct(3,:)    = weightPos+weightNeg;
        
        % con4
        Ctnames{4} = 'CSp_ITI';
        weightPos  = ismember(conditionName, {'task1.CS.CSp'}) * 1;
        weightNeg  = ismember(conditionName, {'task1.CS.ITI'})* -1;
        Ct(4,:)    = weightPos+weightNeg;
        
%         % con2
%         Ctnames{2} = 'Effort';
%         weightPos  = ismember(conditionName, {'task1.CS.CSpxeffort^1', 'task1.CS.CSmxeffort^1', 'task1.CS.Baselinexeffort^1'}) * 1;
%         Ct(2,:)    = weightPos+weightNeg;
        
%         % con2
%         Ctnames{2} = 'CSpEffort_CSmEffort';
%         weightPos  = ismember(conditionName, {'task1.CS.CSpxeffort^1'}) * 1;
%         weightNeg  = ismember(conditionName, {'task1.CS.CSmxeffort^1'})* -1;
%         Ct(2,:)    = weightPos+weightNeg;
%         
%         % con3
%         Ctnames{3} = 'CSp_CSm&Baseline';
%         weightPos  = ismember(conditionName, {'task1.CS.CSp'}) * 1;
%         weightNeg  = ismember(conditionName, {'task1.CS.CSm', 'task1.CS.Baseline'})* -1;
%         Ct(3,:)    = weightPos+weightNeg;
%         
%         % con4 
%         Ctnames{4} = 'CSpEffort_CSmEffort&BaselineEffort';
%         weightPos  = ismember(conditionName, {'task1.CS.CSpxeffort^1'}) * 1;
%         weightNeg  = ismember(conditionName, {'task1.CS.CSmxeffort^1', 'task1.CS.Baselinexeffort^1'})* -1;
%         Ct(4,:)    = weightPos+weightNeg;
%         
%         % con5
%         Ctnames{5} = 'grips';
%         weightPos  = ismember(conditionName, {'task1.grips'}) * 1;
%         Ct(5,:)    = weightPos;
%         
%         % con6
%         Ctnames{6} = 'CSp_Baseline';
%         weightPos  = ismember(conditionName, {'task1.CS.CSp'}) * 1;
%         weightNeg  = ismember(conditionName, {'task1.CS.Baseline'})* -1;
%         Ct(6,:)    = weightPos+weightNeg;
%         
%         % con7
%         Ctnames{7} = 'CSm_Baseline';
%         weightPos  = ismember(conditionName, {'task1.CS.CSm'}) * 1;
%         weightNeg  = ismember(conditionName, {'task1.CS.Baseline'})* -1;
%         Ct(7,:)    = weightPos+weightNeg;
%         
        
        
        
        
        % define F constrasts
        %------------------------------------------------------------------
        Cf = []; Cfnames = [];
        
%         Cfnames{end+1} = 'F_task1';
% 
%         Ftask1 = [1 0 0 0 0 0 0 0 0 0 0 0 % 1 CS.plus
%             0 1 0 0 0 0 0 0 0 0 0 0     % 2 CS.minus
%             0 0 1 0 0 0 0 0 0 0 0 0     % 3 baseline
%             0 0 0 1 0 0 0 0 0 0 0 0     % 4 effort CSplus
%             0 0 0 0 1 0 0 0 0 0 0 0     % 5 effort CSminus
%             0 0 0 0 0 1 0 0 0 0 0 0     % 6 effort baseline
%             0 0 0 0 0 0 1 0 0 0 0 0 ];    % 7 grips
% 
%         
%         
%         Cf = repmat(Ftask1,1,ntask);
        
        % put the contrast matrix
        %------------------------------------------------------------------
        
        % t contrasts
        for icon = 1:size(Ct,1)
            jobs{1}.stats{1}.con.consess{icon}.tcon.name = Ctnames{icon};
            jobs{1}.stats{1}.con.consess{icon}.tcon.convec = Ct(icon,:);
        end
        
        % F constrats
%         for iconf = 1:1 % until the number of F constrast computed
%             jobs{1}.stats{1}.con.consess{iconf+icon}.fcon.name = Cfnames{iconf};
%             jobs{1}.stats{1}.con.consess{iconf+icon}.fcon.convec = Cf(iconf);
%         end
        
        
        % task the job
        spm_jobman('run',jobs)
        
        disp ('contrasts created!')
    end

end