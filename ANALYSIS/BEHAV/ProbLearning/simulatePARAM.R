## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman", "devtools")
  library(devtools)
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




# simulate behavior -------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/ProbLearning/simulatePST.R', echo=TRUE)

# create data structure ----------------------------------------------


s = 500 #number of subjects to simulate
simDATA = c(); paramA = c(); paramB = c()
for (i in 1:s) {
  beta = runif(n = 1, min = 0, max = 10); paramB = rbind(paramB, beta) #rgamma(1, shape =4, scale =0.5)
  alpha = 1-rbeta(1, shape1=5, shape2=1.5); paramA = rbind(paramA, alpha)  #rbeta(1, shape1=5, shape2=1.5) 1-rbeta(1, shape1=5, shape2=1.5)
  subjID = rep(i, each=90)
  type = sample(rep(c(12, 34, 56), each=30))
  data = cbind(subjID, type); data = as_tibble(data)
  print(paste('simulate sub', i))
  d = simulatePST(alpha, beta ,data)
  simDATA = rbind(simDATA, d)
  #print(paste('done sub', i))
  
}
d$trial = 1:length(d$subjID)
data_long <- gather(d, option, ev, ev1:ev6, factor_key=TRUE)
data_long$option <- factor(data_long$option, levels = c("ev1", "ev3", "ev5", "ev2", "ev4", "ev6"))
data_long %>%
  ggplot(aes(x = trial, y = ev)) +
  geom_line(size=0.5) +
  #geom_line(aes(y=pe), color ='red',size=0.5) +
  ylim(0,1) +
  facet_wrap("option")

 # Re-estimate model's parameters  ----------------------------------------------------------
#run Probabilistic Learning Task -- Q-learning (following Frank et al. (2007))
#type ?pst_gain_Q for more info


#Q-learning via Rescorla-Wagner update rule with one learning speed: αlpha.
output <- pst_gain_Q(data = simDATA, niter = 50000, nwarmup = 1000, nchain = 4, ncore = 8, nthin = 1, inits = "random", indPars = "mean", modelRegressor = F, vb = T, inc_postpred = F, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)


mod = output

## Visualize
plot(mod, type = 'trace', inc_warmup=T) #The trace plots indicate that MCMC samples are indeed well mixed and converged, which is consistent with their R^ values #grey area is the burn in samples
dfsim = output$allIndPars
dfsim$betasim = paramB
dfsim$alphasim = paramA

library("ggpubr")
ggscatter(dfsim, x = "alpha_pos", y = "alphasim", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "estimated", ylab = "true")

ggscatter(dfsim, x = "beta", y = "betasim", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "estimated", ylab = "true")

#Visualize individual parameters
# plotInd(mod, "alpha_pos")  
# plotInd(mod, "beta")  

# Check Rhat values (all Rhat values should be less than or equal to 1.1)
#rhat(mod)

# Plot the posterior distributions of the hyper-parameters (distributions should be unimodal)
#densityPlot(mod$parVals$mu_alpha_pos)
#densityPlot(mod$parVals$mu_beta)



# check correlation between true participant's parameters and their  --------


save(dfsim, file = "PBL_OBIWAN_T0_sim.RData")



