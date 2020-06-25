if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)}

pacman::p_load(tidyverse, dplyr, plyr)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

setwd(analysis_path)

path <-'~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/GLM-04/covariates'

HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset

HED  <- subset(HED_full, session == 'second')

#take out incomplete data ##
#`%notin%` <- Negate(`%in%`)
#HED = HED %>% filter(id %notin% c(242, 256, 114, 208))

bs = ddply(HED, .(id, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 
emp = subset(bs, condition == "Empty")
ms = subset(bs, condition == "MilkShake")

diff = ms
diff$lik = diff$lik - emp$lik
diff$int = diff$int - emp$int
diff$fam = diff$fam - emp$fam


# LIKING ------------------------------------------------------------------
lik = diff %>% select(id, lik)
emplik = emp %>% select(id, lik)
mslik = ms %>% select(id, lik)

ob = subset(lik, id >= 200)
hw = subset(lik, id < 200)

rew_con_lik_ob = lik
rew_con_lik_hw = lik

rew_con_lik_ob$lik[rew_con_lik_ob$id < 200] <- 0
rew_con_lik_hw$lik[rew_con_lik_hw$id >= 200] <- 0

write.table(rew_con_lik_ob, (file.path(path, "rew_con_lik_ob.txt")), row.names = F, sep="\t")
write.table(rew_con_lik_hw, (file.path(path, "rew_con_lik_hw.txt")), row.names = F, sep="\t")

write.table(mslik, (file.path(path, "rew_lik.txt")), row.names = F, sep="\t")
write.table(emplik, (file.path(path, "con_lik.txt")), row.names = F, sep="\t")



# INTENSITY ------------------------------------------------------------------
int = diff %>% select(id, int)
empint = emp %>% select(id, int)
msint = ms %>% select(id, int)

ob = subset(int, id >= 200)
hw = subset(int, id < 200)

rew_con_int_ob = int
rew_con_int_hw = int

rew_con_int_ob$int[rew_con_int_ob$id < 200] <- 0
rew_con_int_hw$int[rew_con_int_hw$id >= 200] <- 0

write.table(rew_con_int_ob, (file.path(path, "rew_con_int_ob.txt")), row.names = F, sep="\t")
write.table(rew_con_int_hw, (file.path(path, "rew_con_int_hw.txt")), row.names = F, sep="\t")
write.table(msint, (file.path(path, "rew_int.txt")), row.names = F, sep="\t")
write.table(empint, (file.path(path, "con_int.txt")), row.names = F, sep="\t")

# Odor_NoOdor_lik <- read.delim(file.path(analysis_path, "Odor-NoOdor_lik_meancent.txt"))
# Odor_presence_lik <- read.delim(file.path(analysis_path, "Odor_presence_lik_meancent.txt"))
# reward_neutral_lik <- read.delim(file.path(analysis_path, "reward-neutral_lik_meancent.txt"))
# R_NoR_lik <- read.delim(file.path(analysis_path, "Reward_NoReward_lik_meancent.txt"))





# 
# write.table(Odor_NoOdor_lik, (file.path(analysis_path, "Odor-NoOdor_lik_rank.txt")), row.names = F, sep="\t")
# write.table(Odor_presence_lik, (file.path(analysis_path, "Odor_presence_lik_rank.txt")), row.names = F, sep="\t")
# write.table(reward_neutral_lik, (file.path(analysis_path, "reward-neutral_lik_rank.txt")), row.names = F, sep="\t")
# write.table(R_NoR_lik, (file.path(analysis_path, "Reward_NoReward_lik_rank.txt")), row.names = F, sep="\t")
# 
# 
# 
# #_____________INTENSITY____________#
# Odor_NoOdor_int <- read.delim(file.path(analysis_path, "Odor-NoOdor_int_meancent.txt"))
# Odor_presence_int <- read.delim(file.path(analysis_path, "Odor_presence_int_meancent.txt"))
# reward_control_int <- read.delim(file.path(analysis_path, "reward-control_int_meancent.txt"))
# reward_neutral_int <- read.delim(file.path(analysis_path, "reward-neutral_int_meancent.txt"))
# 
# 
# # Draw from chi-1 distribution
# Odor_NoOdor_int$int = rankNorm(Odor_NoOdor_int$int)
# Odor_presence_int$int = rankNorm(Odor_presence_int$int)
# reward_control_int$int = rankNorm(reward_control_int$int)
# reward_neutral_int$int = rankNorm(reward_neutral_int$int)
# 
# # Plot density of transformed measurement
# #plot(density(reward_neutral_int$int));
# 
# write.table(Odor_NoOdor_int, (file.path(analysis_path, "Odor-NoOdor_int_rank.txt")), row.names = F, sep="\t")
# write.table(Odor_presence_int, (file.path(analysis_path, "Odor_presence_int_rank.txt")), row.names = F, sep="\t")
# write.table(reward_control_int, (file.path(analysis_path, "reward-control_int_rank.txt")), row.names = F, sep="\t")
# write.table(reward_neutral_int, (file.path(analysis_path, "reward-neutral_int_rank.txt")), row.names = F, sep="\t")