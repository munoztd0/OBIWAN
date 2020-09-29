## R code for FOR PAV LIRA PLOT
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, jtools, interactions, sjstats)

# SETUP ------------------------------------------------------------------

task = 'PAV'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

## LOADING AND INSPECTING THE DATA
load('PAV_LIRA.RData')
PAV = PAV %>% filter(id %notin% c(230, 248)) #remove 230 because he doesnt have CSm session T1 and 248 bc huge outlier
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
p_inter = emmeans(mod, ~ condition:time)
con_inter <- contrast(p_inter, interaction = 'pairwise', by = c('time'), side = "<")
con_inter

df.predicted = data.frame(con_inter)
df.predicted$estimate = df.predicted$estimate * -1

df = ddply(PAV, .(id, intervention, condition, time), summarise, estimate = mean(RT, na.rm = TRUE)) 

CSp = subset(df, condition == '1')
CSm = subset(df, condition == '-1')
df.observed = CSp
df.observed$estimate =  CSm$estimate - CSp$estimate
df.observed$time = as.factor(df.observed$time)

df.observed.jit <- df.observed %>% mutate(timejit = jitter(as.numeric(time), 0.3),
                                          grouping = interaction(id, time))

plt0 <- ggplot(df.observed.jit, aes(x = as.numeric(time), y = estimate, fill = time)) + 
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.8) +
  geom_line(aes(timejit, group = id), alpha = 0.1) +
  geom_point(aes(x=timejit,y=estimate, shape = intervention),size=1, alpha=.5, fill = "black") +
  geom_flat_violin(aes(x=as.numeric(time),y=estimate),position=position_nudge(x=0.15),adjust=1.5,trim=FALSE,alpha=.6,colour=NA) +
  geom_errorbar(data = df.predicted,aes(group=as.numeric(time), ymin=estimate-SE, ymax=estimate+SE),position=position_nudge(x=0.15), size=0.5, width=0.15,  color = "black") + 
  geom_point(data = df.predicted, aes(x=as.numeric(time),y=estimate),size=1.5,shape=23,position=position_nudge(x=0.15)) +
  geom_boxplot(aes(x=as.numeric(time),y=estimate),fatten = 0.5, outlier.shape=NA, alpha=.6,width=.1,colour="black") 

labelsSES <- c("0" = "   Pre-Test", "1" = "   Post-Test")
labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")
labelsCON <- c( "-1" = "CS-" , "1" = "CS+")

plot = plt0 + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-100,300, by = 100)), limits = c(-100,300)) +
  scale_x_continuous(limits = c(0.7,2.6)) +
  #scale_x_discrete(labels=labelsSES) +
  scale_fill_manual(values=c('royalblue','aquamarine3'),labels=labelsSES) +
  scale_shape_manual(labels = labelsTRE,values=c(21,24))   + 
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
        legend.title=element_blank(),legend.text=element_text(size=14),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "", 
       y =  "\u0394 Latency (ms)", x = "",
       caption = "CS- > CS+, p < 0 .001\n 
       condition*time  p = 0.007 \n  
       Error bar represent \u00B1 SE for the model estimated means\n
       Prediction controling for satiety levels\n")

plot(plot)

cairo_pdf(file.path(figures_path,paste(task, 'condXtime.pdf',  sep = "_")),
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


