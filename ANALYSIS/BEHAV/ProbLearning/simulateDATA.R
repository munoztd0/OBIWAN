## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


pacman::p_load(tidyverse, plyr,dplyr,readr,rlist, parallel, effectsize) #whatchout to have tidyBF 0.2.0
pacman::p_load_gh("munoztd0/hBayesDM") # your need to install this modfied version of hBayesDM where I implement an alternate model of the PST task 


options(mc.cores = parallel::detectCores()) #to mulithread

# SETUP ------------------------------------------------------------------

task = 'PBlearning'


# Set working directory #change here if the switchdrive is not on your home folder
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV/T0') 

setwd(analysis_path)

# open dataset 
full <- read_csv("~/OBIWAN/DERIVATIVES/BEHAV/PBLearning.csv")


#load("~/OBIWAN/DERIVATIVES/BEHAV/PBL_OBIWAN_T0.RData") # if you dont want ot recompute and go directly to stats


# Preprocess --------------------------------------------------------------

data  <- subset(full, Session == 1) #subset #only session one 
data  <- subset(data, Phase == 'proc1') #only learning phase

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


bs = ddply(data, .(Subject, imcor), summarise, acc = mean(Stim.ACC, na.rm = TRUE)) 

# Crtierium chose A at 65%, C at 60% and E at 50% and min 30 trials.
bs_wide <- spread(bs, imcor, acc)
bs_wide$pass = c(1:length(bs_wide$Subject)) #initialize variable
for (i in  1:length(bs_wide$Subject)) {
  if((bs_wide$A[i] >= 0.65) && (bs_wide$C[i] >=  0.60) && (bs_wide$E[i] >= 0.50 )) 
  {bs_wide$pass[i] = 1} 
  else {bs_wide$pass[i] = 0}
}

data = merge(data, bs_wide[ , c("Subject", "pass")], by = "Subject", all.x=TRUE)

data = subset(data, pass == 1)

dataclean <- select(data, c(subjID, type, Group))

#check that nobody has more than 200 trial
count_trial = dataclean %>% group_by(subjID) %>%tally()




# simulate behavior -------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/ProbLearning/simulatePST.R', echo=TRUE)
load("~/OBIWAN/DERIVATIVES/BEHAV/PBL_OBIWAN_T0.RData")
s = unique(dataclean$subjID)
Nrep = 1
simDATA = c()
for (i in s) {
  print(paste('simulate sub', i, ':', Nrep, 'times'))
  param = subset(df, subjID == i)
  dataS = subset(dataclean, subjID == i)
  listIND <- vector(mode = "list", length = Nrep)
  d = simulatePST(param$alpha_pos, param$beta,dataS)
  simDATA = rbind(simDATA, d)
}


# Re-estimate model's parameters  ----------------------------------------------------------
#run Probabilistic Learning Task -- Q-learning (following Frank et al. (2007))
#type ?pst_gain_Q for more info

### Group Lean
Lean_data  <- subset(simDATA, Group == 'C')
#Q-learning via Rescorla-Wagner update rule with one learning speed: αlpha.
Lean_output <- pst_gain_Q(data = Lean_data, niter = 50000, nwarmup = 1000, nchain = 4, ncore = 8, nthin = 1, inits = "random", indPars = "mean", modelRegressor = F, vb = T, inc_postpred = F, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)


mod = Lean_output

## Visualize
plot(mod, type = 'trace', inc_warmup=T) #The trace plots indicate that MCMC samples are indeed well mixed and converged, which is consistent with their R^ values #grey area is the burn in samples

#Visualize individual parameters
# plotInd(mod, "alpha_pos")  
# plotInd(mod, "beta")  

# Check Rhat values (all Rhat values should be less than or equal to 1.1)
#rhat(mod)

# Plot the posterior distributions of the hyper-parameters (distributions should be unimodal)
#densityPlot(mod$parVals$mu_alpha_pos)
#densityPlot(mod$parVals$mu_beta)


### Group Obese
Obese_data  <- subset(simDATA, Group == 'O')
#Q-learning via Rescorla-Wagner update rule with one learning speed: αlpha.
Obese_output <- pst_gain_Q(data = Obese_data, niter = 5000, nwarmup = 1000,nchain = 4, ncore = 8,nthin = 1,inits = "random", indPars = "mean", modelRegressor = F, vb = T, inc_postpred = F, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

mod = Obese_output

## Visualize
plot(mod, type = 'trace', inc_warmup=T) #The trace plots indicate that MCMC samples are indeed well mixed and converged, which is consistent with their R^ values #grey area is the burn in smaples

#Visualize individual parameters
# plotInd(mod, "beta_pos")  
# plotInd(mod, "beta")  

# Check Rhat values (all Rhat values should be less than or equal to 1.1)
#rhat(mod)

# Plot the posterior distributions of the hyper-parameters (distributions should be unimodal)
#densityPlot(mod$parVals$mu_beta_pos)
#densityPlot(mod$parVals$mu_beta)



# check correlation between true participant's parameters and their  --------
sim1 = Lean_output$allIndPars
sim2 = Obese_output$allIndPars
dfsim = rbind(sim1, sim2)
dfsim$group = ifelse(dfsim$subjID > 199, "obese", "lean")
dfsim$group = as.factor(dfsim$group); dfsim$group  <- relevel(dfsim$group , "obese")

save(dfsim, file = "PBL_OBIWAN_T0_sim.RData")
dfsim = output$allIndPars
dfsim$alphaO = df$alpha_pos
dfsim$betaO = df$beta
library("ggpubr")
ggscatter(dfsim, x = "alphaO", y = "alpha_pos", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "estimated", ylab = "true")

ggscatter(dfsim, x = "betaO", y = "beta", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "estimated", ylab = "true")


 