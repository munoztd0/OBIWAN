function prepro_VBM()

% intended for OBIWAN 
    
    
dbstop if error
clear all

%define steps
segm = 0;
smooth = 1;
copytissues = 1;
task = 'VBM';
name_ana = 'GLM-00';

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

groupdir   = fullfile (homedir, '/DERIVATIVES/GLM/SPM', task, name_ana, 'group/');% mdl directory (timing and outputs of the analysis)
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC/');
%tmp_files = '/usr/local/MATLAB/toolbox/spm/tpm/'; 
tmp_files = '/usr/local/external_toolboxes/spm12/tpm/';
addpath (genpath(fullfile(homedir,'/CODE/ANALYSIS/fMRI/dependencies')));


control = [homedir '/sub-control*'];
obese = [homedir '/sub-obese*'];

controlX = dir(control);
obeseX = dir(obese);

%subj = controlX; 
%subj = obeseX; %, 
subj = vertcat(controlX, obeseX);



%loop trhough subjects
for i = 1:length(subj)
    
        
        %subjX=subj(i,1);
        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        sub = subjX(end-2:end);

            
        path = fullfile(sourcefiles, subjX,'ses-first','anat');
        T1_file = [num2str(subjX), '_ses-first_acq-ANTsNorm_T1w.nii'];
        full_path = fullfile(path, T1_file);
            

        if exist(full_path, 'file')
            cd (path)
        else 
            continue
        end
        
        
        disp (['****** PARTICIPANT: ' subjX ' **** session  first ****' ]);
        
        
        %doing it with enhanced Tissue Probability Maps priors for improved automated classification of subcortical brain structures
        %from Lorio S, Fresard S, Adaszewski S, Kherif F, Chowdhury R, Frackowiak RS, Ashburner J, Helms G, Weiskopf N, Lutti A, Draganski B. 2016
        job{1}.spm.spatial.preproc.channel.vols = {[sourcefiles subjX '/ses-first/anat/' subjX '_ses-first_acq-ANTsNorm_T1w.nii,1']};
        job{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        job{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        job{1}.spm.spatial.preproc.channel.write = [0 0];
        job{1}.spm.spatial.preproc.tissue(1).tpm = {[tmp_files 'enhanced_TPM.nii,1']};
        job{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
        job{1}.spm.spatial.preproc.tissue(1).native = [1 1];
        job{1}.spm.spatial.preproc.tissue(1).warped = [1 1];
        job{1}.spm.spatial.preproc.tissue(2).tpm = {[tmp_files 'enhanced_TPM.nii,2']};
        job{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
        job{1}.spm.spatial.preproc.tissue(2).native = [1 1];
        job{1}.spm.spatial.preproc.tissue(2).warped = [1 1];
        job{1}.spm.spatial.preproc.tissue(3).tpm = {[tmp_files 'enhanced_TPM.nii,3']};
        job{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        job{1}.spm.spatial.preproc.tissue(3).native = [1 1];
        job{1}.spm.spatial.preproc.tissue(3).warped = [1 1];
        job{1}.spm.spatial.preproc.tissue(4).tpm = {[tmp_files 'enhanced_TPM.nii,4']};
        job{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        job{1}.spm.spatial.preproc.tissue(4).native = [1 0];
        job{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
        job{1}.spm.spatial.preproc.tissue(5).tpm = {[tmp_files 'enhanced_TPM.nii,5']};
        job{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        job{1}.spm.spatial.preproc.tissue(5).native = [1 0];
        job{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
        job{1}.spm.spatial.preproc.tissue(6).tpm = {[tmp_files 'enhanced_TPM.nii,6']};
        job{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
        job{1}.spm.spatial.preproc.tissue(6).native = [1 0];
        job{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
        job{1}.spm.spatial.preproc.warp.mrf = 1;
        job{1}.spm.spatial.preproc.warp.cleanup = 1;
        job{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        job{1}.spm.spatial.preproc.warp.affreg = ''; %   we are doing it with ANTS     %job{1}.spm.spatial.preproc.warp.affreg = 'mni';
        job{1}.spm.spatial.preproc.warp.fwhm = 0;
        job{1}.spm.spatial.preproc.warp.samp = 3;
        job{1}.spm.spatial.preproc.warp.write = [1 1];




        if segm == 1
            spm_jobman('run', job)
        end
        
        
        %relsice to functional resolution
        batch{1}.spm.spatial.coreg.write.ref = {[homedir '/DERIVATIVES/EXTERNALDATA/CANONICALS/CIT168_T1w_MNI_lowres.nii,1']}; %this is to reslice at 3x3x3.6
        batch{1}.spm.spatial.coreg.write.source = {[sourcefiles subjX '/ses-first/anat/mwc1' subjX '_ses-first_acq-ANTsNorm_T1w.nii,1']
            [sourcefiles subjX '/ses-first/anat/mwc2' subjX '_ses-first_acq-ANTsNorm_T1w.nii,1']
            [sourcefiles subjX '/ses-first/anat/mwc3' subjX '_ses-first_acq-ANTsNorm_T1w.nii,1']
            };
        batch{1}.spm.spatial.coreg.write.roptions.interp = 4;
        batch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        batch{1}.spm.spatial.coreg.write.roptions.mask = 0;
        batch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
        
        %smooth FWHM 8mm         %it goes grey c1, white matter c2 , CSF c3 and then other tissue
        batch{2}.spm.spatial.smooth.data = {[sourcefiles subjX '/ses-first/anat/rmwc1' subjX '_ses-first_acq-ANTsNorm_T1w.nii,1']
                                          [sourcefiles subjX '/ses-first/anat/rmwc2' subjX '_ses-first_acq-ANTsNorm_T1w.nii,1']
                                          [sourcefiles subjX '/ses-first/anat/rmwc3' subjX '_ses-first_acq-ANTsNorm_T1w.nii,1']};
        batch{2}.spm.spatial.smooth.fwhm = [8 8 8];
        batch{2}.spm.spatial.smooth.dtype = 0;
        batch{2}.spm.spatial.smooth.im = 0;
        batch{2}.spm.spatial.smooth.prefix = 's';
        
        if smooth == 1
            spm_jobman('run', batch)
        end
        

        
            %%%%%%%%%%%%%%%%%%%%% COPY CONSTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if copytissues == 1
        
        mkdir (groupdir); % make the group directory where tissues segm will be copied
       
        
        % copy images T
        Timages = ['c1'; 'c2'; 'c3']; 
        Fimages = ['GM'; 'WM'; 'CF']; 
        for y =1:size(Timages,1)
            copyfile(['srmw' (Timages(y,:)) subjX '_ses-first_acq-ANTsNorm_T1w.nii'],[groupdir, subjX '_' (Fimages(y,:)) '.nii'])
        end
        
        
        display('contrasts copied!');
    end
    

end
end
