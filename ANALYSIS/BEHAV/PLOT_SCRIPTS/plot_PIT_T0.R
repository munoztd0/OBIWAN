## R code for FOR PIT PLOT
## last modified on April 2020 by David MUNOC TORD

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

mod <- lmer(gripC ~ condition*group + hungryC:condition  +(condition |id) + (1|trialxcondition) , 
            data = PIT, control = control)

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

df.predicted = data.frame(CI_inter$emmeans)
df.observed = ddply(PIT, .(id, group, condition), summarise, emmean = mean(gripC, na.rm = TRUE)) 
# position on x axis is based on combination of B and jittered A. Mix to taste.
df.observed.jit <- df.observed %>%
  mutate(groupjit = as.numeric(condition)*0.4 - 0.6 + jitter(as.numeric(group), 0.55),
         grouping = interaction(id, group))

df.predicted.jit <- df.predicted %>%
  mutate(groupjit = as.numeric(condition)*0.4 - 0.6 + jitter(as.numeric(group), 0.55),
         grouping = interaction(1, group))

plt0 = ggplot(df.observed.jit, aes(x=group,  y=emmean,  group = grouping)) + 
  geom_blank() +
  geom_line(aes(groupjit), alpha = 0.1) +
  geom_point(aes(groupjit, col=condition), size=0.8, alpha=0.5)

plt = plt0 +
  geom_bar(data = df.predicted.jit, stat = "identity", position=position_dodge2(width=1), fill = "black", alpha = 0.3, width = 0.7) +
  geom_errorbar(data = df.predicted.jit,aes(group = condition, ymin=emmean-SE, ymax=emmean+SE), size=0.5, width=0.1,  color = "black", position=position_dodge(width = 0.7)) + 
  geom_point(data = df.predicted.jit, size = 2, shape=23, color= "black", fill = 'grey40',  position=position_dodge2(width = 0.7))

plot = plt + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-80,80, by = 40)), limits = c(-80,80)) +
  scale_x_discrete(labels=c("Lean", "Obese")) +
  scale_color_manual(values=c('royalblue','aquamarine3'),labels=c("CS+", "CS-")) +
  guides(color = guide_legend(override.aes = list(shape = 15, size = 2))) + 
  theme_bw() +
  theme(aspect.ratio = 1.7/1,
        plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #element_line(size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x =  element_text(size=14,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16),   
        axis.line.x = element_blank(),
        legend.title=element_blank(),
        legend.text=element_text(size=14),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "", 
       y =  "Mobilized Effort - AUC (x - \u03BC\u2071)", x = "",
       caption = "Two-way interaction (GroupxPavCue): p = 0.031\n
       CS+ > CS-; Lean, p = 0.77; Obese, p = 0.0038\n 
       Error bar represent \u00B1 SE for the model estimated means\n
       Prediction controling for satiety levels\n")

plot(plot)

cairo_pdf(file.path(figures_path,paste(task, 'condXgroup.pdf',  sep = "_")),
          width = 5.5,
          height = 6)

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

