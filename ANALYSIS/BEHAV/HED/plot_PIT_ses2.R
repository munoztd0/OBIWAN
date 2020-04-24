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
OBIWAN_PIT  <- subset(OBIWAN_PIT_full, session == 'second') #only session 2
OBIWAN_PIT_control  <- subset(OBIWAN_PIT, group == 'control') 
OBIWAN_PIT_obese  <- subset(OBIWAN_PIT, group == 'obese') 
OBIWAN_PIT_third  <- subset(OBIWAN_PIT_full, session == 'third') #only session 2


# define factors
OBIWAN_PIT$id      <- factor(OBIWAN_PIT$id)
OBIWAN_PIT$trial    <- factor(OBIWAN_PIT$trial)
OBIWAN_PIT$group    <- factor(OBIWAN_PIT$group)

#OBIWAN_PIT$condition[OBIWAN_PIT$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_PIT$condition[OBIWAN_PIT$condition== 'Empty']     <- 'Control'
OBIWAN_PIT$condition <- factor(OBIWAN_PIT$condition)

OBIWAN_PIT$trialxcondition <- factor(OBIWAN_PIT$trialxcondition)



# get means by condition 
bt = ddply(OBIWAN_PIT, .(trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE)) 
btg = ddply(OBIWAN_PIT, .(group, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE) ) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_PIT, .(condition, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
btcg = ddply(OBIWAN_PIT, .(group, condition, trialxcondition), summarise,  gripFreq = mean(gripFreq, na.rm = TRUE) ) 

# get means by participant 
bsT = ddply(OBIWAN_PIT, .(id, trialxcondition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsC= ddply(OBIWAN_PIT, .(id, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsTC = ddply(OBIWAN_PIT, .(id, trialxcondition, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 

bsTg = ddply(OBIWAN_PIT, .(id, group, trialxcondition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE) ) 
bsCg= ddply(OBIWAN_PIT, .(id, group, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 
bsTCg = ddply(OBIWAN_PIT, .(id, group, trialxcondition, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)  ) 

tot_n = length(unique(OBIWAN_PIT$id))
tot_control = length(unique(OBIWAN_PIT_control$id))
tot_obese = length(unique(OBIWAN_PIT_obese$id))
tot_obese_third = length(unique(OBIWAN_PIT_third$id))

# PLOTS -------------------------------------------------------------------


#  _PITing  


#********************************** PLOT 1 main effect by subject ########### rainplot _PITing
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')


#ratings

df_PIT <- summarySEwithin(bsCg,
                         measurevar = "gripFreq",
                         withinvars = c("condition", "group"), 
                         idvar = "id")

df_PIT_C  <- subset(df_PIT, condition == 'BL')
df_PIT_Co  <- subset(df_PIT_C, group == 'obese')
df_PIT_Cc  <- subset(df_PIT_C, group == 'control')

df_PIT_R  <- subset(df_PIT, condition == 'CSplus')
df_PIT_Ro  <- subset(df_PIT_R, group == 'obese')
df_PIT_Rc  <- subset(df_PIT_R, group == 'control')

df_PIT_M  <- subset(df_PIT, condition == 'CSminus')
df_PIT_Mo  <- subset(df_PIT_M, group == 'obese')
df_PIT_Mc  <- subset(df_PIT_M, group == 'control')

bsC_C  <- subset(bsCg, condition == 'BL')
bsC_Co  <- subset(bsC_C , group == 'obese')
bsC_Cc  <- subset(bsC_C , group == 'control')

bsC_R  <- subset(bsCg, condition == 'CSplus')
bsC_Ro  <- subset(bsC_R , group == 'obese')
bsC_Rc  <- subset(bsC_R , group == 'control')

bsC_M  <- subset(bsCg, condition == 'CSminus')
bsC_Mo  <- subset(bsC_M , group == 'obese')
bsC_Mc  <- subset(bsC_M , group == 'control')


plt1 <- ggplot(data = bsCg, aes(x = condition, y = gripFreq, color = group, fill = group)) +
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
  geom_line(data = df_PIT, aes(x = as.numeric(condition) +0.15, y = gripFreq, group=group), alpha=0.4,  
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
        caption = "Second session: nControl = 30, nObese = 62. \n Error bars represent standard error of measurement")

plot(plt1)

pdf(file.path(figures_path,paste(task, '_PIT_ratings_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()


#**********************************  PLOT 2 main effect by trial # # plot _PITing by time by condition  

df_PIT <- summarySEwithin(bsTCg,
                         measurevar = "gripFreq",
                         withinvars = c("condition", "trialxcondition", "group"), 
                         idvar = "id")

df_PIT$condition <- factor(df_PIT$condition, levels = rev(levels(df_PIT$condition)))

df_PIT$trialxcondition =as.numeric(df_PIT$trialxcondition)

plt2 <- ggplot(df_PIT, aes(x = trialxcondition, y = gripFreq, fill = condition, color=condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_abline(slope= 0, intercept=50, linetype = "dasPIT", color = "black") +
  geom_ribbon(aes(ymax = gripFreq +se, ymin = gripFreq -se), alpha=0.2, linetype = 0 ) +
  scale_fill_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_color_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(30,80),  breaks=c(seq.int(30,80, by = 5))) +
  scale_x_continuous(expand = c(0, 0), limits = c(0,20.25), breaks=c(seq.int(1,20, by = 1)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.text.x = element_text(size=11,  colour = "black"),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), 
        legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Number of Grips")


pdf(file.path(figures_path,paste(task, '_PIT_time_ses2.pdf',  sep = "_")),
    width     = 7.5,
    height    = 6)

plot(plt2)
dev.off()
plot(plt2)




