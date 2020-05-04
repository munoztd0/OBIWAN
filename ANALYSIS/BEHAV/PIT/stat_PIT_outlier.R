## R code for FOR OBIWAN_PIT Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, ggplot2, Rmisc, dplyr, lmerTest, car, r2glmm, optimx, visreg, MuMIn,  pbkrtest, bootpredictlme4, sjPlot)

#SETUP
task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$id      <- as.factor(info$id)

#subset
OBIWAN_PIT  <- subset(OBIWAN_PIT_full, session == 'second') #only session 2

# define as.factors
OBIWAN_PIT$id      <- as.factor(OBIWAN_PIT$id)
OBIWAN_PIT$trial    <- as.factor(OBIWAN_PIT$trial)
OBIWAN_PIT$group    <- as.factor(OBIWAN_PIT$group)

#OBIWAN_PIT$condition[OBIWAN_PIT$condition== 'Empty']     <- 'Control'

OBIWAN_PIT$condition <- as.factor(OBIWAN_PIT$condition)

OBIWAN_PIT$trialxcondition <- as.factor(OBIWAN_PIT$trialxcondition)

OBIWAN_PIT = full_join(OBIWAN_PIT, info, by = "id")

OBIWAN_PIT <-OBIWAN_PIT %>% drop_na("condition")


# get means by condition 
bt = ddply(OBIWAN_PIT, .(trialxcondition), summarise,   gripFreq = mean( gripFreq, na.rm = TRUE)) 
btg = ddply(OBIWAN_PIT, .(group, trialxcondition), summarise,   gripFreq = mean( gripFreq, na.rm = TRUE))

# get means by condition and trialxcondition
btc = ddply(OBIWAN_PIT, .(condition, trialxcondition), summarise,   gripFreq = mean( gripFreq, na.rm = TRUE))
btcg = ddply(OBIWAN_PIT, .(group, condition, trialxcondition), summarise,   gripFreq = mean( gripFreq, na.rm = TRUE))

# get means by participant 
bsT = ddply(OBIWAN_PIT, .(id, trialxcondition), summarise,  gripFreq = mean( gripFreq, na.rm = TRUE))
bsC= ddply(OBIWAN_PIT, .(id, condition), summarise,  gripFreq = mean( gripFreq, na.rm = TRUE))
bsTC = ddply(OBIWAN_PIT, .(id, trialxcondition, condition), summarise,  gripFreq = mean( gripFreq, na.rm = TRUE))

bsTg = ddply(OBIWAN_PIT, .(id, group, trialxcondition), summarise,  gripFreq = mean( gripFreq, na.rm = TRUE)) 
bsCg= ddply(OBIWAN_PIT, .(id, group, condition), summarise,  gripFreq = mean( gripFreq, na.rm = TRUE))
bsTCg = ddply(OBIWAN_PIT, .(id, group, trialxcondition, condition), summarise,  gripFreq = mean( gripFreq, na.rm = TRUE)) 

#check for weird behaviors in BsC-> especially in ID.. 201 218 239 242 249 256 259 266 269 267
#Visible outliers (in descriptive stats)
#con_106 -> didn't press at all for any
#con_122 -> only press for the baseline
#ob_242 -> didn't have the tubes during PIT
#ob_249 -> ne fait plus la tache apes 3 essais
#ob_256 -> arrive pas a faire la tache ("pas doué avec les ordis")
#ob_259 -> detest le milkshake
#ob_266 -> comprends pas la tache

#subset outliers
OBIWAN_PIT_out  <- subset(OBIWAN_PIT, id != 106 & id != 122 & id != 242 &id != 249 & id != 256 & id != 259 & id != 266) 


#before was 30 con and 62 ob
n = length(unique(OBIWAN_PIT$id))

con = subset(OBIWAN_PIT, group == 'control')
obe = subset(OBIWAN_PIT, group == 'obese')
n_con = length(unique(con$id))
n_obe = length(unique(obe$id))

#now 28 con and 57 ob %enlever 8%

# QUICK STATS -------------------------------------------------------------------

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman


#scale everything
OBIWAN_PIT$gripFreq= scale(OBIWAN_PIT$gripFreq)
OBIWAN_PIT$bmi = hscale(OBIWAN_PIT$BMI_t1, OBIWAN_PIT$id) #agragate by subj and then scale 
OBIWAN_PIT$ageZ = hscale(OBIWAN_PIT$age, OBIWAN_PIT$id) #agragate by subj and then scale 

OBIWAN_PIT_out$gripFreq= scale(OBIWAN_PIT_out$gripFreq)
OBIWAN_PIT_out$bmi = hscale(OBIWAN_PIT_out$BMI_t1, OBIWAN_PIT_out$id) #agragate by subj and then scale 
OBIWAN_PIT_out$ageZ = hscale(OBIWAN_PIT_out$age, OBIWAN_PIT_out$id) #agragate by subj and then scale 


#************************************************** test
mdl.force = lmer(gripFreq ~ condition*bmi*trialxcondition+ gender + ageZ + (condition|id), data = OBIWAN_PIT, REML=FALSE)
anova(mdl.force)

mdl.forceout = lmer(gripFreq ~ condition*bmi*trialxcondition+ gender + ageZ + (condition|id), data = OBIWAN_PIT_out, REML=FALSE)
anova(mdl.forceout)
#DOESNT CHANGE ANYTHING