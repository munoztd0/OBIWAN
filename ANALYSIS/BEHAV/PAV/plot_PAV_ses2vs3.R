## R code for FOR OBIWAN_PAV Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, lme4, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)

#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'PAV'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_PAV_full <- read.delim(file.path(analysis_path,'OBIWAN_PAV.txt'), header = T, sep ='') # read in dataset



#subset
OBIWAN_PAV  <- subset(OBIWAN_PAV_full, group == 'obese') #only session 2
#OBIWAN_PAV_control  <- subset(OBIWAN_PAV, session == 'control') 
#OBIWAN_PAV_obese  <- subset(OBIWAN_PAV, session == 'obese') 
OBIWAN_PAV_sec  <- subset(OBIWAN_PAV, session == 'second') #only session 2
OBIWAN_PAV_third  <- subset(OBIWAN_PAV, session == 'third') #only session 3

# define factors
OBIWAN_PAV$id      <- factor(OBIWAN_PAV$id)
OBIWAN_PAV$trial    <- factor(OBIWAN_PAV$trial)
OBIWAN_PAV$session    <- factor(OBIWAN_PAV$session)

#OBIWAN_PAV$condition[OBIWAN_PAV$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_PAV$condition[OBIWAN_PAV$condition== 'Empty']     <- 'Control'
OBIWAN_PAV$condition <- factor(OBIWAN_PAV$condition)

OBIWAN_PAV$trialxcondition <- factor(OBIWAN_PAV$trialxcondition)
OBIWAN_PAV$RT <- as.numeric(OBIWAN_PAV$RT)*1000

#Cleaning
##only first round
OBIWAN_PAV.clean <- filter(OBIWAN_PAV, rounds == 1)
OBIWAN_PAV.clean$condition <- droplevels(OBIWAN_PAV.clean$condition, exclude = "Baseline")
full = length(OBIWAN_PAV.clean$RT)

##shorter than 100ms and longer than 3sd+mean
OBIWAN_PAV.clean <- filter(OBIWAN_PAV.clean, RT >= 100) # min RT is 106ms
mean <- mean(OBIWAN_PAV.clean$RT)
sd <- sd(OBIWAN_PAV.clean$RT)
OBIWAN_PAV.clean <- filter(OBIWAN_PAV.clean, RT <= mean +3*sd) #which is 854.4ms
#now accuracy is to a 100%
clean= length(OBIWAN_PAV.clean$RT)

dropped = full-clean
(dropped*100)/full

OBIWAN_PAV  = OBIWAN_PAV.clean 

OBIWAN_PAV$liking = OBIWAN_PAV$liking -50

# get means by condition 
bt = ddply(OBIWAN_PAV, .(trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE)) 
btg = ddply(OBIWAN_PAV, .(session, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_PAV, .(condition, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
btcg = ddply(OBIWAN_PAV, .(session, condition, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

# get means by participant 
bsT = ddply(OBIWAN_PAV, .(id, trialxcondition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsC= ddply(OBIWAN_PAV, .(id, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsTC = ddply(OBIWAN_PAV, .(id, trialxcondition, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

bsTg = ddply(OBIWAN_PAV, .(id, session, trialxcondition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsCg= ddply(OBIWAN_PAV, .(id, session, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsTCg = ddply(OBIWAN_PAV, .(id, session, trialxcondition, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

tot_n = length(unique(OBIWAN_PAV$id))
tot_sec = length(unique(OBIWAN_PAV_sec$id))
#tot_obese = length(unique(OBIWAN_PAV_third$id))
tot_third = length(unique(OBIWAN_PAV_third$id))

# PLOTS -------------------------------------------------------------------


#  PAV


#********************************** PLOT 1 main effect by subject ########### rainplot _PAVing
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')


#RT

df_PAV <- summarySEwithin(bsCg,
                          measurevar = "RT",
                          withinvars = c("condition", "session"), 
                          idvar = "id")


df_PAV_R  <- subset(df_PAV, condition == 'CSplus')
df_PAV_Ro  <- subset(df_PAV_R, session == 'second')
df_PAV_Rc  <- subset(df_PAV_R, session == 'third')

df_PAV_M  <- subset(df_PAV, condition == 'CSminus')
df_PAV_Mo  <- subset(df_PAV_M, session == 'second')
df_PAV_Mc  <- subset(df_PAV_M, session == 'third')

df_PAV_o  <- subset(df_PAV, session == 'second')
df_PAV_c  <- subset(df_PAV, session == 'third')


bsC_R  <- subset(bsCg, condition == 'CSplus')
bsC_Ro  <- subset(bsC_R , session == 'second')
bsC_Rc  <- subset(bsC_R , session == 'third')

bsC_M  <- subset(bsCg, condition == 'CSminus')
bsC_Mo  <- subset(bsC_M , session == 'second')
bsC_Mc  <- subset(bsC_M , session == 'third')


plt1 <- ggplot(data = bsCg, aes(x = condition, y = RT, color = session, fill = session)) +
  #left CS- ob
  geom_left_violin(data = bsC_Mo, alpha = .4, adjust = 1.5, trim = F, color = NA) +
  geom_point(data = df_PAV_Mo, aes(x = as.numeric(condition)+0.2), shape = 18, color ="black") +
  geom_errorbar(data=df_PAV_Mo, aes(x = as.numeric(condition)+0.2, ymax = RT + se, ymin = RT - se), width=0.1,  alpha=1, size=0.4)+
  
  #left cs- co
  geom_left_violin(data = bsC_Mc, alpha = .4, adjust = 1.5, trim = F, color = NA) +
  geom_point(data = df_PAV_Mc,  aes(x = as.numeric(condition)+0.1), shape = 18, color ="black") +
  geom_errorbar(data=df_PAV_Mc, aes(x = as.numeric(condition)+0.1, ymax = RT + se, ymin = RT - se), width=0.1,  alpha=1, size=0.4)+
  
  
  #right CS+ ob
  geom_right_violin(data = bsC_Ro, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_PAV_Ro, aes(x = as.numeric(condition)+0.2, y = RT), color ="black", shape = 18) +
  geom_errorbar(data=df_PAV_Ro, aes(x = as.numeric(condition)+0.2, y = RT, ymax = RT + se, ymin = RT - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #right CS+ co
  geom_right_violin(data = bsC_Rc, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_PAV_Rc, aes(x = as.numeric(condition)+0.1, y = RT), shape = 18, color ="black") +
  geom_errorbar(data=df_PAV_Rc, aes(x = as.numeric(condition)+0.1, y = RT, ymax = RT + se, ymin = RT - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsCg, aes(x = as.numeric(condition) +0.15, y = RT), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = df_PAV_o, aes(x = as.numeric(condition) +0.2, y = RT, group=session), alpha=0.4,  
            position = position_jitter(width = 0.025, seed = 123)) +
  
  geom_line(data = df_PAV_c, aes(x = as.numeric(condition) +0.1, y = RT, group=session), alpha=0.4,  
            position = position_jitter(width = 0.025, seed = 123)) +
  
  #details
  #scale_fill_manual(values = c("second"="blue", "third"="black")) +
  #scale_color_manual(values = c("second"="blue", "third"="black")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(240,740, by = 80)), limits = c(240,740)) +
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
  labs( x = "CS-                            CS+", 
        y = "Reaction Time",
        caption = "Second session (n=64)  Vs Third session (n=51) \nError bars represent SEM for within-subject design using method from Morey (2008)")


plot(plt1)

pdf(file.path(figures_path,paste(task, 'RT_ses2vs3.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()


#RTatings

df_LIK <- summarySEwithin(bsCg,
                          measurevar = "liking",
                          withinvars = c("condition", "session"), 
                          idvar = "id")


df_LIK_R  <- subset(df_LIK, condition == 'CSplus')
df_LIK_Ro  <- subset(df_LIK_R, session == 'second')
df_LIK_Rc  <- subset(df_LIK_R, session == 'third')

df_LIK_M  <- subset(df_LIK, condition == 'CSminus')
df_LIK_Mo  <- subset(df_LIK_M, session == 'second')
df_LIK_Mc  <- subset(df_LIK_M, session == 'third')

df_LIK_o  <- subset(df_LIK, session == 'second')
df_LIK_c  <- subset(df_LIK, session == 'third')



plt2 <- ggplot(data = bsCg, aes(x = condition, y = liking, color = session, fill = session)) +
  #left CS- ob
  geom_left_violin(data = bsC_Mo, alpha = .4, adjust = 1.5, trim = F, color = NA) +
  geom_point(data = df_LIK_Mo, aes(x = as.numeric(condition)+0.2), shape = 18, color ="black") +
  geom_errorbar(data=df_LIK_Mo, aes(x = as.numeric(condition)+0.2, ymax = liking + se, ymin = liking - se), width=0.1,  alpha=1, size=0.4)+
  
  #left cs- co
  geom_left_violin(data = bsC_Mc, alpha = .4, adjust = 1.5, trim = F, color = NA) +
  geom_point(data = df_LIK_Mc,  aes(x = as.numeric(condition)+0.1), shape = 18, color ="black") +
  geom_errorbar(data=df_LIK_Mc, aes(x = as.numeric(condition)+0.1, ymax = liking + se, ymin = liking - se), width=0.1,  alpha=1, size=0.4)+
  
  
  #right CS+ ob
  geom_right_violin(data = bsC_Ro, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_LIK_Ro, aes(x = as.numeric(condition)+0.2, y = liking), color ="black", shape = 18) +
  geom_errorbar(data=df_LIK_Ro, aes(x = as.numeric(condition)+0.2, y = liking, ymax = liking + se, ymin = liking - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #right CS+ co
  geom_right_violin(data = bsC_Rc, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_LIK_Rc, aes(x = as.numeric(condition)+0.1, y = liking), shape = 18, color ="black") +
  geom_errorbar(data=df_LIK_Rc, aes(x = as.numeric(condition)+0.1, y = liking, ymax = liking + se, ymin = liking - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsCg, aes(x = as.numeric(condition) +0.15, y = liking), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = df_LIK_o, aes(x = as.numeric(condition) +0.2, y = liking, session=session), alpha=0.4) +
  
  geom_line(data = df_LIK_c, aes(x = as.numeric(condition) +0.1, y = liking, session=session), alpha=0.4) +
  
  #details
  #scale_fill_manual(values = c("second"="blue", "third"="black")) +
  #scale_color_manual(values = c("second"="blue", "third"="black")) +
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
  labs( x = "CS-                            CS+", 
        y = "Pleasantness Ratings",
        caption = "Second session (n=64)  Vs Third session (n=51) \nError bars represent SEM for within-subject design using method from Morey (2008)")

plot(plt2)

pdf(file.path(figures_path,paste(task, 'ratings_ses2vs3.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt2)
dev.off()