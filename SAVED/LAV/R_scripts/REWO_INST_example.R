## R code for FOR REWOD_INST
# last modified on Nov 2018 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
#if(!require(pacman)) {
  #install.packages("pacman")
  #library(pacman)
#}
#pacman::p_load(car, lme4, lmerTest, pbkrtest, ggplot2, dplyr, plyr, tidyr, multcomp, mvoutlier, HH, doBy, psych, pastecs, reshape, reshape2, 
               #jtools, effects, compute.es, DescTools, MBESS, afex, ez, metafor, influence.ME)

#require(lattice)
rm(list = ls())


#SETUP

# load library
library(lme4)
library(lmerTest)
library(ggplot2)
library(dplyr)
library(plyr)

# Set working directory
analysis_path <- '~/rewod/DATABASES/'# for this to work the script needs to be sourced
setwd(analysis_path)

# open dataset
REWOD_INST <- read.delim(file.path(analysis_path,'REWOD_INSTRUMENTAL.txt'), header = T, sep ='') # read in dataset

# define factors
REWOD_INST$id               <- factor(REWOD_INST$id)
#REWOD_INST$trial            <- factor(REWOD_INST$trial)
REWOD_INST$session          <- factor(REWOD_INST$session)
REWOD_INST$rewarded_response        <- factor(REWOD_INST$rewarded_response)

## remove sub 8 (we dont have scans)
REWOD_INST <- subset (REWOD_INST,!id == '8') 

# PLOTS
## plot non-averaged per participant

#n_grips per trial
boxplot(REWOD_INST$n_grips ~ REWOD_INST$trial, las = 1)


## plot overall effects

# get means by trial
bc = ddply(REWOD_INST, .(trial), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 

# get means by participant 
bs = ddply(REWOD_INST, .(id, trial), summarise, n_grips = mean(n_grips, na.rm = TRUE)) 

#Ngrips average per trial
boxplot(bc$n_grips ~ bc$trial, las = 1)


##plot n_grips to see the trajectory of learning (overall average by trials)

ggplot(bc, aes(x = trial, y = n_grips, fill = I('royalblue1'), color = I('royalblue4'))) +
  geom_point() + geom_line(group=1) +
  guides(color = "none", fill = "none") +
  guides(color = "none", fill = "none") +
  theme_bw() +
  labs(
    title = "Average n-grips per trial",
    x = "Trial",
    y = "number of grips"
  )

#OR different representation
ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                       "Intercept =",signif(fit$coef[[1]],5 ),
                       " Slope =",signif(fit$coef[[2]], 5),
                       " P =",signif(summary(fit)$coef[2,4], 5)))
}

# plot number of grips by time with regression lign
ggplotRegression(lm(n_grips ~ trial, data = bc))




#ANALYSIS

##1. number of grips: are participants gripping more over time?

#contrasts?? (should I include the first trial even its biased)
REWOD_INST$trial            <- factor(REWOD_INST$trial)
REWOD_INST$time <- rep(0, (length(REWOD_INST$trial)))
REWOD_INST$time[REWOD_INST$trial== '24']     <- 1
REWOD_INST$time[REWOD_INST$trial== '23']     <- 1
REWOD_INST$time[REWOD_INST$trial== '22']     <- 1
REWOD_INST$time[REWOD_INST$trial== '2']     <- -1
REWOD_INST$time[REWOD_INST$trial== '3']     <- -1
REWOD_INST$time[REWOD_INST$trial== '4']     <- -1
REWOD_INST$time        <- factor(REWOD_INST$time)

# classical anova 
summary(aov(n_grips ~ time + Error(id / (time)), data = REWOD_INST)) 
#sentence => F prop associated to Time is not significant
