function matlabbatch = espm_level2_ff(groupdir,sub_list, factor, contrast, analysisX)

% created on April 2019 by Eva
% last modified on April 2019 by Eva

%   ARGUMENTS:
%       1) groupdir: path for finding level 1 dirs containing con images
%       2) sub_list: list of participants to be inclueded in a cell vector (e.g., {01; 03; 04; 05...})     
%       3) factor: specified as follows: 
%           factor(n).name      = 'Factor Name';
%           factor(n).condition = how conditions should be coded for a single participants (e.g., [1 1 1 2 2 2] or [1 2 3 1 2 3]
%           factor(n).levels    = number of level of the factor (e.g. 3)           
%           factor(1).idx2con   = indices for con files corresponding to levels (e.g., {'con-0001', 'con-0002', 'con-0003'})
%       4) constrast: specified as follows:
%           constrast(n).name      = 'constrs Name';
%           constrast(n).weights   = constrasts weigths (e.g., [1 1 -1 -1]
%       5) analysisX: analysis name (e.g., ValuexTime)               
    

% Adapted from BSPM_LEVEL2_FF_TWOWAY of Bob Spunt



% | DEFINE FOLDER
contrastFolder = fullfile (groupdir, 'flexFact', analysisX);

if ~isdir(contrastFolder); mkdir (contrastFolder); end

matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; %  output directory

% | GET FACTORS

%first factor is always subject
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'subjects';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0; % 1 for within subjects design 0 for between subject designs
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;

for f = 1:size(factor,2)
    
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).name = factor(f).name;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).dept = 1; % 1 for within subjects design 0 for between subject designs
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).ancova = 0;
    
end

% | FACTORIAL DESIGN SPECIFICATIONS

% specify design matrix

for f = 1:size(factor,2)  
    design_matrix (:,f) = factor(f).condition;% build the matrix based on the factors specifications 
end

% get contrasts
cmpt = 1;
for s = 1:length(sub_list)
    
    unit_length = size(design_matrix,1);
    
    
    subX = cell2mat(sub_list(s));
    subX = str2double(subX);
    
    
    ID = repmat(subX,unit_length,1);
    design_Matrix(cmpt:cmpt+unit_length-1,:)  = [ID design_matrix]; % find a way to compile big matrix
    
    subX = char(sub_list(s));
    Scue = deblank(['sub-' subX]);
    
    for c = 1: length(factor(1).idx2cons)
        conImageX = char(factor(1).idx2cons(c));
        conSubX (c,:) = spm_select('List',groupdir,['^' Scue '.*' conImageX '.nii']); % select constrasts
    end
    
    conAll(cmpt:cmpt+unit_length-1,:) = conSubX;
    
    cmpt = cmpt + unit_length;
    
end


for j = 1:size(conAll,1)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject.scans{j,1} = [groupdir  conAll(j,:) ',1'];
end


matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject.conds = design_Matrix;



% | main effects and interations

if size(factor,2) > 1
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = [2, 3]; % interaction if two factors
else
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 2; % main effect if one factor

end


% | SET COVARIATE
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});

% | SET MASKING and GLOBAL CALCULATIONS
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% | ESTIMATE
matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;

% | CONSTASTS

for c = 1:size(contrast,2)
    matlabbatch{3}.spm.stats.con.spmmat(1)                = {[contrastFolder  '/SPM.mat']};
    matlabbatch{3}.spm.stats.con.consess{c}.tcon.name     = contrast(c).name;
    matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights  = contrast(c).weights; % in the covariate the second colon is the one of interest
    matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep  = 'none';
end