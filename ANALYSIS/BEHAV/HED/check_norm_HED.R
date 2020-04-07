
library("RNOmni")
library(Hmisc)
library(purrr)
library(tidyr)
library(ggplot2)

analysis_path <-'~/REWOD/DERIVATIVES/ANALYSIS/hedonic/GLM-04/group_covariates'

setwd(analysis_path)

#_____________LIKING____________#
od_noOd_lik <- read.delim(file.path(analysis_path, "Odor-NoOdor_lik_meancent.txt"))
od_noOd_lik = rename(od_noOd_lik, c("subj"="subj","lik"="od_noOd_lik"))
pres_lik <- read.delim(file.path(analysis_path, "Odor_presence_lik_meancent.txt"))
pres_lik = rename(pres_lik, c("subj"="subj","lik"="pres_lik"))
r_c_lik <- read.delim(file.path(analysis_path, "reward-control_lik_meancent.txt"))
r_c_lik = rename(r_c_lik, c("subj"="subj","lik"="r_c_lik"))
r_n_lik <- read.delim(file.path(analysis_path, "reward-neutral_lik_meancent.txt"))
r_n_lik = rename(r_n_lik, c("subj"="subj","lik"="r_n_lik"))

lik = Reduce(function(x,y) merge(x = x, y = y, by = "subj", all = TRUE), list(od_noOd_lik, pres_lik, r_c_lik, r_n_lik))


#_____________LIKING___RANKNORM_________#
od_noOd_lik_rank <- read.delim(file.path(analysis_path, "Odor-NoOdor_lik_rank.txt"))
od_noOd_lik_rank = rename(od_noOd_lik_rank, c("subj"="subj","lik"="od_noOd_lik"))
pres_lik_rank <- read.delim(file.path(analysis_path, "Odor_presence_lik_rank.txt"))
pres_lik_rank = rename(pres_lik_rank, c("subj"="subj","lik"="pres_lik"))
r_c_lik_rank <- read.delim(file.path(analysis_path, "reward-control_lik_rank.txt"))
r_c_lik_rank = rename(r_c_lik_rank, c("subj"="subj","lik"="r_c_lik"))
r_n_lik_rank <- read.delim(file.path(analysis_path, "reward-neutral_lik_rank.txt"))
r_n_lik_rank = rename(r_n_lik_rank, c("subj"="subj","lik"="r_n_lik"))

lik_rank = Reduce(function(x,y) merge(x = x, y = y, by = "subj", all = TRUE), list(od_noOd_lik_rank, pres_lik_rank, r_c_lik_rank, r_n_lik_rank))

# Plot density of non-transformed measurement
lik %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 

# Plot density of transformed measurement

lik_rank %>%
  keep(is.numeric) %>%
  gather() %>%
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density()


#check correlation (diagonal)
cor(lik_rank, lik)  #or spearman
cor(lik_rank, lik, method="kendall")  #for ranks


#_____________INTENSITY____________#
od_noOd_int <- read.delim(file.path(analysis_path, "Odor-NoOdor_int_meancent.txt"))
od_noOd_int = rename(od_noOd_int, c("subj"="subj","int"="od_noOd_int"))
pres_int <- read.delim(file.path(analysis_path, "Odor_presence_int_meancent.txt"))
pres_int = rename(pres_int, c("subj"="subj","int"="pres_int"))
r_c_int <- read.delim(file.path(analysis_path, "reward-control_int_meancent.txt"))
r_c_int = rename(r_c_int, c("subj"="subj","int"="r_c_int"))
r_n_int <- read.delim(file.path(analysis_path, "reward-neutral_int_meancent.txt"))
r_n_int = rename(r_n_int, c("subj"="subj","int"="r_n_int"))

int = Reduce(function(x,y) merge(x = x, y = y, by = "subj", all = TRUE), list(od_noOd_int, pres_int, r_c_int, r_n_int))


#_____________INTENSITY___RANKNORM_________#
od_noOd_int_rank <- read.delim(file.path(analysis_path, "Odor-NoOdor_int_rank.txt"))
od_noOd_int_rank = rename(od_noOd_int_rank, c("subj"="subj","int"="od_noOd_int"))
pres_int_rank <- read.delim(file.path(analysis_path, "Odor_presence_int_rank.txt"))
pres_int_rank = rename(pres_int_rank, c("subj"="subj","int"="pres_int"))
r_c_int_rank <- read.delim(file.path(analysis_path, "reward-control_int_rank.txt"))
r_c_int_rank = rename(r_c_int_rank, c("subj"="subj","int"="r_c_int"))
r_n_int_rank <- read.delim(file.path(analysis_path, "reward-neutral_int_rank.txt"))
r_n_int_rank = rename(r_n_int_rank, c("subj"="subj","int"="r_n_int"))

int_rank = Reduce(function(x,y) merge(x = x, y = y, by = "subj", all = TRUE), list(od_noOd_int_rank, pres_int_rank, r_c_int_rank, r_n_int_rank))


# Plot density of non-transformed measurement
int %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 

# Plot density of transformed measurement

int_rank %>%
  keep(is.numeric) %>%
  gather() %>%
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density()


#check correlation (diagonal)
cor(int_rank, int)  #or spearman
cor(int_rank, int, method="kendall")  #for ranks



