function classic_preproc (subID, runID, sessionID)

% script for the classical spm preprocessing pipeline as a quick check that
% the signal is working.
% This script works with on spm12-jobs ('matlabbatch')which are stored in
% something like '...\study_folder\subject\jobs' jobs are stored
% as: slice timing: SLT.mat
% slice time correction is particolarly important for multi band sequences


%% define paths
%
%homedir = '/Users/evapool/mountpoint';
homedir = '/home/OBIWAN';

popdir        = fullfile (homedir, '/DATA/STUDY/DERIVED/PIT_HEDONIC');
jobdir        = fullfile (homedir, '/ANALYSIS/spm_jobs');

%addpath(fullfile(homedir,  '/ANALYSIS/my_tools'));
% addpath('/usr/local/matlab/R2014a/toolbox/spm12b');
%% define preproc to be executed
toDo     = {'realig'; 'slicet';    'coregi';      'normal';     'smoot'};
prefix   = {     ' ' ;      'r';        'ar';         'ar';       'war'}; % images to be selected for that preproc step

% toDo     = { 'smoot' };
% prefix   = {   'war' }; % images to be selected for that preproc step


%% define experiment and population
TR      = 2;
nslices = 40; % double check

runs    =  runID;
subj    =  subID;%cellstr([num2str(subID)]);
session =  char(sessionID);
%% Start pipeline

for i = 1:length(runs)
    
    runX =char(runs(i));% define current run
    
    for ii = 1:length(subj)
        
        % define subject and their path
        subjX = char(subj(ii));
        subjdir=fullfile(popdir, ['sub-' subjX],['ses-' session], 'func');
        cd (subjdir)
        fprintf('participant: %s run: %s \n', subjX, runX)
        
        % get the number of EPI for each session
        tmp.V = dir (['s*' runX '_run-01_bold.nii']);
        if ischar(tmp.V(1).name)
            [p,n,e]   = spm_fileparts(tmp.V(1).name);
            tmp.Vn = spm_vol(fullfile(p,[n e]));
        end
        
        nEPI = numel(tmp.Vn);
        
        
        %------------------------------------------------------------------
        % REALIGN (RE)
        if find(ismember(toDo,'realig'))
            
            
            % select images to be RE
            idx = find(ismember(toDo,'realig'));
            
            scanRE = dir (['*' runX '_run-01_bold.nii']);
            for j=1:nEPI
                tmp.scanREX(j,:)={[subjdir,'/',scanRE.name ',' num2str(j)]};
            end
            scanRE = cellstr(tmp.scanREX);
            
            % load job
            cd (jobdir);
            load RE.mat
            cd (subjdir);
            
            % execute job on the selected images
            matlabbatch{1}.spm.spatial.realign.estwrite.data{1,1} = scanRE;
            spm_jobman('run', matlabbatch);
            clear matlabbatch
            
            % plot movement parameter
            % plot_rp (rundir, subjX, runX)
            
        end
     
        %------------------------------------------------------------------
        % SLICE TIMING (SLT)
        if find(ismember(toDo,'slicet'))
            
            % select religned images
            idx = find(ismember(toDo,'slicet'));
            images = char(prefix(idx));
          
            
            scanSLT = dir ([images '*' runX '_run-01_bold.nii']);
            for j=1:nEPI 
                tmp.scanSLTX(j,:)={[subjdir,'/',scanSLT.name ',' num2str(j)]};
            end
            scanSLT = cellstr(tmp.scanSLTX);
            
            % load job
            cd (jobdir);
            load SLT.mat
            cd (subjdir);
            
            % execute job on the selected images
            matlabbatch{1}.spm.temporal.st.tr         = TR;
            matlabbatch{1}.spm.temporal.st.nslices    = nslices;
            matlabbatch{1}.spm.temporal.st.ta         = TR - (TR/nslices);
            matlabbatch{1}.spm.temporal.st.so         = [2:2:nslices, 1:2:nslices];
            matlabbatch{1}.spm.temporal.st.scans{1,1} = scanSLT;
            spm_jobman ('run', matlabbatch)
            clear matlabbatch
            
        end
        
        %------------------------------------------------------------------
        % COREGISTRATION (CO) (multi-modal T1/T2 is not used here)
        if find(ismember(toDo,'coregi'))
            
            % select mean reference image
            scanCOmean = dir (fullfile(subjdir, ['mean*' runX '*.nii']));
            for j=1:1
                tmp.scanCO1X(j,:)={[subjdir,'/',scanCOmean.name ',' num2str(j)]};
            end
            scanCOmean = cellstr(tmp.scanCO1X);
            
            % select anatomical image (T1)
            structdir = fullfile(popdir, ['sub-' subjX],'ses-first', 'anat');
            
            cd (structdir)

            scanT1 = dir(fullfile(structdir, 'sub-*T1.nii'));
            for j=1:1
                tmp.scanCO2X(j,:)={[structdir,'/',scanT1(1).name ',' num2str(j)]};
            end
            scanT1 = cellstr(tmp.scanCO2X);
            
            % load job
            cd (jobdir);
            load CO.mat
            cd (subjdir);
            
            % execute job on the selected images
             matlabbatch{1}.spm.spatial.coreg.estimate.ref    = scanCOmean;
             matlabbatch{1}.spm.spatial.coreg.estimate.source = scanT1;
             matlabbatch{1}.spm.spatial.coreg.estimate.other  = {''};

            spm_jobman('run', matlabbatch);
            clear matlabbatch
            
        end
              
        
        %------------------------------------------------------------------
        % NORMALIZE TO MNI (NO)
        if find(ismember(toDo,'normal'))
            
            if i == 1 % we need to do this only for the first run
                
                %---------- segmet to get deformation field
                
                % load job
                cd (jobdir);
                load create_DeformField.mat
                cd (subjdir);
                
                % define specifics to 
                matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'/usr/local/external_toolboxes/spm12/tpm/TPM.nii,1'};
                matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'/usr/local/external_toolboxes/spm12/tpm/TPM.nii,2'};
                matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'/usr/local/external_toolboxes/spm12/tpm/TPM.nii,3'};
                matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'/usr/local/external_toolboxes/spm12/tpm/TPM.nii,4'};
                matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'/usr/local/external_toolboxes/spm12/tpm/TPM.nii,5'};
                matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'/usr/local/external_toolboxes/spm12/tpm/TPM.nii,6'};
                
                % execute job
                matlabbatch{1}.spm.spatial.preproc.channel.vols = scanT1;
                spm_jobman('run', matlabbatch);
                clear matlabbatch
                
                %---------- normalize T1 to MNI
                
                % get deformation map
                deformField = dir(fullfile(structdir, 'y_*.nii'));
                tmp.deformFieldX(1,:)=[structdir,'/',deformField.name];
                deformField = cellstr(tmp.deformFieldX);
                
                % load job
                cd (jobdir);
                load NO.mat
                cd (subjdir);
                
                % execute job
                matlabbatch{1}.spm.spatial.normalise.write.subj.def      = deformField;
                matlabbatch{1}.spm.spatial.normalise.write.subj.resample = scanT1;
                spm_jobman('run', matlabbatch);
                clear matlabbatch
            end
            %---------- normalize EPI to MNI
            
            % select images to be normalize
            idx = find(ismember(toDo,'normal'));
            images = char(prefix(idx));

            scanNO = dir ([images '*' runX '_run-01_bold.nii']);
            for j=1:nEPI
                tmp.scanNOX(j,:)={[subjdir,'/',scanNO.name,',' num2str(j)]};
            end
            scanNO = cellstr(tmp.scanNOX);
            
            % load job
            cd (jobdir);
            load NO.mat
            cd (subjdir);
            
            % execute job
            matlabbatch{1}.spm.spatial.normalise.write.subj.def      = deformField;
            matlabbatch{1}.spm.spatial.normalise.write.subj.resample = scanNO;
            spm_jobman('run', matlabbatch);
            clear matlabbatch
            
        end
        
        %------------------------------------------------------------------
        % SMOOTHING (SM)
        if find(ismember(toDo,'smoot'))
            
            % select images to be smoothed
            idx = find(ismember(toDo,'smoot'));% ?
            images = char(prefix(idx));
            
            scanSMOOTH = dir ([images '*' runX '_run-01_bold.nii']);
            for j=1:nEPI
                tmp.scanSMOOTHX(j,:)={[subjdir,'/',scanSMOOTH.name ',' num2str(j)]};
            end
            scanSMOOTH = cellstr(tmp.scanSMOOTHX);
            
            % load job
            cd (jobdir);
            load SM.mat
            cd (subjdir);
            
            % execute job
            matlabbatch{1}.spm.spatial.smooth.data   = scanSMOOTH;
            matlabbatch{1}.spm.spatial.smooth.fwhm   = [6 6 6];
            matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
            matlabbatch{1}.spm.spatial.smooth.im     = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run', matlabbatch);
            clear matlabbatch
            
        end
        
    end
    
end

end