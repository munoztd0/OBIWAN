function GLM_15_stLevel(subID)

% get onsets for first control model (reward vs neutral)
% Stick function for swallow
% Simplified model on ONSETs 6 (2*TASTE 3*questions 1 RINSE)
% last modified on JULY 2019

% on swallowing signal w/ stick function; parametric modulators liking, intensity and familiarity w/ more accurate model of events of non-interest

%dbstop if error

%% What to do
firstLevel    = 1;
constrasts    = 1;
copycontrasts = 1;

%% define task variable
sessionX = 'second';
task = 'hedonicreactivity';
%% define path

homedir = '/home/OBIWAN/';
%homedir = '/Users/evapool/mountpoint/';

funcdir  = fullfile(homedir, '/DATA/STUDY/CLEAN');% directory with  post processed functional scans
mdldir   = fullfile (homedir, '/DATA/STUDY/MODELS/SPM/', task);% mdl directory (timing and outputs of the analysis)
name_ana = 'GLM-15-control'; % output folder for this analysis
groupdir = fullfile (mdldir,name_ana, 'group/');

addpath('/usr/local/external_toolboxes/spm12/');
%% specify fMRI parameters
param.TR = 2;
param.im_format = 'nii'; %'img' or 'nii';
param.ons_unit = 'secs'; % 'scans' or 'secs';
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% define experiment setting parameters
subj       =  subID;
param.runs = {'hedonicreactivity'};

%% define experimental design parameters
param.Cnam     = cell (length(param.runs), 1);
param.duration = cell (length(param.runs), 1);

for i = 1:length(param.runs)

    % Specify each conditions of your desing matrix separately for each session. The sessions
    % represent a line in Cnam, and the conditions correspond to a item in the line
    % these names must correspond identically to the names from your ONS*mat.
    param.Cnam{i} = {'ONS.onsets.trialstart',...%1
        'ONS.onsets.swallow',...%2
        'ONS.onsets.liking',...%3
        'ONS.onsets.intensity',...%4
        'ONS.onsets.familiarity',...%5
        'ONS.onsets.rinse'};%6

    % duration of the blocks (if events, put '0'). Specify it for each condition of each session
    % the values must be included in your onsets in seconds
    param.duration{i} = {'ONS.durations.trialstart',...%1
        'ONS.durations.swallow',...%2
        'ONS.durations.liking',...%3
        'ONS.durations.intensity',...%4
        'ONS.durations.familiarity',...%5
        'ONS.durations.rinse'};%6

    % parametric modulation of your events or blocks (ex: linear time, or emotional value, or pupillary size, ...)
    % If you have a parametric modulation
    param.modulName{i} = {'none',...%1
        'multiple',...%2
        'none',...%3
        'none',...%4
        'none',...%5
        'none'};%6

    param.modul{i} = {'none',...%1
        'ONS.modulators.swallow',...%2
        'none',... %3
        'none',... %4
        'none',... %5
        'none'};%6


    % value of the modulators, If you have a parametric modulation
    param.time{i} = {'0',... %1
        '1',... %2
        '0',... %3
        '0',... %4
        '0',... %5
        '0'};%6


end

%% apply design for first level analysis for each participant

for i = 1:length(subj)

    % participant's specifics
    subjX = char(subj(i));
    subjoutdir =fullfile(mdldir,name_ana, [ 'sub-' subjX]); % subj{i,1}
    subjanatdir=fullfile(funcdir, [ 'sub-' subjX], 'ses-first/anat/');
    subjfuncdir=fullfile(funcdir, [ 'sub-' subjX], ['ses-' sessionX]); % subj{i,1}
    fprintf('participant number: %s \n', subj{i});
    cd (subjoutdir)

    if ~exist('output','dir');
        mkdir ('output');
    end

    %%%%%%%%%%%%%%%%%%%%% DO FIRST LEVEL ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%
    if firstLevel == 1
        [SPM] = doFirstLevel(subjoutdir,subjfuncdir,subjanatdir,name_ana,param,subjX);
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

        % copy images T
        Timages = ['01'; '02'];% constrasts of interest
        for y =1:size(Timages,1)
            copyfile(['con_00' (Timages(y,:)) '.nii'],[groupdir, 'sub-' subjX '_con-00' (Timages(y,:)) '.nii'])
        end

        % copy images F
        Fimages = '03';% constrasts of interest
        for y =1:size(Fimages,1)
            copyfile(['ess_00' (Fimages(y,:)) '.nii'],[groupdir, 'sub-' subjX '_ess-00' (Timages(y,:)) '.nii'])
        end

        display('contrasts copied!');
    end

end

%% function section
    function [SPM] = doFirstLevel(subjoutdir,subjfuncdir,subjanatdir, name_ana, param, subjX)

        % variable initialization
        nruns = size(param.runs,1);
        im_style = 'swar'; % this is only for the old pipeline
        nscans = [];
        scanID = [];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %-----------------------------
        % select post processed images for each Session
        for ses = 1:nruns

            runX = char(param.runs(ses));
            smoothfolder       = [subjfuncdir '/func'];
            %targetscan         = dir (fullfile(smoothfolder, [im_style '*' runX '*' param.im_format]));
            targetscan         = dir (fullfile(smoothfolder, ['*' runX '*' param.im_format]));

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
        for ses = 1:nruns

            runX = char(param.runs(ses));

            ONSname = spm_select('List',[subjoutdir '/timing/'],[name_ana '_run-' runX '_onsets.mat']);
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
                    SPM.Sess(ses).U(c).orth      = 0; % orthogonalization
%                    off

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
        %multiple regressors for mvts parameters ( no movement regressor
        %after ICA)

        rnam = {'X','Y','Z','x','y','z'};
        for ses=1:nruns

            SPM.Sess(ses).C.C = [];
            SPM.Sess(ses).C.name = {};

            %movement
%                         targetfile         = dir (fullfile(smoothfolder, ['rp_*' runX '*.txt']));
%
%                         fn = spm_select('List',smoothfolder,targetfile.name);% path
%                         [r1,r2,r3,r4,r5,r6] = textread([smoothfolder '/' fn(1,:)],'%f%f%f%f%f%f'); % path
%                         SPM.Sess(ses).C.C = [r1 r2 r3 r4 r5 r6];
%                         SPM.Sess(ses).C.name = rnam;
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
        SPM.xVi.form       = 'AR(1)'; %AR(0.2)???? SOSART

        % specify SPM working dir for this sub
        %==========================================================================
        SPM.swd = pwd;

        % set threshold of mask
        %==========================================================================
        SPM.xM.gMT = -Inf;% set -inf if we want to use explicit masking 0.8 is the spm default


        % Configure design matrix
        %==========================================================================
        SPM = spm_fmri_spm_ui(SPM);

        % *After* configuration but before *estimation* we need to specify the explicit mask
        %--------------------------------------------------------------------------
        SPM.xM.VM  = spm_vol(char({[subjanatdir '/sub-' subjX '_ses-first_acq-ANTnorm_T2.nii']})); % here enter the mask based on the subject anatomical


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

            runN = SPM.xX.name{j} (4);
            run  = ['run' runN '.'];
            conditionName{j} = strcat(run,SPM.xX.name{j} (18:end-6));

        end

        Ct = []; Ctnames = []; nrun = size(param.runs,1);

        % | CONSTRASTS FOR T-TESTS

        % con1
        Ctnames{1} = 'liquid';
        weightPos  = ismember(conditionName, {'run1.swallow'}) * 1;
        Ct(1,:)    = weightPos;

        % con2
        Ctnames{2} = 'liking';
        weightPos  = ismember(conditionName, {'run1.swallowxliking^1'}) * 1;
        Ct(2,:)    = weightPos;
         

        % define F constrasts
        %------------------------------------------------------------------
        Cf = []; Cfnames = [];

        Cfnames{end+1} = 'F_RUN1';
        Frun1 = [1 0 0 0 0 0    %1 trialstart
                 0 1 0 0 0 0    %2 swallow
                 0 0 1 0 0 0    %3 liking
                 0 0 0 1 0 0    %4 intensity
                 0 0 0 0 1 0    %5 familiarity
                0 0 0 0 0 1];   %6 rinse


        Cf = repmat(Frun1,1,nrun);

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
