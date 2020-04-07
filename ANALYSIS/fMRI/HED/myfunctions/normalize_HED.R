
library("RNOmni")

analysis_path <-'~/REWOD/DERIVATIVES/ANALYSIS/hedonic/GLM-04/group_covariates'

setwd(analysis_path)


# LIKING ------------------------------------------------------------------


Odor_NoOdor_lik <- read.delim(file.path(analysis_path, "Odor-NoOdor_lik_meancent.txt"))
Odor_presence_lik <- read.delim(file.path(analysis_path, "Odor_presence_lik_meancent.txt"))
reward_control_lik <- read.delim(file.path(analysis_path, "reward-control_lik_meancent.txt"))
reward_neutral_lik <- read.delim(file.path(analysis_path, "reward-neutral_lik_meancent.txt"))


# Draw from chi-1 distribution
Odor_NoOdor_lik$lik = rankNorm(Odor_NoOdor_lik$lik)
Odor_presence_lik$lik = rankNorm(Odor_presence_lik$lik)
reward_control_lik$lik = rankNorm(reward_control_lik$lik)
reward_neutral_lik$lik = rankNorm(reward_neutral_lik$lik)

# Plot density of transformed measurement
#plot(density(reward_neutral_lik$lik));

write.table(Odor_NoOdor_lik, (file.path(analysis_path, "Odor-NoOdor_lik_rank.txt")), row.names = F, sep="\t")
write.table(Odor_presence_lik, (file.path(analysis_path, "Odor_presence_lik_rank.txt")), row.names = F, sep="\t")
write.table(reward_control_lik, (file.path(analysis_path, "reward-control_lik_rank.txt")), row.names = F, sep="\t")
write.table(reward_neutral_lik, (file.path(analysis_path, "reward-neutral_lik_rank.txt")), row.names = F, sep="\t")



#_____________INTENSITY____________#
Odor_NoOdor_int <- read.delim(file.path(analysis_path, "Odor-NoOdor_int_meancent.txt"))
Odor_presence_int <- read.delim(file.path(analysis_path, "Odor_presence_int_meancent.txt"))
reward_control_int <- read.delim(file.path(analysis_path, "reward-control_int_meancent.txt"))
reward_neutral_int <- read.delim(file.path(analysis_path, "reward-neutral_int_meancent.txt"))


# Draw from chi-1 distribution
Odor_NoOdor_int$int = rankNorm(Odor_NoOdor_int$int)
Odor_presence_int$int = rankNorm(Odor_presence_int$int)
reward_control_int$int = rankNorm(reward_control_int$int)
reward_neutral_int$int = rankNorm(reward_neutral_int$int)

# Plot density of transformed measurement
#plot(density(reward_neutral_int$int));

write.table(Odor_NoOdor_int, (file.path(analysis_path, "Odor-NoOdor_int_rank.txt")), row.names = F, sep="\t")
write.table(Odor_presence_int, (file.path(analysis_path, "Odor_presence_int_rank.txt")), row.names = F, sep="\t")
write.table(reward_control_int, (file.path(analysis_path, "reward-control_int_rank.txt")), row.names = F, sep="\t")
write.table(reward_neutral_int, (file.path(analysis_path, "reward-neutral_int_rank.txt")), row.names = F, sep="\t")