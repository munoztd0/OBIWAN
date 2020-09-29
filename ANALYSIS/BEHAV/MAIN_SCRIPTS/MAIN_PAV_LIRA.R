## R code for FOR PAV OBIWAN LIRA
# last modified on April 2020 by David MUNOZ TORD

# REMOVE STUFF ----------------------------------------
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


# open dataset or load('PAV_LIRA.RData')
PAV_full <- read.delim(file.path(analysis_path,'OBIWAN_PAV.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PAV  <- subset(PAV_full, group == 'obese') 
intern  <- subset(intern, group == 'obese') 

#merge with info
PAV = merge(PAV, info, by = "id")

#take out incomplete data ## look out for  122 & 110 & 254 outliers!
#exclude 242 really outlier everywhere, 256 can't do the task, 228 also
`%notin%` <- Negate(`%in%`)
PAV = PAV %>% filter(id %notin% c(242, 256, 228)) #check 224 254 227
intern = intern %>% filter(id %notin%  c(242, 256, 228))

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

PAV$idXsession = as.numeric(PAV$id) * as.numeric(PAV$session)

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
PAV$RT_TC = center(PAV$RT_T, type = "CWC", group = PAV$idXsession)
PAV$likC = center(PAV$liking, type = "CWC", group = PAV$idXsession)

# Center level-2 predictor at the grand mean (CGM)
PAV <- PAV %>% group_by(idXsession) %>% mutate(pissC = center(piss))
PAV <- PAV %>% group_by(idXsession) %>% mutate(thirstyC = center(thirsty))
PAV <- PAV %>% group_by(idXsession) %>% mutate(hungryC = center(hungry))
PAV <- PAV %>% group_by(idXsession) %>% mutate(diff_pissC = center(diff_piss)) 
PAV <- PAV %>% group_by(idXsession) %>% mutate(diff_thirstyC = center(diff_thirsty))
PAV <- PAV %>% group_by(idXsession) %>% mutate(diff_hungryC = center(diff_hungry))
PAV <- PAV %>% group_by(id) %>% mutate(ageC = center(age))
PAV <- PAV %>% group_by(id) %>% mutate(diff_bmiC = center(BMI_t1 - BMI_t2))
PAV <- PAV %>% group_by(id) %>% mutate(bmiC = center(BMI_t1))

#revalue all catego
#change value of group
PAV$time = as.factor(revalue(PAV$session, c(second="0", third="1")))

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
#save.image(file = "PAV_LIRA.RData", version = NULL, ascii = FALSE,compress = FALSE, safe = TRUE)

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PAV_LIRA.R

mdl.aov = aov_4(RT_TC ~ condition*intervention*time + diff_bmiC + likC +  (condition * time |id) ,
                data = PAV, observed = c("diff_bmiC", "age", "likC"), factorize = FALSE, fun_aggregate = mean)

mdl.aov = aov_4(RT_TC ~ condition*intervention*time +  (condition * time |id) ,
                data = PAV, factorize = FALSE, fun_aggregate = mean)

summary(mdl.aov)

#set to method LRT to quick check
model = mixed(RT_TC ~ condition*intervention*time  + diff_bmiC+ likC+ (condition*time|id) + (1|trialxcondition),
              data = PAV, method = "LRT", control = control, REML = FALSE)
model

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: RT_TC ~ condition * intervention * time + diff_bmiC + likC + 
#   Model:     (condition * time | id) + (1 | trialxcondition)
# Data: PAV
# Df full model: 22
# Effect df     Chisq p.value
# 1                   condition  1      23.98    <.001 ***
# 2                intervention  1      0.01    .907
# 3                        time  1      5.44     .020 *
# 4                   diff_bmiC  1      0.02    .891
# 5                        likC  1      30.56    <.001 ***
# 6      condition:intervention  1      1.52    .217
# 7              condition:time  1      7.38     .007 **
# 8           intervention:time  1      0.14    .712
# 9 condition:intervention:time  1      0.62    .430

#increase repetitions limit but it takes foreveeeer
emm_options(pbkrtest.limit = 15000, lmerTest.limit = 15000)

mod <- lmer(RT_TC ~ condition*intervention*time + likC + diff_bmiC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control)
ref_grid(mod) #triple check everything is more or less centered at 0

#manullay
main = lmer(RT_TC ~ condition*intervention*time + likC + diff_bmiC + (condition*time|id) + (1|trialxcondition), 
            data = PAV, control = control, REML = FALSE)
null = lmer(RT_TC ~ condition + intervention*time + likC + diff_bmiC + (condition*time|id) + (1|trialxcondition), 
            data = PAV, control = control, REML = FALSE)

#manual test to double check and to get BF
test = anova(main, null, test = 'Chisq')
#test

#get BF from mixed see Wagenmakers, 2007
exp((test[1,2] - test[2,2])/2) # 10.41099

#get CI and pval for condition (left sided!)
p_cond = emmeans(mod, pairwise~ condition, side = "<") 
p_cond
#get CI condition
CI_cond = confint( emmeans(mod, pairwise~ condition),level = 0.95,method = c("boot"),nsim = 5000)
CI_cond$contrasts
# contrast estimate     SE df lower.CL upper.CL t.ratio p.value
# contrast estimate   SE  df z.ratio p.value
# 1 - -1        -24 4.88 Inf -4.925  <.0001 

#INTER
con <- list(
  c1 = c(0, 0, 0, 0, 1, -1, 0, 0), #Post: CSp Placebo > CSm Placebo
  c2 = c(0, 0, 0, 0, 0, 0, 1, -1), #Post: CSp Lira > CSm Lira
  c3 = c(0, 0, 1, -1, 0, 0, 0, 0), #Pre: CSp Lira > CSm Lira
  c4 = c(1, -1, 0, 0, 0, 0, 0, 0) #Pre: CSp Placebo > CSm Placebo
)

# con1 <- list(
#   c5 = c(0,0, 0, 0, -1, -1, 1, 1), #Post: CSp+CSm Placebo > CSp + CSm Lira
#   c6 = c(-1, -1, 1, 1, 0, 0, 0, 0)  #Pre: CSp+CSm Placebo > CSp + CSm Lira
# )

#get CI and pval for inter

p_inter = emmeans(mod, ~ condition:intervention:time, contr = con, adjust = "mvt")
p_inter

#get contrasts for intevention X condition (adjusted but still left sided)
inter = emmeans(mod, pairwise~ condition|intervention|time, adjust = "tukey", side = "<") 
inter$contrasts
#get CI contrasts
CI_inter = confint(emmeans(mod, pairwise~ condition|intervention|time),level = 0.95,method = c("boot"),nsim = 5000)
CI_inter$contrasts

#   contrast estimate     SE   df lower.CL upper.CL t.ratio p.value



#looking at coeficients time 0 # takes a while
coef.out <- function(merMod) { coef(merMod)$id[,2] } #column 2 is coeficient for diff of CS- from CS+ at Inter = 0 and time = 0
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=1000,use.u=TRUE,type="parametric"))
coef.conf = confint(boot.out,method="boot",boot.type="perc",level=0.95)
coef.conf

#looking at coeficients time 0 # takes a while
coef.out <- function(merMod) { coef(merMod)$id[,2]+coef(merMod)$id[,4] }
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=100,use.u=TRUE,type="parametric"))
coef.conf2 = confint(boot.out,method="boot",boot.type="perc",level=0.95)
coef.conf2

#This paints a slightly more interesting picture. We have XX person 
#with no significant decreases  (95%) in grips for the CS- stimulus,
#In other words, the proportion of people showing a PIT effect is 
#estimated to be x% (x/51)!. -


# The rest on plot_PAV_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------
