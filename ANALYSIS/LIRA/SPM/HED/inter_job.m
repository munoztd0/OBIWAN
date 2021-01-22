%-----------------------------------------------------------------------
% Job saved on 22-Jan-2021 12:04:29 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.imcalc.input = {
                                        '/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-01_0/group/placebo/sub-obese202_con_0003.nii,1'
                                        '/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-01_0/group/placebo/sub-obese202_con_0004.nii,1'
                                        '/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-01_1/group/placebo/sub-obese202_con_0003.nii,1'
                                        '/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-01_1/group/placebo/sub-obese202_con_0004.nii,1'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'output';
matlabbatch{1}.spm.util.imcalc.outdir = {'/home/davidM/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity'};
matlabbatch{1}.spm.util.imcalc.expression = 'i1 - i2 - i3 + i4';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
