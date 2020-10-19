## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, plyr,dplyr,readr, car, BayesFactor, tidyBF, sjmisc, parallel)
options(mc.cores = parallel::detectCores()) #to mulithread
#install.packages("~/Desktop/hBayesDM.tar.xz", repos = NULL) # your need to install this modfied version of hBayesDM where I implement a model of the PST task with one learning rate
library(hBayesDM) #again only load after your installed my version of hBayesDM
# SETUP ------------------------------------------------------------------

task = 'PBlearning'


# Set working directory #change here if the switchdrive is not on your home folder
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

# open dataset 
full <- read_csv("~/OBIWAN/DERIVATIVES/BEHAV/PBLearning.csv")



# Preprocess --------------------------------------------------------------

data  <- subset(full, Session == 1) #subset #only session one 
data  <- subset(data, Phase == 'proc1') #only learning phase
data  <- subset(data, Trial <= 30) #only first 30 trials 

#factorize and rename
data$type = as.factor(revalue(data$imcor, c(A="AB", C="CD", E="EF")))
data$reward = revalue(data$feedback, c(Negatif=0, Positif=1))
data$side = revalue(data$Stim.RESP, c(x='L', n='R'))
data$subjID = data$Subject

#This loop is there to transform everything into one column "choice"
#this column takes a 1 if the action was to choose either A, C or E 
#and takes 0 if the response is either B, D or F (and that independently of the side)

data$choice = c(1:length(data$Trial)) #initialize variable
for (i in  1:length(data$Trial)) {
  if((data$side[i] == 'L')&(data$img[i] == 'A' || data$img[i] == 'C' || data$img[i] == 'E')) {
    data$choice[i] = 1
  } else if ((data$side[1] == 'R')&(data$imd[i] == 'A' || data$imd[i] == 'C' || data$imd[i] == 'E')) {
    data$choice[i] = 1}
  else {
    data$choice[i] = 0}
}

data$reward = as.numeric(data$reward)
data$type = revalue(data$type, c(AB=12, CD=34, EF=56))
data$type = as.numeric(as.character(data$type))

dataclean <- select(data, c(subjID, type, choice, reward, Group))

#check that everybody has 10 trial for each type (3x10)
count_trial = dataclean %>% group_by(subjID, type) %>%tally()

# Create general_info
general_info <- data.frame(subjs=dataclean$subjID,
      n_subj=length(unique(dataclean$subjID)), 
      t_subjs=30, 
      t_max=30) 

x  = pst_preprocess_func2(dataclean, general_info)
pst_preprocess_func2 <- function(raw_data, general_info) {
  # Currently class(raw_data) == "data.table"
  
  # Use general_info of raw_data
  subjs   <- general_info$subjs
  n_subj  <- general_info$n_subj
  t_subjs <- general_info$t_subjs
  t_max   <- general_info$t_max
  
  # Initialize (model-specific) data arrays
  option1 <- array(-1, c(n_subj, t_max))
  option2 <- array(-1, c(n_subj, t_max))
  choice  <- array(-1, c(n_subj, t_max))
  reward  <- array(-1, c(n_subj, t_max))
  
  # Write from raw_data to the data arrays
  for (i in 1:n_subj) {
    subj <- subjs[i]
    t <- t_subjs[i]
    DT_subj <- raw_data[raw_data$subjid == subj]
    
    option1[i, 1:t] <- DT_subj$type %/% 10
    option2[i, 1:t] <- DT_subj$type %% 10
    choice[i, 1:t]  <- DT_subj$choice
    reward[i, 1:t]  <- DT_subj$reward
  }
  
  # Wrap into a list for Stan
  data_list <- list(
    N       = n_subj,
    T       = t_max,
    Tsubj   = t_subjs,
    option1 = option1,
    option2 = option2,
    choice  = choice,
    reward  = reward
  )
  
  # Returned data_list will directly be passed to Stan
  return(data_list)
}


library(rstan)
options(mc.cores = parallel::detectCores()) #to mulithread
file = '/home/davidM/Desktop/hBayesDM/commons/stan_files/pst_gain_Q.stan'
fit1 <- stan(file = file, iter = 10, verbose = FALSE) 
print(fit1)
fit2 <- stan(fit = fit1, iter = 10000, verbose = FALSE) 