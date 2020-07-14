## R code for FOR PIT PLOT
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni, jtools, interactions, sjstats)

# SETUP ------------------------------------------------------------------

task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

## LOADING AND INSPECTING THE DATA
load('PIT.RData')

mod <- lmer(gripZ ~ condition*group + hungryZ + hungryZ:condition + thirstyZ + pissZ  +(condition |id) + (1|trialxcondition) , 
            data = PIT, control = control) #need to be fitted using ML so here I just use lmer function so its faster

#check groups
# PIT$group2 = c(1:length(PIT$group))
# PIT$group2[PIT$BMI_t1 < 30 ] <- '-1' # control BMI = 22.25636 
# PIT$group2[PIT$BMI_t1 >= 30 & PIT$BMI_t1 < 35] <- '0' # Class I obesity: BMI = 30 to 35. 
# PIT$group2[PIT$BMI_t1 >= 35] <- '1' # Class II obesity: BMI = 35 to 40.

N_group = ddply(PIT, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

BMI_group = ddply(PIT, .(group), summarise, bmi=mean(BMI_t1)) 


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)


#get contrasts for groups obesity X condition
CI_inter = confint(emmeans(mod, pairwise~ condition|group, adjust = "tukey"),level = 0.95,method = c("boot"),nsim = 5000)

df.predicted = data.frame(CI_inter$contrasts)

CSPlus <- subset(PIT, condition =="1" )
CSPlus <- CSPlus[order(as.numeric(levels(CSPlus$id))[CSPlus$id], CSPlus$trialxcondition),]
CSMinus <- subset(PIT, condition =="-1" )
CSMinus <- CSMinus[order(as.numeric(levels(CSMinus$id))[CSMinus$id], CSPlus$trialxcondition),]
df = CSMinus
df$diff = CSPlus$gripZ - CSMinus$gripZ
df.observed = ddply(df, .(id, group), summarise, estimate = mean(diff, na.rm = TRUE)) 

plt = ggplot(data = df.predicted, aes(x=group, y= estimate)) + 
  geom_point(data = df.observed, size=0.7, color='royalblue', alpha=0.5, position=position_jitter(seed =123,width=0.2)) +
  geom_abline(slope=0, intercept=0, linetype='dashed', size=0.5, alpha=0.5) + 
  geom_errorbar(data = df.predicted, aes(ymin=lower.CL, ymax=upper.CL), size=0.5, width=0.1) + 
  geom_point(shape=23, color='blue', fill='royalblue')

plot = plt + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-2,2, by = 1)), limits = c(-2,2)) +
  scale_x_discrete(labels=c("Lean", "Obese")) +
  #coord_fixed(ratio=0.9) +
  theme_bw() +
  theme(aspect.ratio = 1.7/1,
        plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #element_line(size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x =  element_text(size=10,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16),   
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "", 
       y =  "\u0394 Mobilized Effort (z)", x = "",
       caption = "Two-way interaction (GroupxPavCue): p = 0.040\n
       Post-hoc test, Lean: p = 0.64, Obese: p = 0.0011\n 
       Error range represent 95% CI for the model estimated \n
       prediction controling for satiety levels\n")

plot(plot)

cairo_pdf(file.path(figures_path,paste(task, 'condXgroup.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt)
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

