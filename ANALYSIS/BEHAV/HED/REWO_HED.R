## R code for FOR REWOD_HED
# last modified on March 2020 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(mosaic, influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, sm, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
setwd(analysis_path)

# open dataset (session two only)
REWOD_HED <- read.delim(file.path(analysis_path,'REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset

# define factors
REWOD_HED$session          <- factor(REWOD_HED$session)
REWOD_HED$condition        <- factor(REWOD_HED$condition)

REWOD_HED$Condition[REWOD_HED$condition== 'chocolate']     <- 'Reward'
REWOD_HED$Condition[REWOD_HED$condition== 'empty']     <- 'Control'
REWOD_HED$Condition[REWOD_HED$condition== 'neutral']     <- 'Neutral'

REWOD_HED$Condition2[REWOD_HED$condition== 'chocolate']     <- 'Reward'
REWOD_HED$Condition2[REWOD_HED$condition== 'empty']     <- 'NoReward'
REWOD_HED$Condition2[REWOD_HED$condition== 'neutral']     <- 'NoReward'

REWOD_HED$Condition        <- factor(REWOD_HED$Condition)
REWOD_HED$Condition2        <- factor(REWOD_HED$Condition2)
## remove sub 1 & 8 
REWOD_HED <- filter(REWOD_HED,  id != "8")

# PLOTS


# get means by condition 
bt = ddply(REWOD_HED, .(trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) 
# get means by condition and trialxcondition
bct = ddply(REWOD_HED, .(condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), EMG = mean(EMG, na.rm = TRUE)) 

# get means by participant 
bs = ddply(REWOD_HED, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), EMG = mean(EMG, na.rm = TRUE)) 
bsLIK = ddply(REWOD_HED, .(id, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
bsEMG = ddply(REWOD_HED, .(id, Condition), summarise, EMG = mean(EMG, na.rm = TRUE), EMG = mean(EMG, na.rm = TRUE))

# be consistent so do the same for fMRI

# functions ---------------------------------------------------------------


ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Rˆ2* = ",signif(summary(fit)$adj.r.squared, 5),
                       " P =",signif(summary(fit)$coef[2,4], 5)))
}

data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}




# plots -------------------------------------------------------------------


# # plot liking by time by condition with regression lign
# ggplotRegression(lm(perceived_liking ~ trialxcondition*condition, data = bct)) + 
#   facet_wrap(~condition)



# get mean an SEM

df <- summarySE(REWOD_HED, measurevar="perceived_liking", groupvars=c("id", "trialxcondition", "Condition"))

dfLIK <- summarySEwithin(df,
                         measurevar = "perceived_liking",
                         withinvars = c("Condition", "trialxcondition"), 
                         idvar = "id")

dfLIK$Condition = as.factor(dfLIK$Condition)
dfLIK$Condition = factor(dfLIK$Condition,levels(dfLIK$Condition)[c(3,2,1)])
dfLIK$trialxcondition =as.numeric(dfLIK$trialxcondition)


ggplot(dfLIK, aes(x = trialxcondition, y = perceived_liking, color=Condition)) +
  geom_line(alpha = .7, size = 1, position =position_dodge(width = 0.5)) +
  geom_point(position =position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = perceived_liking +se, ymin = perceived_liking -se), width=0.5, alpha=0.7, size=0.4, position = position_dodge(width = 0.5))+
  scale_colour_manual(values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(40,80),  breaks=c(seq.int(40,80, by = 5))) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  scale_x_continuous(expand = c(0, 0), limits = c(0,19), breaks=c(0, seq.int(1,18, by = 2),19))+ 
  theme_classic() +
    theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
          axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Pleasantness Ratings")


#### INTENSITY
df <- summarySE(REWOD_HED, measurevar="perceived_intensity", groupvars=c("id", "trialxcondition", "Condition"))

dfINT <- summarySEwithin(df,
                         measurevar = "perceived_intensity",
                         withinvars = c("Condition", "trialxcondition"), 
                         idvar = "id")

dfINT$Condition = as.factor(dfINT$Condition)
dfINT$Condition = factor(dfINT$Condition,levels(dfINT$Condition)[c(3,2,1)])
dfINT$trialxcondition =as.numeric(dfINT$trialxcondition)


ggplot(dfINT, aes(x = trialxcondition, y = perceived_intensity, color=Condition)) +
  geom_line(alpha = .7, size = 1, position =position_dodge(width = 0.5)) +
  geom_point(position =position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = perceived_intensity +se, ymin = perceived_intensity -se), width=0.5, alpha=0.7, size=0.4, position = position_dodge(width = 0.5))+
  scale_colour_manual(values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(10,80),  breaks=c(seq.int(10,80, by = 5))) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  #scale_x_continuous(expand = c(0, 0), limits = c(0,19), breaks=c(0, seq.int(1,18, by = 2),19))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Intensity Ratings")


#### EMG
REWOD_HED$EMG                        <- zscore(REWOD_HED$EMG)
#df <- summarySE(REWOD_HED, measurevar="EMG", groupvars=c("id", "trialxcondition", "Condition"))

dfEMG <- summarySEwithin(REWOD_HED,
                         measurevar = "EMG",
                         withinvars = c("Condition", "trialxcondition"), 
                         idvar = "id")

dfEMG$Condition = as.factor(dfEMG$Condition)
dfEMG$Condition = factor(dfEMG$Condition,levels(dfEMG$Condition)[c(3,2,1)])
dfEMG$trialxcondition =as.numeric(dfEMG$trialxcondition)


ggplot(dfEMG, aes(x = trialxcondition, y = EMG, color=Condition)) +
  geom_line(alpha = .7, size = 1, position =position_dodge(width = 0.5)) +
  geom_point(position =position_dodge(width = 0.5)) +
  #geom_ribbon(aes(ymax = EMG +se, ymin = EMG -se), fill = "grey", alpha=0.01, color = 'grey") +
  geom_errorbar(aes(ymax = EMG +se, ymin = EMG -se), width=0.5, alpha=0.7, size=0.4, position = position_dodge(width = 0.5))+
  scale_colour_manual(values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
  #scale_y_continuous(expand = c(0, 0),  limits = c(10,80),  breaks=c(seq.int(10,80, by = 5))) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  #scale_x_continuous(expand = c(0, 0), limits = c(0,19), breaks=c(0, seq.int(1,18, by = 2),19))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "EMG cor")

####Corr COR & LIK


dfEMG$perceived_liking = dfLIK$perceived_liking
df = ddply(REWOD_HED, .(id, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE),  EMG = mean(EMG, na.rm = TRUE)) 
# 
# df = dfEMG

ggplot(df, aes(x = perceived_liking, y = EMG, color=Condition)) +
  #geom_line(alpha = .7, size = 1, position =position_dodge(width = 0.5)) +
  geom_point() +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16),  legend.title=element_blank())

dfR <- filter(df,  Condition == "Reward")
dfN <- filter(df,  Condition == "Neutral")
dfC <- filter(df,  Condition == "Control")


cor.test(dfR$EMG,dfR$perceived_liking)  
cor.test(dfN$EMG,dfN$perceived_liking)  
cor.test(dfC$EMG,dfC$perceived_liking)  

bsEMG2 = ddply(REWOD_HED, .(id), summarise, EMG = mean(EMG, na.rm = TRUE), EMG = mean(EMG, na.rm = TRUE))
Boxplot(~EMG, data= bsEMG2, id=TRUE) # across conditions
Boxplot(~EMG, data= dfR, id=TRUE) # for REW
Boxplot(~EMG, data= dfN, id=TRUE) # for NEU
Boxplot(~EMG, data= dfC, id=TRUE) # for CON



# corre <- rmcorr(id, perceived_liking, EMG, REWOD_HED, CIs = c("analytic",
#                                                      "bootstrap"), nreps = 100, bstrap.out = F)


# x = REWOD_HED$perceived_liking[REWOD_HED$Condition2 == 'Reward']
# y = REWOD_HED$perceived_liking[REWOD_HED$Condition2 == 'NoReward']
# #Compute Leven test for homgeneity of variance
# leveneTest(REWOD_HED$perceived_liking ~ REWOD_HED$Condition)
# 
# Dummy <- data.frame(numbers = 1:432)
# Dummy2 <- data.frame(numbers = 1:864)
# Dummy$'Reward pleasantness ratings' =  x
# Dummy2$'No Reward pleasantness ratings' =  y
# 
# 
# 
# 
# ggplot(Dummy, aes('Reward pleasantness ratings')) +
# geom_density() + 
# theme_classic() +
# theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
#         panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)
# 
# d <- density(Dummy$'Reward pleasantness ratings' ) + theme_classic() +
#   theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
#         panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)
# 
# plot(d)
# 
# 
# 
# # plot densities
# sm.density.compare(REWOD_HED$perceived_liking, REWOD_HED$Condition,  xlab="Pleasantness ratings")
# 
# 
# # add legend via mouse click
# colfill<-c(2:(2+length(levels(REWOD_HED$Condition))))
# legend(locator(1), levels(REWOD_HED$Condition), fill=colfill)
# 
# df <- summarySE(REWOD_HED, measurevar="perceived_liking", groupvars=c("id", "Condition"))
# 
# # inspecting variance  control ###
# 
# REWOD_check<- filter(REWOD_HED,  id != "3" & id !='4' & id !='13' & id != '20' & id != '23')
# 
# 
# # plot densities
# sm.density.compare(REWOD_check$perceived_liking, REWOD_check$Condition,  xlab="Pleasantness ratings")
# colfill<-c(2:(2+length(levels(REWOD_check$Condition))))
# legend(locator(1), levels(REWOD_check$Condition), fill=colfill)
# 
# df2 <- summarySE(REWOD_check, measurevar="perceived_liking", groupvars=c("id", "Condition"))
# 
# 
# dfLIK3 <- summarySEwithin(df2,
#                           measurevar = "perceived_liking",
#                           withinvars = c("Condition"), 
#                           idvar = "id")
# 
# dfLIK3 <- summarySEwithin(df2,
#                           measurevar = "perceived_liking",
#                           withinvars = c("Condition"), 
#                           idvar = "id")
# 
# # get means by participant 
# bs2 = ddply(REWOD_check, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
# bsLIK2 = ddply(REWOD_check, .(id, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
# 
# 
# 
# dfLIK3$Condition <- as.factor(dfLIK3$Condition)
# bsLIK2$Condition <- as.factor(bsLIK2$Condition)
# 
# dfLIK3$Condition = factor(dfLIK2$Condition,levels(dfLIK3$Condition)[c(3,2,1)])
# bsLIK2$Condition = factor(bsLIK$Condition,levels(bsLIK2$Condition)[c(3,2,1)])  
# 
# ggplot(bsLIK2, aes(x = Condition, y = perceived_liking, fill = Condition)) +
#   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
#   geom_bar(data=dfLIK3, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
#   geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
#   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
#   geom_line(aes(x=Condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
#   geom_errorbar(data=dfLIK3, aes(x = Condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
#   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
#         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
#   labs(
#     x = "Odor Stimulus",
#     y = "Plesantness Ratings"
#   )
# 
# 
# # inspecting variance NEUTRAL ###
# 
# REWOD_check<- filter(REWOD_HED,  id != "23" )
# 
# 
# # plot densities
# sm.density.compare(REWOD_check$perceived_liking, REWOD_check$Condition,  xlab="Pleasantness ratings")
# colfill<-c(2:(2+length(levels(REWOD_check$Condition))))
# legend(locator(1), levels(REWOD_check$Condition), fill=colfill)
# 
# df2 <- summarySE(REWOD_check, measurevar="perceived_liking", groupvars=c("id", "Condition"))
# 
# 
# dfLIK3 <- summarySEwithin(df2,
#                           measurevar = "perceived_liking",
#                           withinvars = c("Condition"), 
#                           idvar = "id")
# 
# dfLIK3 <- summarySEwithin(df2,
#                           measurevar = "perceived_liking",
#                           withinvars = c("Condition"), 
#                           idvar = "id")
# 
# # get means by participant 
# bs2 = ddply(REWOD_check, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
# bsLIK2 = ddply(REWOD_check, .(id, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
# 
# 
# 
# dfLIK3$Condition <- as.factor(dfLIK3$Condition)
# bsLIK2$Condition <- as.factor(bsLIK2$Condition)
# 
# dfLIK3$Condition = factor(dfLIK2$Condition,levels(dfLIK3$Condition)[c(3,2,1)])
# bsLIK2$Condition = factor(bsLIK$Condition,levels(bsLIK2$Condition)[c(3,2,1)])  
# 
# ggplot(bsLIK2, aes(x = Condition, y = perceived_liking, fill = Condition)) +
#   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
#   geom_bar(data=dfLIK3, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
#   geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
#   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
#   geom_line(aes(x=Condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
#   geom_errorbar(data=dfLIK3, aes(x = Condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
#   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
#         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
#   labs(
#     x = "Odor Stimulus",
#     y = "Plesantness Ratings"
#   )



#ratings


dfLIK2 <- summarySEwithin(df,
                          measurevar = "perceived_liking",
                          withinvars = c("Condition"), 
                          idvar = "id")

dfLIK2 <- summarySEwithin(df,
                          measurevar = "perceived_liking",
                          withinvars = c("Condition"), 
                          idvar = "id")


dfLIK2$Condition <- as.factor(dfLIK2$Condition)
bsLIK$Condition <- as.factor(bsLIK$Condition)

dfLIK2$Condition = factor(dfLIK2$Condition,levels(dfLIK2$Condition)[c(3,2,1)])
bsLIK$Condition = factor(bsLIK$Condition,levels(bsLIK$Condition)[c(3,2,1)])  

# ggplot(bsLIK, aes(x = Condition, y = perceived_liking, fill = Condition)) +
#   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
#   geom_bar(data=dfLIK2, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
#   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
#   geom_line(aes(x=Condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
#   geom_errorbar(data=dfLIK2, aes(x = Condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
#   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
#         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
#   labs(
#     x = "Odor Stimulus",
#     y = "Plesantness Ratings"
#   )


# ggplot(bsLIK, aes(x = Condition, y = perceived_liking, fill = Condition)) +
#   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
#   geom_bar(data=dfLIK2, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
#   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
#   geom_line(aes(x=Condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
#   geom_errorbar(data=dfLIK2, aes(x = Condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
#   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
#         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
#   labs(
#     x = "Odor Stimulus",
#     y = "Plesantness Ratings"
#   )

#rainplot Liking
source('~/REWOD/CODE/ANALYSIS/BEHAV/my_tools/rainclouds.R')



ggplot(bsLIK, aes(x = Condition, y = perceived_liking, fill = Condition)) +
  geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
  geom_bar(data=dfLIK2, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
  geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
  scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
  geom_line(aes(x=Condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
  geom_errorbar(data=dfLIK2, aes(x = Condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
        axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
  labs(
    x = "Odor Stimulus",
    y = "Plesantness Ratings"
  )

#EMG - Physio

dfEMG2 <- summarySEwithin(df,
                          measurevar = "EMG",
                          withinvars = c("Condition"), 
                          idvar = "id")

dfEMG2 <- summarySEwithin(df,
                          measurevar = "EMG",
                          withinvars = c("Condition"), 
                          idvar = "id")


dfEMG2$Condition <- as.factor(dfEMG2$Condition)
bsEMG$Condition <- as.factor(bsEMG$Condition)

dfEMG2$Condition = factor(dfEMG2$Condition,levels(dfEMG2$Condition)[c(3,2,1)])
bsEMG$Condition = factor(bsEMG$Condition,levels(bsEMG$Condition)[c(3,2,1)])  


ggplot(bsEMG, aes(x = Condition, y = EMG, fill = Condition)) +
  geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
  geom_bar(data=dfEMG2, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
  geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
  scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
  geom_line(aes(x=Condition, y=EMG, group=id), col="grey", alpha=0.4) +
  geom_errorbar(data=dfEMG2, aes(x = Condition, ymax = EMG + se, ymin = EMG - se), width=0.1, colour="black", alpha=1, size=0.4)+
  #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
        axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
  labs(
    x = "Odor Stimulus",
    y = "EMG activity Cor"
  )


# ANALYSIS

REWOD_HED$id               <- factor(REWOD_HED$id)
REWOD_HED$condition       <- factor(REWOD_HED$condition)
REWOD_HED$trialxcondition           <- factor(REWOD_HED$trialxcondition)

#removing empty condition
REWOD_HED.woemp <- filter(REWOD_HED, condition != "empty")

#Assumptions:
my.model = lmer(perceived_liking ~ condition + trialxcondition + (1|id), data = REWOD_HED)

#1)Linearity 
plot(my.model)
#2) Absence of collinearity
#3)Homoscedasticity AND #4)Normality of residuals
qqnorm(residuals(my.model))
#5) Absence of influential data points (less visible but need to check)
alt.est.id <- influence(model=my.model, group="id")
#plot(alt.est.id)




# LIKING ------------------------------------------------------------------


main.model.lik = lmer(perceived_liking ~ condition + trialxcondition  + (1+condition|id), data = REWOD_HED, REML=FALSE)
summary(main.model.lik)

null.model.lik = lmer(perceived_liking ~ trialxcondition  + (1+condition|id), data = REWOD_HED, REML=FALSE)

test = anova(main.model.lik, null.model.lik, test = 'Chisq')
test

# main.model.lik = lmer(perceived_liking ~ condition + EMG +  trialxcondition  + (1+condition|id), data = REWOD_HED, REML=FALSE)
# summary(main.model.lik)
# 
# null.model.lik = lmer(perceived_liking ~ trialxcondition + condition + (1+condition|id), data = REWOD_HED, REML=FALSE)
# 
# test = anova(main.model.lik, null.model.lik, test = 'Chisq')
# test


#sentence => main.liking is 'signifincatly' better than the null model wihtout condition a fixe effect
# condition affected liking rating (χ2 (1)= 868.41, p<2.20×10ˆ-16), rising reward ratings by 17.63 points ± 0.57 (SEE) compared to neutral condition and,
# 17.63 ± 0.56 (SEE) compared to the control condition.

#Δ BIC = 847.92
delta_BIC = test$BIC[1] -test$BIC[2] 
delta_BIC


#
ems = emmeans(main.model.lik, list(pairwise ~ condition), adjust = "none")
confint(emmeans(main.model.lik, list(pairwise ~ condition)), level = .95, type = "response", adjust = "none")
plot(ems)
ems

#compute ptukey because ems rounds everything !!
#pR_N = 1 - ptukey(11.692 * sqrt(2), 3, 25.04)
#pR_C = 1 - ptukey(12.652 * sqrt(2), 3, 25.04)

# Neutral VS Control (so we do that to be less bias and more conservator)
# playing against ourselvees
cont = emmeans(main.model.lik, ~ condition)
contr_mat <- coef(pairs(cont))[c("c.3")]
emmeans(main.model.lik, ~ condition, contr = contr_mat, adjust = "none")$contrasts
confint(emmeans(main.model.lik, ~ condition, contr = contr_mat, adjust = "none")$contrasts)


# planned contrast
REWOD_HED$cvalue[REWOD_HED$condition== 'chocolate']     <- 2
REWOD_HED$cvalue[REWOD_HED$condition== 'empty']     <- -1
REWOD_HED$cvalue[REWOD_HED$condition== 'neutral']     <- -1


#
main.cont.lik = lmer(perceived_liking ~ cvalue + trialxcondition + (1|id), data = REWOD_HED, REML=FALSE)
summary(main.cont.lik)

null.cont.lik = lmer(perceived_liking ~ trialxcondition + (1|id), data = REWOD_HED, REML=FALSE)

test2 = anova(main.cont.lik, null.cont.lik, test = 'Chisq')
test2
#sentence => main.liking is 'signifincatly' better than the null model wihtout condition a fixe effect
# condition affected liking rating (χ2 (1)= 866.73, p<2.20×10ˆ-16), rising reward ratings by 17.27 points ± 0.49 (SEE) compared to the other two conditions
#Δ BIC = 847.92
delta_BIC = test2$BIC[1] -test2$BIC[2] 
delta_BIC




# INTENSITY ---------------------------------------------------------------


main.model.int = lmer(perceived_intensity ~ condition + trialxcondition + (1+condition|id), data = REWOD_HED, REML=FALSE)
summary(main.model.int)

null.model.int = lmer(perceived_intensity ~ trialxcondition + (1+condition|id), data = REWOD_HED, REML=FALSE)

testint = anova(main.model.int, null.model.int, test = 'Chisq')
testint
#sentence => main.intensity is 'signifincatly' better than the null model wihtout condition a fixe effect
# condition affected intensity rating (χ2 (1)= 868.41, p<2.20×10ˆ-16), rising reward ratings by 17.63 points ± 0.57 (SEE) compared to neutral condition and,
# 17.63 ± 0.56 (SEE) compared to the control condition.

#Δ BIC = XX
delta_BIC = testint$BIC[1] -testint$BIC[2] 
delta_BIC

ems = emmeans(main.model.int, list(pairwise ~ condition), adjust = "tukey")
confint(emmeans(main.model.int,list(pairwise ~ condition)), level = .95, type = "response", adjust = "tukey")
plot(ems)
ems



#compute ptukey because ems rounds everything !!
pR_C = 1 - ptukey(9.657 * sqrt(2), 3, 25.06)
pR_C 

# Neutral VS Control (so we do that to be less bias and more conservator)
# playing against ourselvees
cont = emmeans(main.model.lik, ~ condition)
contr_mat <- coef(pairs(cont))[c("c.3")]
emmeans(main.model.lik, ~ condition, contr = contr_mat, adjust = "none")$contrasts


# planned contrast
REWOD_HED$cvalue[REWOD_HED$condition== 'chocolate']     <- 2
REWOD_HED$cvalue[REWOD_HED$condition== 'empty']     <- -1
REWOD_HED$cvalue[REWOD_HED$condition== 'neutral']     <- -1


# planned contrast
REWOD_HED$cvalue[REWOD_HED$condition== 'chocolate']     <- 2
REWOD_HED$cvalue[REWOD_HED$condition== 'empty']     <- -1
REWOD_HED$cvalue[REWOD_HED$condition== 'neutral']     <- -1

#
main.cont.int = lmer(perceived_intensity ~ cvalue + trialxcondition + (1|id), data = REWOD_HED, REML=FALSE)
summary(main.cont.int)

null.cont.int = lmer(perceived_intensity ~ trialxcondition + (1|id), data = REWOD_HED, REML=FALSE)

testint2 = anova(main.cont.int, null.cont.int, test = 'Chisq')
testint2
#sentence => main.intensity is 'signifincatly' better than the null model without condition as fixed effect
# condition affected intensity rating (χ2 (1)= XX p<2.20×10ˆ-16), rising reward intensity ratings by XX points ± X.X (SEE) compared to the other two conditions
#Δ BIC = XX
delta_BIC = test2$BIC[1] -test2$BIC[2] 
delta_BIC


# 
# #  contrast NEUTRAL - EMPTY "we play against ourselves by oding this contrast and being conservator"
# REWOD_HED$cvalue1[REWOD_HED$condition== 'chocolate']     <- 0
# REWOD_HED$cvalue1[REWOD_HED$condition== 'empty']     <- 1
# REWOD_HED$cvalue1[REWOD_HED$condition== 'neutral']     <- -1
# REWOD_HED$cvalue1       <- factor(REWOD_HED$cvalue1)
# 
# #
# main.cont1 = lmer(perceived_intensity ~ cvalue1 + trialxcondition + (1|id), data = REWOD_HED, REML=FALSE)
# summary(main.cont1)

