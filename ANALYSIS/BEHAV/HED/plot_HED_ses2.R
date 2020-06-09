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
OBIWAN_HED  <- subset(OBIWAN_HED_full, session == 'second') #only session 2
OBIWAN_HED_control  <- subset(OBIWAN_HED, group == 'control') 
OBIWAN_HED_obese  <- subset(OBIWAN_HED, group == 'obese') 
OBIWAN_HED_third  <- subset(OBIWAN_HED_full, session == 'third') #only session 2

OBIWAN_HED$perceived_liking = OBIWAN_HED$perceived_liking -50
OBIWAN_HED$perceived_intensity = OBIWAN_HED$perceived_intensity -50
OBIWAN_HED$perceived_familiarity = OBIWAN_HED$perceived_familiarity -50

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

tot_n = length(unique(OBIWAN_HED$id))
tot_control = length(unique(OBIWAN_HED_control$id))
tot_obese = length(unique(OBIWAN_HED_obese$id))
tot_obese_third = length(unique(OBIWAN_HED_third$id))

# PLOTS -------------------------------------------------------------------


#  Liking  


#********************************** PLOT 1 main effect by subject ########### rainplot Liking
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')

#Rmisc
bsCg= ddply(HED, .(id, group, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

#ratings

dfLIK <- summarySEwithin(bsCg,
                         measurevar = "lik",
                         withinvars = c("condition", "group"), 
                         idvar = "id")

dfLIK_C  <- subset(dfLIK, condition == 'Empty')
dfLIK_Co  <- subset(dfLIK_C, group == 'obese')
dfLIK_Cc  <- subset(dfLIK_C, group == 'control')
dfLIK_R  <- subset(dfLIK, condition == 'MilkShake')
dfLIK_Ro  <- subset(dfLIK_R, group == 'obese')
dfLIK_Rc  <- subset(dfLIK_R, group == 'control')

bsC_C  <- subset(bsCg, condition == 'Empty')
bsC_Co  <- subset(bsC_C , group == 'obese')
bsC_Cc  <- subset(bsC_C , group == 'control')
bsC_R  <- subset(bsCg, condition == 'MilkShake')
bsC_Ro  <- subset(bsC_R , group == 'obese')
bsC_Rc  <- subset(bsC_R , group == 'control')


plt1 <- ggplot(data = bsCg, aes(x = condition, y = perceived_liking, color = group, fill = group)) +
  #left ob
  geom_left_violin(data = bsC_Co, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_Co, aes(x = as.numeric(condition)+0.15), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_Co, aes(x = as.numeric(condition)+0.15, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1,  alpha=1, size=0.4)+
  
  #left co
  geom_left_violin(data = bsC_Cc, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_Cc,  aes(x = as.numeric(condition)+0.15), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_Cc, aes(x = as.numeric(condition)+0.15, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1,  alpha=1, size=0.4)+
  

  #right ob
  geom_right_violin(data = bsC_Ro, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_Ro, aes(x = as.numeric(condition)+0.15, y = perceived_liking), color ="black", shape = 18) +
  geom_errorbar(data=dfLIK_Ro, aes(x = as.numeric(condition)+0.15, y = perceived_liking, ymax = perceived_liking + se, ymin = perceived_liking - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #right co
  geom_right_violin(data = bsC_Rc, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_Rc, aes(x = as.numeric(condition)+0.15, y = perceived_liking), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_Rc, aes(x = as.numeric(condition)+0.15, y = perceived_liking, ymax = perceived_liking + se, ymin = perceived_liking - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsCg, aes(x = as.numeric(condition) +0.15, y = perceived_liking), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = dfLIK, aes(x = as.numeric(condition) +0.15, y = perceived_liking, group=group), alpha=0.4,  
            position = position_jitter(width = 0.025, seed = 123)) +
  
  #details
  #scale_fill_manual(values = c("obese"="blue", "control"="black")) +
  #scale_color_manual(values = c("obese"="blue", "control"="black")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-50,50, by = 25)), limits = c(-50,50)) +
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
        caption = "Second session: nControl = 27, nObese = 63 \n Error bars represent SEM for within-subject design using method from Morey (2008)")

plot(plt1)

pdf(file.path(figures_path,paste(task, 'Liking_ratings_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()


#**********************************  PLOT 2 main effect by trial # # plot liking by time by condition  

bsCT = ddply(HED, .(id, condition, trialxcondition), summarise, lik = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bT = ddply(HED, .(trialxcondition, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

bT <- summarySEwithin(bsCT,
                         measurevar = "lik",
                         withinvars = c("condition", "trialxcondition"), 
                         idvar = "id")

dfLIK$condition <- factor(dfLIK$condition, levels = rev(levels(dfLIK$condition)))

dfLIK$trialxcondition = as.numeric(dfLIK$trialxcondition)

plt2 <- ggplot(bsCT, aes(x = trialxcondition, y = lik, fill = id, color=condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  #geom_ribbon(aes(ymax = lik +se, ymin = lik -se), alpha=0.2, linetype = 0 ) +
  #geom_ribbon(aes(ymax = lik +se, ymin = lik -se), alpha=0.2, linetype = 0 ) +
  #scale_fill_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  #scale_color_manual(values = c("MilkShake"="purple",  "Empty"="black")) +
  #scale_y_continuous(expand = c(0, 0),  limits = c(-10,30),  breaks=c(seq.int(-10,30, by = 5))) +
  #scale_x_continuous(expand = c(0, 0), limits = c(0,21), breaks=c(seq.int(1,21, by = 2)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.text.x = element_text(size=11,  colour = "black"),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), 
        legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trial",
       y = "Pleasantness Rating",
       caption = "Second session: nControl = 27, nObese = 63 \n Error bars represent SEM for within-subject design using method from Morey (2008)")



pdf(file.path(figures_path,paste(task, 'Liking_time_ses2.pdf',  sep = "_")),
    width     = 7.5,
    height    = 6)

plot(plt2)
dev.off()
plot(plt2)



plt <- ggplot(bsCT, aes(x = trialxcondition, y = lik)) +
  geom_point(data = bsCT, size = 0.5, color = 'royalblue', alpha = .4) +
  geom_line(data = bsCT, aes(group = id), color = 'royalblue', alpha = .2) +
  geom_line(data= bT, alpha = .9, group=1) +
  geom_point(data= bT, alpha = .9, size = 0.5) +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_ribbon(data= bT, aes(ymax = lik + se, ymin = lik -se), alpha=0.7) +
  facet_wrap(~ condition) +
  theme(legend.position =  'none')

empty = subset(bsCT, condition == 'Empty')
MS = subset(bsCT, condition == 'MilkShake')
data = MS

data$diff = MS$lik - empty$lik
dataT <- summarySEwithin(data,
                      measurevar = "diff",
                      withinvars = c("condition", "trialxcondition"), 
                      idvar = "id")

dataID= ddply(data, .(id), summarise, diff = mean(diff, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

ggplot(data, aes(x = trialxcondition, y = diff)) +
  geom_point(data = data, size = 0.5, color = 'royalblue', alpha = .4) +
  geom_line(data = data, aes(group = id), color = 'royalblue', alpha = .2) +
  geom_line(data= dataT, alpha = .9, group=1) +
  geom_point(data= dataT, alpha = .9, size = 0.5) +
  geom_abline(slope= 0, intercept=0, linetype = "dashed", color = "black") + 
  geom_ribbon(data= dataT, aes(x = 1:length(trialxcondition), ymax = diff + sd, ymin = diff -sd), alpha = 0.5) 


