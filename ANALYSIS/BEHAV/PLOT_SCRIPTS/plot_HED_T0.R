## R code for FOR HED PLOT
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni, jtools, interactions, sjstats)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

## LOADING AND INSPECTING THE DATA
load('HED.RData')

mod <- lmer(likZ ~ condition*group  + famZ + intZ+ intZ:condition + thirstyZ + hungryZ:condition +  hungryZ + pissZ + 
              (condition + famZ*intZ|id) + (condition|trialxcondition), data = HED, control = control) #need to be fitted using ML so here I just use lmer function so its faster

#check groups
# HED$group = c(1:length(HED$group))
# HED$group[HED$group < 30 ] <- '-1' # control BMI = 22.25636 
# HED$group[HED$group >= 30 & HED$group < 35] <- '0' # Class I obesity: BMI = 30 to 35. 
# HED$group[HED$group >= 35] <- '1' # Class II obesity: BMI = 35 to 40.

N_group = ddply(HED, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

BMI_group = ddply(HED, .(group), summarise, bmi=mean(group)) 


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#get model prediction estimates
em = emmeans(mod, pairwise~ condition|group, adjust = "mvt")
em.df = confint(em) #get CI
df.predicted = as.data.frame(em.df$contrasts)

#get observed
full.obs = ddply(HED, .(id, group, condition), summarise, estimate = mean(likZ)) 
reward = subset(full.obs, condition == '1')
neutral = subset(full.obs, condition == '-1')
df.observed = neutral
df.observed$estimate = reward$estimate - neutral$estimate

plt <-   ggplot(data = df.predicted, aes(x=group, y= estimate)) + 
  geom_point(data = df.observed, size=0.7, color='tomato', alpha=0.5, position=position_jitter(seed =123,width=0.2)) +
  geom_abline(slope=0, intercept=0, linetype='dashed', size=0.5, alpha=0.5) + 
  geom_errorbar(data = df.predicted, aes(ymin=lower.CL, ymax=upper.CL), size=0.5, width=0.1) + 
  geom_point(shape=23, color='red', fill='tomato')

plot = plt + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-2,4, by = 1)), limits = c(-2,4)) +
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
       y =  "\u0394 Pleasantness Ratings (z)", x = "",
       caption = "Two-way interaction (GroupxSolution): p = 0.21\n
       Post-hoc test, Lean: p = 0.016, Obese: p < 0.001\n 
       Error range represent 95% CI for the model estimated \n
       prediction controling for motivational states\n")

plot(plot)

cairo_pdf(file.path(figures_path,paste(task, 'condXgroup.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt)
dev.off()


#create table
sjPlot::tab_model(mod, 
                  show.re.var= TRUE, 
                  show.icc = TRUE,
                  show.r2 = TRUE,
                  show.stat = TRUE,
                  #rm.terms
                  #show.aic = TRUE,
                  #bootstrap = TRUE,
                  #iterations = 5000,
                  pred.labels =c("(Intercept)", "Pavlovian Cue (CS-)", "BMI", "Hunger", "Thirst", "Need to urinate",
                                 "Pavlovian Cue (CS-) X BMI", "Pavlovian Cue (CS-) X Hunger"),
                  dv.labels= "Moblized Effort")


#using jtool to look at ICC and more
summ(mod)
#interact_plot(mod, pred = bmiZ, modx = condition) + 
#theme_apa(legend.pos = "bottomright")

# contrast estimate     SE df lower.CL upper.CL t.ratio p.value
# 1 - -1      0.136 0.0596 80   0.0373      Inf  2.290   0.0123 

# bmiZ = -1.36:
#   contrast estimate     SE df lower.CL upper.CL t.ratio p.value
# 1 - -1   -0.00279 0.1013 80  -0.1713      Inf   -0.028  0.5110 
# bmiZ =  0.17:
# 1 - -1    0.15502 0.0606 80   0.0542      Inf   2.559  0.0062 
# bmiZ =  0.92:
# 1 - -1    0.23238 0.0820 80   0.0959      Inf  2.832  0.0029 


# 
# #contrasts on estimated means adjusted via the Multivariate normal t distribution // taken the mean of each group
# cont = emmeans(mod, pairwise~ condition|group, at = list(group = c(-1.36,0.17,0.92)), adjust = "mvt")
# cont
# #pwpp(cont$emmeans)
# plot(cont, comparisons = TRUE, horizontal = FALSE) #no overlapping red arrow-> signif
# df.HED = as.data.frame(cont$contrasts) 
# df.HED$group <- as.character(df.HED$group)
# 
# #change value of groups to plot
# HED$group = c(1:length(HED$group))
# HED$group[HED$group < 30 ] <- '-1.36' # control BMI = 22.25636 -> -1.36,
# HED$group[HED$group >= 30 & HED$group < 35] <- '0.17' # Class I obesity: BMI = 30 to 35. -> 0.17
# HED$group[HED$group >= 35] <- '0.92' # Class II obesity: BMI = 35 to 40. -> 0.92)
# #HED$group[HED$group > 40] <- '3' # Class III obesity: BMI 40 or higher -> 1.89
# 
# N_group = ddply(HED, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
#   group_by(group) %>% tally()
# 
# BMI_group = ddply(HED, .(group), summarise, bmi=mean(group)) 
# 
# contgroup = emmeans(mod, pairwise~ condition|group, at = list(group = c(-1.36,0.17,0.92)), adjust = "mvt")
# #get pval
# 
# cont = emmeans(mod, pairwise~ condition|group, at = list(group = c(-2,-1,0, 1, 2)), adjust = "mvt")
# 
# df = confint(cont)
# 
# df.HED = as.data.frame(df$contrasts)
# 
# df.HED %>%
#   ggplot(aes(group, estimate)) +
#   geom_line() +
#   geom_ribbon(aes(ymin=lower.CL, ymax=upper.CL), alpha = .1) +
#   geom_point(data = df.observed, size = 0.5, alpha = 0.4, color = 'tomato', position = position_jitter(width = 0.2)) +
#   ylab("Delta effort (z)")
# 
# 
# 
# 
# full.obs = ddply(HED, .(id, group, condition), summarise, estimate = mean(gripZ)) 
# plus = subset(full.obs, condition == '1')
# minus = subset(full.obs, condition == '-1')
# df.observed = minus
# df.observed$estimate = plus$estimate - minus$estimate
# df.observed$group = df.observed$group
# 
# labels <- c("-1.36" = "Lean", "0.17" = "Class I" , "0.92" = "II-III")
# 
# # pl <-  ggplot(df.HED, aes(x = group, y = estimate)) +
# #   #geom_bar(stat="identity", alpha=0.6, width=0.3, ) +
# #   geom_errorbar(aes(ymax = estimate + SE, ymin = estimate - SE), width=0.05,  alpha=1)+
# #   geom_point(size = 0.5, color = 'red') + 
# #   geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) + 
# #   geom_point(data = df.observed, size = 0.1, alpha = 0.4, color = 'tomato',  position = position_jitter(width = 0.1))
# 
# pl <-  ggplot(df.HED, aes(x = group, y = estimate)) +
#   geom_point(data = df.observed, size = 0.1, alpha = 0.4, color = 'tomato', position = position_jitter(width = 0.2)) +
#   geom_bar(data =df.HED, stat="identity", alpha=0.6, width=0.3) +
#   geom_errorbar(data =df.HED,  aes(ymax = estimate + SE, ymin = estimate - SE), color = 'black', width=0.05,  alpha=0.7)+
#   geom_point(size = 0.7, color = 'black') + 
#   geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) 
# 
# plt = pl + 
#   scale_y_continuous(expand = c(0, 0),
#                      breaks = c(seq.int(-1,2, by = 0.5)), limits = c(-1,2)) +
#   scale_x_discrete(labels=labels) + 
#   #coord_fixed(ratio=0.9) +
#   theme_bw() +
#   theme(aspect.ratio = 1.7/1,
#         plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
#         plot.title = element_text(hjust = 0.5),
#         plot.caption = element_text(hjust = 0.5),
#         panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
#         panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
#         axis.text.x =  element_text(size=10,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
#         axis.text.y = element_text(size=10,  colour = "black"),
#         axis.title.x =  element_text(size=16), 
#         axis.title.y = element_text(size=16),   
#         axis.ticks.x = element_blank(), 
#         axis.line.x = element_blank(),
#         strip.background = element_rect(fill="white"))+ 
#   labs(title = "HED Effect by BMI Category", 
#        y =  "\u0394 Mobilized Effort", x = "",
#        caption = "Error bars represent SEM for the model estimated mean constrasts\n")
# #Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")
# 
# 
# plot(plt)
# 
# cairo_pdf(file.path(figures_path,paste(task, 'condXbmi.pdf',  sep = "_")),
#           width     = 5.5,
#           height    = 6)
# 
# plot(plt)
# dev.off()
# 


# 
# # PLOT --------------------------------------------------------------------
# source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions
# 
# mod <- lmer(likZ ~ condition*bmiT  + gender + ageZ + famZ + condition*intZ + (condition*intZ + famZ |id) + (1|trialxcondition),
#             data = HED, control = control) #need to be fitted using ML so here I just use lmer function so its faster
# 
# 
# visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="bmiT", by='condition', gg=TRUE,type="contrast",ylab="Liking (z)",breaks=c(-1.03,022,0.89,1.89),xlab="")
# #contrasts on estimated means adjusted via the Multivariate normal t distribution
# cont = emmeans(mod, pairwise~ condition|bmiT, at = list(bmiT = c(-1,0,1)), adjust = "mvt")
# cont
# #pwpp(cont$emmeans)
# #plot(cont, comparisons = TRUE)
# df.HED = as.data.frame(cont$contrasts) 
# df.HED$bmiT <- as.character(df.HED$bmiT)
# 
# 
# full.obs = ddply(HED, .(id, group, condition), summarise, estimate = mean(likZ))
# milk = subset(full.obs, condition == '1')
# tastless = subset(full.obs, condition == '-1')
# df.observed = tastless
# df.observed$estimate = milk$estimate - tastless$estimate
# df.observed$bmiT = df.observed$group
# 
# labels <- c("-1" = "Lean", "0" = "Class I" , "1" = "II-III")
# 
# 
# pl <-  ggplot(df.HED, aes(x = bmiT, y = estimate)) +
#   geom_point(data = df.observed, size = 0.1, alpha = 0.7, color = 'seagreen3', position = position_jitter(width = 0.2)) +
#   geom_bar(stat="identity", alpha=0.6, width=0.3, ) +
#   geom_errorbar(data =df.HED,  aes(ymax = estimate + SE, ymin = estimate - SE), color = 'black', width=0.05,  alpha=0.7)+
#   geom_point(size = 0.7, color = 'black') + 
#   geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) 
# 
# plt = pl + 
#   scale_y_continuous(expand = c(0, 0),
#                      breaks = c(seq.int(-3,4, by = 1)), limits = c(-3,4)) +
#   scale_x_discrete(labels=labels) +
#   theme_bw() +
#   theme(aspect.ratio = 1.7/1,
#         plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
#         plot.title = element_text(hjust = 0.5),
#         plot.caption = element_text(hjust = 0.5),
#         panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
#         panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
#         axis.text.x =  element_text(size=10,  colour = "black"),
#         axis.text.y = element_text(size=10,  colour = "black"),
#         axis.title.x =  element_text(size=16), 
#         axis.title.y = element_text(size=16),   
#         axis.ticks.x = element_blank(), 
#         axis.line.x = element_blank(),
#         strip.background = element_rect(fill="white"))+ 
#   labs(title = "Taste contrast between solutions by BMI Category", 
#        y =  "\u0394 Pleasantness Ratings", x = "",
#        caption = "Error bars represent SEM for the model estimated mean constrasts\n")
# #Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")
# 
# plot(plt)
# 
# cairo_pdf(file.path(figures_path,paste(task, 'condXbmi.pdf',  sep = "_")),
#           width     = 5,
#           height    = 6)
# 
# plot(plt)
# dev.off()
# 
# 
# 
