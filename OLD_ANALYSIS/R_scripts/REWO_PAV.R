## R code for FOR REWOD_PAV
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

# load library
#library(sjstats)
#library(gamlss)
library(lme4)
library(lmerTest)
library(ggplot2)
library(plyr)
library(dplyr)


#SETUP

# Set working directory
analysis_path <- '~/rewod/DATABASES/'; # for this to work the script needs to be sourced
setwd(analysis_path)

# open dataset
REWOD_PAV <- read.delim(file.path(analysis_path,'REWOD_PAVLOVIAN.txt'), header = T, sep ='') # read in dataset

# define factors
REWOD_PAV$id               <- factor(REWOD_PAV$id)
REWOD_PAV$trial            <- factor(REWOD_PAV$trial)
REWOD_PAV$session          <- factor(REWOD_PAV$session)
REWOD_PAV$condition        <- factor(REWOD_PAV$condition)

# get times in milliseconds 
REWOD_PAV$RT       <- REWOD_PAV$RT * 1000

# remove sub 8 (bc we dont have scans)
REWOD_PAV <- subset (REWOD_PAV,!id == '8') 

#Cleaning
##no Baseline
REWOD_PAV.clean <- filter(REWOD_PAV, condition != "Baseline")
REWOD_PAV.clean$condition <- droplevels(REWOD_PAV.clean$condition, exclude = "Baseline")

##shorter than 100ms and longer than 3sd+mean
REWOD_PAV.clean <- filter(REWOD_PAV.clean, RT >= 100) # min RT is 106ms
mean <- mean(REWOD_PAV.clean$RT)
sd <- sd(REWOD_PAV.clean$RT)
REWOD_PAV.clean <- filter(REWOD_PAV.clean, RT <= mean +3*sd) #which is 854.4ms
#now accuracy is to a 100%

##only first round
REWOD_PAV.clean <- filter(REWOD_PAV.clean, rounds == 1)


#PLOTS 

##plot (non-averaged per participant) 

# reaction time by conditions #(baseline non included)
boxplot(REWOD_PAV.clean$RT ~ REWOD_PAV.clean$condition, las = 1)

# get RT and Liking means by condition (with baseline)
bc = ddply(REWOD_PAV, .(condition), summarise,  RT = mean(RT, na.rm = TRUE), liking_ratings = mean(liking_ratings, na.rm = TRUE)) 

# get acc means by condition (without baseline)
ba = ddply(REWOD_PAV.clean, .(condition), summarise,  accuracy = mean(accuracy, na.rm = TRUE))

# get RT and Liking means by participant (with baseline)
bs = ddply(REWOD_PAV, .(id, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking_ratings = mean(liking_ratings, na.rm = TRUE))

# get acc means by participant (without baseline)
bsacc = ddply(REWOD_PAV.clean, .(id), summarise, accuracy = mean(accuracy, na.rm = TRUE))

## plot overall effect RT##


#RT average per subjects by condition (baseline non included)
bsrt <- filter(bs, condition != "Baseline")
bsrt$condition <- droplevels(bsrt$condition, exclude = "Baseline")
boxplot(bsrt$RT ~ bsrt$condition, las = 1)


## plot overall effect Ratings

# condition X ratings
boxplot(bs$liking_ratings ~ bs$condition, las = 1)



# ANALYSIS

## 1. Reaction time: are participants faster to detect CS associated with reward? 

# lmer analyis 
main.RT = lmer(RT ~ condition + (1+condition|id) + (1|trial), data = REWOD_PAV.clean, REML = FALSE)
anova(main.RT)

# quick check with classical anova (! this is not reliable)
summary(aov(RT ~ condition + Error(id / (condition)), data = REWOD_PAV.clean))

# model comparison
main.RT.0 = lmer(RT ~ (1|id) + (1|trial), data = REWOD_PAV.clean, REML = FALSE)
anova(main.RT.0, main.RT, test = 'Chisq')

#sentence => CHi² prop is significative **



##2. Liking ratings: do participants like more the CS associated with reward? 

#define contrasts of interest based on hypothesis 
bs$cvalue[bs$condition== 'CSplus']     <- 2
bs$cvalue[bs$condition== 'CSminus']     <- -1
bs$cvalue[bs$condition== 'Baseline']     <- -1
bs$cvalue        <- factor(bs$cvalue)

# classical anova 
summary(aov(liking_ratings ~ cvalue + Error(id / (cvalue)), data = bs))
#sentence => F prop is significative




##take a quick descriptive look at ACC

#pressed <- filter(REWOD_PAV.clean, accuracy == 1)
#hits <- nrow(pressed)
#notpressed <- filter(REWOD_PAV.clean, accuracy == 0)
#miss <- nrow(notpressed)
#total <- nrow(REWOD_PAV.clean)

#hits/total * 100 # total Acc = 98.07099
#filter(ba, condition == 'CSminus')#CSminus Acc = XX
#filter(ba, condition == 'CSplus')#CSplus Acc = XX
#summarise(bsacc, min(accuracy)) # min acc is XX sub Y

