## R code for FOR PIT OBIWAN
# last modified on April 2020 by David MUNOZ TORD

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


# open dataset or load('PIT_Lira.RData')
PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PIT  <- subset(PIT_full, group == 'obese')
HED  <- subset(HED_full, group == 'obese') 
intern  <- subset(intern, group == 'obese') 

#merge with info
PIT = merge(PIT, info, by = "id")

#take out incomplete data ##218 only have the third ? influence -> 238 & 234 & 232 & 254
`%notin%` <- Negate(`%in%`)
PIT = PIT %>% filter(id %notin% c(242,245, 256, 266)) #& 266??
HED = HED %>% filter(id %notin% c(242, 245, 256, 266)) #& 266??
#, 201, 218, 219, 221, 225, 230, 241,  244, 246, 247 check
#242 245 bc MRI & behav 256 task

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
fac <- c("id", "trial", "condition", "session", "trialxcondition", "gender", "intervention")
PIT[fac] <- lapply(PIT[fac], factor)


#check demo
n_tot = length(unique(PIT$id))
bs = ddply(PIT, .(id, session),summarise,mean=mean(AUC))
n_pre = length(which(bs$session == "second"))
n_post = length(which(bs$session == "third"))

AGE = ddply(PIT,~session,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PIT,~session,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PIT, .(id, session), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, session) %>%
  tally() #2 = female

N_inter = ddply(PIT, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(intervention) %>% tally() # 1 = placebo 2 = treart

#remove the baseline from other trials and then scale  by id  
PIT =  subset(PIT, condition != 'BL') 

#exctract liking
HED_BL = ddply(HED, .(id,condition), summarise, lik=mean(perceived_liking))
HED_BL = subset(HED_BL, condition == 'MilkShake')
HED_BL = select(HED_BL, -c(condition) )
PIT = merge(PIT, HED_BL, by = "id")


#  center everything ------------------------------------------------------

# Center level-1 predictor within cluster (CWC)
PIT$gripC = center(PIT$AUC, type = "CWC", group = PIT$id) #nested within session?
#densityPlot(PIT$gripC)

# Center level-2 predictor at the grand mean (CGM)
PIT <- PIT %>% group_by(id) %>% mutate(pissC = center(piss))
PIT <- PIT %>% group_by(id) %>% mutate(thirstyC = center(thirsty))
PIT <- PIT %>% group_by(id) %>% mutate(hungryC = center(hungry))
PIT <- PIT %>% group_by(id) %>% mutate(diff_pissC = center(diff_piss))
PIT <- PIT %>% group_by(id) %>% mutate(diff_thirstyC = center(diff_thirsty))
PIT <- PIT %>% group_by(id) %>% mutate(diff_hungryC = center(diff_hungry))
PIT <- PIT %>% group_by(id) %>% mutate(diff_bmiC = center(BMI_t1 - BMI_t2))
PIT <- PIT %>% group_by(id) %>% mutate(bmiC = center(BMI_t1))
PIT <- PIT %>% group_by(id) %>% mutate(likC = center(lik))
PIT <- PIT %>% group_by(id) %>% mutate(ageC = center(age))


#revalue all catego
#change value of condition
PIT$condition = as.factor(revalue(PIT$condition, c(CSminus="-1", CSplus="1")))
PIT$condition <- factor(PIT$condition, levels = c("1", "-1"))

#change value of sessions
PIT$time = as.factor(revalue(PIT$session, c(second="0", third="1")))

#save RData for cluster computing
# save.image(file = "PIT_LIRA.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PIT.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

# mdl.aov = aov_4(gripC ~ condition*intervention*time + diff_bmiC +  (condition * time |id) ,
#                 data = PIT, observed = "diff_bmiC", factorize = FALSE, fun_aggregate = mean)
# 
# summary(mdl.aov)

#Calculates p-values using parametric bootstrap takes forever #set to method LRT to quick check
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 
#takes ages even on the cluster! # method = "PB", control = control, REML = FALSE, args_test = list(nsim = 1000))
model = mixed(gripC ~ condition*intervention*time + diff_bmiC + (condition * time|id) + (1|trialxcondition), 
              data = PIT, method = "LRT", control = control, REML = FALSE)

model 


#manually test cond
main = lmer(gripC ~ condition*intervention*time + diff_bmiC + (condition * time|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
null = update(main, . ~ . - condition)

#manual test to double check and to get delta AIC
test = anova(main, null, test = 'Chisq')
#test

#get BF fro mixed see Wagenmakers, 2007
exp((test[1,2] - test[2,2])/2) #

#INTER
main1 = lmer(gripC ~ condition*intervention*time + diff_bmiC + (condition * time|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
null1 = update(main, . ~ . - condition:intervention)

#manual test to double check and to get BF
test1 = anova(main1, null1, test = 'Chisq')
#test

exp((test1[1,2] - test1[2,2])/2) #

# Computing CIs and Post-Hoc contrasts ------------------------------------
mod <- lmer(gripC ~ condition*intervention*time + diff_bmiC + (condition * time|id) + (1|trialxcondition), 
            data = PIT, control = control)
#lsmeans::ref_grid(mod)

#increase repetitions limit but it takes foreveeeer
emm_options(pbkrtest.limit = 15000, lmerTest.limit = 15000)

#get CI and pval for condition (right sided)
p_cond = emmeans(mod, pairwise~ condition, side = ">") 
p_cond
# $emmeans
# condition emmean  SE   df lower.CL upper.CL
# 1           8.64 6.8 27.4    -2.93      Inf
# -1         -8.64 6.8 27.4   -20.21      Inf

#get CI condition
CI_cond = confint(emmeans(mod, pairwise~ condition),level = 0.95,method = c("boot"),nsim = 5000)
CI_cond$contrasts
# contrast estimate SE df lower.CL upper.CL t.ratio p.value
# contrast estimate   SE   df t.ratio p.value asymp.LCL asymp.UCL
# 1 - -1       17.3 7.51 48.3 2.301   0.0129  2.93      31.6


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


#get CI inter
CI_inter = confint(emmeans(mod, ~ intervention:condition:time, contr = con, adjust = "mvt"),level = 0.95,method = c("boot"),nsim = 5000)
CI_inter$contrasts
# contrast estimate    SE   df t.ratio p.value    LCL   UCL
# c1          17.78 15.68 48.3 1.134   0.6643  -49.6      37.7
# c2          23.60 15.88 46.2 1.486   0.4276  -37.2      37.0
# c3           7.63  8.65 47.6 0.881   0.8250  -38.7      32.3
# c4          20.10  8.16 48.0 2.463   0.0635   -23.9      42.5e


#looking at coeficients time 0 # takes a while
coef.out <- function(merMod) { coef(merMod)$id[,2] } #column 2 is coeficient for diff of CS- from CS+ at Inter = 0 and time = 0
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=1000,use.u=TRUE,type="parametric"))
coef.conf = confint(boot.out,method="boot",boot.type="perc",level=0.95)
coef.conf

#              2.5 %       97.5 %
# [1,]    0.08587507   36.0527961
# [2,]  -32.30963129    5.5037371
# [3,]  -43.57778223   -5.3070404
# [4,]  -33.10186797    4.4881558
# [5,]  -23.29091773    9.0647046
# [6,]  -32.31895659    7.2385980
# [7,]  -28.48121545    9.4807594
# [8,]  -49.36567242  -13.2377423
# [9,]  -52.33729682  -20.1938471
# [10,]  -27.20179258   14.1601540
# [11,]  -11.96159070   23.5271994
# [12,]  -21.08446326   15.3325834
# [13,]  -76.82561368  -39.0647958
# [14,]  -43.40355105   -5.8995366
# [15,]  -20.29358780   -6.0888675
# [16,]  -67.99646180  -32.5039233
# [17,]  -41.54743980   -8.6065673
# [18,]  -21.50373967   -7.8974127
# [19,]   -6.78979548   34.7183779
# [20,]  -42.83614677  -10.2126424
# [21,]  -80.87137223  -43.8189162
# [22,]  -16.76116123   18.6042973
# [23,]  -20.47072379   17.1164528
# [24,]   -8.87204175   23.3474044
# [25,]  -34.28343787    4.3867584
# [26,]  -30.31889017    5.1632690
# [27,] -117.35815947  -79.1847185
# [28,]   18.31085261   51.7010433
# [29,]  -17.72371176   14.3426688
# [30,]  -31.43066801    0.9444708
# [31,] -149.29065302 -111.9566270
# [32,] -153.86363526 -113.2536573
# [33,]    2.58166797   35.2490216
# [34,]  -35.61688580   -2.9162671
# [35,]  -43.93252041  -11.7538653
# [36,] -124.81412955  -88.5555515
# [37,]  -48.56158541   -5.5379145
# [38,]  -24.22094982    9.2274552
# [39,]  -46.98936936   -9.4582156
# [40,]  -23.05978621   14.8570791
# [41,]   -2.39222639   37.5702890
# [42,]  -72.79943189  -38.8719359
# [43,]  -27.73925678   10.9623252
# [44,]  -44.91007584  -12.4218160
# [45,]   -6.50346718   25.7181158
# [46,]  -17.82606899   21.8684130
# [47,]  -11.72522970   24.9925446
# [48,]  -62.10776977   12.3757345
# [49,]  -18.46116240   20.1071493
# [50,]   35.80856254   71.4891398
# [51,]  -66.05771084  -25.7870939

#This paints a slightly more interesting picture. We have 28 person 
#with no significant decreases  (95%) in grips for the CS- stimulus,
#In other words, the proportion of people showing a PIT effect is 
#estimated to be 45% (23/51)!. -

#looking at coeficients time 0 # takes a while
coef.out <- function(merMod) { coef(merMod)$id[,2]+coef(merMod)$id[,4] }
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=100,use.u=TRUE,type="parametric"))
coef.conf2 = confint(boot.out,method="boot",boot.type="perc",level=0.95)
coef.conf2

# 2.5 %       97.5 %
#   [1,]    0.08587507   36.0527961
# [2,]  -32.30963129    5.5037371
# [3,]  -43.57778223   -5.3070404
# [4,]  -33.10186797    4.4881558
# [5,]  -23.29091773    9.0647046
# [6,]  -32.31895659    7.2385980
# [7,]  -28.48121545    9.4807594
# [8,]  -49.36567242  -13.2377423
# [9,]  -52.33729682  -20.1938471
# [10,]  -27.20179258   14.1601540
# [11,]  -11.96159070   23.5271994
# [12,]  -21.08446326   15.3325834
# [13,]  -76.82561368  -39.0647958
# [14,]  -43.40355105   -5.8995366
# [15,]  -20.29358780   -6.0888675
# [16,]  -67.99646180  -32.5039233
# [17,]  -41.54743980   -8.6065673
# [18,]  -21.50373967   -7.8974127
# [19,]   -6.78979548   34.7183779
# [20,]  -42.83614677  -10.2126424
# [21,]  -80.87137223  -43.8189162
# [22,]  -16.76116123   18.6042973
# [23,]  -20.47072379   17.1164528
# [24,]   -8.87204175   23.3474044
# [25,]  -34.28343787    4.3867584
# [26,]  -30.31889017    5.1632690
# [27,] -117.35815947  -79.1847185
# [28,]   18.31085261   51.7010433
# [29,]  -17.72371176   14.3426688
# [30,]  -31.43066801    0.9444708
# [31,] -149.29065302 -111.9566270
# [32,] -153.86363526 -113.2536573
# [33,]    2.58166797   35.2490216
# [34,]  -35.61688580   -2.9162671
# [35,]  -43.93252041  -11.7538653
# [36,] -124.81412955  -88.5555515
# [37,]  -48.56158541   -5.5379145
# [38,]  -24.22094982    9.2274552
# [39,]  -46.98936936   -9.4582156
# [40,]  -23.05978621   14.8570791
# [41,]   -2.39222639   37.5702890
# [42,]  -72.79943189  -38.8719359
# [43,]  -27.73925678   10.9623252
# [44,]  -44.91007584  -12.4218160
# [45,]   -6.50346718   25.7181158
# [46,]  -17.82606899   21.8684130
# [47,]  -11.72522970   24.9925446
# [48,]  -62.10776977   12.3757345
# [49,]  -18.46116240   20.1071493
# [50,]   35.80856254   71.4891398
# [51,]  -66.05771084  -25.7870939

#This paints a slightly more interesting picture. We have 27 person 
#with no significant decreases  (95%) in grips for the CS- stimulus,
#In other words, the proportion of people showing a PIT effect is 
#estimated to be 47% (24/51)!. -








