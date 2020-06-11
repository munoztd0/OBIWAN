
library("RNOmni")

analysis_path <-'~/REWOD/DERIVATIVES/ANALYSIS/PIT/GLM-04/group_covariates/'

setwd(analysis_path)


CSm_Baseline <- read.delim(file.path(analysis_path, "CSm-Baseline_eff_meancent.txt"))
CSp_Baseline <- read.delim(file.path(analysis_path, "CSp-Baseline_eff_meancent.txt"))
CSp_CSmANDBaseline <- read.delim(file.path(analysis_path, "CSp-CSm&Baseline_eff_meancent.txt"))
CSp_CSm <- read.delim(file.path(analysis_path, "CSp-CSm_eff_meancent.txt"))



# COVARIATE RANKNORM ------------------------------------------------------



# Draw from chi-1 distribution
CSm_Baseline$eff = rankNorm(CSm_Baseline$eff)
CSp_Baseline$eff = rankNorm(CSp_Baseline$eff)
CSp_CSmANDBaseline$eff = rankNorm(CSp_CSmANDBaseline$eff)
CSp_CSm$eff = rankNorm(CSp_CSm$eff)

# Plot density of transformed measurement
#plot(density(Z));

write.table(CSm_Baseline, (file.path(analysis_path, "CSm-Baseline_eff_rank.txt")), row.names = F, sep="\t")
write.table(CSp_Baseline, (file.path(analysis_path, "CSp-Baseline_eff_rank.txt")), row.names = F, sep="\t")
write.table(CSp_CSmANDBaseline, (file.path(analysis_path, "CSp-CSm&Baseline_eff_rank.txt")), row.names = F, sep="\t")
write.table(CSp_CSm, (file.path(analysis_path, "CSp-CSm_eff_rank.txt")), row.names = F, sep="\t")