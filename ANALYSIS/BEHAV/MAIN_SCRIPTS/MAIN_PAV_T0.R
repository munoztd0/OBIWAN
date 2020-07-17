## R code for FOR PAV OBIWAN
# last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, misty)

# SETUP ------------------------------------------------------------------

task = 'PAV'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


# open dataset or load('PAV.RData')
PAV_full <- read.delim(file.path(analysis_path,'OBIWAN_PAV.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PAV  <- subset(PAV_full, session == 'second') 
intern  <- subset(intern, session == 'second') 

#merge with info
PAV = merge(PAV, info, by = "id")

#take out incomplete data ## look out for  122 & 110 & 254 outliers!
#exclude 242 really outlier everywhere, 256 can't do the task, 114 REALLY hated the solution and thus didn't "do" the conditioning, 228 also
`%notin%` <- Negate(`%in%`)
PAV = PAV %>% filter(id %notin% c(242, 256, 114, 228))
intern = intern %>% filter(id %notin%  c(242, 256, 114, 228))

# INTERNAL STATES
baseINTERN = subset(intern, phase == 2)
PAV = merge(x = PAV, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
diffINTERN = subset(intern, phase == 2 | phase == 3) #before and after PAV
before = subset(diffINTERN, phase == 2)
after = subset(diffINTERN, phase == 3)
diff = after
diff$diff_piss = diff$piss - before$piss
diff$diff_thirsty = diff$thirsty - before$thirsty
diff$diff_hungry = diff$hungry - before$hungry

PAV = merge(x = PAV, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)

# define as.factors
fac <- c("id", "trial", "condition", "session", "trialxcondition", "gender", "intervention")
PAV[fac] <- lapply(PAV[fac], factor)

PAV$RT <- as.numeric(PAV$RT)*1000 # transform in millisecond

#check demo

AGE = ddply(PAV,~session,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PAV,~session,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PAV, .(id, session), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, session) %>%
  tally() #2 = female

# Cleaning Up -------------------------------------------------------------
#shorter than 100ms and longer than 3sd+mean

densityPlot(PAV$RT) # bad 

acc_bef = mean(PAV$ACC, na.rm = TRUE) #0.93

full = length(PAV$RT)
PAV.clean <- PAV %>% filter(RT <= mean(RT, na.rm = TRUE) + 3*sd(RT, na.rm = TRUE) &  RT >= 200) 

clean= length(PAV.clean$RT)

dropped = full-clean
(dropped*100)/full  #dropped 6%

densityPlot(PAV.clean$RT) #skewed bwaaa

PAV = PAV.clean 

#log transform function
t_log_scale <- function(x){
  if(x==0){y <- 1} 
  else {y <- (sign(x)) * (log(abs(x)))}
  y }

PAV$RT_T <- sapply(PAV$RT,FUN=t_log_scale)
densityPlot(PAV$RT_T) # ahh this is much better !

#accuracy is to 99 (was 93 before cleaning)
acc_clean = mean(PAV$ACC, na.rm = TRUE)

n_tot = length(unique(PAV$id))
bs = ddply(PAV, .(id), summarise, RT = mean(RT, na.rm = TRUE)) 

# Center level-1 predictor within cluster (CWC)
PAV$RT_TC = center(PAV$RT_T, type = "CWC", group = PAV$id)
PAV$likC = center(PAV$liking, type = "CWC", group = PAV$condition)

# Center level-2 predictor at the grand mean (CGM)
PAV <- PAV %>% group_by(id) %>% mutate(pissC = center(piss))
PAV <- PAV %>% group_by(id) %>% mutate(thirstyC = center(thirsty))
PAV <- PAV %>% group_by(id) %>% mutate(hungryC = center(hungry))
PAV <- PAV %>% group_by(id) %>% mutate(diff_pissC = center(diff_piss)) 
PAV <- PAV %>% group_by(id) %>% mutate(diff_thirstyC = center(diff_thirsty))
PAV <- PAV %>% group_by(id) %>% mutate(diff_hungryC = center(diff_hungry))
PAV <- PAV %>% group_by(id) %>% mutate(ageC = center(age))

#revalue all catego
#change value of group
PAV$group = as.factor(revalue(PAV$group, c(control="-1", obese="1")))

#change value of condition
PAV$condition = as.factor(revalue(PAV$condition, c(CSminus="-1", CSplus="1")))
PAV$condition <- factor(PAV$condition, levels = c("1", "-1"))

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)
options(contrasts=c("contr.sum","contr.poly")) #set contrasts to sum !

#save RData for cluster computing
# save.image(file = "PAV.RData", version = NULL, ascii = FALSE,compress = FALSE, safe = TRUE)

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PAV_T0.R

#set to method LRT to quick check
model = mixed(RT_TC ~ condition*group + group:likC + likC +  (condition|id) + (1|trialxcondition),
              data = PAV, method = "LRT", control = control, REML = FALSE)
model

#Calculates p-values using parametric bootstrap takes forever
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 
# #takes ages even on the cluster!
#model = mixed(RT_TC ~ condition*group   + ageC + likC + thirstyC +  hungryC + pissC + (condition|id) + (1|trialxcondition),
#              data = PAV, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 5000))
# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: RT_TC ~ condition * group + group:likC + likC + (condition | id) + (1 | trialxcondition)
# Data: PAV
# Df full model: 11
# Effect df   Chisq p.value
# 1       condition  1  5.06 *    .024
# 2           group  1    0.01    .903
# 3            likC  1 6.77 **    .009
# 4 condition:group  1    0.14    .713
# 5      group:likC  1    1.11    .293

mod <- lmer(RT_TC ~ condition*group + group:likC + likC +  (condition|id) + (1|trialxcondition), data = PAV, control = control) # REML now for further analysis
ref_grid(mod) #triple check everything is more or less centered at 0

#get CI and pval for condition (left sided!)
p_cond = emmeans(mod, pairwise~ condition, side = "<") 
p_cond
#get CI condition
CI_cond = confint( emmeans(mod, pairwise~ condition),level = 0.95,
                   method = c("boot"),
                   nsim = 5000)
CI_cond$contrasts
# contrast estimate     SE df lower.CL upper.CL t.ratio p.value
# 1 - -1   -0.0285 0.0127 84.2  -0.0537 -0.00328 -2.247  0.0136 

#get contrasts for group X condition (adjusted but still left sided)
inter = emmeans(mod, pairwise~ condition|group, adjust = "tukey", side = "<") 
inter$contrasts
#get CI contrasts
CI_inter = confint(emmeans(mod, pairwise~ condition|group),level = 0.95,method = c("boot"),nsim = 5000)
CI_inter$contrasts

# group = control:
#   contrast estimate     SE   df lower.CL upper.CL t.ratio p.value
# 1 - -1    -0.0239 0.0209 83.5  -0.0654   0.0177  -1.141  0.1285 
# 
# group = obese:
#   contrast estimate     SE   df lower.CL upper.CL  t.ratio p.value
# 1 - -1    -0.0331 0.0143 85.6  -0.0616  -0.0046  -2.309  0.0117 


# The rest on plot_PAV_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------
