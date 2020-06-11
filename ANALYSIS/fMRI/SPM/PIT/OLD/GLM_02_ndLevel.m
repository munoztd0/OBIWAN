function GLM_02_ndLevel()

% intended for REWOD PIT GROUP
% get onsets for model 
% Duration =1 + modulators
% last modified on July 2019 by David Munoz

task = 'PIT';

dbstop if error
%does t-test and full_factorial
do_ttest = 1;
remove = 0;
%removesub = {'sub-23'} ;
%removedsub = 'no variance neutral';


%% define path

cd ~
home = pwd;
homedir = [home '/OBIWAN'];

name_ana = 'GLM-02'; % output folder for this analysis

mdldir   = fullfile (homedir, '/DERIVATIVES/GLM', task);% mdl directory (timing and outputs of the analysis)
covdir   = fullfile (homedir, 'DERIVATIVES/GLM/', task, name_ana, 'group_covariates'); % director with the extracted second level covariates
groupdir = fullfile (mdldir,name_ana, 'group/');


%% specify spm param
addpath('/usr/local/external_toolboxes/spm12/');
addpath ([homedir '/CODE/ANALYSIS/fMRI/dependencies']);
spm('Defaults','fMRI');
spm_jobman('initcfg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if do_ttest
    
    % These contrast names become folders    
    
    contrastNames = {'CSp_CSm'%1
        'CSpEffort_CSmEffort'%2
        'CSp_CSm&Baseline'%3
        'CSpEffort_CSmEffort&BaselineEffort' %4
        'grips'
        'CSp_Baseline'
        'CSm_Baseline'};%5
    
    
        conImages = {'con-0001'
        'con-0002'
        'con-0003'
        'con-0004'
        'con-0005'
        'con-0006'
        'con-0007'};
    
    
  %% prepare batch for each contrasts
    
%     for c = 1:length(contrastNames)
%         
%         covariateX = covariateNames{c};
%         
%         filename = fullfile(covdir, [covariateX '.txt']);
%         delimiterIn = '\t';
%         headerlinesIn = 1;
%         C = importdata(filename,delimiterIn,headerlinesIn); %importdata
%         
%         cov.ID   = C.data(:,1);
%         cov.data = C.data(:,2);
%         
% 
%         if remove
%             for i = 1:length(removesub)
%                 idx            = str2double(removesub{i}(5:end));
%                 torm           = find(cov.ID==idx);
% 
%                 cov.ID(torm)   = [];
%                 cov.data(torm) = [];
%             end
%         end
        
        for n = 1:length(contrastNames)
            
            clear matlabbatch
            
            
            conImageX = conImages{n};
            contrastX = contrastNames{n};
            
            if remove 
                contrastFolder = fullfile (groupdir, 'ttests', contrastX, ['removing-' removedsub], contrastX);
            else
                contrastFolder = fullfile (groupdir, 'ttests', contrastX, 'all', contrastX);
            end
            
            mkdir(contrastFolder);
            
            % create the group level spm file
            matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; % directory
              

            %group factor
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.name = 'Group';
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.levels = 2;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = 1;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = 2;
            
            % select contrasts
            orig = pwd;
            cd(groupdir);
            conAll = dir(['*' num2str(conImageX) '*.nii' ]);
            cd(orig);
            

              %ugly but works  
            l = 0;
            for j=1:length(conAll)
                if strfind(conAll(j).name, 'control')
                    if remove
                        for k=1:length(removesub)
                            if strfind(conAll(j).name, removesub{k})
                                continue
                            else        
                                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans{j,1} = [groupdir conAll(j).name ',1'];
                            end
                        end
                    else        
                        matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans{j,1} = [groupdir conAll(j).name ',1'];
                    end
                else
                    l = l +1;
                    if remove
                        for k=1:length(removesub)
                            if strfind(conAll(j).name, removesub{k})
                                continue
                            else        
                                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans{l,1} = [groupdir conAll(j).name ',1'];
                            end
                        end
                    else        
                        matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans{l,1} = [groupdir conAll(j).name ',1'];
                    end
                end
            end
            
            
%             matlabbatch{1}.spm.stats.factorial_design.cov.c      = cov.data;
%             matlabbatch{1}.spm.stats.factorial_design.cov.cname  = covariateX;
%             matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
%             matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
            
            %matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.dept = 0;
            %matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.variance = 1;
            %matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.gmsca = 0;
            %matlabbatch{1}.spm.stats.factorial_design.des.fd.fact.ancova = 0;
            
            matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

            % estimate design matrix
            matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
            matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

            % specify one sample tconstrast
            matlabbatch{3}.spm.stats.con.spmmat(1)               = {[contrastFolder  '/SPM.mat']};
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.name     = contrastX (1:end);
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights  = [1];
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep  = 'none';
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.name     = ['Neg ' contrastX(1:end)];
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights  = [-1];
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep  = 'none';
        

            disp ('***************************************************************') 
            disp (['running batch for: '  contrastX] ) 
            disp ('***************************************************************') 
               
            spm_jobman('run',matlabbatch)
            
        end
    end
end

