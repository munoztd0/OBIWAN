## R code for FOR INST OBIWAN
# last modified on April 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, Rmisc, lspline, car, afex, r2glmm, optimx, emmeans,misty)

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
INST  <- subset(INST_full, group == 'obese') 
intern  <- subset(intern, group == 'obese') 

#merge with info
INST = merge(INST, info, by = "id")

#take out incomplete data ##218 only have the third ? influence? -> 238 & 234 & 232 & 254
#exclude 242 really outlier everywhere, 256 can't do the task, 123 & 124 incomplete data
`%notin%` <- Negate(`%in%`)
INST = INST %>% filter(id %notin% c(242, 256)) 
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
fac <- c("id", "trial", "gender", "session", "intervention")
INST[fac] <- lapply(INST[fac], factor)

#check demo
n_tot = length(unique(INST$id))
bs = ddply(INST, .(id, trial), summarise, grips = mean(grips, na.rm = TRUE)) 
bt = ddply(INST, .(trial), summarise, grips = mean(grips, na.rm = TRUE)) 
#bs$grips = scale(bs$grips)
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

INST$trial = as.numeric(INST$trial)
INST$time <- scale(INST$trial)

#spline at 4 
INST$spline <- ifelse(INST$trial<5, 0, INST$trial-5)

#save RData for cluster computing
save.image(file = "INST_LIRA.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#model with everything #quick check the covariates #keep it simple
# aov_car(gripC ~ trial*group + ageC +  gender + pissC + thirstyC + hungryC + diff_pissC + diff_thirstyC + diff_hungryC
#         + Error(id/trial), data = INST, factorize = FALSE, observed = c("gender", "ageC", "pissC", "thirstyC", "hungryC", "diff_pissC", "diff_thirstyC", "diff_hungryC"))

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#set to method LRT to quick check

model = mixed(gripC ~ trial+spline + session + intervention + trial:session + trial:intervention + spline:session + spline:intervention + session:intervention + trial:session:intervention +  spline:session:intervention +
                + thirstyC + thirstyC:trial + thirstyC:spline +   hungryC + pissC + (session |id) ,  data = INST, method = "LRT", control = control, REML = FALSE)
model

# Data: INST
# Df full model: 21
# Effect df     Chisq p.value
# 1                        trial  1    5.94 *    .015
# 2                       spline  1 22.30 ***   <.001
# 3                      session  1 15.95 ***   <.001
# 4                 intervention  1   8.74 **    .003
# 5                     thirstyC  1    4.01 *    .045
# 6                      hungryC  1      0.00    .987
# 7                        pissC  1      0.00    .998
# 8                trial:session  1 52.80 ***   <.001
# 9           trial:intervention  1    3.70 +    .055
# 10              spline:session  1 51.15 ***   <.001
# 11         spline:intervention  1      1.81    .178
# 12        session:intervention  1      0.10    .748
# 13              trial:thirstyC  1    4.19 *    .041
# 14             spline:thirstyC  1    3.94 *    .047
# 15  trial:session:intervention  1      0.89    .345
# 16 spline:session:intervention  1      0.31    .580

mod <- lmer(gripC ~ lspline(trial, 5)* session*intervention +  thirstyC + thirstyC:trial + thirstyC:spline +  hungryC + pissC + (session |id) ,  data = INST, control = control)
summary(mod)

visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="trial", by='session', gg=TRUE,type="contrast",ylab="liking",breaks=c(-1,0,1),xlab="int")

#coef learning 1-5 -> 0.3255 +/- 0.08531 SE
#coef learning 6-24 -> -0.1117 +/- 0.01395

#### The rest on plot_INST_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------
