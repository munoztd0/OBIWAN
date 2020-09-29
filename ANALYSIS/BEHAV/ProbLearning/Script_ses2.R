## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, plyr,dplyr, hBayesDM,readr, car, BayesFactor)
options(mc.cores = parallel::detectCores())

# SETUP ------------------------------------------------------------------

task = 'PBlearning'


# Set working directory #change here if the switchdrive is not on your home folder
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/') 
figures_path  <- file.path('~/OBIWAN/Fichiers résultats NORA/') 

setwd(analysis_path)

# open dataset 

full <- read_csv("~/Switchdrive/OBIWAN (2)/Fichiers résultats NORA/DataNora_MF.csv")
#subset #only group obese 
data  <- subset(full, Session == 1) #only session 1
data  <- subset(data, Phase == 'proc1') #only learning for now

data$type = as.factor(revalue(data$imcor, c(A="AB", C="CD", E="EF")))
data$reward = revalue(data$feedback, c(Negatif=0, Positif=1))
data$side = revalue(data$Stim.RESP, c(x='L', n='R'))
data$subjID = data$Subject

#soo thus function is there to transform everything into one column "choice"
#this column takes a 1 if the action was to choose either A, C or E 
#and takes 0 if the response is either B, D or F (and that independently of the side)
#start variable
data$choice = c(1:length(data$Trial))
for (i in  1:length(data$Trial)) {
  if((data$side[i] == 'L')&(data$img[i] == 'A' || data$img[i] == 'C' || data$img[i] == 'E')) {
    data$choice[i] = 1
  } else if ((data$side[1] == 'R')&(data$imd[i] == 'A' || data$imd[i] == 'C' || data$imd[i] == 'E')) {
    data$choice[i] = 1
  }
  else {
    data$choice[i] = 0
  }
}

data$reward = as.numeric(data$reward)
data$type = revalue(data$type, c(AB=12, CD=34, EF=56))
data$type = as.numeric(as.character(data$type))

dataclean <- select(data, c(subjID, type, choice, reward, Group))

### --------------- Analysis -------
#run Probabilistic Learning Task -- Q-learning with two learning rates (function from from M. J. Frank et al. (2007))
source('~/Switchdrive/OBIWAN (2)/Fichiers résultats NORA/Q-learning.R', echo=FALSE)
output <- pst_gainloss_Q(data = dataclean,niter = 20000,nwarmup = 10000,nchain = 4,ncore = 4,nthin = 1,inits = "random",indPars = "median",modelRegressor = FALSE,vb = FALSE,inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1,max_treedepth = 10)
#indPars = "mean" can also choose median or mode
pst_gain_Q(data = dataclean,niter = 20000,nwarmup = 10000,nchain = 4,ncore = 4,nthin = 1,inits = "random",indPars = "median",modelRegressor = FALSE,vb = FALSE,inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1,max_treedepth = 10)
# Visually check convergence of the sampling chains (should like like 'hairy caterpillars')
plot(output, type = 'trace') #The trace plots indicate that MCMC samples are indeed well mixed and converged, which is consistent with their R^ values

#Visualize individual parameters
plotInd(output, "alpha_pos")  
plotInd(output, "alpha_neg")  
plotInd(output, "beta")  

# Check Rhat values (all Rhat values should be less than or equal to 1.1)
rhat(output)

# Plot the posterior distributions of the hyper-parameters (distributions should be unimodal)
#plot(output)
densityPlot(output$parVals$mu_alpha_pos)
densityPlot(output$parVals$mu_alpha_neg)
densityPlot(output$parVals$mu_beta)

# Show the LOOIC model fit estimates
printFit(output)

#Compare  groups!
#create df
for (i in  1:length(output$allIndPars$subjID)) {
  if(output$allIndPars$subjID[i] > 199) {
    output$allIndPars$subjID[i] = 'obese'
  }
  else {
    output$allIndPars$subjID[i] = 'control'
  }
}
output$allIndPars$group = as.factor(output$allIndPars$subjID)

#frequentist
classical.test = t.test(alpha_pos ~ group, data = output$allIndPars, var.eq = FALSE)
classical.test
# Welch Two Sample t-test
# 
# data:  alpha_pos by group
# t = 1.7721, df = 47.535, p-value = 0.08279
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.001173411  0.018569669
# sample estimates:
#   mean in group control   mean in group obese 
# 0.1735750             0.1648769 
#bayesian 
bf = ttestBF(formula = alpha_pos ~ group, data = output$allIndPars)
bf
# Bayes factor analysis
# --------------
#   [1] Alt., r=0.707 : 1.110036 ±0%
# 
# Against denominator:
#   Null, mu1-mu2 = 0 

#frequentist
classical.test = t.test(alpha_neg ~ group, data = output$allIndPars, var.eq = FALSE)
classical.test

# Welch Two Sample t-test
# 
# data:  alpha_neg by group
# t = -0.74101, df = 61.278, p-value = 0.4615
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.003737762  0.001716410
# sample estimates:
#   mean in group control   mean in group obese 
# 0.02562123            0.02663190 
#bayesian 
bf = ttestBF(formula = alpha_neg ~ group, data = output$allIndPars)
bf
# Bayes factor analysis
# --------------
#   [1] Alt., r=0.707 : 0.287437 ±0.03%
# 
# Against denominator:
#   Null, mu1-mu2 = 0 

#frequentist
classical.test = t.test(beta ~ group, data = output$allIndPars, var.eq = FALSE)
classical.test
# Welch Two Sample t-test
# 
# data:  beta by group
# t = 1.2894, df = 64.905, p-value = 0.2018
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.06553619  0.30429918
# sample estimates:
#   mean in group control   mean in group obese 
# 3.677060              3.557679 
#bayesian 
bf = ttestBF(formula = beta ~ group, data = output$allIndPars)
bf
# Bayes factor analysis
# --------------
#   [1] Alt., r=0.707 : 0.4386925 ±0.02%
# 
# Against denominator:
#   Null, mu1-mu2 = 0 

#save RData for cluster computing
# save.image(file = "RL_NORA.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

## End -> need to do BMS still

# control  <- subset(dataclean, Group == 'C')
# obese  <- subset(dataclean, Group == 'O')
# 
# output_con <- pst_gainloss_Q(data = control,niter = 2000,nwarmup = 1000,nchain = 4,ncore = 4,nthin = 1,inits = "random",indPars = "median",modelRegressor = FALSE,vb = FALSE,inc_postpred = FALSE,adapt_delta = 0.95, stepsize = 1,max_treedepth = 10)
# output_obe <- pst_gainloss_Q(data = obese,niter = 2000,nwarmup = 1000,nchain = 4,ncore = 4,nthin = 1,inits = "random",indPars = "median",modelRegressor = FALSE,vb = FALSE,inc_postpred = FALSE,adapt_delta = 0.95, stepsize = 1,max_treedepth = 10)
# # evaluate the group difference on the lr parameters by examining the posterior distribution of group mean differences.
# #pos
# diffDist = output_con$parVals$mu_alpha_pos - output_obe$parVals$mu_alpha_pos  # group1 - group2
# HDIofMCMC( diffDist )  # Compute the 95% Highest Density Interval (HDI).
# plotHDI( diffDist )    # plot the group mean differences
# #diff doesn't contain 0!

