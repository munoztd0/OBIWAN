## R code for FOR PAV PLOT
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni, jtools, interactions, sjstats)

# SETUP ------------------------------------------------------------------

task = 'PAV'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

## LOADING AND INSPECTING THE DATA
load('PAV.RData')
options(contrasts=c("contr.sum","contr.poly")) #set contrasts to sum !

#use non centered DV for plotting
mod <- lmer(RT ~ condition*group + group:likC + likC +  (condition|id) + (1|trialxcondition), data = PAV, control = control) 
modLIK <- aov_car(liking ~ condition*group + Error(id/condition), data = PAV, fun_aggregate = mean, anova_table = list(es = "pes"))

N_group = ddply(PAV, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

BMI_group = ddply(PAV, .(group), summarise, bmi=mean(BMI_t1)) 


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#get contrasts for groups obesity X condition
CI_RT = confint(emmeans(mod, pairwise~ condition, adjust = "tukey"),level = 0.95,method = c("boot"),nsim = 5000) 
CI_lik = confint(emmeans(modLIK, pairwise~ condition, adjust = "tukey"),level = 0.95,method = c("boot"),nsim = 5000)

df.predictedRT = data.frame(CI_RT$emmeans)
df.observedRT = ddply(PAV, .(id, condition), summarise, emmean = mean(RT, na.rm = TRUE)) 
df.predictedLIK = data.frame(CI_lik$emmeans)
df.predictedLIK$condition = factor(c("1", "-1"))
df.predictedLIK$condition = factor(df.predictedLIK$condition,levels(df.predictedLIK$condition)[c(2,1)])

df.observedLIK = ddply(PAV, .(id, condition), summarise, emmean = mean(liking, na.rm = TRUE)) 

df.predictedRT$emmean = df.predictedRT$emmean / 5 #litlle trick to double plot
df.predictedRT$lower.CL = df.predictedRT$lower.CL / 5 #litlle trick to double plot
df.predictedRT$upper.CL = df.predictedRT$upper.CL / 5 #litlle trick to double plot
df.predictedRT$SE = df.predictedRT$SE / 5 #litlle trick to double plot

plt = ggplot() + 
  geom_bar(mapping = aes(x = df.predictedLIK$condition, y = df.predictedLIK$emmean), stat = "identity", fill = "black", alpha = 0.4, width=0.5) +
  geom_errorbar(mapping = aes(x = df.predictedLIK$condition, y = df.predictedLIK$emmean, ymin=df.predictedLIK$emmean - df.predictedLIK$SE, ymax=df.predictedLIK$emmean + df.predictedLIK$SE), size=0.5, width=0.1, color = 'black', alpha = 0.8) + 
  geom_point(mapping = aes(x = df.predictedLIK$condition, y = df.predictedLIK$emmean), size = 2, shape=23, fill = 'grey40') + 
  geom_line(mapping = aes(x = df.predictedRT$condition, y = df.predictedRT$emmean, group =1), color = 'royalblue', lty = 4) + 
  geom_errorbar(mapping = aes(x = df.predictedRT$condition, y = df.predictedRT$emmean, ymin=df.predictedRT$emmean - df.predictedRT$SE, ymax=df.predictedRT$emmean + df.predictedRT$SE), size=0.5, width=0.1,  color='royalblue') + 
  geom_point(mapping = aes(x = df.predictedRT$condition, y = df.predictedRT$emmean), size = 2, shape=23,  fill='royalblue') + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100),
    name = "Pleasantness Ratings", sec.axis = sec_axis(~./1, name = "Latency", labels = function(b) { paste0(round(b * 5, 0))}))  

plot = plt + 
  scale_x_discrete(labels=c("CS+", "CS-")) +
  theme_bw() +
  theme(aspect.ratio = 1.7/1,
        plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #element_line(size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.line.y.right = element_line(size = 0.5, linetype = "dashed", colour = "royalblue"),
        axis.line.y.left = element_line(size = 0.5),
        axis.text.x =  element_text(size=10,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y.left = element_text(size=10,  colour = "black"),
        axis.text.y.right = element_text(size=10,  colour = "royalblue"),
        axis.title.x =  element_text(size=16), 
        axis.title.y.left = element_text(size=16),  
        axis.title.y.right = element_text(angle = 90, color = "royalblue", size=16),
        axis.line.x = element_blank(),
        axis.ticks.y.right = element_line(color = "royalblue"),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "", y =  "", x = "",
       caption = "Latency: CS+ < CS-, p =  0.014\n
       Pleasantness ratings: CS+ > CS-, p <  0.001\n 
       Error bar represent \u00B1 SE for the model estimated means\n")

plot(plot)

cairo_pdf(file.path(figures_path,paste(task,'cond&RTpleas.pdf',  sep = "_")),
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

#change value of group
PAV$group = as.factor(revalue(PAV$group, c('-1'="control", '1'="obese")))

#change value of condition
PAV$condition = as.factor(revalue(PAV$condition, c('-1'="CSminus", '1'="CSplus")))


visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="likC", by='condition', gg=TRUE,type="contrast",ylab="RT (z)",breaks=c(-1,0,1),xlab="Liking ratings Cues")

interact_plot(mod, pred = likC, modx = group, plot.points = TRUE, jitter = 0.1, point.shape = TRUE, point.alpha =0.2,  interval = TRUE, int.width = 0.95)


emmip(ref_grid(mod, cov.reduce = FALSE),  ~ percent)


