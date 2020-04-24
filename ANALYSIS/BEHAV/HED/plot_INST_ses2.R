## R code for FOR OBIWAN_INST Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, lme4, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)

#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'INST'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_INST_full <- read.delim(file.path(analysis_path,'OBIWAN_INST.txt'), header = T, sep ='') # read in dataset


#subset
OBIWAN_INST  <- subset(OBIWAN_INST_full, session == 'second') #only session 2
OBIWAN_INST_control  <- subset(OBIWAN_INST, group == 'control') 
OBIWAN_INST_obese  <- subset(OBIWAN_INST, group == 'obese') 
OBIWAN_INST_third  <- subset(OBIWAN_INST_full, session == 'third') #only session 2


# define factors
OBIWAN_INST$id      <- factor(OBIWAN_INST$id)
OBIWAN_INST$trial    <- factor(OBIWAN_INST$trial)
OBIWAN_INST$group    <- factor(OBIWAN_INST$group)

#OBIWAN_INST$condition[OBIWAN_INST$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_INST$condition[OBIWAN_INST$condition== 'Empty']     <- 'Control'
OBIWAN_INST$condition <- factor(OBIWAN_INST$condition)

OBIWAN_INST$trialxcondition <- factor(OBIWAN_INST$trialxcondition)



# get means by condition 
bt = ddply(OBIWAN_INST, .(trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE)) 
btg = ddply(OBIWAN_INST, .(group, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_INST, .(condition, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
btcg = ddply(OBIWAN_INST, .(group, condition, trialxcondition), summarise,  RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

# get means by participant 
bsT = ddply(OBIWAN_INST, .(id, trialxcondition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsC= ddply(OBIWAN_INST, .(id, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsTC = ddply(OBIWAN_INST, .(id, trialxcondition, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

bsTg = ddply(OBIWAN_INST, .(id, group, trialxcondition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsCg= ddply(OBIWAN_INST, .(id, group, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 
bsTCg = ddply(OBIWAN_INST, .(id, group, trialxcondition, condition), summarise, RT = mean(RT, na.rm = TRUE),  liking = mean(liking, na.rm = TRUE) ) 

tot_n = length(unique(OBIWAN_INST$id))
tot_control = length(unique(OBIWAN_INST_control$id))
tot_obese = length(unique(OBIWAN_INST_obese$id))
tot_obese_third = length(unique(OBIWAN_INST_third$id))

# PLOTS -------------------------------------------------------------------


#  INST


#********************************** PLOT 1 main effect by subject ########### rainplot _INSTing
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')


#RT

df_INST <- summarySEwithin(bsCg,
                          measurevar = "RT",
                          withinvars = c("condition", "group"), 
                          idvar = "id")


df_INST_R  <- subset(df_INST, condition == 'CSplus')
df_INST_Ro  <- subset(df_INST_R, group == 'obese')
df_INST_Rc  <- subset(df_INST_R, group == 'control')

df_INST_M  <- subset(df_INST, condition == 'CSminus')
df_INST_Mo  <- subset(df_INST_M, group == 'obese')
df_INST_Mc  <- subset(df_INST_M, group == 'control')

df_INST_o  <- subset(df_INST, group == 'obese')
df_INST_c  <- subset(df_INST, group == 'control')


bsC_R  <- subset(bsCg, condition == 'CSplus')
bsC_Ro  <- subset(bsC_R , group == 'obese')
bsC_Rc  <- subset(bsC_R , group == 'control')

bsC_M  <- subset(bsCg, condition == 'CSminus')
bsC_Mo  <- subset(bsC_M , group == 'obese')
bsC_Mc  <- subset(bsC_M , group == 'control')


plt1 <- ggplot(data = bsCg, aes(x = condition, y = RT, color = group, fill = group)) +
  #left CS- ob
  geom_left_violin(data = bsC_Mo, alpha = .4, adjust = 1.5, trim = F, color = NA) +
  geom_point(data = df_INST_Mo, aes(x = as.numeric(condition)+0.2), shape = 18, color ="black") +
  geom_errorbar(data=df_INST_Mo, aes(x = as.numeric(condition)+0.2, ymax = RT + se, ymin = RT - se), width=0.1,  alpha=1, size=0.4)+
  
  #left cs- co
  geom_left_violin(data = bsC_Mc, alpha = .4, adjust = 1.5, trim = F, color = NA) +
  geom_point(data = df_INST_Mc,  aes(x = as.numeric(condition)+0.1), shape = 18, color ="black") +
  geom_errorbar(data=df_INST_Mc, aes(x = as.numeric(condition)+0.1, ymax = RT + se, ymin = RT - se), width=0.1,  alpha=1, size=0.4)+
  
  
  #right CS+ ob
  geom_right_violin(data = bsC_Ro, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_INST_Ro, aes(x = as.numeric(condition)+0.2, y = RT), color ="black", shape = 18) +
  geom_errorbar(data=df_INST_Ro, aes(x = as.numeric(condition)+0.2, y = RT, ymax = RT + se, ymin = RT - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #right CS+ co
  geom_right_violin(data = bsC_Rc, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_INST_Rc, aes(x = as.numeric(condition)+0.1, y = RT), shape = 18, color ="black") +
  geom_errorbar(data=df_INST_Rc, aes(x = as.numeric(condition)+0.1, y = RT, ymax = RT + se, ymin = RT - se)
                , width=0.1, alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsCg, aes(x = as.numeric(condition) +0.15, y = RT), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = df_INST_o, aes(x = as.numeric(condition) +0.2, y = RT, group=group), alpha=0.4) +
  
  geom_line(data = df_INST_c, aes(x = as.numeric(condition) +0.1, y = RT, group=group), alpha=0.4) +
  
  #details
  #scale_fill_manual(values = c("obese"="blue", "control"="black")) +
  #scale_color_manual(values = c("obese"="blue", "control"="black")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(240,760, by = 40)), limits = c(240,760)) +
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
        caption = "Second session: nControl = 30, nObese = 64. \n Error bars represent standard error of measurment")

plot(plt1)

pdf(file.path(figures_path,paste(task, '_INST_RT_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()


#RTatings

df_LIK <- summarySEwithin(bsCg,
                          measurevar = "liking",
                          withinvars = c("condition", "group"), 
                          idvar = "id")


df_LIK_R  <- subset(df_LIK, condition == 'CSplus')
df_LIK_Ro  <- subset(df_LIK_R, group == 'obese')
df_LIK_Rc  <- subset(df_LIK_R, group == 'control')

df_LIK_M  <- subset(df_LIK, condition == 'CSminus')
df_LIK_Mo  <- subset(df_LIK_M, group == 'obese')
df_LIK_Mc  <- subset(df_LIK_M, group == 'control')

df_LIK_o  <- subset(df_LIK, group == 'obese')
df_LIK_c  <- subset(df_LIK, group == 'control')



plt2 <- ggplot(data = bsCg, aes(x = condition, y = liking, color = group, fill = group)) +
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
  geom_line(data = df_LIK_o, aes(x = as.numeric(condition) +0.2, y = liking, group=group), alpha=0.4) +
  
  geom_line(data = df_LIK_c, aes(x = as.numeric(condition) +0.1, y = liking, group=group), alpha=0.4) +
  
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
  labs( x = "CS-                            CS+", 
        y = "Pleasantness Ratings",
        caption = "Second session: nControl = 30, nObese = 64. \n Error bars represent standard error of measurement")

plot(plt2)

pdf(file.path(figures_path,paste(task, '_INST_ratings_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt2)
dev.off()


#**********************************  PLOT 2 main effect by trial # # plot _INSTing by time by condition  

df_INST <- summarySEwithin(bsTCg,
                          measurevar = "RT",
                          withinvars = c("condition", "trialxcondition", "group"), 
                          idvar = "id")

df_INST$condition <- factor(df_INST$condition, levels = rev(levels(df_INST$condition)))

df_INST$trialxcondition =as.numeric(df_INST$trialxcondition)

plt2 <- ggplot(df_INST, aes(x = trialxcondition, y = RT, fill = condition, color=condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_abline(slope= 0, intercept=50, linetype = "dasINST", color = "black") +
  geom_ribbon(aes(ymax = RT +se, ymin = RT -se), alpha=0.2, linetype = 0 ) +
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


#pdf(file.path(figures_path,paste(task, '_INST_time_ses2.pdf',  sep = "_")),
#width     = 7.5,
#height    = 6)

plot(plt2)
dev.off()
plot(plt2)


