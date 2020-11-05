## R code for FOR PIT OBIWAN
# last modified on April 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, emmeans,misty)

# SETUP ------------------------------------------------------------------

task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


# open dataset or load('PIT.RData')
PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PIT  <- subset(PIT_full, session == 'second') 
HED  <- subset(HED_full, session == 'second') 
intern  <- subset(intern, session == 'second') 

#merge with info
PIT = merge(PIT, info, by = "id")

#take out incomplete data ##218 only have the third ? influence? -> 238 & 234 & 232 & 254
#exclude 242 really outlier everywhere, 256 can't do the task, 123 & 124 incomplete data
`%notin%` <- Negate(`%in%`)
PIT = PIT %>% filter(id %notin% c(242, 256, 123, 124)) 
HED = HED %>% filter(id %notin% c(242, 256, 123, 124))
intern = intern %>% filter(id %notin% c(242, 256, 123, 124)) 


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

#remove the baseline  ##but double check
PIT =  subset(PIT, condition != 'BL') 

#exctract liking
HED_BL = ddply(HED, .(id,condition), summarise, lik=mean(perceived_liking))
HED_BL = subset(HED_BL, condition == 'MilkShake')
HED_BL = select(HED_BL, -c(condition) )
PIT = merge(PIT, HED_BL, by = "id")

#  center everything ------------------------------------------------------

# Center level-1 predictor within cluster (CWC)
PIT$gripC = center(PIT$AUC, type = "CWC", group = PIT$id)
#densityPlot(PIT$gripC)

# Center level-2 predictor at the grand mean (CGM)
PIT <- PIT %>% group_by(id) %>% mutate(pissC = center(piss))
PIT <- PIT %>% group_by(id) %>% mutate(thirstyC = center(thirsty))
PIT <- PIT %>% group_by(id) %>% mutate(hungryC = center(hungry))
PIT <- PIT %>% group_by(id) %>% mutate(diff_pissC = center(diff_piss))
PIT <- PIT %>% group_by(id) %>% mutate(diff_thirstyC = center(diff_thirsty))
PIT <- PIT %>% group_by(id) %>% mutate(diff_hungryC = center(diff_hungry))
PIT <- PIT %>% group_by(id) %>% mutate(likC = center(lik))
PIT <- PIT %>% group_by(id) %>% mutate(ageC = center(age))

#revalue all catego
#change value of group
PIT$group = as.factor(revalue(PIT$group, c(control="-1", obese="1")))

#change value of condition
PIT$condition = as.factor(revalue(PIT$condition, c(CSminus="-1", CSplus="1")))
PIT$condition <- factor(PIT$condition, levels = c("1", "-1"))


#save RData for cluster computing
# save.image(file = "PIT.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PIT_T0.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))


# mdl.aov = aov_4(gripC ~ condition*group + hungryC + hungryC:condition + thirstyC + pissC  +  (condition|id/trialxcondition) , 
#                 data = PIT, observed = c("gender", "ageC", "diff_bmiC"), factorize = FALSE, fun_aggregate = mean)
# 
# summary(mdl.aov)

#set to method LRT to quick check
model = mixed(gripC ~ condition*group + hungryC + hungryC:condition + thirstyC + pissC  + (condition|id) + (1|trialxcondition),
              data = PIT, method = "LRT", control = control, REML = FALSE)
model

#Calculates p-values using parametric bootstrap takes forever
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 
# #takes ages even on the cluster!
# model = mixed(gripC ~ condition + condition:group + hungryC:condition + (condition|id) + (1|trialxcondition), 
#               data = PIT, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 5000))
# 
# Mixed Model Anova Table (Type 3 tests, PB-method)
# 
# Model: gripC ~ condition * group + hungryC + hungryC:condition + thirstyC + 
#   Model:     pissC + (condition | id) + (1 | trialxcondition)
# Data: PIT
# Df full model: 13
# Effect df     Chisq p.value
# 1         condition  1      0.76    .383
# 2             group  1      0.00   >.999
# 3           hungryC  1      0.00   >.999
# 4          thirstyC  1      0.00   >.999
# 5             pissC  1      0.00   >.999
# 6   condition:group  1    4.64 *    .031
# 7 condition:hungryC  1 11.06 ***   <.001


#manually do COND
main = lmer(gripC ~ condition*group + hungryC:condition + (condition |id) + (1|trialxcondition) , 
            data = PIT, control = control, REML = FALSE)
null = lmer(gripC ~ condition + group + hungryC:condition + (condition |id) + (1|trialxcondition) , 
           data = PIT, control = control, REML = FALSE)

#manual test to double check and to get delta AIC
test = anova(main, null, test = 'Chisq')
#test

#get BF fro mixed see Wagenmakers, 2007
exp((test[1,2] - test[2,2])/2) #3.734812



# Computing CIs and Post-Hoc contrasts ------------------------------------
mod <- lmer(gripC ~ condition*group + hungryC:condition + (condition |id) + (1|trialxcondition) , 
            data = PIT, control = control) #need to be fitted using ML so here I just use lmer function so its faster
#lsmeans::ref_grid(mod)

#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#get CI and pval for condition (right sided)
p_cond = emmeans(mod, pairwise~ condition, side = ">") 
p_cond

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


#looking at coeficients # takes a while
coef.out <- function(merMod) { coef(merMod)$id[,2] } #column 2 is coeficient for diff of CS- from CS+
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=1000,use.u=TRUE))
coef.conf = confint(boot.out,method="boot",boot.type="perc",level=0.95)
coef.conf

#This paints a slightly more interesting picture. We have 11 person 
#with no significant decreases  (95%) in grips for the CS- stimulus,
#In other words, the proportion of people showing a PIT effect is 
#estimated to be XX% (15/24)!. -

#### The rest on plot_PIT_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------





#LR test for condition 
# full <- lmer(gripC ~ condition*group + hungryC + hungryC:condition + thirstyC + pissC  + (condition |id) + (1|trialxcondition),
#              data = PIT, control = control, REML = FALSE)
# null <- lmer(gripC ~ condition:group + group + hungryC + hungryC:condition + thirstyC + pissC  + (condition |id) + (1|trialxcondition),
#              data = PIT, control = control, REML = FALSE)
# test = anova(full, null, test = "Chisq")
# test
# #Δ AIC = was 3.35
# delta_AIC = test$AIC[1] - test$AIC[2]
# delta_AIC

#LR test for condition:group 
# full <- lmer(gripC ~ condition*group + hungryC + hungryC:condition + thirstyC + pissC  + (condition |id) + (1|trialxcondition),
#              data = PIT, control = control, REML = FALSE)
# null <- lmer(gripC ~ condition + group + hungryC + hungryC:condition + thirstyC + pissC  + (condition |id) + (1|trialxcondition),
#              data = PIT, control = control, REML = FALSE)
# test = anova(full, null, test = "Chisq") # 4.2018  1    0.04038 *
# #Δ AIC = 2.20
# delta_AIC = test$AIC[1] - test$AIC[2]
# delta_AIC