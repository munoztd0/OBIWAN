## R code for FOR OBIWAN_HED Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, ggplot2, Rmisc, dplyr, lmerTest, car, r2glmm, optimx, visreg, MuMIn,  pbkrtest, bootpredictlme4, sjPlot, bayestestR)

#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$id      <- as.factor(info$id)

#subset
OBIWAN_HED  <- subset(OBIWAN_HED_full, session == 'second') #only session 2

# define as.factors
OBIWAN_HED$id      <- as.factor(OBIWAN_HED$id)
OBIWAN_HED$trial    <- as.factor(OBIWAN_HED$trial)
OBIWAN_HED$group    <- as.factor(OBIWAN_HED$group)
OBIWAN_HED$condition <- as.factor(OBIWAN_HED$condition)
OBIWAN_HED$trialxcondition <- as.factor(OBIWAN_HED$trialxcondition)

OBIWAN_HED = full_join(OBIWAN_HED, info, by = "id")
OBIWAN_HED <-OBIWAN_HED %>% drop_na("condition")
OBIWAN_HED$gender   <- as.factor(OBIWAN_HED$gender) #M=0



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

#check for weird behaviors in BsC-> especially in ID.. 267 259 256 242
#Visible outliers (in descriptive stats)
#"Loved (>80) Neutral" : 102 , 219 , 114
#"Hated (>20) Milkshake": 109, 114, 253, 259, 203, 210

#take out participants with corrupted data (missing trials or problem during the passation)
OBIWAN_HED  <- subset(OBIWAN_HED, id != 242 & id != 256)

n = length(unique(OBIWAN_HED$id))

con = subset(OBIWAN_HED, group == 'control')
obe = subset(OBIWAN_HED, group == 'obese')
n_con = length(unique(con$id))
n_obe = length(unique(obe$id))


# QUICK STATS -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#scale everything
OBIWAN_HED$perceived_liking= scale(OBIWAN_HED$perceived_liking)
OBIWAN_HED$perceived_familiarity = scale(OBIWAN_HED$perceived_familiarity)
OBIWAN_HED$perceived_intensity = scale(OBIWAN_HED$perceived_intensity)
OBIWAN_HED$bmi = hscale(OBIWAN_HED$BMI_t1, OBIWAN_HED$id) #agregate by subj and then scale 
OBIWAN_HED$ageZ = hscale(OBIWAN_HED$age, OBIWAN_HED$id) #agregate by subj and then scale 


#************************************************** test
mdl.liking = lmer(perceived_liking ~ condition*bmi*trialxcondition + gender + ageZ+ (condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.liking)

#************************************************** test
mdl.intensity = lmer(perceived_intensity ~ condition*bmi*trialxcondition+ gender + ageZ+(condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.intensity)

#************************************************** test
mdl.familiarity= lmer(perceived_familiarity ~ condition*bmi*trialxcondition+ gender + ageZ+(condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.familiarity)



# STATS LMM -------------------------------------------------------------------

#set "better" optimizer to maximize convergence
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))


#MODEL SELECTION ####

# Bates et al. 2015 seems to be that one starts with the maximal model a la Barr et al. 2013 
# and then decreases the complexity until the covariance matrix is full rank. 
# (Moreover, they would often recommend to reduce the complexity even further, 
# in order to increase the power.) Update: In contrast, Barr et al. recommend to reduce complexity 
# ONLY if the model did not converge; they are willing to tolerate singular covariance matrices.



## COMPARING RANDOM EFFECTS MODELS #REML = TRUE (commented out to run faster) -------------------
#mod1 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+ (1|id) , data = OBIWAN_HED)
mod2 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender + ageZ +(condition|id) , data = OBIWAN_HED)
#mod3 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+ (1|trialxcondition) , data = OBIWAN_HED)
#mod4 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(1|id) +  (1|trialxcondition) , data = OBIWAN_HED)
#mod5 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(condition|id) +  (1|trialxcondition) , data = OBIWAN_HED)
##mod6 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED)
#mod7 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+ (1|bmi) , data = OBIWAN_HED)
#mod8 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(1|id) +  (1|bmi) , data = OBIWAN_HED)
#mod9 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(bmi|id), data = OBIWAN_HED)
#mod10 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(bmi*condition|id), data = OBIWAN_HED)
#mod11 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(1|id) +   (1|bmi) + (1|trialxcondition) , data = OBIWAN_HED)
#mod12 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(condition|id) +   (1|bmi) + (1|trialxcondition) , data = OBIWAN_HED)
# mod7 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+ (1|gender) , data = OBIWAN_HED)
# mod8 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(1|id) +  (1|gender) , data = OBIWAN_HED)
# mod9 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(gender|id), data = OBIWAN_HED)
# mod10 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(gender*condition|id), data = OBIWAN_HED)
# mod11 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(1|id) +   (1|gender) + (1|trialxcondition) , data = OBIWAN_HED)
# mod12 <-  lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity + gender+(condition|id) +   (1|gender) + (1|trialxcondition) , data = OBIWAN_HED)



#AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2) #
#AIC(mod3) ; BIC(mod3)
#AIC(mod4) ; BIC(mod4) 
#AIC(mod5) ; BIC(mod5) 
#AIC(mod6) ; BIC(mod6) #degenerate hession with 4 negative eigenvalues (not good)
# AIC(mod7) ; BIC(mod7)
# AIC(mod8) ; BIC(mod8)
# AIC(mod9) ; BIC(mod9)
# AIC(mod10) ; BIC(mod10)
# AIC(mod11) ; BIC(mod11)
# AIC(mod12) ; BIC(mod12)


## BEST RANDOM SLOPE MODEL ####
rslope = mod2
summary(rslope) #win #cor is Not 1 #var is not 0  # no warnings #AIC and BIC are congruent!



## COMPARE FIXED #ML (or REML = FALSE) ####
#mod1 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity + perceived_intensity +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
mod2 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity  +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
#mod3 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_intensity  +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
#mod4 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + (condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)

#mod5 <- lmer(perceived_liking ~  condition*bmi +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
#mod6 <- lmer(perceived_liking ~  condition*bmi + perceived_intensity +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
#mod7 <- lmer(perceived_liking ~  condition*bmi + perceived_familiarity +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
#mod8 <- lmer(perceived_liking ~  condition*bmi + perceived_intensity + perceived_familiarity +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
# mod9 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity  + gender + ageZ + (condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
# mod10 <- lmer(perceived_liking ~  condition*bmi +trialxcondition  + gender + (condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
# mod11 <- lmer(perceived_liking ~  condition*bmi  + gender + (condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
# mod1 <- lmer(perceived_liking ~  condition+bmi +trialxcondition + perceived_familiarity  +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
# mod2 <- lmer(perceived_liking ~  condition*bmi +trialxcondition + perceived_familiarity  +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
# mod3 <- lmer(perceived_liking ~  condition*group +trialxcondition + perceived_familiarity  +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)
# mod4 <- lmer(perceived_liking ~  condition*bmi*group +trialxcondition + perceived_familiarity  +(condition|id)  , data = OBIWAN_HED,  REML=FALSE, control= control)


# AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2) #
# AIC(mod3) ; BIC(mod3)
# AIC(mod4) ; BIC(mod4)
#AIC(mod5) ; BIC(mod5) 
#AIC(mod6) ; BIC(mod6)
#AIC(mod7) ; BIC(mod7) 
#AIC(mod8) ; BIC(mod8)
# AIC(mod9) ; BIC(mod9)
# AIC(mod10) ; BIC(mod10)
# AIC(mod11) ; BIC(mod11)



## BEST MODEL ####
model = mod2 
summary(model) #win #cor is not 1 ! #var is not 0 # no warnings #AIC and BIC are congruent!

#All of these warnings generally point to a misspecification of your model, in particular the random effects. Most likely some random effects parameters are close to 0 (for variances), or -1/1 (for correlations), which creates for redundancies in the covariance matrix of the model's parameters (of which the so-called Hessian matrix is the inverse).
#Usually, removing the redundant parameters solves the issue. However, it may happen that models with degenerate Hessians still achieve massively lower AIC/BIC than a competing simpler model. In this scenario, the degenerate model may sometimes be preferred to obtain suitably conservative degrees of freedom for inferential tests.
#In fact, the fixed effects estimates and standard errors of a multilevel model are not always strongly impacted by misspecifications in the random effects part!


## TESTING THE RANDOM INTERCEPT
modint <- lm(perceived_liking ~  condition*bmi + trialxcondition +  perceived_familiarity, data = OBIWAN_HED)

AIC(model) ; BIC(model) # largely better !
AIC(modint) ; BIC(modint)


## INFERENCE IN MULTILEVEL MODELS -------------------

#this value thus reflects the conditional R2 for the condition effect # R2c = 0.16
#K-R Kenward and Roger (2009) is probably the most reliable option Stroup (2013)

### test CONDITION without interact ####
main.model.lik = lmer(perceived_liking ~ condition +  bmi  + trialxcondition + perceived_familiarity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)

#only remove fixed ef cond #double check that "It is non-sensical to remove the fixed deprivation effect without removing the random deprivation effect!"
null.model.lik = lmer(perceived_liking ~ bmi  + trialxcondition + perceived_familiarity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)

test = anova(main.model.lik, null.model.lik, test = 'Chisq')

#Δ BIC = 15.3648 -> evidence for model with condition
delta_BIC = test$BIC[1] -test$BIC[2] 
delta_BIC

#BOOOTSTAPING /  Parametric Bootstrap Methods for Tests in Linear Mixed Models #PBmodcomp the bootstrapped p-values is in the PBtest line, 
#the LRT line report the standard p-value assuming a chi-square distribution for the LRT value
#Approximate null–distribution by a kernel density estimate. The p–value is then calculated from the kernel density estimate.

#commented out because #takes a whiiiiiiiile time: 5010.19 sec
#PBtest.cond = PBmodcomp(main.model.lik,null.model.lik,nsim=5000, seed = 101, details = 10) 
#PBtest.cond

#   stat    df        p.value    
#   LRT    23.555  1 1.214e-06 ***
#   PBtest 23.555     0.000999 ***


# EFFECT SIZES 
#CONDITIONAL R squared -> really debated though
r2beta(rslope,method="nsj")

#drop the condition random slope because its condtional we want
mod1 <- lmer(perceived_liking ~  bmi + trialxcondition + perceived_familiarity +  (1|id) , data = OBIWAN_HED,  REML=FALSE)

r1 = r.squaredGLMM(model)
r2 = r.squaredGLMM(mod1)
r1[2] -  r2[2]   #this value thus reflects the conditional R2 for the condition effect # R2c = 0.16


#### test BMI effect ####
null.model.lik = lmer(perceived_liking ~ condition  + trialxcondition + perceived_familiarity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)

test = anova(main.model.lik, null.model.lik, test = 'Chisq')

#Δ BIC = -5.66 -> evidence for model without BMI
delta_BIC = test$BIC[1] -test$BIC[2] 
delta_BIC

#commented out because #takes a whiiiiiiiile time: 5014.71 sec
# PBtest.bmi = PBmodcomp(main.model.lik,null.model.lik,nsim=5000, seed = 101, details = 10) #takes a whiiiiiiiile
# PBtest.bmi

# stat df p.value
# LRT    2.5205  1  0.1124
# PBtest 2.5205     0.1129

# EFFECT SIZES

#CONDITIONAL R squared -> really debated though
#drop the BMI 
mod1 <- lmer(perceived_liking ~  condition + trialxcondition + perceived_familiarity +  (condition|id) , data = OBIWAN_HED,  REML=FALSE)

r1 = r.squaredGLMM(model)
r2 = r.squaredGLMM(mod1)
r1[2] -  r2[2] #this value thus reflects the conditional R2 for the condition effect # R2c = #0.00047


#### test INTER effect ####
main.model.lik = lmer(perceived_liking ~ condition *  bmi  + trialxcondition + perceived_familiarity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)
null.model.lik = lmer(perceived_liking ~ condition + bmi + trialxcondition + perceived_familiarity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)

test = anova(main.model.lik, null.model.lik, test = 'Chisq')

#Δ BIC = -7.52 -> evidence for model without BMI
delta_BIC = test$BIC[1] -test$BIC[2] 
delta_BIC

#commented out because #takes a whiiiiiiiile time: 5014.71 sec
# PBtest.inter = PBmodcomp(main.model.lik,null.model.lik,nsim=5000, seed = 101, details = 10) #takes a whiiiiiiiile
# PBtest.inter

# stat df p.value
#LRT    0.6684  1  0.4136
#PBtest 0.6684     0.4455


# EFFECT SIZES

#CONDITIONAL R squared -> really debated though

r1 = r.squaredGLMM(main.model.lik)
r2 = r.squaredGLMM(null.model.lik)
r1[2] -  r2[2] #this value thus reflects the conditional R2 for the condition effect # R2c = #0.000686


# PLOTTING -------------------------------------------------------
gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

n = 2 # 2 condition
cols = gg_color_hue(n)

## SIMPLE PLOTTING MODEL ## 
model <- lmer(perceived_liking ~ condition*BMI_t1 + trialxcondition + perceived_familiarity  + (condition|id) , data = OBIWAN_HED)


#show predicted values for liking
plot_model(model,  type = "pred", show.data = T)



#PLOTTING EFFECTS
#no we take out the big guns

#get CI via bootstrap
options(bootnsim = 100)

#commented out bc takesss a whilllleee
#predict(model, newdata=OBIWAN_HED, re.form=NA, se.fit=TRUE, nsim = 5000) #or options(bootnsim = 500)


#useful plot functions 
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/utils_plot.R') 
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/plot_mod.R') 
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/settheme.R') 


#exctract model prediction
dat <- ggeffects::ggpredict(
  model = model,
  terms = c("condition"),
  ci.lvl = 0.95,
  type = "fe")

raw = attr(dat, "rawdata")

raw$x[raw$x== 2]     <- 'MilkShake'
raw$x[raw$x== 1]     <- 'Empty'

raw$x = as.factor(raw$x)
raw$predicted =raw$response



#RATINGS

dfLIK_C  <- subset(dat, x == 'Empty')
#dfLIK_Co  <- subset(dfLIK_C, group == 'obese')
#dfLIK_Cc  <- subset(dfLIK_C, group == 'control')
dfLIK_R  <- subset(dat, x == 'MilkShake')
#dfLIK_Ro  <- subset(dfLIK_R, group == 'obese')
#dfLIK_Rc  <- subset(dfLIK_R, group == 'control')

bsC_C  <- subset(raw, x == 'Empty')
#bsC_Co  <- subset(bsC_C , group == 'obese')
#bsC_Cc  <- subset(bsC_C , group == 'control')
bsC_R  <- subset(raw, x == 'MilkShake')
#bsC_Ro  <- subset(bsC_R , group == 'obese')
#bsC_Rc  <- subset(bsC_R , group == 'control')

plt1 <- ggplot(data = dat, aes(x = x, y = predicted, color = x, fill = x)) +
  #left 
  geom_left_violin(data = bsC_C, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_C, aes(x = as.numeric(x)+0.15), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_C, aes(x = as.numeric(x)+0.15, ymax = conf.high, ymin =conf.low), width=0.05,  alpha=1, size=0.4)+
  
  #right 
  geom_right_violin(data = bsC_R, aes(x= x, y = response), alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_R, aes(x = as.numeric(x)+0.15, y = predicted), color ="black", shape = 18) +
  geom_errorbar(data=dfLIK_R, aes(x = as.numeric(x)+0.15, y = predicted, ymax = conf.high, ymin = conf.low) , width=0.05, alpha=1, size=0.4)+
  #make it raaiiin
  geom_point(data = raw, aes(x = as.numeric(x) +0.15, y = response), alpha=0.1, size = 0.5, 
             position = position_jitter(width = 0.05, seed = 123), color ="lightgrey") +
  #geom_line(data = dat, aes(x = as.numeric(x) +0.15, y = predicted), alpha=0.4) +
  
  #details
  #scale_fill_manual(values = c("Empty"="blue", "Milkshake"="red")) +
  #scale_color_manual(values = c("Empty"="blue", "Milkshake"="red")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-3,2, by = 1)), limits = c(-3,2)) +
  #scale_x_discrete(expand = c(0, 2)) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 2, 1), units = "cm"),
        axis.text.x = element_blank(), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = "none", #c(0.525, 1,1), 
        legend.title = element_blank(),
        #legend.direction = "horizontal",
        plot.caption = element_text(size=8,  colour = "black"),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( x = "    Empty                  Milshake", 
        y = "Plesantness Ratings (z)",
        caption = "Marginal Effect Condition\n 
        ajusted for BMI, Trial, Familiarity & Subject \n 
        Plesantness ~ Condition*BMI + Trial + Familiarity  + (Condition|Subject) \n 
        Control (BMI < 30) n = 27, Obese (BMI > 30) n = 63 \n  
        Bootstrapped (i = 5000) p-values & 95% CI \n 
        Condition effect (p < 0.001, \u0394 BIC = 15.36, R\u00B2c = 0.16)") 

plot(plt1)

pdf(file.path(figures_path,paste(task, 'Liking_condition_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()


## BMI

#exctract model prediction
dat <- ggeffects::ggpredict(
  model = model,
  terms = c("BMI_t1"),
  ci.lvl = 0.95,
  type = "fe")

raw = attr(dat, "rawdata")

raw$predicted =raw$response


plt2 <- ggplot(dat, aes(x = x, y = predicted)) +
  geom_line(alpha = 1, size = 1, color = "black") +
  geom_ribbon(aes(ymax = conf.high, ymin = conf.low), alpha=0.2, linetype = 0, color= "royalblue") +
  geom_point(data = raw, alpha = .1, color = "royalblue") +
  scale_y_continuous(expand = c(0, 0),  limits = c(-3,2),  breaks=c(seq.int(-3,2, by = 1))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 2, 1), units = "cm"), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.text.x = element_text(size=11,  colour = "black"),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), 
        legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "BMI",
       y = "Plesantness Ratings (z)",
       caption = "Marginal Effect BMI \n 
        ajusted for Condition, Trial, Familiarity & Subject\n 
        Plesantness ~ Condition*BMI + Trial + Familiarity  + (Condition|Subject) \n 
        Control (BMI < 30) n = 27, Obese (BMI > 30) n = 63 \n  
        Bootstrapped (i = 5000) p-values & 95% CI \n 
        BMI effect (p = 0.11, \u0394 BIC = -5.66, R\u00B2c = 0.00047)") 

plot(plt2)

pdf(file.path(figures_path,paste(task, 'Liking_BMI_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt2)
dev.off()


#show interaction predicted values for liking #custom script because the one by SJS bugs
plt3 <- plot_mod(model, type = "eff", terms = c("BMI_t1","condition"), show.data = TRUE, ci.lvl = 0.99, colors = cols)  +
  #scale_color_manual(values = c("obese"="blue", "control"="black")) +
  #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(20,40, by = 5)), limits = c(20,40)) +
  #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-2,2, by = 1)), limits = c(-2,2)) +
  guides(color = FALSE, fill = guide_legend(override.aes = list(alpha = 0.3))) +
  theme_bw() +
  theme(plot.margin = unit(c(2, 1, 2, 1), units = "cm"),
        axis.text.x = element_text(size=12,  colour = "black"),
        axis.text.y = element_text(size=12,  colour = "black"),
        plot.title = element_blank(),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16),
        legend.position = c(0.525, 1.1), legend.title=element_blank(),
        legend.direction = "horizontal") +
        #axis.ticks.x = element_blank(),
        #axis.line.x = element_blank()) +
  labs( x = "BMI",
        y = "Plesantness Ratings (z)",
        caption = "Marginal Effect of Interaction (Condition*BMI)  \n 
        ajusted for Trial, Familiarity & Subject \n 
        Plesantness ~ Condition*BMI + Trial + Familiarity  + (Condition|Subject) \n 
        Control (BMI < 30) n = 27, Obese (BMI > 30) n = 63 \n  
        Bootstrapped (i = 5000) p-values & 95% CI \n 
        Interaction effect (p = 0.45, \u0394 BIC = -7.52, R\u00B2c = 0.00069)") 

plot(plt3)

pdf(file.path(figures_path,paste(task, 'Liking_inter_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt3)
dev.off()


#CHECK ASSUMPTIONS: REML = TRUE -------------
mod = lmer(perceived_liking ~  condition*bmi + trialxcondition + perceived_familiarity + (condition|id) , data = OBIWAN_HED, control= control)


#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good

#2)Linearity    #3)Homoscedasticity AND #4)Normality of residuals

#sjPlot
plot_model(mod, type = "diag")


#Ben
#par(mfrow=c(2,2))
# hist(residuals(mod),breaks=100,main="Untransformed",freq=FALSE,col="slategray",border="white")
# lines(density(residuals(mod)),lwd=3,col="firebrick")
# hist(tdiagnostic(mod)$tres,breaks=100,main="Transformed",freq=FALSE,col="slategray",border="white")
# lines(density(tdiagnostic(mod)$tres),lwd=3,col="firebrick")
# qqnorm(residuals(mod),pch=4,col="bisque3") ; qqline(residuals(mod),col="darkblue",lwd=2)
# qqnorm(tdiagnostic(mod)$tres,pch=4,col="bisque3") ; qqline(tdiagnostic(mod)$tres,col="darkblue",lwd=2)
#dev.off()


#5) Absence of influential data points (203, 256)

#simple boxplots
boxplot(scale(ranef(mod)$id))

#disgnostic plots -> Cook's distance
set.seed(101)
im <- influence(mod,maxfun=100,  group="id")

infIndexPlot(im,col="steelblue",
             vars=c("cookd"))


# #SAME FOR SESSION 3 -> 238 & 227 & ~206
# 
# OBIWAN_HED  <- subset(OBIWAN_HED_full, session == 'third') #only session 3
# 
# # define as.factors
# OBIWAN_HED$id      <- as.factor(OBIWAN_HED$id)
# OBIWAN_HED$trial    <- as.factor(OBIWAN_HED$trial)
# OBIWAN_HED$group    <- as.factor(OBIWAN_HED$group)
# OBIWAN_HED$gender   <- as.factor(OBIWAN_HED$gender) #M=0
# 
# OBIWAN_HED$condition <- as.factor(OBIWAN_HED$condition)
# 
# OBIWAN_HED$trialxcondition <- as.factor(OBIWAN_HED$trialxcondition)
# 
# OBIWAN_HED = full_join(OBIWAN_HED, info, by = "id")
# 
# OBIWAN_HED <-OBIWAN_HED %>% drop_na("condition")
# 
# OBIWAN_HED$perceived_liking= scale(OBIWAN_HED$perceived_liking)
# OBIWAN_HED$perceived_familiarity = scale(OBIWAN_HED$perceived_familiarity)
# OBIWAN_HED$perceived_intensity = scale(OBIWAN_HED$perceived_intensity)
# OBIWAN_HED$bmi = hscale(OBIWAN_HED$BMI_t1, OBIWAN_HED$id) #agragate by subj and then scale 
# OBIWAN_HED$ageZ = hscale(OBIWAN_HED$age, OBIWAN_HED$id) #agragate by subj and then scale 
# 
# mod = lmer(perceived_liking ~  condition*bmi + trialxcondition + perceived_familiarity + (condition|id) , data = OBIWAN_HED)
# 
# 
# #disgnostic plots -> Cook's distance
# set.seed(101)
# im <- influence(mod,maxfun=100,  group="id")
# 
# infIndexPlot(im,col="steelblue",
#              vars=c("cookd"))
