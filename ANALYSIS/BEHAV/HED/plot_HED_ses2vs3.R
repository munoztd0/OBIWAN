## R code for FOR OBIWAN_HED Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, lme4, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)

#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset


#subset
OBIWAN_HED  <- subset(OBIWAN_HED_full, group == 'obese') #only session 2
#OBIWAN_HED_control  <- subset(OBIWAN_HED, group == 'control') 
#OBIWAN_HED_obese  <- subset(OBIWAN_HED, group == 'obese') 
OBIWAN_HED_sec  <- subset(OBIWAN_HED, session == 'second') #only session 2
OBIWAN_HED_third  <- subset(OBIWAN_HED_full, session == 'third') #only session 3


# define factors
OBIWAN_HED$id      <- factor(OBIWAN_HED$id)
OBIWAN_HED$trial    <- factor(OBIWAN_HED$trial)
OBIWAN_HED$group    <- factor(OBIWAN_HED$group)

#OBIWAN_HED$condition[OBIWAN_HED$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_HED$condition[OBIWAN_HED$condition== 'Empty']     <- 'Control'
OBIWAN_HED$condition <- factor(OBIWAN_HED$condition)

OBIWAN_HED$trialxcondition <- factor(OBIWAN_HED$trialxcondition)



# get means by condition 
bt = ddply(OBIWAN_HED, .(trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
btg = ddply(OBIWAN_HED, .(session, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_HED, .(condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
btcg = ddply(OBIWAN_HED, .(session, condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

# get means by participant 
bsT = ddply(OBIWAN_HED, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsC= ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsTC = ddply(OBIWAN_HED, .(id, trialxcondition, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

bsTg = ddply(OBIWAN_HED, .(id, session, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsCg= ddply(OBIWAN_HED, .(id, session, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsTCg = ddply(OBIWAN_HED, .(id, session, trialxcondition, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

tot_n = length(unique(OBIWAN_HED$id))
tot_sec = length(unique(OBIWAN_HED_sec$id))
#tot_obese = length(unique(OBIWAN_HED_third$id))
tot_third = length(unique(OBIWAN_HED_third$id))

# PLOTS -------------------------------------------------------------------


#  Liking  


#********************************** PLOT 1 main effect by subject ########### rainplot Liking
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')


#ratings

dfLIK <- summarySEwithin(bsCg,
                         measurevar = "perceived_liking",
                         withinvars = c("condition", "session"), 
                         idvar = "id")

dfLIK_C  <- subset(dfLIK, condition == 'Empty')
dfLIK_Co  <- subset(dfLIK_C, session == 'second')
dfLIK_Cc  <- subset(dfLIK_C, session == 'third')
dfLIK_R  <- subset(dfLIK, condition == 'MilkShake')
dfLIK_Ro  <- subset(dfLIK_R, session == 'second')
dfLIK_Rc  <- subset(dfLIK_R, session == 'third')

dfLIK_t  <- subset(dfLIK, session == 'third')
dfLIK_s  <- subset(dfLIK, session == 'second')

bsC_C  <- subset(bsCg, condition == 'Empty')
bsC_Co  <- subset(bsC_C , session == 'second')
bsC_Cc  <- subset(bsC_C , session == 'third')
bsC_R  <- subset(bsCg, condition == 'MilkShake')
bsC_Ro  <- subset(bsC_R , session == 'second')
bsC_Rc  <- subset(bsC_R , session == 'third')


plt1 <- ggplot(data = bsCg, aes(x = condition, y = perceived_liking, color = session, fill = session)) +
  #left ob
  geom_left_violin(data = bsC_Co, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_Co, aes(x = as.numeric(condition)+0.15), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_Co, aes(x = as.numeric(condition)+0.15, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1,  alpha=1, size=0.4)+
  
  #left co
  geom_left_violin(data = bsC_Cc, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_Cc,  aes(x = as.numeric(condition)+0.1), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_Cc, aes(x = as.numeric(condition)+0.1, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1,  alpha=1, size=0.4)+
  
  
  #right ob
  geom_right_violin(data = bsC_Ro, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_Ro, aes(x = as.numeric(condition)+0.15, y = perceived_liking), color ="black", shape = 18) +
  geom_errorbar(data=dfLIK_Ro, aes(x = as.numeric(condition)+0.15, y = perceived_liking, ymax = perceived_liking + se, ymin = perceived_liking - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #right co
  geom_right_violin(data = bsC_Rc, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_Rc, aes(x = as.numeric(condition)+0.1, y = perceived_liking), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_Rc, aes(x = as.numeric(condition)+0.1, y = perceived_liking, ymax = perceived_liking + se, ymin = perceived_liking - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsCg, aes(x = as.numeric(condition) +0.15, y = perceived_liking), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  
  geom_line(data = dfLIK_s, aes(x = as.numeric(condition) +0.15, y = perceived_liking, group=session), alpha=0.4) +
  geom_line(data = dfLIK_t, aes(x = as.numeric(condition) +0.1, y = perceived_liking, group=session), alpha=0.4) +
  
  #details
  #scale_fill_manual(values = c("obese"="blue", "control"="black")) +
  #scale_color_manual(values = c("obese"="blue", "control"="black")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  guides(fill = guide_legend(override.aes = list(alpha = 0.3))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
        axis.text.x = element_blank(), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.525, 0.99), legend.title=element_blank(),
        legend.direction = "horizontal",
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( x = "Empty                  Milshake", 
        y = "Plesantness Ratings",
        caption = "Second session (n=63)  Vs Third session (n=48) \n Error bars represent standard error of measurment")

plot(plt1)

pdf(file.path(figures_path,paste(task, 'Liking_ratings_ob2vs3.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()