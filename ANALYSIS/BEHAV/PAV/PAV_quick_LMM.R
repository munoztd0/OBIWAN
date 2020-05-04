## R code for FOR OBIWAN_PAV session 2 only
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, lme4, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)

#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'PAV'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_PAV_full <- read.delim(file.path(analysis_path,'OBIWAN_PAV.txt'), header = T, sep ='') # read in dataset

#subset
OBIWAN_PAV  <- subset(OBIWAN_PAV_full, session == 'second') #only session 2
OBIWAN_PAV_control  <- subset(OBIWAN_PAV, group == 'control') 
OBIWAN_PAV_obese  <- subset(OBIWAN_PAV, group == 'obese') 
OBIWAN_PAV_third  <- subset(OBIWAN_PAV_full, session == 'third') #only session 2


# define factors
OBIWAN_PAV$id      <- factor(OBIWAN_PAV$id)
OBIWAN_PAV$trial    <- factor(OBIWAN_PAV$trial)
OBIWAN_PAV$group    <- factor(OBIWAN_PAV$group)

#OBIWAN_PAV$condition[OBIWAN_PAV$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_PAV$condition[OBIWAN_PAV$condition== 'Empty']     <- 'Control'
OBIWAN_PAV$condition <- factor(OBIWAN_PAV$condition)

OBIWAN_PAV$trialxcondition <- factor(OBIWAN_PAV$trialxcondition)
OBIWAN_PAV$RT <- as.numeric(OBIWAN_PAV$RT)*1000

#Cleaning
##there is only first round in OBIWAN
#OBIWAN_PAV.clean <- filter(OBIWAN_PAV, rounds == 1)
#OBIWAN_PAV.clean$condition <- droplevels(OBIWAN_PAV.clean$condition, exclude = "Baseline")


#accuracy is to 0.9604732
mean(OBIWAN_PAV$ACC, na.rm = TRUE)

##shorter than 100ms and longer than 3sd+mean
full = length(OBIWAN_PAV$RT)
OBIWAN_PAV.clean <- filter(OBIWAN_PAV, RT >= 100) # min RT is 106ms
mean <- mean(OBIWAN_PAV.clean$RT)
sd <- sd(OBIWAN_PAV.clean$RT)
OBIWAN_PAV.clean <- filter(OBIWAN_PAV.clean, RT <= mean +3*sd) #which is 854.4ms



clean= length(OBIWAN_PAV.clean$RT)

dropped = full-clean
(dropped*100)/full  #dropped 10%

OBIWAN_PAV  = OBIWAN_PAV.clean 

#accuracy is to 0.964497
mean(OBIWAN_PAV$ACC, na.rm = TRUE)

OBIWAN_PAV$liking = OBIWAN_PAV$liking -50

# get means by condition 
bt = ddply(OBIWAN_PAV, .(trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE)) 
btg = ddply(OBIWAN_PAV, .(group, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_PAV, .(condition, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
btcg = ddply(OBIWAN_PAV, .(group, condition, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

# get means by participant 
bsT = ddply(OBIWAN_PAV, .(id, trialxcondition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsC= ddply(OBIWAN_PAV, .(id, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsTC = ddply(OBIWAN_PAV, .(id, trialxcondition, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

bsTg = ddply(OBIWAN_PAV, .(id, group, trialxcondition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsCg= ddply(OBIWAN_PAV, .(id, group, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsTCg = ddply(OBIWAN_PAV, .(id, group, trialxcondition, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

tot_n = length(unique(OBIWAN_PAV$id))
tot_control = length(unique(OBIWAN_PAV_control$id))
tot_obese = length(unique(OBIWAN_PAV_obese$id))
tot_obese_third = length(unique(OBIWAN_PAV_third$id))

df_PAV <- summarySEwithin(bsCg,
                          measurevar = "RT",
                          withinvars = c("condition", "group"), 
                          idvar = "id")
 

#ben #MODEL SELECTION
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R')

#scale!

OBIWAN_PAV$RT = scale(OBIWAN_PAV$RT)
OBIWAN_PAV$liking = scale(OBIWAN_PAV$liking) #, OBIWAN_PAV$condition)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

# Bates et al. 2015 seems to be that one starts with the maximal model a la Barr et al. 2013 
# and then decreases the complexity until the covariance matrix is full rank. 
# (Moreover, they would often recommend to reduce the complexity even further, 
# in order to increase the power.) Update: In contrast, Barr et al. recommend to reduce complexity 
# ONLY if the model did not converge; they are willing to tolerate singular covariance matrices.



## COMPARING RANDOM EFFECTS MODELS #REML
mod1 <- lmer(RT ~  condition*group +trialxcondition + liking +  (1|id) , data = OBIWAN_PAV)
mod2 <- lmer(RT ~  condition*group +trialxcondition + liking +  (condition|id) , data = OBIWAN_PAV)
mod3 <- lmer(RT ~  condition*group +trialxcondition + liking +  (1|trialxcondition) , data = OBIWAN_PAV)
mod4 <-  lmer(RT ~  condition*group +trialxcondition + liking + (1|id) +  (1|trialxcondition) , data = OBIWAN_PAV)
mod5 <-  lmer(RT ~  condition*group +trialxcondition + liking + (condition|id) +  (1|trialxcondition) , data = OBIWAN_PAV)
mod6 <-  lmer(RT ~  condition*group +trialxcondition + liking + (condition|id) +  (condition|trialxcondition) , data = OBIWAN_PAV)
mod7 <- lmer(RT ~  condition*group +trialxcondition + liking +  (1|group) , data = OBIWAN_PAV)
mod8 <-  lmer(RT ~  condition*group +trialxcondition + liking + (1|id) +  (1|group) , data = OBIWAN_PAV)
mod9 <-  lmer(RT ~  condition*group +trialxcondition + liking + (group|id), data = OBIWAN_PAV)
mod10 <-  lmer(RT ~  condition*group +trialxcondition + liking + (group*condition|id), data = OBIWAN_PAV)
mod11 <-  lmer(RT ~  condition*group +trialxcondition + liking + (1|id) +   (1|group) + (1|trialxcondition) , data = OBIWAN_PAV)
mod12 <-  lmer(RT ~  condition*group +trialxcondition + liking + (condition|id) +   (1|group) + (1|trialxcondition) , data = OBIWAN_PAV)



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
summary(rslope) #win #check cor is Not 1 #var is not 0  # well here it gets tricky, same AIC btw mod1 and 2 but mod1 better BIC -> but mod 1 REALLY surestimates ddf -> so mod2 for now AND so its ocngruent for the tasks



## COMPARE FIXED #ML
mod1 <- lmer(RT ~  condition*group +trialxcondition + liking + (condition|id), data = OBIWAN_PAV,  REML=FALSE, control= control)
mod2 <- lmer(RT ~  condition*group +trialxcondition  + (condition|id), data = OBIWAN_PAV,  REML=FALSE, control= control)
mod3 <- lmer(RT ~  condition*group + liking + (condition|id)  , data = OBIWAN_PAV,  REML=FALSE, control= control)
mod4 <- lmer(RT ~  condition*group + (condition|id)  , data = OBIWAN_PAV,  REML=FALSE, control= control)
#mod5 <- lmer(RT ~  condition+group +trialxcondition  +(condition|id), data = OBIWAN_PAV,  REML=FALSE, control= control)
#mod6 <- lmer(RT ~  condition+group + (condition|id)  , data = OBIWAN_PAV,  REML=FALSE, control= control)

#If you are just checking for the presence of an interaction to make sure you are specifying 
#the model correctly, go ahead and drop it.  The interaction uses up df and changes the meaning 
#of the lower order coefficients and complicates the model.  So if you were just checking for it, drop it.

AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)



## BEST MODEL  
model = mod2
summary(model) #win #check cor is -1 ! #var is not 0 # not warnings #AIC and BIC are congruent! drop liking which kinda makes sense

#All of these warnings generally point to a misspecification of your model, in particular the random effects. Most likely some random effects parameters are close to 0 (for variances), or -1/1 (for correlations), which creates for redundancies in the covariance matrix of the model's parameters (of which the so-called Hessian matrix is the inverse).
#Usually, removing the redundant parameters solves the issue. However, it may happen that models with degenerate Hessians still achieve massively lower AIC/BIC than a competing simpler model. In this scenario, the degenerate model may sometimes be preferred to obtain suitably conservative degrees of freedom for inferential tests.
#In fact, the fixed effects estimates and standard errors of a multilevel model are not always strongly impacted by misspecifications in the random effects part!


## TESTING THE RANDOM INTERCEPT
modint <- lm(RT ~  condition*group +trialxcondition , data = OBIWAN_PAV)

AIC(model) ; BIC(model) # largely better !
AIC(modint) ; BIC(modint)


## R-SQUARED IN MULTILEVEL MODELS

r2beta(rslope,method="nsj")

#drop the condition random because its condtional we want
mod1 <- lmer(RT ~  group + trialxcondition +  (1|id), data = OBIWAN_PAV,  REML=FALSE)

r1 = r.squaredGLMM(model)
r2 = r.squaredGLMM(mod1)
r1 - r2
#this value thus reflects the partial marginal and conditional R2 for the condition effect # R2c = 0.1663726


main.model.lik = model
#only remove fixed ef cond
null.model.lik = lmer(RT ~ trialxcondition  + (condition|id) , data = OBIWAN_PAV,  REML=FALSE)


#anova(model,type=2) #bad?

test = anova(main.model.lik, null.model.lik, test = 'Chisq')
test


lik.BF = lmBF(
  
  x = anovaBF(RT ~ condition + trialxcondition + condition:id,  whichRandom=c('condition:id'), data = OBIWAN_PAV)
  
  # BAYESIAN
  
  #In practice, many set a prior using the results from one highly similar study #need to update priors #allowing explicit specification of all priors,
  #only on fixed because we dont have prior on random
  priors_mixed = auto_prior(RT ~ condition + trialxcondition  , data = OBIWAN_PAV, TRUE)
  
  #takes a while
  
  #Note that `Evid.Ratio` is the Bayes factor in favor of the null (!) since that is the hypothesis that we stated,
  #`brms::hypothesis` computes an evidence ratio (a Bayes Factor) using the Savage-Dickey method which only requires 
  #the posterior of the parameter of interest. Thus, no null model needs to be fitted explicitly
  
  
  full_brms = brm(RT ~ condition + trialxcondition  + (condition|id), data = OBIWAN_PAV, save_all_pars = TRUE, iter = 5000)
  null_brms = update(full_brms, formula = ~ .-condition)  # Same but without the interaction term
  #null_brms = update(full_brms, formula = ~ .-group:session)  # Same but without the interaction term
  BF_brms_bridge = bayes_factor(full_brms, null_brms)
  BF_brms_bridge
  
  
  
  # N.B. Please note that the estimated Bayes factors might (slightly) vary due to Monte Carlo sampling noise
  PAV.aov_BF  <- anovaBF(squeezing_freq ~ cue_type * trial + ParticipantID, data = PAV, whichRandom = "ParticipantID", iterations = 50000)
  (PAV.aov_BF <- recompute(PAV.aov_BF, iterations = 50000))
  plot(PAV.aov_BF)
  
  # Interaction effect
  (PAV.aov_BF[4]/PAV.aov_BF[3])
  lik.BF[1]
  
  full_BF = lmBF(RT ~ condition + trialxcondition  + id + condition:id,  whichRandom=c('id','condition:id'), data = OBIWAN_PAV)
  null_BF = lmBF(RT ~ condition + trialxcondition  + id,  whichRandom=c('id'), data = OBIWAN_PAV)
  
  lmBF(RT ~ condition + trialxcondition + id + condition:ID,  whichRandom=c('id','condition:id'), data = OBIWAN_PAV)
  
  mixed_data$id = factor(mixed_data$id)  # BayesFactor wants the random to be a factor
  
  full_BF = lmBF(WMI ~ session * group + id, data = mixed_data, whichRandom = 'id')
  
  null_BF = lmBF(RT ~ trialxcondition , data = OBIWAN_PAV, whichRandom = 'id')
  null_BF = lmBF(RT ~ session + group + id, data = mixed_data, whichRandom = 'id')
  full_BF / null_BF  # The Bayes factor in favor of the full model
  `lmBF(formula, data, whichRandom = c('id', 'other_var', 'third_var'))`.
  
  #quasi-Bayesian statistics, such as Bayes factors or information criteria and Δ BIC 
  #The BIC approximation to the Bayes Factor he advocates for BF_01 is given by exp( (BIC_1 - BIC_0)/2 )  Wagenmakers (2007)
  x = AIC(mod1) 
  y = AIC(mod2) 
  exp( (test$BIC[1] - test$BIC[2])/2 ) 
  delta_BIC = test$BIC[1] -test$BIC[2] 
  delta_BIC
  
  