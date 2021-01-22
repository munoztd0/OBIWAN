%-----------------------------------------------------------------------
% Job saved on 05-Jan-2021 19:25:38 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.imcalc.input = {
                                        '/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-02_1/group/sub-obese202_con-0001.nii,1'
                                        '/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-02_0/group/sub-obese201_con-0001.nii,1'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'con_0003';
matlabbatch{1}.spm.util.imcalc.outdir = {'/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity'};
matlabbatch{1}.spm.util.imcalc.expression = 'i1-i2';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
