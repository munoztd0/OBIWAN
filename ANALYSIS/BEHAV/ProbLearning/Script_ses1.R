## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, plyr,dplyr,readr, car, BayesFactor, tidyBF, sjmisc, parallel, lsr)
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



### ---------------- Estimate model's parameters and compare model's fit ----------------------------------------------------------
#run Probabilistic Learning Task -- Q-learning (following Frank et al. (2007))
#check the hBayesDM::pst_gain_Q for more info
#Compare two groups in a Bayesian fashion (Ahn et al., 2014)


#Q-learning via Rescorla-Wagner update rule with one learning speed: αlpha.
output1 <- pst_gain_Q(data = dataclean, niter = 5000, nwarmup = 1000, nchain = 4, ncore = 8, nthin = 1, inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

# 10'000 per model ... x 4 chains.. so 40'000 itertaions  X 4 model, where 1 chain ~ 7min on my dedicated GPU cores and ~25 min on my normal CPU cores.. so prepare your expectations ..

### Group Lean
Lean_data  <- subset(dataclean, Group == 'C')
#Q-learning via Rescorla-Wagner update rule with one learning speed: αlpha.
Lean_output1 <- pst_gain_Q(data = Lean_data, niter = 10000, nwarmup = 500, nchain = 4, ncore = 8, nthin = 1, inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

#Q-learning via Rescorla-Wagner update rule with two different learning speeds: α-Gain referring to player’s sensitivity to rewards and α-Loose referring to player’s sensitivity to punishments.
Lean_output2 <- pst_gainloss_Q(data = Lean_data, niter = 10000, nwarmup = 500, nchain = 4, ncore = 8, nthin = 1, inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

#BIC; k*ln(n) - 2*logLik
BIC11 = 2*log(length(Lean_output1$allIndPars$subjID)) - 2*mean(Lean_output1$parVals$log_lik); BIC11
BIC21 = 3*log(length(Lean_output2$allIndPars$subjID)) - 2*mean(Lean_output2$parVals$log_lik); BIC21

mod = Lean_output1
extract_ic(mod) #check the LOOIC in more details


## Visualize
plot(mod, type = 'trace', inc_warmup=T) #The trace plots indicate that MCMC samples are indeed well mixed and converged, which is consistent with their R^ values #grey area is the burn in samples

#Visualize individual parameters
# plotInd(mod, "beta_pos")  
# plotInd(mod, "beta")  

# Check Rhat values (all Rhat values should be less than or equal to 1.1)
#rhat(mod)

# Plot the posterior distributions of the hyper-parameters (distributions should be unimodal)
#densityPlot(mod$parVals$mu_beta_pos)
#densityPlot(mod$parVals$mu_beta)


### Group Obese
Obese_data  <- subset(dataclean, Group == 'O')
#Q-learning via Rescorla-Wagner update rule with one learning speed: αlpha.
Obese_output1 <- pst_gain_Q(data = Obese_data, niter = 10000, nwarmup = 500,nchain = 4, ncore = 8,nthin = 1,inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

#Q-learning via Rescorla-Wagner update rule with two different learning speeds: α-Gain referring to player’s sensitivity to rewards and α-Loose referring to player’s sensitivity to punishments.
Obese_output2 <- pst_gainloss_Q(data = Obese_data, niter = 10000, nwarmup = 500, nchain = 4, ncore = 8,nthin = 1,inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

#BIC approx ; k*ln(n) - 2*logLik
BIC12 = 2*log(length(Obese_output1$allIndPars$subjID)) - 2*mean(Obese_output1$parVals$log_lik); BIC12
BIC22 = 3*log(length(Obese_output2$allIndPars$subjID)) - 2*mean(Obese_output2$parVals$log_lik); BIC22

mod = Obese_output1
extract_ic(mod) #check the LOOIC in more details

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


#save RData so I don't have to recompute everytime
# save.image(file = "PBL_OBIWAN_T0.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)


# Compare groups ----------------------------------------------------------

## After model fitting is complete for both groups, evaluate the group difference by examining the posterior distribution of group mean differences.
group1 = Lean_output1$parVals
group2 = Obese_output1$parVals

### For alpha
diffDist = group1$mu_alpha_pos - group2$mu_alpha_pos  # lean - obese 
HDIofMCMC(diffDist)  # Compute the 95% Highest Density Interval (HDI). 
#plotHDI(diffDist)    # plot the group mean differences
#contains 0 so not signif


### For Beta
diffDist = group1$mu_beta - group2$mu_beta  # lean - obese 
HDIofMCMC(diffDist)  # Compute the 95% Highest Density Interval (HDI). 
#plotHDI(diffDist)  # plot the group mean differences
#contains 0 so not signif




ggplot(df, aes(x = n, fill = Group)) +
  #geom_histogram() + # two-sample t-test results in an expression
  geom_density(alpha = 0.5) +
  xlim(range(df$n)+ c(-10, 0.02)) +
  labs(subtitle = bf_two_sample_ttest(df, Group, n, output = "alternative"), x ='trials') 














group1 = Lean_output1$allIndPars
group2 = Obese_output1$allIndPars
df = rbind(group1, group2)
df$group = ifelse(df$subjID > 199, "obese", "lean")

#### For alpha

# unpaired Bayesian t-test
BF_alpha = ttestBF(df$alpha_pos[df$group=='lean'], df$alpha_pos[df$group=='obese'], paired=FALSE)
BF_alpha <- recompute(BF_alpha, iterations = 50000)
BF_alpha

ggplot(df, aes(x = alpha_pos, fill = group)) + geom_density(alpha = 0.5) +
   xlim(range(df$alpha_pos)+ c(-0.02, 0.02))


## Sample from the corresponding posterior distribution
samples = ttestBF(df$alpha_pos[df$group=='lean'], df$alpha_pos[df$group=='obese'],                 paired=FALSE, posterior = TRUE, iterations = 5000)

plot(samples[,"mu"], trace = FALSE)


#Frequentist
classical.test = t.test(df$alpha_pos[df$group=='lean'], df$alpha_pos[df$group=='obese'], paired=FALSE, var.eq = FALSE)
classical.test

cohensD(alpha_pos ~ group, data = df)



#### For beta

# unpaired Bayesian t-test
BF_beta = ttestBF(df$beta[df$group=='lean'], df$beta[df$group=='obese'], paired=FALSE)
BF_beta <- recompute(BF_beta, iterations = 50000)
BF_beta

ggplot(df, aes(x = beta, fill = group)) + geom_density(beta = 0.5) +
  xlim(range(df$beta)+ c(-0.02, 0.02))


## Sample from the corresponding posterior distribution
samples = ttestBF(df$beta[df$group=='lean'], df$beta[df$group=='obese'],                 paired=FALSE, posterior = TRUE, iterations = 5000)

plot(samples[,"mu"], trace = FALSE)


#Frequentist
classical.test = t.test(df$beta[df$group=='lean'], df$beta[df$group=='obese'], paired=FALSE, var.eq = FALSE)
classical.test

cohensD(beta ~ group, data = df)




### For Beta
diffDist = Lean_output1$parVals$mu_beta - Obese_output1$parVals$mu_beta  # lean - obese 
HDIofMCMC( diffDist )  # Compute the 95% Highest Density Interval (HDI). 
plotHDI( diffDist )    # plot the group mean differences
#contains 0 so not signif




#Beta
#frequentist
classical.test = t.test(beta ~ group, data = output$allIndPars, var.eq = FALSE)
classical.test

#bayesian 
bf = ttestBF(formula = beta ~ group, data = output$allIndPars)
bf
# Bayes factor analysis


#save RData for cluster computing
# save.image(file = "RL_NORA.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

## End -> need to do BMS still

control  <- subset(dataclean, Group == 'C')
obese  <- subset(dataclean, Group == 'O')
# 
output_con <- pst_gainloss_Q(data = control,niter = 2000,nwarmup = 1000,nchain = 4,ncore = 4,nthin = 1,inits = "random",indPars = "median",modelRegressor = FALSE,vb = FALSE,inc_postpred = FALSE,adapt_delta = 0.95, stepsize = 1,max_treedepth = 10)
output_obe <- pst_gainloss_Q(data = obese,niter = 2000,nwarmup = 1000,nchain = 4,ncore = 4,nthin = 1,inits = "random",indPars = "median",modelRegressor = FALSE,vb = FALSE,inc_postpred = FALSE,adapt_delta = 0.95, stepsize = 1,max_treedepth = 10)
# evaluate the group difference on the lr parameters by examining the posterior distribution of group mean differences.
#pos
diffDist = output_con$parVals$mu_beta_pos - output_obe$parVals$mu_beta_pos  # group1 - group2
HDIofMCMC( diffDist )  # Compute the 95% Highest Density Interval (HDI).
plotHDI( diffDist )    # plot the group mean differences
#diff doesn't contain 0!

diffDist = output_con$parVals$mu_beta_neg - output_obe$parVals$mu_beta_neg  # group1 - group2
HDIofMCMC( diffDist )  # Compute the 95% Highest Density Interval (HDI).
plotHDI( diffDist )    # plot the group mean differences
#diff doesn't contain 0!

diffDist = output_con$parVals$mu_beta - output_obe$parVals$mu_beta  # group1 - group2
HDIofMCMC( diffDist )  # Compute the 95% Highest Density Interval (HDI).
plotHDI( diffDist )    # plot the group mean differences
#diff doesn't contain 0!
  
 



## After model fitting is complete for both groups, evaluate the group difference by examining the posterior distribution of group mean differences.
group1 = Lean_output1$parVals
group2 = Obese_output1$parVals

diffDist = group1$mu_beta_pos - group2$mu_beta_pos  # lean - obese 
HDIofMCMC( diffDist )  # Compute the 95% Highest Density Interval (HDI). 
plotHDI( diffDist )    # plot the group mean differences
#contains 0 so not signif



df = Obese_output1[["parVals"]][["beta_pos"]]
df = as_tibble(df)
colnames(df) = Obese_output1$allIndPars$subjID
data_long <- gather(df, factor_key=FALSE)
colnames(data_long) = c('subjID','beta_pos')

df = Lean_output1[["parVals"]][["beta_pos"]]
df = as_tibble(df)
colnames(df) = Lean_output1$allIndPars$subjID
data_long2 <- gather(df, factor_key=FALSE)
colnames(data_long2) = c('subjID','beta_pos')

summarySE(data = x, Lean_output2$allIndPars$subjID)