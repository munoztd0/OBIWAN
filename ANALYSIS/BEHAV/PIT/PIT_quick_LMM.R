## R code for FOR OBIWAN_PIT session 2 only
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, lme4, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)

#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset


#subset
OBIWAN_PIT  <- subset(OBIWAN_PIT_full, session == 'second') #only session 2

# define factors
OBIWAN_PIT$id      <- factor(OBIWAN_PIT$id)
OBIWAN_PIT$trial    <- factor(OBIWAN_PIT$trial)
OBIWAN_PIT$group    <- factor(OBIWAN_PIT$group)

#OBIWAN_PIT$condition[OBIWAN_PIT$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_PIT$condition[OBIWAN_PIT$condition== 'Empty']     <- 'Control'
OBIWAN_PIT$condition <- factor(OBIWAN_PIT$condition)

OBIWAN_PIT$trialxcondition <- factor(OBIWAN_PIT$trialxcondition)



# get means by condition 
bt = ddply(OBIWAN_PIT, .(trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE)) 
btg = ddply(OBIWAN_PIT, .(group, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE) ) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_PIT, .(condition, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
btcg = ddply(OBIWAN_PIT, .(group, condition, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE) ) 

# get means by participant 
bsT = ddply(OBIWAN_PIT, .(id, trialxcondition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsC= ddply(OBIWAN_PIT, .(id, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsTC = ddply(OBIWAN_PIT, .(id, trialxcondition, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 

bsTg = ddply(OBIWAN_PIT, .(id, group, trialxcondition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE) ) 
bsCg= ddply(OBIWAN_PIT, .(id, group, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsTCg = ddply(OBIWAN_PIT, .(id, group, trialxcondition, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 



df_PIT <- summarySEwithin(bsCg,
                          measurevar = "gripFreq",
                          withinvars = c("condition", "group"), 
                          idvar = "id")


#ben #MODEL SELECTION
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R')


#! scale
OBIWAN_PIT$gripFreq = scale(OBIWAN_PIT$gripFreq) #watcha

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

# Bates et al. 2015 seems to be that one starts with the maximal model a la Barr et al. 2013 
# and then decreases the complexity until the covariance matrix is full rank. 
# (Moreover, they would often recommend to reduce the complexity even further, 
# in order to increase the power.) Update: In contrast, Barr et al. recommend to reduce complexity 
# ONLY if the model did not converge; they are willing to tolerate singular covariance matrices.



## COMPARING RANDOM EFFECTS MODELS #REML
mod1 <- lmer(gripFreq ~  condition*group +trialxcondition  + (1|id) , data = OBIWAN_PIT)
mod2 <- lmer(gripFreq ~  condition*group +trialxcondition  + (condition|id) , data = OBIWAN_PIT, control= control) # added optimX too remove warning but it doesnt change AIC and BIC
mod3 <- lmer(gripFreq ~  condition*group +trialxcondition  + (1|trialxcondition) , data = OBIWAN_PIT)
mod4 <-  lmer(gripFreq ~  condition*group +trialxcondition  +(1|id) +  (1|trialxcondition) , data = OBIWAN_PIT)
mod5 <-  lmer(gripFreq ~  condition*group +trialxcondition  +(condition|id) +  (1|trialxcondition) , data = OBIWAN_PIT)
mod6 <-  lmer(gripFreq ~  condition*group +trialxcondition  +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_PIT)
mod7 <- lmer(gripFreq ~  condition*group +trialxcondition  + (1|group) , data = OBIWAN_PIT)
mod8 <-  lmer(gripFreq ~  condition*group +trialxcondition  +(1|id) +  (1|group) , data = OBIWAN_PIT)
mod9 <-  lmer(gripFreq ~  condition*group +trialxcondition  +(group|id), data = OBIWAN_PIT)
mod10 <-  lmer(gripFreq ~  condition*group +trialxcondition  +(group*condition|id), data = OBIWAN_PIT)
mod11 <-  lmer(gripFreq ~  condition*group +trialxcondition  +(1|id) +   (1|group) + (1|trialxcondition) , data = OBIWAN_PIT)
mod12 <-  lmer(gripFreq ~  condition*group +trialxcondition  +(condition|id) +   (1|group) + (1|trialxcondition) , data = OBIWAN_PIT)



AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2) #
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4) 
AIC(mod5) ; BIC(mod5) 
AIC(mod6) ; BIC(mod6)
AIC(mod7) ; BIC(mod7)
AIC(mod8) ; BIC(mod8)
AIC(mod9) ; BIC(mod9) 
AIC(mod10) ; BIC(mod10) 
AIC(mod11) ; BIC(mod11)
AIC(mod12) ; BIC(mod12)


## BEST RANDOM SLOPE MODEL
rslope = mod2
summary(rslope) #win #check cor is Not 1 #var is not 0  #AIC and BIC are congruent!



## COMPARE FIXED #ML
mod1 <- lmer(gripFreq ~  condition*group +trialxcondition  +(condition|id), data = OBIWAN_PIT,  REML=FALSE, control= control)
mod2 <- lmer(gripFreq ~  condition*group + (condition|id)  , data = OBIWAN_PIT,  REML=FALSE, control= control)
#mod3 <- lmer(gripFreq ~  condition+group +trialxcondition  +(condition|id), data = OBIWAN_PIT,  REML=FALSE, control= control)
#mod4 <- lmer(gripFreq ~  condition+group + (condition|id)  , data = OBIWAN_PIT,  REML=FALSE, control= control)



AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
#AIC(mod3) ; BIC(mod3)
#AIC(mod4) ; BIC(mod4)



## BEST MODEL  #AIC and BIC are not congruent! staay with AIC for the moment
model = mod1
summary(model) #win #check cor is -1 ! #var is not 0 # not warnings
#All of these warnings generally point to a misspecification of your model, in particular the random effects. Most likely some random effects parameters are close to 0 (for variances), or -1/1 (for correlations), which creates for redundancies in the covariance matrix of the model's parameters (of which the so-called Hessian matrix is the inverse).
#Usually, removing the redundant parameters solves the issue. However, it may happen that models with degenerate Hessians still achieve massively lower AIC/BIC than a competing simpler model. In this scenario, the degenerate model may sometimes be preferred to obtain suitably conservative degrees of freedom for inferential tests.
#In fact, the fixed effects estimates and standard errors of a multilevel model are not always strongly impacted by misspecifications in the random effects part!


## TESTING THE RANDOM INTERCEPT
modint <- lm(gripFreq ~  condition*group +trialxcondition , data = OBIWAN_PIT)

AIC(model) ; BIC(model) # largely better !
AIC(modint) ; BIC(modint)


## R-SQUARED IN MULTILEVEL MODELS

r2beta(rslope,method="nsj")

#drop the condition random because its condtional we want
mod1 <- lmer(gripFreq ~  group + perceived_familiarity +  (1|id) +  (1|trialxcondition) , data = OBIWAN_PIT,  REML=FALSE)

r1 = r.squaredGLMM(model)
r2 = r.squaredGLMM(mod1)
r1 - r2
#this value thus reflects the partial marginal and conditional R2 for the condition effect # R2c = 0.1663726


main.model.lik = model
#only remove fixed ef cond
null.model.lik = lmer(gripFreq ~ trialxcondition  + (condition|id) , data = OBIWAN_PIT,  REML=FALSE)


#anova(model,type=2) #bad?

test = anova(main.model.lik, null.model.lik, test = 'Chisq')
test


lik.BF = lmBF(
  
  x = anovaBF(gripFreq ~ condition + trialxcondition + condition:id,  whichRandom=c('condition:id'), data = OBIWAN_PIT)
  
  # BAYESIAN
  
  #In practice, many set a prior using the results from one highly similar study #need to update priors #allowing explicit specification of all priors,
  #only on fixed because we dont have prior on random
  priors_mixed = auto_prior(gripFreq ~ condition + trialxcondition  , data = OBIWAN_PIT, TRUE)
  
  #takes a while
  
  #Note that `Evid.Ratio` is the Bayes factor in favor of the null (!) since that is the hypothesis that we stated,
  #`brms::hypothesis` computes an evidence ratio (a Bayes Factor) using the Savage-Dickey method which only requires 
  #the posterior of the parameter of interest. Thus, no null model needs to be fitted explicitly
  
  
  full_brms = brm(gripFreq ~ condition + trialxcondition  + (condition|id), data = OBIWAN_PIT, save_all_pars = TRUE, iter = 5000)
  null_brms = update(full_brms, formula = ~ .-condition)  # Same but without the interaction term
  #null_brms = update(full_brms, formula = ~ .-group:session)  # Same but without the interaction term
  BF_brms_bridge = bayes_factor(full_brms, null_brms)
  BF_brms_bridge
  
  
  
  # N.B. Please note that the estimated Bayes factors might (slightly) vary due to Monte Carlo sampling noise
  PIT.aov_BF  <- anovaBF(squeezing_freq ~ cue_type * trial + ParticipantID, data = PIT, whichRandom = "ParticipantID", iterations = 50000)
  (PIT.aov_BF <- recompute(PIT.aov_BF, iterations = 50000))
  plot(PIT.aov_BF)
  
  # Interaction effect
  (PIT.aov_BF[4]/PIT.aov_BF[3])
  lik.BF[1]
  
  full_BF = lmBF(gripFreq ~ condition + trialxcondition  + id + condition:id,  whichRandom=c('id','condition:id'), data = OBIWAN_PIT)
  null_BF = lmBF(gripFreq ~ condition + trialxcondition  + id,  whichRandom=c('id'), data = OBIWAN_PIT)
  
  lmBF(gripFreq ~ condition + trialxcondition + id + condition:ID,  whichRandom=c('id','condition:id'), data = OBIWAN_PIT)
  
  mixed_data$id = factor(mixed_data$id)  # BayesFactor wants the random to be a factor
  
  full_BF = lmBF(WMI ~ session * group + id, data = mixed_data, whichRandom = 'id')
  
  null_BF = lmBF(gripFreq ~ trialxcondition , data = OBIWAN_PIT, whichRandom = 'id')
  null_BF = lmBF(gripFreq ~ session + group + id, data = mixed_data, whichRandom = 'id')
  full_BF / null_BF  # The Bayes factor in favor of the full model
  `lmBF(formula, data, whichRandom = c('id', 'other_var', 'third_var'))`.
  
  #quasi-Bayesian statistics, such as Bayes factors or information criteria and Δ BIC 
  #The BIC approximation to the Bayes Factor he advocates for BF_01 is given by exp( (BIC_1 - BIC_0)/2 )  Wagenmakers (2007)
  x = AIC(mod1) 
  y = AIC(mod2) 
  exp( (test$BIC[1] - test$BIC[2])/2 ) 
  delta_BIC = test$BIC[1] -test$BIC[2] 
  delta_BIC
  
  