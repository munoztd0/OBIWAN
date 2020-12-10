if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)

# LIKING ------------------------------------------------------------------
load("HED.RData")

bs = ddply(HED, .(id, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 
emp = subset(bs, condition == "-1")
ms = subset(bs, condition == "1")

diff = ms
diff$lik = diff$lik - emp$lik
diff$int = diff$int - emp$int
diff$fam = diff$fam - emp$fam


lik = diff %>% select(id, lik, int, fam)

write.table(lik, (file.path(analysis_path, "HED_covariateT0_Ratings.tsv")), row.names = F, sep="\t")

# EFORT ------------------------------------------------------------------
load("PIT.RData")

bs = ddply(PIT, .(id, condition), summarise, eff = mean(AUC, na.rm = TRUE), grip = mean(gripFreq, na.rm = TRUE)) 
CSp = subset(bs, condition == "1")
CSm = subset(bs, condition == "-1")

diff = CSp
diff$eff = CSp$eff - CSm$eff
diff$grip = CSp$grip - CSm$grip



eff = diff %>% select(id, eff, grip)

write.table(eff, (file.path(analysis_path, "PIT_covariateT0_Force.tsv")), row.names = F, sep="\t")
