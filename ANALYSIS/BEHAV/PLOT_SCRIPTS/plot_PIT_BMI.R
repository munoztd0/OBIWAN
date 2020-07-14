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

mod <- lmer(gripZ ~ condition*BMI_t1 + hungryZ + hungryZ:condition + thirstyZ + pissZ  +(condition |id) + (1|trialxcondition) , 
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

#get model contrast group estimates
cont = emmeans(mod, pairwise~ condition|BMI_t1, at = list(BMI_t1 = c(22.24,35.57)), side = ">", adjust = "tukey") #those are the mean per group intercepts
df.cont = as.data.frame(cont$contrasts)

#get model pblueiction estimates
em = emmeans(mod, pairwise~ condition|BMI_t1, at = list(BMI_t1 = seq.int(18,45, by = 2)), adjust = "mvt")
em.df = confint(em) #get CI
df.predicted = as.data.frame(em.df$contrasts)

#get observed
full.obs = ddply(PIT, .(id, BMI_t1, condition), summarise, estimate = mean(gripZ)) 
plus = subset(full.obs, condition == '1')
minus = subset(full.obs, condition == '-1')
df.observed = minus
df.observed$estimate = plus$estimate - minus$estimate

pl <-  ggplot(df.predicted, aes(x = BMI_t1, y = estimate)) +
  geom_point(data = df.observed, size = 0.5, alpha = 0.4, color = 'royalblue', position = position_jitter(width = 0.2)) + 
  geom_line(data = df.predicted, color = 'royalblue', size = 1) +
  geom_ribbon(aes(ymin=lower.CL, ymax=upper.CL), alpha = .5, fill = 'lightgrey', color = 'royalblue') +
  geom_point(data = df.cont,  shape = 23, size = 2, color = 'blue', fill = 'royalblue')+
  geom_abline(slope= 0, intercept=0, alpha = .5, size= 0.5, linetype = "dashed", color = "black") 

plt = pl + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-2,2, by = 1)), limits = c(-2,2)) +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(20,44, by = 4)), limits = c(17,46)) +
  #coord_fixed(ratio=0.9) +
  theme_bw() +
  theme(aspect.ratio = 1.7/1,
        plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_line(size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x =  element_text(size=10,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16),   
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "PIT Effect by BMI", 
       y =  "\u0394 Mobilized Effort (z)", x = "BMI",
       caption = "Error range represent 95% CI for the model estimated pblueiction\n
       Main effect of Pavlovian cue (CS+ > CS-), p = 0.012\n
       Two-way interaction (BMIxCue), p = 0.086\n
       Post-hoc test, HW: p = 0.51, OB: p = 0.0028\n 
       Controling for motivational states\n")


plot(plt)

cairo_pdf(file.path(figures_path,paste(task, 'condXbmi.pdf',  sep = "_")),
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
                  pblue.labels =c("(Intercept)", "Pavlovian Cue (CS-)", "BMI", "Hunger", "Thirst", "Need to urinate",
                                 "Pavlovian Cue (CS-) X BMI", "Pavlovian Cue (CS-) X Hunger"),
                  dv.labels= "Moblized Effort")


#using jtool to look at ICC and more
summ(mod)
#interact_plot(mod, pblue = bmiZ, modx = condition) + 
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
# cont = emmeans(mod, pairwise~ condition|BMI_t1, at = list(BMI_t1 = c(-1.36,0.17,0.92)), adjust = "mvt")
# cont
# #pwpp(cont$emmeans)
# plot(cont, comparisons = TRUE, horizontal = FALSE) #no overlapping blue arrow-> signif
# df.PIT = as.data.frame(cont$contrasts) 
# df.PIT$BMI_t1 <- as.character(df.PIT$BMI_t1)
# 
# #change value of groups to plot
# PIT$group2 = c(1:length(PIT$group))
# PIT$group2[PIT$BMI_t1 < 30 ] <- '-1.36' # control BMI = 22.25636 -> -1.36,
# PIT$group2[PIT$BMI_t1 >= 30 & PIT$BMI_t1 < 35] <- '0.17' # Class I obesity: BMI = 30 to 35. -> 0.17
# PIT$group2[PIT$BMI_t1 >= 35] <- '0.92' # Class II obesity: BMI = 35 to 40. -> 0.92)
# #PIT$group2[PIT$BMI_t1 > 40] <- '3' # Class III obesity: BMI 40 or higher -> 1.89
# 
# N_group2 = ddply(PIT, .(id, group2), summarise, group2=mean(as.numeric(group2)))  %>%
#   group_by(group2) %>% tally()
# 
# BMI_group = ddply(PIT, .(group2), summarise, bmi=mean(BMI_t1)) 
# 
# contgroup = emmeans(mod, pairwise~ condition|BMI_t1, at = list(BMI_t1 = c(-1.36,0.17,0.92)), adjust = "mvt")
# #get pval
# 
# cont = emmeans(mod, pairwise~ condition|BMI_t1, at = list(BMI_t1 = c(-2,-1,0, 1, 2)), adjust = "mvt")
# 
# df = confint(cont)
# 
# df.PIT = as.data.frame(df$contrasts)
# 
# df.PIT %>%
#   ggplot(aes(BMI_t1, estimate)) +
#   geom_line() +
#   geom_ribbon(aes(ymin=lower.CL, ymax=upper.CL), alpha = .1) +
#   geom_point(data = df.observed, size = 0.5, alpha = 0.4, color = 'royalblue', position = position_jitter(width = 0.2)) +
#   ylab("Delta effort (z)")
# 
# 
# 
# 
# full.obs = ddply(PIT, .(id, group2, condition), summarise, estimate = mean(gripZ)) 
# plus = subset(full.obs, condition == '1')
# minus = subset(full.obs, condition == '-1')
# df.observed = minus
# df.observed$estimate = plus$estimate - minus$estimate
# df.observed$BMI_t1 = df.observed$group2
# 
# labels <- c("-1.36" = "Lean", "0.17" = "Class I" , "0.92" = "II-III")
# 
# # pl <-  ggplot(df.PIT, aes(x = BMI_t1, y = estimate)) +
# #   #geom_bar(stat="identity", alpha=0.6, width=0.3, ) +
# #   geom_errorbar(aes(ymax = estimate + SE, ymin = estimate - SE), width=0.05,  alpha=1)+
# #   geom_point(size = 0.5, color = 'blue') + 
# #   geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) + 
# #   geom_point(data = df.observed, size = 0.1, alpha = 0.4, color = 'royalblue',  position = position_jitter(width = 0.1))
# 
# pl <-  ggplot(df.PIT, aes(x = BMI_t1, y = estimate)) +
#   geom_point(data = df.observed, size = 0.1, alpha = 0.4, color = 'royalblue', position = position_jitter(width = 0.2)) +
#   geom_bar(data =df.PIT, stat="identity", alpha=0.6, width=0.3) +
#   geom_errorbar(data =df.PIT,  aes(ymax = estimate + SE, ymin = estimate - SE), color = 'black', width=0.05,  alpha=0.7)+
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
#   labs(title = "PIT Effect by BMI Category", 
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
