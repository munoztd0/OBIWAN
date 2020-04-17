## R code for FOR REWOD_PIT
# last modified on Nov 2018 by David

# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(influence.ME,lmerTest, lme4, ez, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


#SETUP
task = 'PIT'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
setwd(analysis_path)

# open dataset
REWOD_PIT <- read.delim(file.path(analysis_path,'REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset

## subsetting into 3 differents tasks
REWOD_PIT.all <- REWOD_PIT
REWOD_RIM <- subset (REWOD_PIT.all,task == 'Reminder') 
REWOD_PE <- subset (REWOD_PIT.all,task == 'Partial_Extinction') 
REWOD_PIT <- subset (REWOD_PIT.all,task == 'PIT') 


# define factors
REWOD_RIM$id               <- factor(REWOD_RIM$id)
REWOD_RIM$trial            <- factor(REWOD_RIM$trial)
REWOD_RIM$task              <- factor(REWOD_RIM$task)
REWOD_RIM$session          <- factor(REWOD_RIM$session)
REWOD_RIM$reward          <- factor(REWOD_RIM$reward)

REWOD_PE$id               <- factor(REWOD_PE$id)
REWOD_PE$trial            <- factor(REWOD_PE$trial)
REWOD_PE$task              <- factor(REWOD_PE$task)
REWOD_PE$session          <- factor(REWOD_PE$session)
REWOD_PE$reward        <- factor(REWOD_PE$reward)

REWOD_PIT$id               <- factor(REWOD_PIT$id)
REWOD_PIT$trial            <- factor(REWOD_PIT$trial)
REWOD_PIT$task              <- factor(REWOD_PIT$task)
REWOD_PIT$session          <- factor(REWOD_PIT$session)


# PLOTS
REWOD_PIT$Condition[REWOD_PIT$condition== 'CSplus']     <- 'CS+'
REWOD_PIT$Condition[REWOD_PIT$condition== 'CSminus']     <- 'CS-'
REWOD_PIT$Condition[REWOD_PIT$condition== 'Baseline']     <- 'Baseline'

REWOD_PIT$Condition <- as.factor(REWOD_PIT$Condition)
REWOD_PIT$trialxcondition <- as.factor(REWOD_PIT$trialxccondition)
# # FUNCTIONS -------------------------------------------------------------


ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                       "Intercept =",signif(fit$coef[[1]],5 ),
                       " Slope =",signif(fit$coef[[2]], 5),
                       " P =",signif(summary(fit)$coef[2,4], 5)))
}



# cleaning ----------------------------------------------------------------


## plot overall effect
# get means by trialxcondition
RIM.bt = ddply(REWOD_RIM, .(trial), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 
PE.bt = ddply(REWOD_PE, .(trial), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 
PIT.bt = ddply(REWOD_PIT, .(trialxcondition), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 

# get means by condition
PIT.bc = ddply(REWOD_PIT, .(condition), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 

# get means by trial & condition
PIT.bct = ddply(REWOD_PIT, .(trialxcondition, condition), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 

# get means by participant 
RIM.bs = ddply(REWOD_RIM, .(id, trial), summarise, n_grips = mean(n_grips, na.rm = TRUE)) #not condition
PE.bs = ddply(REWOD_PE, .(id, trial), summarise, n_grips = mean(n_grips, na.rm = TRUE)) #not condition
PIT.bs = ddply(REWOD_PIT, .(id, Condition), summarise, n_grips = mean(n_grips, na.rm = TRUE)) 



# PLOTS -------------------------------------------------------------------



##plot n_grips to see the trajectory of learning (overall average by trials) by conditions

df <- summarySE(REWOD_PIT, measurevar="n_grips", groupvars=c("id", "trialxcondition", "Condition"))

dfPIT <- summarySEwithin(df,
                           measurevar = "n_grips",
                           withinvars = c("Condition", "trialxcondition"), 
                           idvar = "id")


dfPIT$Condition = factor(dfPIT$Condition,levels(dfPIT$Condition)[c(3,2,1)])
dfPIT$trialxcondition =as.numeric(dfPIT$trialxcondition)


ggplot(dfPIT, aes(x = trialxcondition, y = n_grips, color=Condition)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_line(alpha = .7, size = 1, position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = n_grips + se, ymin = n_grips - se), width=0.5, alpha=0.7, size=0.4,position = position_dodge(width = 0.5))+
  scale_colour_manual(values = c("CS+"="blue", "CS-"="red", "Baseline"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(4.0,16)) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  scale_x_continuous(expand = c(0, 0), limits = c(-10 ,16), breaks=c(-10,seq.int(-9,15, by = 2),16))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Number of Squeezes")



#  REminder
df <- summarySE(REWOD_RIM, measurevar="n_grips", groupvars=c("id", "trial"))

dfRIM <- summarySEwithin(df,
                         measurevar = "n_grips",
                         withinvars = c("trial"), 
                         idvar = "id")


dfRIM$Task_Name <- paste0("Reminder")
dfRIM$trial =as.numeric(dfRIM$trial)
##plot n_grips to see the trajectory of learning (overall average by trials)

ggplot(dfRIM, aes(x = trial, y = n_grips, color=Task_Name)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_line(alpha = .7, size = 1, position = position_dodge(width = 0.5), linetype = "dashed") +
  geom_errorbar(aes(ymax = n_grips + se, ymin = n_grips - se), width=0.5, alpha=0.7, size=0.4,position = position_dodge(width = 0.5))+
  scale_colour_manual(values = c("Reminder"="grey")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(4.0,16)) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  scale_x_continuous(expand = c(0, 0), limits = c(0 ,26), breaks=c(seq.int(0,26, by = 2)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Number of Squeezes")


#  PE
df <- summarySE(REWOD_PE, measurevar="n_grips", groupvars=c("id", "trial"))

dfPE <- summarySEwithin(df,
                         measurevar = "n_grips",
                         withinvars = c("trial"), 
                         idvar = "id")

dfPE$Task_Name <- paste0("Partial Extinction")

dfPE$trial =as.numeric(dfPE$trial)
##plot n_grips to see the trajectory of learning (overall average by trials)

ggplot(dfPE, aes(x = trial, y = n_grips, color=Task_Name)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_line(alpha = .7, size = 1, position = position_dodge(width = 0.5), linetype = "dotted") +
  geom_errorbar(aes(ymax = n_grips + se, ymin = n_grips - se), width=0.5, alpha=0.7, size=0.4,position = position_dodge(width = 0.5))+
  scale_colour_manual(values = c("Partial Extinction"="grey")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(4.0,16)) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  scale_x_continuous(expand = c(0, 0), limits = c(-3 ,26), breaks=c(0,seq.int(-9,15, by = 2),26))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Number of Squeezes")



# summarySE provides the standard deviation, standard error of the mean, and a (default 95%) confidence interval

df <- summarySE(REWOD_PIT, measurevar="n_grips", groupvars=c("id", "Condition"))

dfPIT2 <- summarySEwithin(df,
                         measurevar = "n_grips",
                         withinvars = c("Condition"), 
                         idvar = "id")



dfPIT2$Condition = factor(dfPIT2$Condition,levels(dfPIT2$Condition)[c(3,2,1)])
PIT.bs$Condition = factor(PIT.bs$Condition,levels(PIT.bs$Condition)[c(3,2,1)])  

# ggplot(PIT.bs, aes(x = Condition, y = n_grips, fill = Condition)) +
  # geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
  # geom_bar(data=dfPIT2, stat="identity", alpha=0.6, width=0.35) +
  # scale_fill_manual("legend", values = c("CS+"="blue", "CS-"="red", "Baseline"="black")) +
  # geom_line(aes(x=Condition, y=n_grips, group=id), col="grey", alpha=0.4) +
  # geom_errorbar(data=dfPIT2, aes(x = Condition, ymax = n_grips + se, ymin = n_grips - se), width=0.07, colour="black", alpha=1, size=0.4)+
  # scale_y_continuous(expand = c(0, 0), breaks = c(-1, seq.int(0,30, by = 5)), limits = c(-1,30)) +
  # theme_classic() +
  # theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
  #       axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
  # labs(
  #   x = "Pavlovian Stimulus",
  #   y = "Number of Squeezes"
  # )



source('~/REWOD/CODE/ANALYSIS/BEHAV/my_tools/rainclouds.R')

ggplot(PIT.bs, aes(x = Condition, y = n_grips, fill = Condition)) +
  geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
  geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_bar(data=dfPIT2, stat="identity", alpha=0.6, width=0.35) +
  scale_fill_manual("legend", values = c("CS+"="blue", "CS-"="red", "Baseline"="black")) +
  geom_line(aes(x=Condition, y=n_grips, group=id), col="grey", alpha=0.4) +
  geom_errorbar(data=dfPIT2, aes(x = Condition, ymax = n_grips + se, ymin = n_grips - se), width=0.07, colour="black", alpha=1, size=0.4)+
  scale_y_continuous(expand = c(0, 0), breaks = c( seq.int(0,30, by = 5)), limits = c(-0.1,30)) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
        axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
  labs(
    x = "Pavlovian Stimulus",
    y = "Number of Squeezes"
  )

# ANALYSIS

# ANALYSIS -----------------------------------------------------------------

## 1. number of grips: are participants gripping more on the CSplus condition? 

#factorise trial and condition
REWOD_PIT$trialxcondition            <- factor(REWOD_PIT$trial)
REWOD_PIT$condition       <- factor(REWOD_PIT$condition)
#Assumptions:
my.model <- lmer(n_grips ~ condition + (1|id) , data = REWOD_PIT, REML = FALSE)  #1+cvalue\id or 1\id
#1)Linearity (not good?)
plot(my.model)
#2) Absence of collinearity
#3)Homoscedasticity AND #4)Normality of residuals
qqnorm(residuals(my.model))
#5) Absence of influential data points (ID =4 and ID = 22 ??)
alt.est.id <- influence(model=my.model, group="id")
plot(dfbetas(alt.est.id), PIT.bs$id)



# PIT Grips ------------------------------------------------------------------
REWOD_PIT$condition = factor(REWOD_PIT$condition,levels(REWOD_PIT$condition)[c(3,2,1)])  

main.model = lmer(n_grips ~ condition + trialxcondition + (1+condition |id), data = REWOD_PIT, REML = FALSE) 
summary(main.model)



# Ben saif boundary (singular) fit: see ?isSingular was ok if the variance checks out
null.model = lmer(n_grips ~  trialxcondition + (1+condition |id), data = REWOD_PIT, REML = FALSE) 

test = anova(main.model, null.model, test = 'Chisq')
test


#sentence => main.liking is 'signifincatly' better than the null model wihtout condition a fixe effect
# condition affected handgrip presses (χ2 (1)= 177.60, p<2.20×10ˆ-16), in average having 4.63 ± 0.38 (SEE) more squeezes compared to CS- condition and,
# 4.54 ± 0.38 (SEE) compared to the baseline.



#Δ BIC
delta_BIC = test$BIC[2] - test$BIC[1]
delta_BIC

# #difflsmeans
# pairw = difflsmeans(main.model, test.effs="condition")
# plot(parw)
# pairw

#emmeans
ems = emmeans(main.model, list(pairwise ~ condition), adjust = "none")
confint(emmeans(main.model, list(pairwise ~ condition)) level = .95, type = "response", adjust = "tukey")
plot(ems)
ems



# manual planned contrasts
REWOD_PIT$cvalue[REWOD_PIT$condition== 'CSplus']       <- 2
REWOD_PIT$cvalue[REWOD_PIT$condition== 'CSminus']      <- -1
REWOD_PIT$cvalue[REWOD_PIT$condition== 'Baseline']     <- -1
REWOD_PIT$cvalue1      <- factor(REWOD_PIT$cvalue1)

main.cont = lmer(n_grips ~ cvalue + trialxcondition + (1|id), data = REWOD_PIT, REML = FALSE) 
summary(main.cont)
ems = emmeans(main.cont, list(pairwise ~ cvalue), adjust = "tukey")

null.cont = lmer(n_grips ~  trialxcondition + (1|id), data = REWOD_PIT, REML = FALSE) 


test2 = anova(main.cont, null.cont, test = 'Chisq')
test2

#Δ BIC
delta_BIC = test$BIC[1] -test$BIC[2] 
delta_BIC

#OR ALSO planned contrast also in case: CS+ VS CS- and Baseline
#A = c(2, 0, 0)
#B = c(0, -1, -1)
#cont = emmeans(main.model, ~ condition)
#contrast(cont, method = list(A - B) )



# CSminus VS Baseline (so we do that to be less bias and more conservator)
# playing against ourselvees
cont = emmeans(main.model, ~ condition)
contr_mat <- coef(pairs(cont))[c("c.3")]
emmeans(main.model, ~ condition, contr = contr_mat, adjust = "none")$contrasts
confint(emmeans(main.model, ~ condition, contr = contr_mat, adjust = "none")$contrasts)







# REMINDER ----------------------------------------------------------------


# ANOVA trials ------------------------------------------------------------

##1. number of grips: are participants gripping more over time?
REWOD_RIM$trial            <- factor(REWOD_RIM$trial)


anova_model = ezANOVA(data = REWOD_RIM,
                      dv = n_grips,
                      wid = id,
                      within = trial,
                      detailed = TRUE,
                      type = 3)

#using afex
rem.aov <- aov_car(n_grips ~ trial + Error(id/trial), data = REWOD_RIM, anova_table = list(es = "pes"))

#contrast pairvise corrected to get pvalues
ems = emmeans(rem.aov, list(pairwise ~ trial), adjust = "tukey")
ems

# effect sizes ------------------------------------------------------------
#source('~/REWOD/CODE/ANALYSIS/BEHAV/my_tools/pes_ci.R')


#pes_ci <- function(formula, data, conf.level, epsilon, anova.type)



# Partial extinction ------------------------------------------------------

# 

REWOD_PE$trial            <- factor(REWOD_PE$trial)

dfTRIAL <- data_summary(REWOD_PE, varname="n_grips", groupnames=c("trial"))

o = length(dfTRIAL$sd)
for(x in 1:o){
  dfTRIAL$sem[x] <- dfTRIAL$sd[x]/sqrt(length(dfTRIAL$sd))
}



##plot n_grips to see the trajectory of learning (overall average by trials)

ggplot(dfTRIAL, aes(x = trial, y = n_grips)) +
  geom_point() + geom_line(group=1) +
  geom_errorbar(aes(ymin=n_grips-sem, ymax=n_grips+sem), color='grey', width=.2,
                position=position_dodge(0.05), linetype = "dashed") +
  theme_classic() +
  #scale_y_continuous(expand = c(0, 0), limits = c(10,16)) + #, breaks = c(9.50, seq.int(10,15, by = 1)), ) +
  #scale_x_continuous(expand = c(0, 0), limits = c(0,25), breaks=c(0, seq.int(1,25, by = 3))) + #,breaks=c(seq.int(1,24, by = 2), 24), limits = c(0,24)) + 
  labs(x = "Trial
       ",
       y = "Number of Squeezes",title= "   
       ") +
  theme(text = element_text(size=rel(4)), plot.margin = unit(c(1, 1,0, 1), units = "cm"), axis.title.x = element_text(size=16), axis.title.y = element_text(size=16))


#ANALYSIS

# ANOVA trials ------------------------------------------------------------

##1. number of grips: are participants gripping more over time?
REWOD_PE$trial            <- factor(REWOD_PE$trial)


anova_model = ezANOVA(data = REWOD_PE,
                      dv = n_grips,
                      wid = id,
                      within = trial,
                      detailed = TRUE,
                      type = 3)

#using afex
pe.aov <- aov_car(n_grips ~ trial + Error(id/trial), data = REWOD_PE, anova_table = list(es = "pes"))

#contrast pairvise corrected to get pvalues
ems = emmeans(pe.aov, list(pairwise ~ trial), adjust = "tukey")
ems





