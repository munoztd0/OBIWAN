## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# TODO do correlatin between parameters
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman", "devtools")
  library(devtools)
  library(pacman)
}

if(!require(tidyBF)) {
  install_version("tidyBF", version = "0.3.0")
  library(tidyBF)
}

pacman::p_load(tidyverse, plyr,dplyr,readr, car, BayesFactor, sjmisc, parallel, effectsize, pracma) #whatchout to have tidyBF 0.3.0

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

dataclean <- select(data, c(subjID, type, choice, reward, Group))

#check that nobody has more than 200 trial
count_trial = dataclean %>% group_by(subjID) %>%tally()


# Estimate model's parameters and compare model's fit ----------------------------------------------------------
set.seed(666)
Nrep = 1000;
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/ProbLearning/PST_Q_learning.R', echo=TRUE)

# model1 : RW Q-Learning with one learning rate and a softmax inverse temperature -----------------------------------------------------------------
k = 2
subj = unique(dataclean$subjID)
alpha = c(); beta = c(); nll= c(); ID = c(); group = c(); trials = c()
LB = c(0, 0); UB = c(1, 10) # parameters lower and upper bounds
for (s in subj) {
  data = subset(dataclean, subjID == s)
  param_rep = c(); nll_rep = c()
  for (i in  1:Nrep) {
    x0 = c(rand(), 10*rand()); #different parameter initial values to avoid local minima
    f = fmincon(x0=x0,fn=PST_q, data = data, lb = LB, ub = UB) #optimize
    param_rep = rbind(param_rep, f$par); nll_rep = rbind(nll_rep, f$value)
  }
  pos = which.min(nll_rep)
  alpha = rbind(alpha,param_rep[pos,1]); beta = rbind(beta,param_rep[pos,2]); nll = rbind(nll,nll_rep[pos]); ID = rbind(ID,s); group = rbind(group, ifelse(s > 200, 'obese', 'lean')); trials = rbind(trials,length(data$subjID))
  print(paste('done subj', s))
}

df1 = cbind(ID, alpha, beta, nll, group, trials)
colnames(df1) = c('ID', 'alpha', 'beta', 'nll', 'group', 'trial'); 
df1 = as_tibble(df1); df1$group = as.factor(df1$group); df1$ID =as.factor(df1$ID)
df1[] <- lapply(df1, function(x) {if(is.character(x)) as.numeric(as.character(x)) else x})    



# model2 : RW Q-Learning with dual learning rate (gain and loss) and  softmax inverse temperature -----------------------------------------------------------------

k = 3 # number of free parameteres
subj = unique(dataclean$subjID)
alphaG = c(); alphaL = c(); beta = c(); nll= c(); ID = c(); group = c(); trials = c()
LB = c(0, 0, 0); UB = c(1, 1, 10) # parameters lower and upper bounds
for (s in subj) {
  data = subset(dataclean, subjID == s)
  param_rep = c(); nll_rep = c()
  for (i in  1:Nrep) {
    x0 = c(rand(), rand(), 10*rand()); #different parameter initial values to avoid local minima
    f = fmincon(x0=x0,fn=PST_q_dual, data = data, lb = LB, ub = UB) #optimize
    param_rep = rbind(param_rep, f$par); nll_rep = rbind(nll_rep, f$value)
  }
  pos = which.min(nll_rep)
  alphaG = rbind(alphaG,param_rep[pos,1]); alphaL = rbind(alphaL,param_rep[pos,2]); beta = rbind(beta,param_rep[pos,3]); nll = rbind(nll,nll_rep[pos]); ID = rbind(ID,s); group = rbind(group, ifelse(s > 200, 'obese', 'lean')); trials = rbind(trials,length(data$subjID))
  print(paste('done subj', s))
}

df2 = cbind(ID, alphaG, alphaL, beta, nll, group, trials)
colnames(df2) = c('ID', 'alpha_gain', 'alpha_loss','beta', 'nll', 'group', 'trials'); 
df2 = as_tibble(df2); df2$group =as.factor(df2$group); df2$ID =as.factor(df2$ID)
df2[] <- lapply(df2, function(x) {if(is.character(x)) as.numeric(as.character(x)) else x})    


# Bayesian model comparison for group studies ---------------------------------------------------------------- see Stephan et al., 2009

df1$BIC =  k*log(df1$trial) -2*(-df1$nll) #Bayesian information criterion for each subj
df2$BIC = k*log(df1$trial) -2*(-df2$nll) #Bayesian information criterion for each subj


model_BIC = cbind(df1$BIC, df2$BIC)

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/ProbLearning/VBA.R', echo=TRUE)
#Variational Bayesian Analysis (Daunizeau & Rigoux)
#a list with the posterior estimates of the Dirichlet parameters (alpha), the expected model frequencies (r), the exceedance probabilities (xp), the Bayesian Omnibus Risk (bor), and the protected exceedance probabilities (pxp). 
VBA = VB_bms(-model_BIC/2) ; VBA  #model 2 is "better"

df = df2
save(df, file = "PBL_OBIWAN_T0.RData")


source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/cohen_d_ci.R', echo=F)
#### For alpha gain

# unpaired Bayesian t-test
BF_alphaG = tidyBF::bf_ttest(df, group, alpha_gain, output = "dataframe", paired = F, iterations = 50000); BF_alphaG$bf10; BF_alphaG$estimate; BF_alphaG$conf.low; BF_alphaG$conf.high

# unpaired frequentist t-test
TtestG = t.test(lean$alpha_gain, obese$alpha_gain); TtestG
cohen_d_ci(lean$alpha_gain, obese$alpha_gain,  paired=F, var.equal=F, conf.level=0.95)

#### For alpha loss

# unpaired Bayesian t-test
BF_alphaL = tidyBF::bf_ttest(df, group, alpha_loss, output = "dataframe", paired = F, iterations = 50000); BF_alphaL$bf10; BF_alphaL$estimate; BF_alphaL$conf.low; BF_alphaL$conf.high
lean = subset(df, group == 'lean'); obese = subset(df, group == 'obese'); 

# unpaired frequentist t-test
TtestL = t.test(lean$alpha_loss, obese$alpha_loss); TtestL
cohen_d_ci(lean$alpha_loss, obese$alpha_loss,  paired=F, var.equal=F, conf.level=0.95)

#### For beta

# unpaired Bayesian t-test
BF_beta = tidyBF::bf_ttest(df, group, beta, output = "dataframe", paired = F, iterations = 50000); BF_beta$bf10; BF_beta$estimate; BF_beta$conf.low; BF_beta$conf.high

# unpaired frequentist t-test
TtestB = t.test(lean$beta, obese$beta); TtestB
cohen_d_ci(lean$beta, obese$beta,  paired=F, var.equal=F, conf.level=0.95)


df %>% ggplot(aes(x = beta, color = group)) +
  geom_boxplot()






# model fit ---------------------------------------------------------------

BIC1 = k*log(length(df1$ID)) -2*mean(-df1$nll); BIC1 # Bayesian information criterion k*ln(n) - 2*logLik
AIC1 = 2*k - 2*mean(-df1$nll); AIC1 #AIC=2k-2*logLik


BIC2 = k*log(length(df2$ID)) -2*mean(-df2$nll); BIC2 # Bayesian information criterion k*ln(n) - 2*logLik
AIC2 = 2*k - 2*mean(-df2$nll); AIC2 #AIC=2k-2*logLik
