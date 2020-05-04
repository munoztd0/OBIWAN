## R code for FOR OBIWAN_HED Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, ggplot2, Rmisc, dplyr, lmerTest, car, r2glmm, optimx, visreg, MuMIn,  pbkrtest, bootpredictlme4, sjPlot)
#lme4
#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, Bayesas.factor)

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
OBIWAN_HED$gender   <- as.factor(OBIWAN_HED$gender) #M=0

#OBIWAN_HED$condition[OBIWAN_HED$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_HED$condition[OBIWAN_HED$condition== 'Empty']     <- 'Control'
OBIWAN_HED$condition <- as.factor(OBIWAN_HED$condition)

OBIWAN_HED$trialxcondition <- as.factor(OBIWAN_HED$trialxcondition)

OBIWAN_HED = full_join(OBIWAN_HED, info, by = "id")

OBIWAN_HED <-OBIWAN_HED %>% drop_na("condition")


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

#take out participants with corrupted data (missing trials or problem during the passation)
OBIWAN_PIT_out  <- subset(OBIWAN_PIT, id != 242 & id != 256)

#check for weird behaviors in BsC-> especially in ID.. 267 259 256 242
#Visible outliers (in descriptive stats)
#"Loved (>80) Neutral" : 102 , 219 , 114
#"Hated (>20) Milkshake": 109, 114, 253, 259, 203, 210

#27 con , 63 obe

#subset outliers
OBIWAN_HED_out  <- subset(OBIWAN_HED, id != 102 & id != 114 & id != 219 &id != 109 & id != 114 & id != 253 & id != 259 & id != 203 & id != 210) 
#24 con , 58 obe we took out 9%

n = length(unique(OBIWAN_HED_out$id))

con = subset(OBIWAN_HED_out, group == 'control')
obe = subset(OBIWAN_HED_out, group == 'obese')
n_con = length(unique(con$id))
n_obe = length(unique(obe$id))


# QUICK STATS -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#scale everything
OBIWAN_HED$perceived_liking= scale(OBIWAN_HED$perceived_liking)
OBIWAN_HED$perceived_familiarity = scale(OBIWAN_HED$perceived_familiarity)
OBIWAN_HED$perceived_intensity = scale(OBIWAN_HED$perceived_intensity)
OBIWAN_HED$bmi = hscale(OBIWAN_HED$BMI_t1, OBIWAN_HED$id) #agragate by subj and then scale 
OBIWAN_HED$ageZ = hscale(OBIWAN_HED$age, OBIWAN_HED$id) #agragate by subj and then scale 


OBIWAN_HED_out$perceived_liking= scale(OBIWAN_HED_out$perceived_liking)
OBIWAN_HED_out$perceived_familiarity = scale(OBIWAN_HED_out$perceived_familiarity)
OBIWAN_HED_out$perceived_intensity = scale(OBIWAN_HED_out$perceived_intensity)
OBIWAN_HED_out$bmi = hscale(OBIWAN_HED_out$BMI_t1, OBIWAN_HED_out$id) #agragate by subj and then scale 
OBIWAN_HED_out$ageZ = hscale(OBIWAN_HED_out$age, OBIWAN_HED_out$id) #agragate by subj and then scale 



#************************************************** test
mdl.liking = lmer(perceived_liking ~ condition*bmi*trialxcondition + gender + ageZ+ (condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.liking)

#************************************************** test
mdl.likingout = lmer(perceived_liking ~ condition*bmi*trialxcondition + gender + ageZ+ (condition|id)+ (condition|trialxcondition), data = OBIWAN_HED_out, REML=FALSE)
anova(mdl.likingout)
#DOESNT CHANGE ANYTHING
