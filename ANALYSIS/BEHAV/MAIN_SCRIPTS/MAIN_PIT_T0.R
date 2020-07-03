## R code for FOR PIT OBIWAN
# last modified on April 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni)

# SETUP ------------------------------------------------------------------

task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

# open dataset or load('PIT.RData')
PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
#HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PIT  <- subset(PIT_full, session == 'second') 
#HED  <- subset(HED_full, session == 'second') 
intern  <- subset(intern, session == 'second') 

#merge with info
PIT = merge(PIT, info, by = "id")

#take out incomplete data ##218 only have the third ? influence -> 238 & 234 & 232 & 254
`%notin%` <- Negate(`%in%`)
#PIT = PIT %>% filter(id %notin% c(242, 256, 106, 113, 114, 125, 130, 201, 218, 219, 221, 225, 230, 241,  244, 246, 247))
#HED = HED %>% filter(id %notin% c(242, 256, 106, 113, 114, 125, 130, 201, 218, 219, 221, 225, 230, 241,  244, 246, 247))
PIT = PIT %>% filter(id %notin% c(242, 256))
#HED = HED %>% filter(id %notin% c(242, 256))
intern = intern %>% filter(id %notin% c(242, 256))
#113, 114, 125, 130, 201, 218, 219, 221, 225, 230, 241,  244, 246, 247
#242 245 bc MRI & behav

# INTERNAL STATES
baseINTERN = subset(intern, phase == 3)
PIT = merge(x = PIT, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
diffINTERN = subset(intern, phase == 3 | phase == 4) #before and after PIT
before = subset(diffINTERN, phase == 3)
after = subset(diffINTERN, phase == 4)
diff = after
diff$diff_piss = diff$piss - before$piss
diff$diff_thirsty = diff$thirsty - before$thirsty
diff$diff_hungry = diff$hungry - before$hungry

PIT = merge(x = PIT, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)


# define as.factors
fac <- c("id", "trial", "condition", "trialxcondition", "gender", "group")
PIT[fac] <- lapply(PIT[fac], factor)

#check demo
n_tot = length(unique(PIT$id))
bs = ddply(PIT, .(id, group), summarise, gripFreq = mean(gripFreq, na.rm = TRUE), peak = mean(peak, na.rm = TRUE), AUC = mean(AUC, na.rm = TRUE)) 
bs$AUC = scale(bs$AUC)
#densityPlot(bs$AUC)
#skewness(bs$AUC) not bad

AGE = ddply(PIT,~group,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PIT,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PIT, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #2 = female

N_group = ddply(PIT, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()


#remove the baseline from other trials by id ##but double check
PIT =  subset(PIT, condition != 'BL') 

PIT_BL = ddply(PIT, .(id), summarise, freqA=mean(AUC), sdA=sd(AUC)) 
PIT = merge(PIT, PIT_BL, by = "id")
PIT$gripAUC = (PIT$AUC - PIT$freqA) / PIT$sdA

#HED_BL = ddply(HED, .(id,condition), summarise, lik=mean(perceived_liking)) 
#HED_BL = subset(HED_BL, condition == 'MilkShake') 
#HED_BL = select(HED_BL, -c(condition) )
#PIT = merge(PIT, HED_BL, by = "id")

####scale everything
PIT$gripAUCZ = scale(PIT$gripAUC)
#densityPlot(PIT$gripAUCZ)

#PIT$gripFZ = scale(PIT$gripFreq)
#densityPlot(PIT$gripFZ)

#bsZ = ddply(PIT, .(id, condition), summarise, gripAUCZ = mean(gripAUCZ, na.rm = TRUE)) 

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(pissZ = scale(piss))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(thirstyZ = scale(thirsty))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(hungryZ = scale(hungry))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(diff_pissZ = scale(diff_piss))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(diff_thirstyZ = scale(diff_thirsty))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(diff_hungryZ = scale(diff_hungry))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(likZ = scale(lik))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(ageZ = scale(age))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(bmiZ = scale(BMI_t1))

#densityPlot(PIT$bmiZ) #not really normal but checked with Ben, its cool as long we dont infer on bmi < 25 >30


#change value of condition
PIT$condition = as.factor(revalue(PIT$condition, c(CSminus="-1", CSplus="1")))
PIT$condition <- factor(PIT$condition, levels = c("1", "-1"))

CSPlus <- subset(PIT, condition =="1" )
CSPlus <- CSPlus[order(as.numeric(levels(CSPlus$id))[CSPlus$id], CSPlus$trialxcondition),]
CSMinus <- subset(PIT, condition =="-1" )
CSMinus <- CSMinus[order(as.numeric(levels(CSMinus$id))[CSMinus$id], CSPlus$trialxcondition),]

PIT$gripZ = PIT$gripAUCZ
densityPlot(PIT$gripZ)
# PIT_ind = CSPlus
# PIT_ind$gripdiff = CSPlus$gripAUCZ - CSMinus$gripAUCZ
# 
# mod <- lmer(gripdiff ~  group2 + gender + ageZ + likZ +(1 |id) + (1|trialxcondition) , 
#             data = PIT_ind, control = control) #need to be fitted using ML so here I just use lmer function so its faster


#save RData for cluster computing
# save.image(file = "PIT.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PIT.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))



#Calculates p-values using parametric bootstrap takes forever #set to method LRT to quick check
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 

#takes ages even on the cluster!
# method = "PB", control = control, REML = FALSE, args_test = list(nsim = 10))

#quick check
mdl.aov = aov_4(gripZ ~ condition*bmiZ*hungryZ  + thirstyZ + pissZ + (condition|id),
                data = PIT, observed = c("thirstyZ", "hungryZ", "pissZ"), factorize = FALSE, fun_aggregate = mean)

summary(mdl.aov)

model = mixed(gripZ ~ condition*bmiZ + hungryZ + hungryZ:condition + thirstyZ + pissZ  + (condition|id) + (1|trialxcondition), 
              data = PIT, method = "LRT", control = control, REML = FALSE)

model #The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject.

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: gripZ ~ condition * bmiZ + hungryZ + hungryZ:condition + thirstyZ + 
#   Model:     pissZ + +(condition | id) + (1 | trialxcondition)
# Data: PIT
# Df full model: 13
# Effect df   Chisq p.value
# 1         condition  1  5.35 *    .021
# 2              bmiZ  1    0.00   >.999
# 3           hungryZ  1    0.00   >.999
# 4          thirstyZ  1    0.00   >.999
# 5             pissZ  1    0.00   >.999
# 6    condition:bmiZ  1  2.95 +    .086
# 7 condition:hungryZ  1 7.15 **    .008

mod <- lmer(gripZ ~ condition*bmiZ + hungryZ + hungryZ:condition + thirstyZ + pissZ  +(condition |id) + (1|trialxcondition) , 
            data = PIT, control = control) #need to be fitted using ML so here I just use lmer function so its faster

# COMPUTE EFFECT SIZES (COMPUTE R Squared For Mixed Models VIA NAKAGAWA ESTIMATE)
# R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors 
# R2 #conditionCSplus 0.005    0.012    0.001

#LR test for condition 
full <- lmer(gripZ ~ condition*bmiZ + hungryZ + hungryZ:condition + thirstyZ + pissZ  + (condition |id) + (1|trialxcondition),
             data = PIT, control = control, REML = FALSE)
null <- lmer(gripZ ~ condition:bmiZ + hungryZ + hungryZ:condition + thirstyZ + pissZ  + (condition |id) + (1|trialxcondition),
             data = PIT, control = control, REML = FALSE)
test = anova(full, null, test = "Chisq")
#Δ AIC = 3.35
delta_AIC = test$AIC[1] - test$AIC[2]
delta_AIC

#LR test for condition:bmiZ 
full <- lmer(gripZ ~ condition*bmiZ + hungryZ + hungryZ:condition + thirstyZ + pissZ  + (condition |id) + (1|trialxcondition),
             data = PIT, control = control, REML = FALSE)
null <- lmer(gripZ ~ condition + bmiZ + hungryZ + hungryZ:condition + thirstyZ + pissZ  + (condition |id) + (1|trialxcondition),
             data = PIT, control = control, REML = FALSE)
test = anova(full, null, test = "Chisq") # 2.9478  1    0.08599
#Δ AIC = 3.35
delta_AIC = test$AIC[1] - test$AIC[2]
delta_AIC

#get CI and pval for condition
p_cond = emmeans(mod, pairwise~ condition, side = ">") #right sided!
p_cond 

#get CI condition
CI_cond = confint(p_cond,level = 0.95,
                  method = c("boot"),
                  nsim = 5000)
CI_cond
# contrast estimate     SE df lower.CL upper.CL t.ratio p.value
# 1 - -1      0.136 0.0596 80   0.0373      Inf  2.290   0.0123 

#get contrasts for groups obesity X condition (adjusted but still right sided)
cont = emmeans(mod, pairwise~ condition|bmiZ, at = list(bmiZ = c(-1.36,0.17,0.92)), side = ">", adjust = "tukey") #those are the mean per group intercepts
cont$contrasts
#get CI contrasts
CI_cont = confint(cont,level = 0.95,
                  method = c("boot"),
                  nsim = 5000)
CI_cont$contrasts
# bmiZ = -1.36:
#   contrast estimate     SE df lower.CL upper.CL t.ratio p.value
# 1 - -1   -0.00279 0.1013 80  -0.1713      Inf   -0.028  0.5110 
# bmiZ =  0.17:
# 1 - -1    0.15502 0.0606 80   0.0542      Inf   2.559  0.0062 
# bmiZ =  0.92:
# 1 - -1    0.23238 0.0820 80   0.0959      Inf  2.832  0.0029 

# THE rest on plot_PIT_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------

