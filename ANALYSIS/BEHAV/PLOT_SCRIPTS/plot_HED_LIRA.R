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
load('HED_LIRA.RData')

t0 = subset(HED, time == 0)
t1 = subset(HED, time == 1)
N_t0 = ddply(t0, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention)) %>% tally()
N_t1 = ddply(t1, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention)) %>% tally()

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

`%notin%` <- Negate(`%in%`)
#HED = HED %>% filter(id %notin% c(242,245, 248)) #248 huge outlier

mod <-lmer(perceived_liking ~ condition*intervention*time + diff_bmiC+ condition:intC + condition:famC +(time*condition|id), 
           data = HED, control = control) 

# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

#increase repetitions limit
emm_options(pbkrtest.limit = 5000,lmerTest.limit = 5000)


#get CI and pval for inter
p_inter = emmeans(mod, ~ condition:time)
con_inter <- contrast(p_inter, interaction = 'pairwise', by = c('time'), side = ">")
con_inter

#changed here
#df.predicted = data.frame(con_inter)
df.predicted = data.frame(p_inter)
df.predicted$estimate = df.predicted$emmean

df = ddply(HED, .(id, intervention, condition, time), summarise, estimate = mean(perceived_liking, na.rm = TRUE)) 
df.observed = df
# REW = subset(df, condition == '1')
# NEU = subset(df, condition == '-1')
# df.observed = REW
# df.observed$estimate = REW$estimate - NEU$estimate
df.observed$time = as.factor(df.observed$time)

df.observed.jit <- df.observed %>% mutate(condjit = jitter(as.numeric(condition), 0.3),
                                          grouping = interaction(id, condition))

labelsSES <- c("0" = "   Pre-Test", "1" = "   Post-Test")


plt0 <- ggplot(df.observed.jit, aes(x = as.numeric(condition), y = estimate, fill = condition)) + 
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.8) +
  geom_line(aes(condjit, group = id), alpha = 0.1) +
  geom_point(aes(x=condjit,y=estimate, shape = intervention),size=1, alpha=.5, fill = "black") +
  geom_flat_violin(aes(x=as.numeric(condition),y=estimate),position=position_nudge(x=0.15),adjust=1.5,trim=FALSE,alpha=.6,colour=NA) +
  geom_errorbar(data = df.predicted,aes(group=as.numeric(condition), ymin=estimate-SE, ymax=estimate+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  geom_point(data = df.predicted, aes(x=as.numeric(condition),y=estimate),size=1.5,shape=23,position=position_nudge(x=0.15)) +
  geom_boxplot(aes(x=as.numeric(condition),y=estimate),fatten = 0.5, outlier.shape=NA, alpha=.6,width=.15,colour="black") +
  facet_wrap(~ time, labeller=labeller(time = labelsSES))

labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")
labelsCON <- c( "-1" = "Tasteless" , "1" = "Milkshake")

plot = plt0 + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  scale_x_continuous(limits = c(0.7,2.6)) +
  #scale_x_discrete(labels=labelsCON) +
  scale_fill_manual(values=c('royalblue','aquamarine3'),labels=labelsCON) +
  scale_shape_manual(labels = labelsTRE,values=c(21,24))   + 
  theme_bw() +
  theme(aspect.ratio = 1.7/1,
        plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #element_line(size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x =  element_blank(), #element_text(size=14,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_blank(),
        axis.title.y = element_text(size=16),   
        axis.line.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title=element_blank(),legend.text=element_text(size=14),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "", y =  "Pleasantness Ratings", x = "",
       caption = "Two-way interaction (CnditionXtime): p = 0.038\n
       Milkshake > Tasteless, p < 0.001\n 
       Error bar represent \u00B1 SE for the model estimated means\n") #Solution

plot(plot)



cairo_pdf(file.path(figures_path,paste(task, 'cond&time_LIRA.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plot)
dev.off()


#look at other inteactions!
visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="intC", by='condition', gg=TRUE,type="contrast",ylab="liking",breaks=c(-1,0,1),xlab="int")
visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="famC", by='condition', gg=TRUE,type="contrast",ylab="liking",breaks=c(-1,0,1),xlab="hungry")
#interact_plot(mod, pred = hungryC, modx = condition) #, plot.points = TRUE, jitter = 0.1, point.shape = TRUE, point.alpha =0.2,  interval = TRUE, int.width = 0.95)


#create table
sjPlot::tab_model(mod)


#using jtool to look at ICC and more
summ(mod)
