## R code for FOR PAV LIRA PLOT
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
load('PAV_LIRA.RData')
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset


t0 = subset(PAV, time == 0)
t1 = subset(PAV, time == 1)
N_t0 = ddply(t0, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention)) %>% tally()
N_t1 = ddply(t1, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention)) %>% tally()

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

`%notin%` <- Negate(`%in%`)
#PAV = PAV %>% filter(id %notin% c(242,245, 256, 220, 266,232)) #& 266??


mod <- lmer(RT ~ condition*intervention*time + likC + diff_bmiC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control)
modLIK <- aov_car(liking ~ condition*intervention*time + Error(id/condition*time), data = PAV, fun_aggregate = mean, anova_table = list(es = "pes"))

# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

#get CI and pval for inter

p_inter = emmeans(mod, ~ condition:intervention:time)
df.predictedRT = data.frame(p_inter)

p_lik = emmeans(modLIK, ~ condition:intervention:time)
df.predictedLIK = data.frame(p_lik)
df.predictedLIK$condition <- ifelse(df.predictedLIK$condition == "X1",'1','-1')
df.predictedLIK$time <- ifelse(df.predictedLIK$time == "X0",'0','1')


df.observedRT = ddply(PAV, .(id, intervention, condition, time), summarise, emmean = mean(RT, na.rm = TRUE)) 
df.observedRT$time = as.factor(df.observedRT$time)

df.observedLIk = ddply(PAV, .(id, intervention, condition, time), summarise, emmean = mean(liking, na.rm = TRUE)) 

labelsSES <- c("0" = "\u2800 \u2800 \u2800 Pre-Test", "1" = "\u2800 \u2800 \u2800 Post-Test")
labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")
labelsCON <- c( "-1" = "CS-" , "1" = "CS+")

cat_plot(mod, pred = time, modx = condition, mod2 = intervention)

plt0 <- ggplot(df.observedRT, aes(x = time, y = emmean, fill = condition)) + 
  #geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.5) +
  geom_point(aes(x=time,y=emmean, color = condition),size=2,shape=20, alpha=.5, position=position_jitter(width=0.05, seed = 59)) +
  geom_flat_violin(aes(x=time,y=emmean),position=position_nudge(x=0.15),adjust=1.5,trim=FALSE,alpha=.5,colour=NA) +
  geom_errorbar(data = df.predictedRT,aes(group = condition, ymin=emmean-SE, ymax=emmean+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  #geom_boxplot(aes(x=time,y=emmean),position=position_dodge(width =0.15),fatten = NULL, outlier.shape=NA, alpha=.5,width=.1,colour="black") +
  #stat_summary(fun = mean, geom = "errorbar", aes(ymax = ..y.., ymin = ..y..),width = 0.1, size = 0.5, linetype = "solid", position=position_nudge(x=0.15)) + 
  #stat_summary(fun = mean, geom = "point", size=2,shape=23, position=position_nudge(x=0.15)) +
  facet_wrap(~ intervention, labeller=labeller(intervention = labelsTRE))


plt0 <- ggplot(df.observedRT, aes(x = condition, y = emmean, fill = time)) + 
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.5) +
  geom_point(aes(x=condition,y=emmean),size=2,shape=20, alpha=.5, position=position_jitter(width=0.05, seed = 59)) +
  geom_flat_violin(aes(x=condition,y=emmean),position=position_nudge(x=0.15),adjust=1.5,trim=FALSE,alpha=.5,colour=NA) +
  #geom_errorbar(data = df.predicted,aes(group = time, ymin=emmean-SE, ymax=emmean+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  geom_boxplot(aes(x=condition,y=emmean),position=position_nudge(x=0.15),fatten = NULL, outlier.shape=NA, alpha=.5,width=.1,colour="black") +
  stat_summary(fun = mean, geom = "errorbar", aes(ymax = ..y.., ymin = ..y..),width = 0.1, size = 0.5, linetype = "solid", position=position_nudge(x=0.15)) + 
  stat_summary(fun = mean, geom = "point", size=2,shape=23, position=position_nudge(x=0.15)) +
  facet_wrap(~ intervention, labeller=labeller(intervention = labelsTRE))




df.predictedRT$emmean = df.predictedRT$emmean / 5 #litlle trick to double plot
df.predictedRT$SE = df.predictedRT$SE / 5 #litlle trick to double plot

plt = ggplot() + 
  geom_bar(mapping = aes(fill = time,x = df.predictedLIK$condition, y = df.predictedLIK$emmean), stat = "identity", fill = "black", alpha = 0.4, width=0.5) +
  geom_errorbar(mapping = aes(x = df.predictedLIK$condition, y = df.predictedLIK$emmean, ymin=df.predictedLIK$emmean - df.predictedLIK$SE, ymax=df.predictedLIK$emmean + df.predictedLIK$SE), size=0.5, width=0.1, color = 'black', alpha = 0.8) + 
  geom_point(mapping = aes(color = time, x = df.predictedLIK$condition, y = df.predictedLIK$emmean), size = 2, shape=23, fill = 'grey40') + 
  geom_line(mapping = aes(x = df.predictedRT$condition, y = df.predictedRT$emmean, group =1), color = 'royalblue', lty = 4) + 
  geom_errorbar(mapping = aes(x = df.predictedRT$condition, y = df.predictedRT$emmean, ymin=df.predictedRT$emmean - df.predictedRT$SE, ymax=df.predictedRT$emmean + df.predictedRT$SE), size=0.5, width=0.1,  color='royalblue') + 
  geom_point(mapping = aes(x = df.predictedRT$condition, y = df.predictedRT$emmean), size = 2, shape=23,  fill='royalblue') + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100),
                     name = "Pleasantness Ratings", sec.axis = sec_axis(~./1, name = "Latency", labels = function(b) { paste0(round(b * 5, 0))}))  +
  facet_wrap(~ intervention, labeller=labeller(intervention = labelsTRE))






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
       Error bar represent \u00B1 SE for the model emmeand means\n")

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


