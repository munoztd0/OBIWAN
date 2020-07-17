## R code for FOR IBST OBIWAN
# last modified on April 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, emmeans,misty)

# SETUP ------------------------------------------------------------------

task = 'INST'

# Set working directory
# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


# open dataset or load('INST.RData')
INST_full <- read.delim(file.path(analysis_path,'OBIWAN_INST.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
INST  <- subset(INST_full, session == 'second') 
intern  <- subset(intern, session == 'second') 

#merge with info
INST = merge(INST, info, by = "id")

#take out incomplete data ##218 only have the third ? influence? -> 238 & 234 & 232 & 254
#exclude 242 really outlier everywhere, 256 can't do the task, 123 & 124 incomplete data
`%notin%` <- Negate(`%in%`)
INST = INST %>% filter(id %notin% c(242, 256)) 
HED = HED %>% filter(id %notin% c(242, 256))
intern = intern %>% filter(id %notin% c(242, 256)) 


# INTERNAL STATES
baseINTERN = subset(intern, phase == 1)
INST = merge(x = INST, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
diffINTERN = subset(intern, phase == 1 | phase == 2) #before and after INST
before = subset(diffINTERN, phase == 1)
after = subset(diffINTERN, phase == 2)
diff = after
diff$diff_piss = diff$piss - before$piss
diff$diff_thirsty = diff$thirsty - before$thirsty
diff$diff_hungry = diff$hungry - before$hungry

INST = merge(x = INST, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)


# define as.factors
fac <- c("id", "trial", "gender", "group")
INST[fac] <- lapply(INST[fac], factor)

#check demo
n_tot = length(unique(INST$id))
bs = ddply(INST, .(id, trial), summarise, grips = mean(grips, na.rm = TRUE)) 
bt = ddply(INST, .(trial), summarise, grips = mean(grips, na.rm = TRUE)) 
bs$grips = scale(bs$grips)
#densityPlot(bs$grips)


AGE = ddply(INST,~group,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(INST,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(INST, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #2 = female

N_group = ddply(INST, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

#center everything
# Center level-1 predictor within cluster (CWC)
INST$gripC = center(INST$grips, type = "CWC", group = INST$id)
INST$forceC = center(INST$auc, type = "CWC", group = INST$id)
#densityPlot(INST$gripC)

# Center level-2 predictor at the grand mean (CGM)
INST <- INST %>% group_by(id) %>% mutate(pissC = center(piss))
INST <- INST %>% group_by(id) %>% mutate(thirstyC = center(thirsty))
INST <- INST %>% group_by(id) %>% mutate(hungryC = center(hungry))
INST <- INST %>% group_by(id) %>% mutate(diff_pissC = center(diff_piss))
INST <- INST %>% group_by(id) %>% mutate(diff_thirstyC = center(diff_thirsty))
INST <- INST %>% group_by(id) %>% mutate(diff_hungryC = center(diff_hungry))
INST <- INST %>% group_by(id) %>% mutate(ageC = center(age))

#revalue all catego
#change value of group
INST$group = as.factor(revalue(INST$group, c(control="-1", obese="1")))

#save RData for cluster computing
# save.image(file = "INST.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#model with everything #quick check the covariates #keep it simple
# aov_car(gripC ~ trial*group + ageC +  gender + pissC + thirstyC + hungryC + diff_pissC + diff_thirstyC + diff_hungryC
#         + Error(id/trial), data = INST, factorize = FALSE, observed = c("gender", "ageC", "pissC", "thirstyC", "hungryC", "diff_pissC", "diff_thirstyC", "diff_hungryC"))

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#set to method LRT to quick check
INST$trial = as.numeric(INST$trial)
model = mixed(gripC ~ trial*group +diff_thirstyC:trial + diff_hungryC:trial + (1 |id), data = INST, method = "LRT", control = control, REML = FALSE)
model

#Calculates p-values using parametric bootstrap takes forever
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 
# #takes ages even on the cluster!
#model = mixed(gripC ~ trial*group +diff_thirstyC:trial + diff_hungryC:trial + (1 |id),   data = INST, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 5000))
# 
# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: gripC ~ trial * group + diff_thirstyC:trial + diff_hungryC:trial + 
#   Model:     (1 | id)
# Data: INST
# Df full model: 98
# Effect df     Chisq p.value
# 1               trial 23 96.22 ***   <.001
# 2               group  1      0.00   >.999
# 3         trial:group 23     17.28    .795
# 4 trial:diff_thirstyC 24  48.92 **    .002
# 5  trial:diff_hungryC 24  46.41 **    .004

mod <- lmer(gripC ~ trial* group + diff_thirstyC:trial + diff_hungryC:trial + (1 |id) ,  data = INST, control = control)

## POLYNOMIAL REGRESSION #not better
# polymod <- lmer(gripC ~ trial + I(trial^2) * group + diff_thirstyC:trial + diff_hungryC:trial + (1 |id) ,  data = INST, control = control)

## PIECEWISE REGRESSION WITH SPLINES # not better
# INST$time <- ifelse(INST$trial>4, 1,0)
# INST$diff <- INST$trial -4 
# INST$X <- INST$diff*INST$time
# splinemod <- lmer(gripC~trial+X*group + diff_thirstyC:trial + diff_hungryC:trial + (1 |id) ,  data = INST, control = control)
# 
# AIC(mod) ; BIC(mod)
# AIC(polymod) ; BIC(polymod)
# AIC(splinemod) ; BIC(splinemod)


##### Computing CIs and Post-Hoc contrasts
#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#get CI and pval for trial
trial = emmeans(mod, ~ trial, adjust = "tukey")
trial$contrasts

visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="spline", gg=TRUE,type="contrast",ylab="RT (z)",breaks=c(-1,0,1),xlab="Liking ratings Cues")

#get CI condition
CI_cond = confint(emmeans(mod, pairwise~ condition),level = 0.95,
                  method = c("boot"),
                  nsim = 5000)
CI_cond$contrasts
# contrast estimate SE df lower.CL upper.CL t.ratio p.value
# 1 - -1      3.5 4.08 80  -4.61  11.6  0.859   0.1964

#get contrasts for groups obesity X condition (adjusted but still right sided)
inter = emmeans(mod, pairwise~ condition|group, adjust = "tukey", side = ">")
inter$contrasts
#get CI contrasts
CI_inter = confint(emmeans(mod, pairwise~ condition|group, adjust = "tukey"),level = 0.95,method = c("boot"),nsim = 5000)
CI_inter$contrasts

# group = -1 control:
#   contrast estimate     SE df lower.CL upper.CL t.ratio p.value
#   1 - -1      -5.25 6.83  80  -18.84     8.33   -0.770  0.7781 

#group = 1:
#  contrast estimate     SE df lower.CL upper.CL t.ratio p.value
#1 - -1     12.26 4.48 80     3.35    21.17       2.738  0.0038


#### The rest on plot_INST_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------



#LR test for condition 
# full <- lmer(gripC ~ condition*group + hungryC + hungryC:condition + thirstyC + pissC  + (condition |id) + (1|trialxcondition),
#              data = INST, control = control, REML = FALSE)
# null <- lmer(gripC ~ condition:group + group + hungryC + hungryC:condition + thirstyC + pissC  + (condition |id) + (1|trialxcondition),
#              data = INST, control = control, REML = FALSE)
# test = anova(full, null, test = "Chisq")
# test
# #Δ AIC = was 3.35
# delta_AIC = test$AIC[1] - test$AIC[2]
# delta_AIC

#LR test for condition:group 
# full <- lmer(gripC ~ condition*group + hungryC + hungryC:condition + thirstyC + pissC  + (condition |id) + (1|trialxcondition),
#              data = INST, control = control, REML = FALSE)
# null <- lmer(gripC ~ condition + group + hungryC + hungryC:condition + thirstyC + pissC  + (condition |id) + (1|trialxcondition),
#              data = INST, control = control, REML = FALSE)
# test = anova(full, null, test = "Chisq") # 4.2018  1    0.04038 *
# #Δ AIC = 2.20
# delta_AIC = test$AIC[1] - test$AIC[2]
# delta_AIC