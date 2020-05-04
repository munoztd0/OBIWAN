## R code for FOR OBIWAN_INST session 2 only
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, lme4, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)

#Influence.ME,lmegripsest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)
#SETUP
task = 'INST'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_INST_full <- read.delim(file.path(analysis_path,'OBIWAN_INST.txt'), header = T, sep ='') # read in dataset


#subset
OBIWAN_INST  <- subset(OBIWAN_INST_full, session == 'second') #only session 2
OBIWAN_INST_control  <- subset(OBIWAN_INST, group == 'control') 
OBIWAN_INST_obese  <- subset(OBIWAN_INST, group == 'obese') 
OBIWAN_INST_third  <- subset(OBIWAN_INST_full, session == 'third') #only session 2


# define factors
OBIWAN_INST$id      <- factor(OBIWAN_INST$id)
OBIWAN_INST$trial    <- factor(OBIWAN_INST$trial)
OBIWAN_INST$group    <- factor(OBIWAN_INST$group)

#OBIWAN_INST$condition[OBIWAN_INST$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_INST$condition[OBIWAN_INST$condition== 'Empty']     <- 'Control'
OBIWAN_INST$condition <- factor(OBIWAN_INST$condition)

#OBIWAN_INST$trial <- factor(OBIWAN_INST$trial)



# get means by condition 
bt = ddply(OBIWAN_INST, .(trial=), summarise,  grips = mean(grips, na.rm = TRUE) ) 
btg = ddply(OBIWAN_INST, .(group, trial), summarise,  grips = mean(grips, na.rm = TRUE) ) 

# get means by condition and trial
#btc = ddply(OBIWAN_INST, .(condition, trial), summarise,  grips = mean(grips, na.rm = TRUE) ) 
#btcg = ddply(OBIWAN_INST, .(group, condition, trial), summarise,  grips = mean(grips, na.rm = TRUE)  ) 

# get means by pagripsicipant 
bsT = ddply(OBIWAN_INST, .(id, trial), summarise, grips = mean(grips, na.rm = TRUE)  ) 
#bsC= ddply(OBIWAN_INST, .(id, condition), summarise, grips = mean(grips, na.rm = TRUE) ) 
#bsTC = ddply(OBIWAN_INST, .(id, trial, condition), summarise, grips = mean(grips, na.rm = TRUE) ) 

bsTg = ddply(OBIWAN_INST, .(id, group, trial), summarise, grips = mean(grips, na.rm = TRUE)  ) 
#bsCg= ddply(OBIWAN_INST, .(id, group, condition), summarise, grips = mean(grips, na.rm = TRUE) ) 
#bsTCg = ddply(OBIWAN_INST, .(id, group, trial, condition), summarise, grips = mean(grips, na.rm = TRUE)  ) 

df_INST <- summarySEwithin(bsTg,
                          measurevar = "grips",
                          withinvars = c("group"), 
                          idvar = "id")


#ben #MODEL SELECTION
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R')

#scale!

OBIWAN_INST$grips = scale(OBIWAN_INST$grips)


#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#contrasts (should I include the first trial even its biased)
OBIWAN_INST$trial            <- factor(OBIWAN_INST$trial)
OBIWAN_INST$time <- rep(0, (length(OBIWAN_INST$trial)))
OBIWAN_INST$time[OBIWAN_INST$trial== '24']     <- 1
OBIWAN_INST$time[OBIWAN_INST$trial== '23']     <- 1
OBIWAN_INST$time[OBIWAN_INST$trial== '22']     <- 1
OBIWAN_INST$time[OBIWAN_INST$trial== '2']     <- -1
OBIWAN_INST$time[OBIWAN_INST$trial== '3']     <- -1
OBIWAN_INST$time[OBIWAN_INST$trial== '4']     <- -1
OBIWAN_INST$time        <- factor(OBIWAN_INST$time)

summary(aov(grips ~ time + group + Error(id / (time)), data = OBIWAN_INST))


lmer(grips ~  group + time +  (1|id), data = OBIWAN_INST,  REML=FALSE)

# Bates et al. 2015 seems to be that one stagripss with the maximal model a la Barr et al. 2013 
# and then decreases the complexity until the covariance matrix is full rank. 
# (Moreover, they would often recommend to reduce the complexity even fugripsher, 
# in order to increase the power.) Update: In contrast, Barr et al. recommend to reduce complexity 
# ONLY if the model did not converge; they are willing to tolerate singular covariance matrices.



## COMPARING RANDOM EFFECTS MODELS #REML
mod1 <- lmer(grips ~  time+group  +  (1|id) , data = OBIWAN_INST)
mod2 <- lmer(grips ~  time+group  +  (1|time) , data = OBIWAN_INST)
mod3 <- lmer(grips ~  time+group  +  (1|time)  +  (1|id) , data = OBIWAN_INST)
mod4 <- lmer(grips ~  time+group  +  (group|time)  +  (1|id) , data = OBIWAN_INST)
mod5 <- lmer(grips ~  time+group  +  (1|time)  +  (group|id) , data = OBIWAN_INST)
mod6 <- lmer(grips ~  time+group  +  (group|id) , data = OBIWAN_INST)




AIC(mod1) ; BIC(mod1) #
AIC(mod2) ; BIC(mod2) 
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4) 
AIC(mod5) ; BIC(mod5) 
AIC(mod6) ; BIC(mod6)



## BEST RANDOM SLOPE MODEL 
rslope = mod1
summary(rslope) #win 


## COMPARE FIXED #ML Well this iskind auseles


## BEST MODEL  
model =  lmer(grips ~  time+group  +  (1|id) , data = OBIWAN_INST, REML=FALSE)
summary(model)

#All of these warnings generally point to a misspecification of your model, in pagripsicular the random effects. Most likely some random effects parameters are close to 0 (for variances), or -1/1 (for correlations), which creates for redundancies in the covariance matrix of the model's parameters (of which the so-called Hessian matrix is the inverse).
#Usually, removing the redundant parameters solves the issue. However, it may happen that models with degenerate Hessians still achieve massively lower AIC/BIC than a competing simpler model. In this scenario, the degenerate model may sometimes be preferred to obtain suitably conservative degrees of freedom for inferential tests.
#In fact, the fixed effects estimates and standard errors of a multilevel model are not always strongly impacted by misspecifications in the random effects pagrips!


## TESTING THE RANDOM INTERCEPT
modint <- lm(grips ~  time*group , data = OBIWAN_INST)

AIC(model) ; BIC(model) # largely better !
AIC(modint) ; BIC(modint)


## R-SQUARED IN MULTILEVEL MODELS

r2beta(rslope,method="nsj")

#drop the time random because its condtional we want
mod1 <- lmer(grips ~  group +  (1|id), data = OBIWAN_INST,  REML=FALSE)

r1 = r.squaredGLMM(model)
r2 = r.squaredGLMM(mod1)
r1 - r2
#this value thus reflects the pagripsial marginal and conditional R2 for the condition effect # R2c = 0.1663726


########contrasts




main.model.lik = model
#only remove fixed ef cond
null.model.lik = lmer(grips ~ group  + (1|id) , data = OBIWAN_INST,  REML=FALSE)


#anova(model,type=2) #bad?

test = anova(main.model.lik, null.model.lik, test = 'Chisq')
test


lik.BF = lmBF(
  
  x = anovaBF(grips ~ condition + time + condition:id,  whichRandom=c('condition:id'), data = OBIWAN_INST)
  
  # BAYESIAN
  
  #In practice, many set a prior using the results from one highly similar study #need to update priors #allowing explicit specification of all priors,
  #only on fixed because we dont have prior on random
  priors_mixed = auto_prior(grips ~ condition + time  , data = OBIWAN_INST, TRUE)
  
  #takes a while
  
  #Note that `Evid.Ratio` is the Bayes factor in favor of the null (!) since that is the hypothesis that we stated,
  #`brms::hypothesis` computes an evidence ratio (a Bayes Factor) using the Savage-Dickey method which only requires 
  #the posterior of the parameter of interest. Thus, no null model needs to be fitted explicitly
  
  
  full_brms = brm(grips ~ condition + time  + (condition|id), data = OBIWAN_INST, save_all_pars = TRUE, iter = 5000)
  null_brms = update(full_brms, formula = ~ .-condition)  # Same but without the interaction term
  #null_brms = update(full_brms, formula = ~ .-group:session)  # Same but without the interaction term
  BF_brms_bridge = bayes_factor(full_brms, null_brms)
  BF_brms_bridge
  
  
  
  # N.B. Please note that the estimated Bayes factors might (slightly) vary due to Monte Carlo sampling noise
  INST.aov_BF  <- anovaBF(squeezing_freq ~ cue_type * time + PagripsicipantID, data = INST, whichRandom = "PagripsicipantID", iterations = 50000)
  (INST.aov_BF <- recompute(INST.aov_BF, iterations = 50000))
  plot(INST.aov_BF)
  
  # Interaction effect
  (INST.aov_BF[4]/INST.aov_BF[3])
  lik.BF[1]
  
  full_BF = lmBF(grips ~ condition + time  + id + condition:id,  whichRandom=c('id','condition:id'), data = OBIWAN_INST)
  null_BF = lmBF(grips ~ condition + time  + id,  whichRandom=c('id'), data = OBIWAN_INST)
  
  lmBF(grips ~ condition + time + id + condition:ID,  whichRandom=c('id','condition:id'), data = OBIWAN_INST)
  
  mixed_data$id = factor(mixed_data$id)  # BayesFactor wants the random to be a factor
  
  full_BF = lmBF(WMI ~ session * group + id, data = mixed_data, whichRandom = 'id')
  
  null_BF = lmBF(grips ~ time , data = OBIWAN_INST, whichRandom = 'id')
  null_BF = lmBF(grips ~ session + group + id, data = mixed_data, whichRandom = 'id')
  full_BF / null_BF  # The Bayes factor in favor of the full model
  `lmBF(formula, data, whichRandom = c('id', 'other_var', 'third_var'))`.
  
  #quasi-Bayesian statistics, such as Bayes factors or information criteria and Δ BIC 
  #The BIC approximation to the Bayes Factor he advocates for BF_01 is given by exp( (BIC_1 - BIC_0)/2 )  Wagenmakers (2007)
  x = AIC(mod1) 
  y = AIC(mod2) 
  exp( (test$BIC[1] - test$BIC[2])/2 ) 
  delta_BIC = test$BIC[1] -test$BIC[2] 
  delta_BIC
  
  