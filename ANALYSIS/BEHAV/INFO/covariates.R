if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)



bs = ddply(HED, .(id, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 
emp = subset(bs, condition == "Empty")
ms = subset(bs, condition == "MilkShake")

diff = ms
diff$lik = diff$lik - emp$lik
diff$int = diff$int - emp$int
diff$fam = diff$fam - emp$fam


# LIKING ------------------------------------------------------------------
lik = diff %>% select(id, lik, int, fam)

write.table(lik, (file.path(analysis_path, "HED_covariateT0_Ratings.tsv")), row.names = F, sep="\t")

