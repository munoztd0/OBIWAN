## R code for FOR HED OBIWAN
# last modified on April 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, lmerTest, optimx, car, visreg, ggplot2, ggpubr, sjPlot, glmmTMB, influence.ME)

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
bs = ddply(HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), intensityZ = mean(intensityZ, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
#Visible outliers (in descriptive stats)
#"Loved (>80) Neutral" : 102 , 219 , 114
#"Hated (>20) Milkshake": 109, 114, 253, 259, 203, 210

# INTERNAL STATES
baseINTERN = subset(intern, phase == 4)
HED = merge(x = HED, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
diffINTERN = subset(intern, phase == 4 | phase == 5) #before and after PIT
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

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(pissZ = scale(piss))

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(thirstyZ = scale(thirsty))

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(hungryZ = scale(hungry))

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(diff_pissZ = scale(diff_piss))

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(diff_thirstyZ = scale(diff_thirsty))

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(diff_hungryZ = scale(diff_hungry))

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(ageZ = scale(age))

#scale everything
HED$likZ = scale(HED$perceived_liking)
HED$famZ = scale(HED$perceived_familiarity)
HED$intZ = scale(HED$perceived_intensity)

#change value of condition
HED$condition = as.factor(revalue(HED$condition, c(Empty="-1", MilkShake="1")))
HED$condition <- factor(HED$condition, levels = c("1", "-1"))

#save RData for cluster computing
# save.image(file = "HED.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)


# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_HED.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

# STATS -------------------------------------------------------------------

#really quick check, BAD
# mdl.aov = aov_4(likZ ~ condition*group + (condition|id),
#                 data = HED, factorize = FALSE, fun_aggregate = mean)
# 
# summary(mdl.aov)

#set to method LRT to quick check
model = mixed(likZ ~ condition*group  + famZ + intZ+ intZ:condition + thirstyZ + hungryZ:condition +  hungryZ + pissZ + 
                (condition + famZ*intZ|id) + (condition|trialxcondition),
              data = HED, method = "LRT", control = control, REML = FALSE)
model

#Calculates p-values using parametric bootstrap takes forever
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 
# #takes ages even on the cluster!
# model = mixed(likZ ~ condition*group  + famZ + intZ+ intZ:condition + thirstyZ + hungryZ:condition +  hungryZ + pissZ + 
#               (condition + famZ*intZ|id) + (condition|trialxcondition), 
#               data = PIT, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 5000))
# model 

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: likZ ~ condition * group + famZ + intZ + intZ:condition + thirstyZ + 
#   Model:     hungryZ:condition + hungryZ + pissZ + (condition + famZ * 
#                                                       Model:     intZ | id) + (condition | trialxcondition)
# Data: HED
# Df full model: 30
# Effect df     Chisq p.value
# 1          condition  1 20.73 ***   <.001
# 2              group  1      0.37    .545
# 3               famZ  1 42.41 ***   <.001
# 4               intZ  1      0.01    .927
# 5           thirstyZ  1      0.21    .650
# 6            hungryZ  1      0.02    .878
# 7              pissZ  1      2.58    .109
# 8    condition:group  1      1.52    .217
# 9     condition:intZ  1 26.86 ***   <.001
# 10 condition:hungryZ  1 14.89 ***   <.001
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘+’ 0.1 ‘ ’ 1

mod <- lmer(likZ ~ condition*group  + famZ + intZ+ intZ:condition + thirstyZ + hungryZ:condition +  hungryZ + pissZ + 
              (condition + famZ*intZ|id) + (condition|trialxcondition), data = HED, control = control) #need to be fitted using ML so here I just use lmer function so its faster

# COMPUTE EFFECT SIZES (COMPUTE R Squared For Mixed Models VIA NAKAGAWA ESTIMATE)
R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors
R2 #condition-1 0.012    0.020    0.006

#LR test for condition 
# full <- lmer(likZ ~ condition*group  + famZ + intZ+ intZ:condition + thirstyZ + hungryZ:condition +  hungryZ + pissZ + 
#                (condition + famZ*intZ|id) + (condition|trialxcondition),
#              data = HED, control = control, REML = FALSE) 
# null <- lmer(likZ ~ condition:group  + famZ + intZ+ intZ:condition + thirstyZ + hungryZ:condition +  hungryZ + pissZ + 
#                (condition + famZ*intZ|id) + (condition|trialxcondition),
#              data = HED, control = control, REML = FALSE) 
# test = anova(full, null, test = "Chisq") # 32.097  1  1.467e-08
# #Δ AIC = 30.09695
# delta_AIC = test$AIC[1] - test$AIC[2] 
# delta_AIC


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
#1 - -1      0.475 0.103 90.8    0.271    0.679  4.632   <.0001 

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
#1 - -1       0.359 0.164 89.1   0.0325    0.685  2.185   0.0158 
# group =  obese:
#1 - -1      0.591 0.114 91.9   0.3645    0.818   5.182   <.0001 

# The rest on plot_HED_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------


