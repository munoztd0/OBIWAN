## R code for FOR OBIWAN_PIT Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, lme4, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)

#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset


#subset
OBIWAN_PIT  <- subset(OBIWAN_PIT_full, group == 'obese') #only session 2
#OBIWAN_PIT_control  <- subset(OBIWAN_PIT, session == 'control') 
#OBIWAN_PIT_obese  <- subset(OBIWAN_PIT, session == 'obese') 
OBIWAN_PIT_sec  <- subset(OBIWAN_PIT, session == 'second') #only session 2
OBIWAN_PIT_third  <- subset(OBIWAN_PIT, session == 'third') #only session 3


# define factors
OBIWAN_PIT$id      <- factor(OBIWAN_PIT$id)
OBIWAN_PIT$trial    <- factor(OBIWAN_PIT$trial)
OBIWAN_PIT$session    <- factor(OBIWAN_PIT$session)

#OBIWAN_PIT$condition[OBIWAN_PIT$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_PIT$condition[OBIWAN_PIT$condition== 'Empty']     <- 'Control'
OBIWAN_PIT$condition <- factor(OBIWAN_PIT$condition)

OBIWAN_PIT$trialxcondition <- factor(OBIWAN_PIT$trialxcondition)



# get means by condition 
bt = ddply(OBIWAN_PIT, .(trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE)) 
btg = ddply(OBIWAN_PIT, .(session, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE) ) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_PIT, .(condition, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
btcg = ddply(OBIWAN_PIT, .(session, condition, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE) ) 

# get means by participant 
bsT = ddply(OBIWAN_PIT, .(id, trialxcondition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsC= ddply(OBIWAN_PIT, .(id, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsTC = ddply(OBIWAN_PIT, .(id, trialxcondition, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 

bsTg = ddply(OBIWAN_PIT, .(id, session, trialxcondition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE) ) 
bsCg= ddply(OBIWAN_PIT, .(id, session, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsTCg = ddply(OBIWAN_PIT, .(id, session, trialxcondition, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 

tot_n = length(unique(OBIWAN_PIT$id))
tot_sec = length(unique(OBIWAN_PIT_sec$id))
#tot_obese = length(unique(OBIWAN_PIT_third$id))
tot_third = length(unique(OBIWAN_PIT_third$id))

# PLOTS -------------------------------------------------------------------


#  _PITing  


#********************************** PLOT 1 main effect by subject ########### rainplot _PITing
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')


#ratings

df_PIT <- summarySEwithin(bsCg,
                          measurevar = "gripFreq",
                          withinvars = c("condition", "session"), 
                          idvar = "id")

df_PIT_C  <- subset(df_PIT, condition == 'BL')
df_PIT_Co  <- subset(df_PIT_C, session == 'second')
df_PIT_Cc  <- subset(df_PIT_C, session == 'third')

df_PIT_R  <- subset(df_PIT, condition == 'CSplus')
df_PIT_Ro  <- subset(df_PIT_R, session == 'second')
df_PIT_Rc  <- subset(df_PIT_R, session == 'third')

df_PIT_M  <- subset(df_PIT, condition == 'CSminus')
df_PIT_Mo  <- subset(df_PIT_M, session == 'second')
df_PIT_Mc  <- subset(df_PIT_M, session == 'third')

bsC_C  <- subset(bsCg, condition == 'BL')
bsC_Co  <- subset(bsC_C , session == 'second')
bsC_Cc  <- subset(bsC_C , session == 'third')

bsC_R  <- subset(bsCg, condition == 'CSplus')
bsC_Ro  <- subset(bsC_R , session == 'second')
bsC_Rc  <- subset(bsC_R , session == 'third')

bsC_M  <- subset(bsCg, condition == 'CSminus')
bsC_Mo  <- subset(bsC_M , session == 'second')
bsC_Mc  <- subset(bsC_M , session == 'third')


plt1 <- ggplot(data = bsCg, aes(x = condition, y = gripFreq, color = session, fill = session)) +
  #left BL ob
  geom_left_violin(data = bsC_Co, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_PIT_Co, aes(x = as.numeric(condition)+0.15), shape = 18, color ="black") +
  geom_errorbar(data=df_PIT_Co, aes(x = as.numeric(condition)+0.15, ymax = gripFreq + se, ymin = gripFreq - se), width=0.1,  alpha=1, size=0.4)+
  
  #left BL co
  geom_left_violin(data = bsC_Cc, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_PIT_Cc,  aes(x = as.numeric(condition)+0.15), shape = 18, color ="black") +
  geom_errorbar(data=df_PIT_Cc, aes(x = as.numeric(condition)+0.15, ymax = gripFreq + se, ymin = gripFreq - se), width=0.1,  alpha=1, size=0.4)+
  
  
  #right CS+ ob
  geom_right_violin(data = bsC_Ro, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_PIT_Ro, aes(x = as.numeric(condition)+0.15, y = gripFreq), color ="black", shape = 18) +
  geom_errorbar(data=df_PIT_Ro, aes(x = as.numeric(condition)+0.15, y = gripFreq, ymax = gripFreq + se, ymin = gripFreq - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #right CS+ co
  geom_right_violin(data = bsC_Rc, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_PIT_Rc, aes(x = as.numeric(condition)+0.15, y = gripFreq), shape = 18, color ="black") +
  geom_errorbar(data=df_PIT_Rc, aes(x = as.numeric(condition)+0.15, y = gripFreq, ymax = gripFreq + se, ymin = gripFreq - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #right CS- ob
  geom_right_violin(data = bsC_Mo, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_PIT_Mo, aes(x = as.numeric(condition)+0.15, y = gripFreq), color ="black", shape = 18) +
  geom_errorbar(data=df_PIT_Mo, aes(x = as.numeric(condition)+0.15, y = gripFreq, ymax = gripFreq + se, ymin = gripFreq - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #right CS- co
  geom_right_violin(data = bsC_Mc, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_PIT_Mc, aes(x = as.numeric(condition)+0.15, y = gripFreq), shape = 18, color ="black") +
  geom_errorbar(data=df_PIT_Mc, aes(x = as.numeric(condition)+0.15, y = gripFreq, ymax = gripFreq + se, ymin = gripFreq - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsCg, aes(x = as.numeric(condition) +0.15, y = gripFreq), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = df_PIT, aes(x = as.numeric(condition) +0.15, y = gripFreq, group=session), alpha=0.4,  
            position = position_jitter(width = 0.025, seed = 123)) +
  
  #details
  #scale_fill_manual(values = c("obese"="blue", "control"="black")) +
  #scale_color_manual(values = c("obese"="blue", "control"="black")) +
  #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
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
  labs( x = "Baseline                 CS-                CS+", 
        y = "Number of Grips",
        caption = "Second session (n=62)  Vs Third session (n=50) \n Error bars represent standard error of measurement")

plot(plt1)

pdf(file.path(figures_path,paste(task, '_PIT_ratings_ses2vs3.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()
