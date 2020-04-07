
library("RNOmni")
library(Hmisc)
library(mosaic)
library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)

analysis_path <-'~/REWOD/DERIVATIVES/ANALYSIS/PIT/GLM-04/group_covariates'

setwd(analysis_path)

#_____________EFFORT____________#
CSm_Baseline_eff <- read.delim(file.path(analysis_path, "CSm-Baseline_eff_meancent.txt"))
CSm_Baseline_eff = rename(CSm_Baseline_eff, c("subj"="subj","eff"="CSm-Baseline_eff"))
CSp_Baseline_eff <- read.delim(file.path(analysis_path, "CSp-Baseline_eff_meancent.txt"))
CSp_Baseline_eff = rename(CSp_Baseline_eff, c("subj"="subj","eff"="CSp-Baseline_eff"))
CSp_CSmAndBaseline_eff <- read.delim(file.path(analysis_path, "CSp-CSm&Baseline_eff_meancent.txt"))
CSp_CSmAndBaseline_eff = rename(CSp_CSmAndBaseline_eff, c("subj"="subj","eff"="CSp-CSm&Baseline_eff"))
CSp_CSm_eff <- read.delim(file.path(analysis_path, "CSp-CSm_eff_meancent.txt"))
CSp_CSm_eff = rename(CSp_CSm_eff, c("subj"="subj","eff"="CSp-CSm_eff"))

eff = Reduce(function(x,y) merge(x = x, y = y, by = "subj", all = TRUE), list(CSm_Baseline_eff, CSp_Baseline_eff, CSp_CSmAndBaseline_eff, CSp_CSm_eff))


#_____________EFOORT___RANKNORM_________#
CSm_Baseline_eff_rank <- read.delim(file.path(analysis_path, "CSm-Baseline_eff_rank.txt"))
CSm_Baseline_eff_rank = rename(CSm_Baseline_eff_rank, c("subj"="subj","eff"="CSm-Baseline_eff"))
CSp_Baseline_eff_rank <- read.delim(file.path(analysis_path, "CSp-Baseline_eff_rank.txt"))
CSp_Baseline_eff_rank = rename(CSp_Baseline_eff_rank, c("subj"="subj","eff"="CSp-Baseline_eff"))
CSp_CSmAndBaseline_eff_rank <- read.delim(file.path(analysis_path, "CSp-CSm&Baseline_eff_rank.txt"))
CSp_CSmAndBaseline_eff_rank = rename(CSp_CSmAndBaseline_eff_rank, c("subj"="subj","eff"="CSp-CSm&Baseline_eff"))
CSp_CSm_eff_rank <- read.delim(file.path(analysis_path, "CSp-CSm_eff_rank.txt"))
CSp_CSm_eff_rank = rename(CSp_CSm_eff_rank, c("subj"="subj","eff"="CSp-CSm_eff"))

eff_rank = Reduce(function(x,y) merge(x = x, y = y, by = "subj", all = TRUE), list(CSm_Baseline_eff_rank, CSp_Baseline_eff_rank, CSp_CSmAndBaseline_eff_rank, CSp_CSm_eff_rank))

# Plot density of non-transformed measurement
eff %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 

# Plot density of transformed measurement

eff_rank %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 



#check correlation (diagonal)
cor(eff_rank, eff)  #or spearman
cor(eff_rank, eff, method="kendall")  #for ranks




CSp_CSm_eff$'Mobilized effort INT' =  CSp_CSm_eff_rank$'CSp-CSm_eff'
CSp_CSm_eff$'Mobilized effort' =  CSp_CSm_eff$'CSp-CSm_eff'

CSp_CSm <- CSp_CSm_eff[c(3:4)]

CSp_CSm %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() + 
  theme_classic() +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)





