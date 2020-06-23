## R code for FOR OBIWAN_PIT
# last modified on February by Eva

# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
install.packages("pacman")
library(pacman)
}
pacman::p_load(car, lme4, lmerTest, pbkrtest, ggplot2, dplyr, plyr, tidyr, multcomp, mvoutlier, HH, doBy, psych, pastecs, reshape, reshape2, 
jtools, effects, compute.es, DescTools, MBESS, afex, ez, metafor, influence.ME)


#SETUP

# Set working directory
analysis_path <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(analysis_path)

# open dataset
PIT     <- read.delim(file.path(analysis_path,'OBIWAN_PIT_control.txt'), header = T, sep ='') # read in dataset
HEDO    <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC_control.txt'), header = T, sep ='') # read in dataset


# define factors
PIT$id       <- factor(PIT$id)
PIT$trial    <- factor(PIT$trial)
PIT$group    <- factor(PIT$group)
PIT$condition <- factor(PIT$condition)
PIT$trialxcondition <- factor(PIT$trialxcondition)

# CSp vs CS- constrast
PIT$CSpCSm[PIT$condition == 'CSminus'] <- -1
PIT$CSpCSm[PIT$condition== 'CSplus']  <-  1
PIT$CSpCSm[PIT$condition== 'BL']      <- 0

PIT$CSprest[PIT$condition == 'CSminus'] <- -1
PIT$CSprest[PIT$condition== 'CSplus']  <- +2
PIT$CSptest[PIT$condition== 'BL']      <- -1

# PLOTS
PIT$Condition[PIT$condition== 'CSplus']   <- 'CS+'
PIT$Condition[PIT$condition== 'CSminus']  <- 'CS-'
PIT$Condition[PIT$condition== 'BL']       <- 'Baseline'


# PIT <- subset (PIT,!id == '114') # illustration on how to remove a participant

#--------------------------------------------- PLOTS -------------------------------------------------
 
# PLOT 1 main effect by subject
PIT.bs = ddply(PIT, .(id, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)) 
bg = ddply(PIT.bs,.(condition),summarise, gripFreq=mean(gripFreq))
er   <- ddply(PIT.bs, .(condition), summarise, gripFreq = sd(gripFreq)/sqrt(length(gripFreq)))


ggplot(PIT.bs, aes(x = condition, y = gripFreq, fill = condition, color = condition)) +
  geom_point(alpha = .5)  +
  #geom_violin(alpha = .1)+
  geom_bar(data =bg, stat = "identity", width=.9, position = "dodge", alpha = .5, color = NA) +
  geom_errorbar(data = bg, aes(ymin = gripFreq - er$gripFreq, ymax = gripFreq + er$gripFreq), width = .1) +
  geom_line(aes(group = id), alpha = .2, size = 0.5, color = "gray") +
  theme_bw() +
  labs(
    title = "Pavlovian Instrumental Transfer",
    x = "Trial",
    y = "Number of grips"
  )

# PLOT 2 main effect by trial
PIT.bt   = ddply(PIT, .(trialxcondition, condition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE)) 

ggplot(PIT.bt, aes(x = trialxcondition, y = gripFreq, fill = condition, color = condition)) +
  geom_point()  +
  geom_line(aes(group = condition), alpha = .3, size = 1) +
  theme_bw() +
  labs(
    title = "Pavlovian Instrumental Transfer",
    x = "Trial",
    y = "Number of grips"
  )



#------------------------------------------ inferential statistics -----------------------------------------

# lmer models
mdl.main <- lmer(gripFreq ~ condition + trialxcondition + (condition|id) + (condition|trialxcondition) , data = PIT, REML = FALSE)  #1+cvalue\id or 1\id
anova(mdl.main)
mdl.CSpCSm<- lmer(gripFreq ~ CSpCSm + trialxcondition + (CSpCSm|id) + (condition|trialxcondition) , data = PIT, REML = FALSE)  #1+cvalue\id or 1\id
anova(mdl.CSpCSm)
mdl.CSpRest <- lmer(gripFreq ~ CSprest + trialxcondition + (CSprest|id) + (condition|trialxcondition) , data = PIT, REML = FALSE)  #1+cvalue\id or 1\id
anova(mdl.CSpRest)




