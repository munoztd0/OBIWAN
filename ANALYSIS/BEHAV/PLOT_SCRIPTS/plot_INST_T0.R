## R code for FOR INST PLOT
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, Rmisc, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni, jtools, interactions, sjstats, lspline)

# SETUP ------------------------------------------------------------------

task = 'INST'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

## LOADING AND INSPECTING THE DATA
load('INST.RData')
options(contrasts=c("contr.sum","contr.poly")) #set contrasts to sum !

#use non centered DV for plotting
mod <- lmer(grips ~ lspline(trial, 5)* group + diff_thirstyC:trial + diff_hungryC:trial + (1 |id) ,  data = INST, control = control)

N_group = ddply(INST, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

BMI_group = ddply(INST, .(group), summarise, bmi=mean(BMI_t1)) 


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions


# extract data for plot
INST$x = INST$trial
INST$y = INST$grips
splinemod <- lm(y ~ lspline(x, 5), data=INST)

df.observed = ddply(INST, .(trial), summarise, y = mean(grips, na.rm = TRUE)) 
df.observed$x = df.observed$trial

plt = ggplot(INST, aes(x, y))+
  geom_point(data=df.observed, shape = 21, fill ="grey40", alpha = 0.8) +
  geom_smooth(method="lm", formula=formula(splinemod), color="aquamarine3",fill = "grey30", size=0.7) 
  #geom_vline(xintercept = c(4), linetype=2)+
  
plot = plt + 
theme_classic() +
  #scale_y_continuous(expand = c(0, 0), breaks = round(seq(min(INST$x), max(INST$x), by = 1),1)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0,25), breaks=c(seq.int(1,24, by = 1))) + #,breaks=c(seq.int(1,24, by = 2), 24), limits = c(0,24)) + 
  theme(aspect.ratio = 1/1.7,
        plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_line(size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x =  element_text(size=8,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.title=element_blank(),
        legend.text=element_text(size=14),
        strip.background = element_rect(fill="white"))+  
  labs(x = "Trial", y = "Number of Grips", title= "", 
      caption = "Slope 1-5, p = 0.003; Slope 6-24, p < 0.001\n 
       Error bar represent \u00B1 SE\n
       Prediction controling for motivational levels\n") #Slope 1-5, p < 0.001

cairo_pdf(file.path(figures_path,paste(task, 'trial.pdf',  sep = "_")),
          width = 6,
          height = 5.5)

plot(plot)
dev.off()

#create table
sjPlot::tab_model(mod)
# show.re.var= TRUE, 
# show.icc = TRUE,
# show.r2 = TRUE,
# show.stat = TRUE,
# #rm.terms
# #show.aic = TRUE,
# #bootstrap = TRUE,
# #iterations = 5000,
# pblue.labels =c("(Intercept)", "Pavlovian Cue (CS-)", "BMI", "Hunger", "Thirst", "Need to urinate",
#                 "Pavlovian Cue (CS-) X BMI", "Pavlovian Cue (CS-) X Hunger"),
# dv.labels= "Moblized Effort")


#using jtool to look at ICC and more
summ(mod)
