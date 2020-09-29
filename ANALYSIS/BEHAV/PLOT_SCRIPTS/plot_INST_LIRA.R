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
load('INST_LIRA.RData')
options(contrasts=c("contr.sum","contr.poly")) #set contrasts to sum !
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

t0 = subset(INST, session == 'second')
t1 = subset(INST, session == 'third')
N_t0 = ddply(t0, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention)) %>% tally()
N_t1 = ddply(t1, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention)) %>% tally()

#use non centered DV for plotting?
mod <- lmer(gripC ~ lspline(trial, 5)* session*intervention +  thirstyC + thirstyC:trial + thirstyC:spline +  hungryC + pissC + (session |id) ,  data = INST, control = control)


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

# extract data for plot
INST$x = INST$trial
INST$y = INST$grips
splinemod <- lm(y ~ lspline(x, 5), data=INST)

df.observed = ddply(INST, .(trial, session, intervention), summarise, y = mean(grips, na.rm = TRUE)) 
df.observed$x = df.observed$trial
INST$intervention = as.factor(INST$intervention)

labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")
labelsSES <- c("second" = "Pre-Test", "third" = "Post-Test")

plt = ggplot(INST, aes(x, y, color = intervention))+
  geom_point(data=df.observed, shape = 21, alpha = 0.8) +
  geom_smooth(method="lm", formula=formula(splinemod), size=0.7) +  
  facet_wrap(~ session, labeller=labeller(session = labelsSES))

plot = plt + 
  theme_classic() +
  #scale_y_continuous(expand = c(0, 0), breaks = round(seq(min(INST$x), max(INST$x), by = 1),1)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0,25), breaks=c(1,seq.int(5,25, by = 5))) + #,breaks=c(seq.int(1,24, by = 2), 24), limits = c(0,24)) + 
  scale_color_manual(labels=labelsTRE, values=c('seagreen3','royalblue')) +
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
       caption = "SlopeXSession p < 0.001, Intervention p = 0.003\n 
       Error bar represent \u00B1 SE\n
       Prediction controling for motivational levels\n") #Slope 1-5, p < 0.001

plot(plot)
#thirsty infleunce

cairo_pdf(file.path(figures_path,paste(task, 'trialXsessionXinterv.pdf',  sep = "_")),
          width = 10,
          height = 5.5)

plot(plot)
dev.off()

#create table
sjPlot::tab_model(mod)



#using jtool to look at ICC and more
summ(mod)
