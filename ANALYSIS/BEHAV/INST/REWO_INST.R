## R code for FOR REWOD_INST
# last modified on Nov 2019 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------


# load libraries
pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, ez, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

task = 'INSTRU'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
setwd(analysis_path)

# open dataset
REWOD_INST <- read.delim(file.path(analysis_path,'REWOD_INSTRU_ses_first.txt'), header = T, sep ='') # read in dataset

# define factors
REWOD_INST$id                       <- factor(REWOD_INST$id)
REWOD_INST$session                  <- factor(REWOD_INST$session)
REWOD_INST$rewarded_response        <- factor(REWOD_INST$rewarded_response)
REWOD_INST$trial        <- factor(REWOD_INST$trial)

## remove sub 8 (we dont have scans)
REWOD_INST <- subset (REWOD_INST,!id == '8') 

#REWOD_INST <- filter(REWOD_INST, rewarded_response == 2)




df <- summarySE(REWOD_INST, measurevar="n_grips", groupvars=c("id", "trial"))
dfTRIAL <- summarySEwithin(df,
                         measurevar = "n_grips",
                         withinvars = "trial", 
                         idvar = "id")


dfTRIAL$trial        <- as.numeric(dfTRIAL$trial)
##plot n_grips to see the trajectory of learning (overall average by trials)


ggplot(dfTRIAL, aes(x = trial, y = n_grips)) +
    geom_point() + geom_line(group=1) +
    geom_errorbar(aes(ymin=n_grips-se, ymax=n_grips+se), color='grey', width=.3,
                  position=position_dodge(0.05), linetype = "dashed") +
    theme_classic() +
    scale_y_continuous(expand = c(0, 0), limits = c(10,14)) + #, breaks = c(9.50, seq.int(10,15, by = 1)), ) +
    scale_x_continuous(expand = c(0, 0), limits = c(0,25), breaks=c(0, seq.int(1,25, by = 3))) + #,breaks=c(seq.int(1,24, by = 2), 24), limits = c(0,24)) + 
    labs(x = "Trial
          ",
      y = "Number of Squeezes",title= "   
       ") +
    theme(text = element_text(size=rel(4)), plot.margin = unit(c(1, 1,0, 1), units = "cm"), axis.title.x = element_text(size=16), axis.title.y = element_text(size=16))

  
#ANALYSIS

# ANOVA trials ------------------------------------------------------------


##1. number of grips: are participants gripping more over time?
REWOD_INST$trial            <- factor(REWOD_INST$trial)


anova_model = ezANOVA(data = REWOD_INST,
                      dv = n_grips,
                      wid = id,
                      within = trial,
                      detailed = TRUE,
                      type = 3)  #Ben say they is less Type I error with 2 though ? Here it doesnt change 

inst.aov <- aov_car(n_grips ~ trial + Error(id/trial), data = REWOD_INST, anova_table = list(es = "pes"))
inst.aov
inst.aov_sum <- summary(inst.aov)
inst.aov_sum



#spher = GG corr
#get the same F and all so I just use anova_model to calculate Omega and CI becuase its easier

# effect sizes ------------------------------------------------------------

source('~/REWOD/CODE/ANALYSIS/BEHAV/my_tools/pes_ci.R')

pes_ci(n_grips ~ trial + Error(id/trial),  REWOD_INST, 0.95,"GG", "III")


#contrasts (1 VS 5 first)

# 
# # 1 VS first 5
# cont = emmeans(inst.aov, ~ trial)
# x <- coef(pairs(cont))[c("c.1")]
# #contr_mat = x + c(0, 0, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
# contr_mat = x + c(0, 0, -1, -1 ,-1, -1, -1 ,-1, -1, -1, -1, -1 ,-1 ,-1, -1 ,-1, -1, -1 ,-1, -1 ,-1, -1, -1, -1)
# 
# emmeans(inst.aov, ~ trial, contr = contr_mat, adjust = "none")$contrasts
# 
# 
# 
# confint(emmeans(main.model.lik, ~ condition, contr = contr_mat, adjust = "none")$contrasts)



REWOD_INST$time <- rep(0, (length(REWOD_INST$trial)))

REWOD_INST$time[REWOD_INST$trial== '1']     <- 1

REWOD_INST$time[REWOD_INST$trial== '2']     <- -1
REWOD_INST$time[REWOD_INST$trial== '3']     <- -1
REWOD_INST$time[REWOD_INST$trial== '4']     <- -1
REWOD_INST$time[REWOD_INST$trial== '5']     <- -1


REWOD_INST$time        <- factor(REWOD_INST$time)
inst.aovtime <- aov_car(n_grips ~ time + Error(id/time), data = REWOD_INST, anova_table = list(es = "pes"))
inst.aovtime
inst.aovtime_sum <- summary(inst.aovtime)
inst.aovtime_sum

#extrcat corrcted p-value
ems = emmeans(inst.aovtime, list(pairwise ~ time), adjust = "none")
ems$`pairwise differences of time`[2]
0.0029 * 5

pes_ci(n_grips ~ time + Error(id/time),  REWOD_INST, 0.90, "III")



