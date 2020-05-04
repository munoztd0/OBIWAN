## R code for FOR OBIWAN_HED Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)
#lme4
#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$id      <- factor(info$id)

#subset
OBIWAN_HED  <- subset(OBIWAN_HED_full, session == 'second') #only session 2

# define factors
OBIWAN_HED$id      <- factor(OBIWAN_HED$id)
OBIWAN_HED$trial    <- factor(OBIWAN_HED$trial)
OBIWAN_HED$group    <- factor(OBIWAN_HED$group)

#OBIWAN_HED$condition[OBIWAN_HED$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_HED$condition[OBIWAN_HED$condition== 'Empty']     <- 'Control'
OBIWAN_HED$condition <- factor(OBIWAN_HED$condition)

OBIWAN_HED$trialxcondition <- factor(OBIWAN_HED$trialxcondition)

OBIWAN_HED = full_join(OBIWAN_HED, info, by = "id")




# get means by condition 
bt = ddply(OBIWAN_HED, .(trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
btg = ddply(OBIWAN_HED, .(group, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_HED, .(condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
btcg = ddply(OBIWAN_HED, .(group, condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

# get means by participant 
bsT = ddply(OBIWAN_HED, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsC= ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsTC = ddply(OBIWAN_HED, .(id, trialxcondition, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

bsTg = ddply(OBIWAN_HED, .(id, group, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsCg= ddply(OBIWAN_HED, .(id, group, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsTCg = ddply(OBIWAN_HED, .(id, group, trialxcondition, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 




n = length(unique(OBIWAN_HED$id))

#ben #MODEL SELECTION
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R')

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

# Bates et al. 2015 seems to be that one starts with the maximal model a la Barr et al. 2013 
# and then decreases the complexity until the covariance matrix is full rank. 
# (Moreover, they would often recommend to reduce the complexity even further, 
# in order to increase the power.) Update: In contrast, Barr et al. recommend to reduce complexity 
# ONLY if the model did not converge; they are willing to tolerate singular covariance matrices.

#MCMCglmm and lmer are both functions that can be used for fitting linear mixed models. 
#MCMCglmm takes a Bayesian approach where priors must be specified for fixed and random effects, 
#enabling inference via Markov Chain Monte Carlo sampling, whereas lmer takes a likelihood approach within the frequentist paradigm. To



## COMPARING RANDOM EFFECTS MODELS #REML
mod1 <- lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity + (1|id) , data = OBIWAN_HED)
mod2 <- lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity + (condition|id) , data = OBIWAN_HED)
mod3 <- lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity + (1|trialxcondition) , data = OBIWAN_HED)
mod4 <-  lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(1|id) +  (1|trialxcondition) , data = OBIWAN_HED)
mod5 <-  lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(condition|id) +  (1|trialxcondition) , data = OBIWAN_HED)
mod6 <-  lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED)
mod7 <- lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity + (1|group) , data = OBIWAN_HED)
mod8 <-  lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(1|id) +  (1|group) , data = OBIWAN_HED)
mod9 <-  lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(group|id), data = OBIWAN_HED)
mod10 <-  lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(group*condition|id), data = OBIWAN_HED)
mod11 <-  lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(1|id) +   (1|group) + (1|trialxcondition) , data = OBIWAN_HED)
mod12 <-  lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(condition|id) +   (1|group) + (1|trialxcondition) , data = OBIWAN_HED)



AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4) 
AIC(mod5) ; BIC(mod5) 
AIC(mod6) ; BIC(mod6)#
AIC(mod7) ; BIC(mod7)
AIC(mod8) ; BIC(mod8)
AIC(mod9) ; BIC(mod9) 
AIC(mod10) ; BIC(mod10) 
AIC(mod11) ; BIC(mod11)
AIC(mod12) ; BIC(mod12)


## BEST RANDOM SLOPE MODEL
rslope = mod6
summary(rslope) #win #check cor is Not 1 #var is not 0  # "only" max grad warnings #AIC and BIC are congruent!



## COMPARE FIXED #ML
mod1 <- lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity + perceived_intensity +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod2 <- lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity  +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod3 <- lmer(perceived_liking ~  condition*group +trialxcondition + perceived_intensity  +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod4 <- lmer(perceived_liking ~  condition*group +trialxcondition + (condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)

mod5 <- lmer(perceived_liking ~  condition*group +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod6 <- lmer(perceived_liking ~  condition*group + perceived_intensity +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod7 <- lmer(perceived_liking ~  condition*group + perceived_familiarity +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod8 <- lmer(perceived_liking ~  condition*group + perceived_intensity + perceived_familiarity +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)



AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)
AIC(mod5) ; BIC(mod5) 
AIC(mod6) ; BIC(mod6)
AIC(mod7) ; BIC(mod7) #
AIC(mod8) ; BIC(mod8)



#mod7 <- lmer(perceived_liking ~  condition*group  +(condition|id) +  (condition||trialxcondition) , data = OBIWAN_HED,  REML=FALSE, control= control)

## BEST MODEL
model = mod7 #cor = 1
summary(model) #win #check cor is -1 ! #var is not 0 # not warnings #AIC and BIC are congruent!

#All of these warnings generally point to a misspecification of your model, in particular the random effects. Most likely some random effects parameters are close to 0 (for variances), or -1/1 (for correlations), which creates for redundancies in the covariance matrix of the model's parameters (of which the so-called Hessian matrix is the inverse).
#Usually, removing the redundant parameters solves the issue. However, it may happen that models with degenerate Hessians still achieve massively lower AIC/BIC than a competing simpler model. In this scenario, the degenerate model may sometimes be preferred to obtain suitably conservative degrees of freedom for inferential tests.
#In fact, the fixed effects estimates and standard errors of a multilevel model are not always strongly impacted by misspecifications in the random effects part!

#Doug Bates suggests using MCMC samples instead #https://stat.ethz.ch/pipermail/r-help/2006-May/094765.html
library("languageR")

pvals.fnc(model)

## TESTING THE RANDOM INTERCEPT
modint <- lm(perceived_liking ~  condition*group + perceived_familiarity, data = OBIWAN_HED)

AIC(model) ; BIC(model) # largely better !
AIC(modint) ; BIC(modint)


## R-SQUARED IN MULTILEVEL MODELS

r2beta(rslope,method="nsj")

#drop the condition random because its condtional we want
mod1 <- lmer(perceived_liking ~  group + perceived_familiarity +  (1|id) +  (1|trialxcondition) , data = OBIWAN_HED,  REML=FALSE)

r1 = r.squaredGLMM(model)
r2 = r.squaredGLMM(mod1)
r1 - r2
#this value thus reflects the partial marginal and conditional R2 for the condition effect # R2c = 0.1663726


main.model.lik = model
#only remove fixed ef cond
null.model.lik = lmer(perceived_liking ~ trialxcondition + perceived_familiarity + perceived_intensity + (condition|id) , data = OBIWAN_HED,  REML=FALSE)


#anova(model,type=2) #bad?

test = anova(main.model.lik, null.model.lik, test = 'Chisq')
test

#MCMCglmm and lmer are both functions that can be used for fitting linear mixed models. 
#MCMCglmm takes a Bayesian approach where priors must be specified for fixed and random effects, 
#enabling inference via Markov Chain Monte Carlo sampling, whereas lmer takes a likelihood approach within the frequentist paradigm. To



lik.BF = lmBF(

x = anovaBF(perceived_liking ~ condition + trialxcondition + condition:id,  whichRandom=c('condition:id'), data = OBIWAN_HED)

# BAYESIAN

#In practice, many set a prior using the results from one highly similar study #need to update priors #allowing explicit specification of all priors,
#only on fixed because we dont have prior on random
priors_mixed = auto_prior(perceived_liking ~ condition + trialxcondition + perceived_familiarity + perceived_intensity , data = OBIWAN_HED, TRUE)

#takes a while

#Note that `Evid.Ratio` is the Bayes factor in favor of the null (!) since that is the hypothesis that we stated,
#`brms::hypothesis` computes an evidence ratio (a Bayes Factor) using the Savage-Dickey method which only requires 
#the posterior of the parameter of interest. Thus, no null model needs to be fitted explicitly


full_brms = brm(perceived_liking ~ condition + trialxcondition + perceived_familiarity + perceived_intensity + (condition|id), data = OBIWAN_HED, save_all_pars = TRUE, iter = 5000)
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

full_BF = lmBF(perceived_liking ~ condition + trialxcondition + perceived_familiarity + perceived_intensity + id + condition:id,  whichRandom=c('id','condition:id'), data = OBIWAN_HED)
null_BF = lmBF(perceived_liking ~ condition + trialxcondition + perceived_familiarity + perceived_intensity + id,  whichRandom=c('id'), data = OBIWAN_HED)

lmBF(perceived_liking ~ condition + trialxcondition + id + condition:ID,  whichRandom=c('id','condition:id'), data = OBIWAN_HED)

mixed_data$id = factor(mixed_data$id)  # BayesFactor wants the random to be a factor

full_BF = lmBF(WMI ~ session * group + id, data = mixed_data, whichRandom = 'id')

null_BF = lmBF(perceived_liking ~ trialxcondition + perceived_familiarity + perceived_intensity, data = OBIWAN_HED, whichRandom = 'id')
null_BF = lmBF(perceived_liking ~ session + group + id, data = mixed_data, whichRandom = 'id')
full_BF / null_BF  # The Bayes factor in favor of the full model
`lmBF(formula, data, whichRandom = c('id', 'other_var', 'third_var'))`.

#quasi-Bayesian statistics, such as Bayes factors or information criteria and Δ BIC 
#The BIC approximation to the Bayes Factor he advocates for BF_01 is given by exp( (BIC_1 - BIC_0)/2 )  Wagenmakers (2007)
x = AIC(mod1) 
y = AIC(mod2) 
exp( (test$BIC[1] - test$BIC[2])/2 ) 
delta_BIC = test$BIC[1] -test$BIC[2] 
delta_BIC

