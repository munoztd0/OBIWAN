## R code for FOR PIT PLOT TO
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

mod <- lmer(gripC ~ condition*group + hungryC:condition  +(condition |id) + (1|trialxcondition) , 
            data = PIT, control = control)

N_group = ddply(PIT, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

BMI_group = ddply(PIT, .(group), summarise, bmi=mean(BMI_t1)) 


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

#increase repetitions limit
emm_options(pbkrtest.limit = 5000, lmerTest.limit = 5000)

#get contrasts and means
SE_eff = emmeans(mod, pairwise~ condition|group, adjust = "tukey")

df.predicted = data.frame(SE_eff$contrasts)

df.observed = ddply(PIT, .(id, condition, group), summarise, estimate = mean(gripC, na.rm = TRUE)) 
CSp = subset(df.observed, condition == 1)
CSm = subset(df.observed, condition == -1)
diff = CSp
diff$estimate = CSp$estimate - CSm$estimate

df.observed = diff

df.observed.jit <- df.observed %>% mutate(groupjit = jitter(as.numeric(group), 0.25),
                                          grouping = interaction(id, group))


plt0 <- ggplot(df.observed.jit, aes(x = group, y = estimate, fill = group)) + 
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.8) +
  geom_point(aes(x=group,y=estimate),size=2,shape=20, alpha=.5, position=position_jitter(width=0.05, seed = 59)) +
  geom_flat_violin(aes(x=group,y=estimate),position=position_nudge(x=0.15),adjust=1.5,trim=FALSE,alpha=.6,colour=NA) +
  geom_errorbar(data = df.predicted,aes(group = group, ymin=estimate-SE, ymax=estimate+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  geom_point(data = df.predicted, aes(x=group,y=estimate),size=1.5,shape=23,position=position_nudge(x=0.15)) +
  geom_boxplot(aes(x=group,y=estimate),fatten = 0.5, outlier.shape=NA, alpha=.6,width=.1,colour="black") 

labels <- c("-1" = "   Lean", "1" = "   Obese")

plot = plt0 + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-150,150, by = 50)), limits = c(-150,150)) +
  scale_x_discrete(labels=labels) +
  scale_fill_manual(values=c('royalblue','aquamarine3'),labels=labels) +
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
        axis.ticks.x = element_blank(),
        legend.position = "none", #legend.title=element_blank(),legend.text=element_text(size=14),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "", 
       y =  "\u0394 Mobilized Effort (AUC)", x = "",
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

