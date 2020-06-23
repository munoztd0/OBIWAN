function matlabbatch = level2_ff_oneway(condirpat, factors, varargin)




def =   { ...
    'covariates',   [],                     ...
    'conpat',       'con*nii',              ...
    'conweights',   'auto',                 ...
    'implicitmask',  0,                     ...
    'mask',         '',                     ...
    'nan2zero',      1,                     ...
    'negativecon',   0,                     ...
    'outdir',       [],                     ...
    'pctgroup',     100,                    ...
    'tag',          [],                     ...
    'viewit',        0,                     ...
    };

vals = setargs(def, varargin);
if nargin<2, mfile_showhelp; fprintf('\t= DEFAULT SETTINGS =\n'); disp(vals); return; end
fprintf('\n\t= CURRENT SETTINGS =\n'); disp(vals);
if iscell(condirpat), cons1 = cellstr(condirpat); end
if ~regexp(condirpat, pwd), condirpat = fullfile(pwd, condirpat); end
if iscell(outdir), outdir = char(outdir); end
if iscell(mask), mask = char(mask); end
if ~isempty(mask)
    [~,mtag] = fileparts(mask);
    mtag = upper(mtag);
else
    mtag = 'NOMASK';
end


% | GET CONS 
conidx = sort(factors(1).idx2con(:));

for i = 1:length(conidx)
    conImageX = conidx{i};
    selectcon(:,:,i)  = spm_select('List',condirpat,['^'  '.*'  conImageX '.nii']); % select constrasts 
end
conAll = reshape(permute(selectcon,[2,1,3]),size(selectcon,2),[])';

for j =1:length(conAll)
   conList{j,1} = [condirpat conAll(j,:) ',1'];
end

if isempty(conList), error('No contrasts found!'); end

conname = bspm_con2name(conList);

[ucon, idx2ex, idx2sub] = unique(conname); 

% | BUILD MATRIX
ncon    = length(conname);
ncell   = length(ucon);
nfact   = length(factors);
nsub    = length(conname)/ncell;
nlevel  = [2 1];


I       = repmat(ones(ncon, 4),1); % 2 factors + 1 (for the subjects) and 1 constant
I(:,2)  = reshape(repmat((1:nsub)',1, ncell),ncon,1); % participant
I(:,3)  = repmat(factors(1).level, 1, nsub)'; % first factor 


% | OUTPUT DIRECTORY
if isempty(outdir)
    
    % | Analysis Name
    [p, ~]          = fileparts(fileparts(conList{1})); 
    gadir           = fullfile(p,'group', 'flexibleFactorial');
    outdir          = fullfile(gadir);

    % | Make Directories
    if ~isdir(gadir), mkdir(gadir); end
    
end
if ~isdir(outdir), mkdir(outdir); end


% | FACTORIAL DESIGN SPECIFICATION
matlabbatch{1}.spm.stats.factorial_design.dir{1} = outdir;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'Subject';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;

for i = 1:nfact
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i+1).name     = factors(i).name;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i+1).dept     = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i+1).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i+1).gmsca    = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i+1).ancova   = 0;
end

matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans    = conList;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = I;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.inter.fnums = [2 2];


% | MASKING & GLOBAL CALCULATIONS
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none     = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im             = implicitmask;
matlabbatch{1}.spm.stats.factorial_design.masking.em{1}          = mask; 
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit         = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm        = 1;

% | COVARIATES
if ~isempty(covariates)
    ncov = length(covariates);
    for i = 1:ncov
        matlabbatch{1}.spm.stats.factorial_design.cov(i).c      = covariates(i).values;
        matlabbatch{1}.spm.stats.factorial_design.cov(i).cname  = covariates(i).name; 
        matlabbatch{1}.spm.stats.factorial_design.cov(i).iCFI   = 1;
        matlabbatch{1}.spm.stats.factorial_design.cov(i).iCC    = 1;
    end
end





% | ESTIMATE
matlabbatch{2}.spm.stats.fmri_est.spmmat{1}        = fullfile(outdir,'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


%| CONTRASTS
conweights_pos = [1 -1];
conname_pos = {'Main'};

conweights     = [conweights_pos; conweights_pos*-1];
conname_neg    = strcat({'Neg_'},conname_pos);
conname        = [conname_pos; conname_neg];

matlabbatch{3}.spm.stats.con.spmmat{1}                   = fullfile(outdir,'SPM.mat');
matlabbatch{3}.spm.stats.con.delete                      = 1;

for c = 1:size(conweights,1);
    matlabbatch{3}.spm.stats.con.consess{c}.tcon.name    = conname{c,:};
    matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = conweights(c,:);
    matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec  = conweights(c,:);
    matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'none';
end



end





