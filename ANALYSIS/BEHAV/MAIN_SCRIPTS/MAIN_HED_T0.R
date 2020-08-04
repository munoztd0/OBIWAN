## R code for FOR HED OBIWAN
# last modified on April 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, emmeans,misty)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

# open dataset or load('HED.RData')
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
HED  <- subset(HED_full, session == 'second') 
intern  <- subset(intern, session == 'second') 

#merge with info
HED = merge(HED, info, by = "id")

#take out incomplete data ##
#exclude 242 really outlier everywhere, 256 can't do the task, 123 & 124 incomplete data, 114 complete outlier -> hated the solutin z-score -3.35
`%notin%` <- Negate(`%in%`)
HED = HED %>% filter(id %notin% c(242, 256, 123, 124, 114))
intern = intern %>% filter(id %notin%  c(242, 256, 123, 124, 114))

#check for weird behaviors in subject average
bs = ddply(HED, .(id, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 
#Visible outliers (in descriptive stats)
#"Loved (>80) Neutral" : 102 , 219 , 114
#"Hated (>20) Milkshake": 109, 114, 253, 259, 203, 210


# INTERNAL STATES
baseINTERN = subset(intern, phase == 4)
HED = merge(x = HED, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
diffINTERN = subset(intern, phase == 4 | phase == 5) #before and after HED
before = subset(diffINTERN, phase == 4)
after = subset(diffINTERN, phase == 5)
diff = after
diff$diff_piss = diff$piss - before$piss
diff$diff_thirsty = diff$thirsty - before$thirsty
diff$diff_hungry = diff$hungry - before$hungry

HED = merge(x = HED, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)


# define as.factors
fac <- c("id", "trial", "condition", "trialxcondition", "gender", "group")
HED[fac] <- lapply(HED[fac], factor)

#check demo
n_tot = length(unique(HED$id))

AGE = ddply(HED,~group,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(HED,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(HED, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #2 = female


#center everything

# Center level-1 predictor within cluster (CWC)
HED$likC = center(HED$perceived_liking, type = "CWC", group = HED$id)
HED$famC = center(HED$perceived_familiarity, type = "CWC", group = HED$id)
HED$intC = center(HED$perceived_intensity, type = "CWC", group = HED$id)
#densityPlot(HED$likC)

# Center level-2 predictor at the grand mean (CGM)
HED <- HED %>% group_by(id) %>% mutate(pissC = center(piss))
HED <- HED %>% group_by(id) %>% mutate(thirstyC = center(thirsty))
HED <- HED %>% group_by(id) %>% mutate(hungryC = center(hungry))
HED <- HED %>% group_by(id) %>% mutate(diff_pissC = center(diff_piss))
HED <- HED %>% group_by(id) %>% mutate(diff_thirstyC = center(diff_thirsty))
HED <- HED %>% group_by(id) %>% mutate(diff_hungryC = center(diff_hungry))
HED <- HED %>% group_by(id) %>% mutate(ageC = center(age))

#change value of condition
HED$condition = as.factor(revalue(HED$condition, c(Empty="-1", MilkShake="1")))
HED$condition <- factor(HED$condition, levels = c("1", "-1"))



# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_HED.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#save RData for cluster computing
# save.image(file = "HED.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

# STATS -------------------------------------------------------------------

#set to method LRT to quick check

model = mixed(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC + famC + intC:condition + intC + 
              (condition + famC+intC|id) + (1|trialxcondition),
              data = HED, method = "LRT", control = control, REML = FALSE)
model

#Calculates p-values using parametric bootstrap takes forever
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 
# #takes ages even on the cluster!
# model = mixed(likC ~ condition*group  + famC + intC+ intC:condition + thirstyC + hungryC:condition +  hungryC + pissC + 
#               (condition + famC*intC|id) + (condition|trialxcondition), 
#               data = PIT, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 5000))
# model 

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: likC ~ condition * group + thirstyC + hungryC:condition + hungryC + 
#   Model:     famC + intC:condition + intC + (condition + famC + intC | 
#                                                Model:     id) + (1 | trialxcondition)
# Data: HED
# Df full model: 22
# Effect df     Chisq p.value
# 1         condition  1 27.67 ***   <.001
# 2             group  1      0.01    .915
# 3          thirstyC  1      0.19    .661
# 4           hungryC  1      0.23    .633
# 5              famC  1 37.11 ***   <.001
# 6              intC  1      0.51    .476
# 7   condition:group  1      0.88    .349
# 8 condition:hungryC  1 12.93 ***   <.001
# 9    condition:intC  1 15.71 ***   <.001

mod <- lmer(likC ~ condition*group + thirstyC + hungryC:condition + hungryC + famC + intC:condition + intC + (condition + famC+intC|id) + (1|trialxcondition) , data = HED, control = control)
#ref_grid(mod)
##### Computing CIs and Post-Hoc contrasts

#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)
#get CI and pval for condition
p_cond = emmeans(mod, pairwise~ condition, side = ">") #right sided!
p_cond 
 
#get CI condition
CI_cond = confint(emmeans(mod, pairwise~ condition),level = 0.95,
                  method = c("boot"),
                  nsim = 5000)
CI_cond
# contrast estimate     SE df lower.CL upper.CL t.ratio p.value
#1 - -1      11.2 2.04 80.5     7.15     15.3  5.501   <.0001  

#get contrasts for groups obesity X condition (adjusted but still right sided)
cont = emmeans(mod, pairwise~ condition|group, side = ">", adjust = "tukey") #those are the mean per group intercepts
cont$contrasts
#get CI contrasts
CI_cont = confint(emmeans(mod, pairwise~ condition|group, adjust = "tukey"),level = 0.95,
                  method = c("boot"),
                  nsim = 5000)
CI_cont$contrasts

# group = control:
#   contrast estimate     SE df lower.CL upper.CL t.ratio p.value
#1 - -1      9.38 3.35 82.9     2.72     16.0  2.801   0.0032  
# group =  obese:
#1 - -1     13.02 2.25 82.8     8.54     17.5  5.774   <.0001 

# The rest on plot_HED_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------


#LR test for condition 
# full <-  lmer(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC + famC + intC 
# + (condition + famC*intC|id) + (condition|trialxcondition) , data = HED, control = control, REML = FALSE)
# null <- lmer(likC ~ condition:group  + famC + intC+ intC:condition + thirstyC + hungryC:condition +  hungryC + pissC + 
#                (condition + famC*intC|id) + (condition|trialxcondition),
#              data = HED, control = control, REML = FALSE) 
# test = anova(full, null, test = "Chisq") # 32.097  1  1.467e-08
# #Δ AIC = 30.09695
# delta_AIC = test$AIC[1] - test$AIC[2] 
# delta_AIC
