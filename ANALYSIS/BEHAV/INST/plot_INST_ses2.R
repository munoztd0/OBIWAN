## R code for FOR OBIWAN_INST Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmegripsest, lme4, car, r2glmm, optimx, visreg, MuMIn, BayesFactor, sjstats)

#Influence.ME,lmegripsest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

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

#OBIWAN_INST$trial <- factor(OBIWAN_INST$trial)



# get means by condition 
bt = ddply(OBIWAN_INST, .(trial=), summarise,  grips = mean(grips, na.rm = TRUE) ) 
btg = ddply(OBIWAN_INST, .(group, trial), summarise,  grips = mean(grips, na.rm = TRUE) ) 

# get means by condition and trial
#btc = ddply(OBIWAN_INST, .(condition, trial), summarise,  grips = mean(grips, na.rm = TRUE) ) 
#btcg = ddply(OBIWAN_INST, .(group, condition, trial), summarise,  grips = mean(grips, na.rm = TRUE)  ) 

# get means by pagripsicipant 
bsT = ddply(OBIWAN_INST, .(id, trial), summarise, grips = mean(grips, na.rm = TRUE)  ) 
#bsC= ddply(OBIWAN_INST, .(id, condition), summarise, grips = mean(grips, na.rm = TRUE) ) 
#bsTC = ddply(OBIWAN_INST, .(id, trial, condition), summarise, grips = mean(grips, na.rm = TRUE) ) 

bsTg = ddply(OBIWAN_INST, .(id, group, trial), summarise, grips = mean(grips, na.rm = TRUE)  ) 
#bsCg= ddply(OBIWAN_INST, .(id, group, condition), summarise, grips = mean(grips, na.rm = TRUE) ) 
#bsTCg = ddply(OBIWAN_INST, .(id, group, trial, condition), summarise, grips = mean(grips, na.rm = TRUE)  ) 

tot_n = length(unique(OBIWAN_INST$id))
tot_control = length(unique(OBIWAN_INST_control$id))
tot_obese = length(unique(OBIWAN_INST_obese$id))
tot_obese_third = length(unique(OBIWAN_INST_third$id))

# PLOTS -------------------------------------------------------------------


#  INST



source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')




#**********************************  PLOT 1 main effect of grips by trial # 

#from Morey (2008)
df_INST <- summarySEwithin(bsTg,
                          measurevar = "grips",
                          withinvars = c("trial", "group"), 
                          idvar = "id")

#df_INST$condition <- factor(df_INST$condition, levels = rev(levels(df_INST$condition)))

df_INST$trial =as.numeric(df_INST$trial)

plt2 <- ggplot(df_INST, aes(x = trial, y = grips, fill = group, color=group)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  #geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_ribbon(aes(ymax = grips +se, ymin = grips -se), alpha=0.2, linetype = 0 ) +
  scale_fill_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  #scale_color_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(6,14),  breaks=c(seq.int(6,14, by = 2))) +
  scale_x_continuous(expand = c(0, 0), limits = c(0,25), breaks=c(seq.int(1,25, by = 2)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.text.x = element_text(size=11,  colour = "black"),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), 
        legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trial",
       y = "Number of Grips",
       caption = "Second session: nControl = 31, nObese = 63 \n Error bars represent SEM for within-subject design using method from Morey (2008)")


pdf(file.path(figures_path,paste(task, 'time_ses2.pdf',  sep = "_")),
  width     = 7.5,
  height    = 6)

plot(plt2)
dev.off()
plot(plt2)


