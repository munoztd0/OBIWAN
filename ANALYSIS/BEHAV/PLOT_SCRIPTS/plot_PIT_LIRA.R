## R code for FOR PIT PLOT LIRA
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
load('PIT_LIRA.RData')
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset


t0 = subset(PIT, time == 0)
t1 = subset(PIT, time == 1)
N_t0 = ddply(t0, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention)) %>% tally()
N_t1 = ddply(t1, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention)) %>% tally()

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

`%notin%` <- Negate(`%in%`)
PIT = PIT %>% filter(id %notin% c(242,245, 256, 220, 266,232)) #& 266??

mod <-lmer(gripC ~ condition*intervention*time + diff_bmiC + (condition * time|id) + (1|trialxcondition), 
           data = PIT, control = control)

# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions


con <- list(
  c1 = c(0, 0, 0, 0, 1, -1, 0, 0), #Post: CSp Placebo > CSm Placebo
  c2 = c(0, 0, 0, 0, 0, 0, 1, -1), #Post: CSp Lira > CSm Lira
  c3 = c(0, 0, 1, -1, 0, 0, 0, 0), #Pre: CSp Lira > CSm Lira
  c4 = c(1, -1, 0, 0, 0, 0, 0, 0) #Pre: CSp Placebo > CSm Placebo
)


#get CI and pval for inter

p_inter = emmeans(mod, ~ condition:intervention:time, contr = con, adjust = "mvt")
df.predicted = data.frame(p_inter$contrasts)
intervention = c(0, 1, 1, 0)
time = c(1, 1, 0, 0)
df.predicted = cbind(df.predicted, intervention, time)
df.predicted$time = as.factor(df.predicted$time)

#get predicted by ind
cof = coef(mod)
dtf = data.frame(cof$id)
dtf = rownames_to_column(dtf, var = "id")

dtf$CSp0 = dtf$X.Intercept.
dtf$CSm0 = dtf$CSp0 + dtf$condition.1
dtf$CSp1 = dtf$X.Intercept. + dtf$time1
dtf$CSm1 = dtf$CSp1 + dtf$condition.1 + dtf$time1
df = select(dtf, c(CSp0, CSm0, CSp1, CSm1, id))
df <- gather(df, condition, emmean, CSp0:CSm1, factor_key=TRUE)
df$time <- ifelse(df$condition %in% c("CSp0","CSm0"),'0','1')
df$condition <- ifelse(df$condition %in% c("CSp0","CSp1"),'1','-1')

#merge with info
df = merge(df, info, by = "id")
df$intervention =  as.factor(df$intervention)
df$emmean[df$intervention == '1'] <- df$emmean[df$intervention == '1'] + dtf$intervention1[1]

#df = ddply(PIT, .(id, intervention, condition, time), summarise, estimate = mean(gripC, na.rm = TRUE)) 

CSp = subset(df, condition == '1')
CSm = subset(df, condition == '-1')
df.observed = CSp
df.observed$estimate = CSp$emmean - CSm$emmean
df.observed$time = as.factor(df.observed$time)

# position on x axis is based on combination of B and jittered A. Mix to taste.
df.observed.jit <- df.observed %>%
  mutate(timejit = jitter(as.numeric(time), 0.25) -1)

labelsSES <- c("0" = "\u2800 \u2800 \u2800 Pre-Test", "1" = "\u2800 \u2800 \u2800 Post-Test")
labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")
labelsCON <- c( "-1" = "CS-" , "1" = "CS+")


plt0 <- ggplot(df.observed, aes(x = time, y = estimate, fill = time)) + 
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.5) +
  geom_point(aes(x=time,y=estimate),size=2,shape=20, alpha=.5, position=position_jitter(width=0.05, seed = 59)) +
  geom_flat_violin(aes(x=time,y=estimate),position=position_nudge(x=0.15),adjust=1.5,trim=FALSE,alpha=.5,colour=NA) +
  #geom_errorbar(data = df.predicted,aes(group = time, ymin=estimate-SE, ymax=estimate+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  geom_boxplot(aes(x=time,y=estimate),position=position_nudge(x=0.15),fatten = NULL, outlier.shape=NA, alpha=.5,width=.1,colour="black") +
  stat_summary(fun = mean, geom = "errorbar", aes(ymax = ..y.., ymin = ..y..),width = 0.1, size = 0.5, linetype = "solid", position=position_nudge(x=0.15)) + 
  stat_summary(fun = mean, geom = "point", size=2,shape=23, position=position_nudge(x=0.15)) +
  facet_wrap(~ intervention, labeller=labeller(intervention = labelsTRE))

#geom_segment(data = df.predicted, aes(x = as.numeric(time)- 0.1, y = estimate - SE, xend = as.numeric(time) + 0.1, yend = estimate - SE)) + 
plt = plt0 + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-400,400, by = 100)), limits = c(-400,400)) +
  scale_x_discrete(labels=labelsSES) +
  scale_fill_manual(labels=labelsSES, values=c('seagreen3','royalblue')) +
  #scale_color_manual(labels=labelsCON, values=c('seagreen3','royalblue')) + 
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5, size=26),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=16,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=20), 
        legend.title = element_blank(),
        legend.text = element_text(size=16), 
        legend.position = "none", #c(0.5, 0.5),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"),
        strip.text = element_text(size=16),
        legend.key.size = unit(2,"line"))+ 
  labs(title = "Effect of Treatment on PIT", 
       y =  "Mobilized Effort (CS+ > CS-) \u2013 AUC ", x = "") # ,caption = "Error bars represent SEM for the model emmeand mean constrasts\n")
#Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")

plot(plt)

cairo_pdf(file.path(figures_path,paste(task, 'LIRA_condXtreate.pdf',  sep = "_")),
          width     = 10,
          height    = 5)

plot(plt)
dev.off()







# done --------------------------------------------------------------------








# position on x axis is based on combination of B and jittered A. Mix to taste.
df.observed.jit <- df.observed %>%
  mutate(groupjit = as.numeric(condition)*0.4 - 0.6 + jitter(as.numeric(time), 0.55) + 1,
         grouping = interaction(id, time))

df.predicted.jit <- df.predicted %>%
  mutate(groupjit = as.numeric(condition)*0.4 - 0.6 + jitter(as.numeric(time), 0.55) + 1,
         grouping = interaction(1, time))

plt0 = ggplot(df.observed.jit, aes(x=time,  y=emmean,  group = grouping)) + 
  geom_blank() +
  geom_line(aes(groupjit), alpha = 0.1) +
  geom_point(aes(groupjit, col=condition), size=0.8, alpha=0.5) + geom_violin(trim = FALSE, position = position_dodge(0.9) ) +
  geom_violin(aes(x=time, y=emmean, col=condition), trim = FALSE, position = position_dodge(0.9) )
  geom_boxplot(width = 0.15, position = position_dodge(0.9)) 


plt + geom_violin(trim = FALSE, position = position_dodge(0.9) ) +
  geom_boxplot(width = 0.15, position = position_dodge(0.9)) 

plt = plt0 +
  geom_bar(data = df.predicted.jit, stat = "identity", position=position_dodge2(width=1), fill = "black", alpha = 0.3, width = 0.7) +
  geom_errorbar(data = df.predicted.jit,aes(group = condition, ymin=emmean-SE, ymax=emmean+SE), size=0.5, width=0.1,  color = "black", position=position_dodge(width = 0.7)) + 
  geom_point(data = df.predicted.jit, size = 2, shape=23, color= "black", fill = 'grey40',  position=position_dodge2(width = 0.7))

plt +   facet_wrap(~ intervention, labeller=labeller(intervention = labelsTRE))


pl <-  ggplot(df.predicted, aes(x = time, y = emmean, color = condition, fill = condition)) +
  geom_bar(aes(y = emmean, x = time, group = intervention), stat="identity", alpha=0.6, width=0.3, position = "dodge2") +
  geom_errorbar(aes(ymax = emmean + SE, ymin = emmean - SE), width=0.1,  alpha=0.7, position = "dodge2")+
  geom_point(size = 0.5,  position = "dodge2") +  #color = 'blue'
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) +
  geom_jitter(data = df.observed, position = position_jitter(seed = 123, width = 0.02), alpha=0.5, size = 0.5) +
  geom_line(data = df.observed, aes(group=id), alpha=0.1, position = position_jitter (seed = 123, width = 0.02)) + 
  facet_wrap(~ intervention, labeller=labeller(intervention = labelsTRE))


# interaction plot interventionXconditionXtime 
PIT$gripZ = PIT$gripAUC
PIT$group2 <- as.factor(PIT$group2)
mod <- lmer(gripZ ~ condition*time*intervention  +(time*condition |id) + (1|trialxcondition) , 
            data = PIT, control = control) #need to be fitted using ML so here I just use lmer function so its faster

#pred CI #takes forever
# pred = confint(emmeans(mod,list(pairwise ~ intervention:condition:time:group2)), level = .95, type = "response")
# df.predicted = data.frame(pred$`emmeans of intervention, condition, time, group2`)
# colnames(df.predicted) <- c("intervention", "condition", "time", "group2","fit", "SE", "df", "lowCI", "uppCI")

#custom contrasts
con1 <- list(
  c1 = c(1, 0, 1, 0, -1, 0,-1, 0), #Post PIT - Pre PIT placebo
  c2 = c(0, 1, 0, 1, 0, -1, 0, -1) #PIT - Pre PIT Lira
)

con <- list(
  #group1
  c10 = c(0, 0, 0, 0, -1, 0, 1, 0), #Post: CSp Placebo > CSm- Placebo
  c20 = c(0, 0, 0, 0, 0, -1, 0, 1), #Post: CSp Lira > CSm Lira
  c30 = c(0, -1, 0, 1, 0, 0, 0, 0), #Pre: CSp Lira > CSm Lira
  c40 = c(-1, 0, 1, 0, 0, 0, 0, 0) #Pre: CSp Placebo > CSm Placebo
)

#contrasts on emmeand means adjusted via the Multivariate normal t distribution
cont = emmeans(mod, ~ intervention:condition:time, contr = con, adjust = "mvt")
cont2 = emmeans(mod, ~ intervention:condition:time, contr = con2, adjust = "mvt")
#cont = confint(emmeans(mod,~ intervention:condition:time:group2, contr = con,adjust = "mvt"), level = .95, type = "response")
cont2$contrasts

#plot(cont$contrasts, comparisons = TRUE, horizontal=FALSE)
df.PIT = as.data.frame(cont$contrasts) 
intervention = c(0, 1, 1, 0)
time = c(1, 1, 0, 0)
df.PIT = cbind(df.PIT, intervention, time)
fac <- c("intervention", "time")
df.PIT[fac] <- lapply(df.PIT[fac], factor)

# CSPlus <- subset(PIT, condition =="CSplus" )
# CSPlus <- CSPlus[order(as.numeric(levels(CSPlus$id))[CSPlus$id], CSPlus$trialxcondition),]
# CSMinus <- subset(PIT, condition =="CSminus" )
# CSMinus <- CSMinus[order(as.numeric(levels(CSMinus$id))[CSMinus$id], CSPlus$trialxcondition),]
# df.observed = CSPlus
# df.observed$emmean = CSPlus$gripZ - CSMinus$gripZ

full.obs = ddply(PIT, .(id, intervention, time, condition), summarise, emmean = mean(gripZ)) 
plus = subset(full.obs, condition == 'CSplus')
minus = subset(full.obs, condition == 'CSminus')
df.observed = minus
df.observed$emmean = plus$emmean - minus$emmean
#df.observed$group = df.observed$group

labelsSES <- c("0" = "Pre-Test", "1" = "Post-Test")
#labelsOB <- c( "0" = "Class I" , "1" = "Class II-III")
labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")


pl <-  ggplot(df.PIT, aes(x = time, y = emmean, color = intervention)) +
  geom_bar(aes(y = emmean, x = time, group = intervention), stat="identity", alpha=0.6, width=0.3, color  = 'lightgrey', fill  = 'lightgrey') +
  geom_errorbar(aes(ymax = emmean + SE, ymin = emmean - SE), width=0.1,  alpha=0.7)+
  geom_point(size = 0.5,  position = position_dodge(0.4)) +  #color = 'blue'
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) +
  geom_jitter(data = df.observed, position = position_jitter(seed = 123, width = 0.02), alpha=0.5, size = 0.5) +
  geom_line(data = df.observed, aes(group=id), alpha=0.1, position = position_jitter (seed = 123, width = 0.02)) + 
  facet_wrap(~ intervention, labeller=labeller(intervention = labelsTRE))




plt = pl + 
  scale_y_continuous(expand = c(0, 0),
                     breaks = c(seq.int(-2,3, by = 1)), limits = c(-2,3)) +
  scale_x_discrete(labels=labelsOB) +
  scale_color_manual(labels=labelsTRE, values=c('seagreen3','royalblue')) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        #axis.text.x =  element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16), 
        legend.title = element_blank(),
        #legend.position = c(0.5, 0.5),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "PIT Effect by BMI Category", 
       y =  "\u0394 Mobilized Effort", x = "",
       caption = "Error bars represent SEM for the model emmeand mean constrasts\n")
#Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")

plot(plt)

cairo_pdf(file.path(figures_path,paste(task, 'condXtreat.pdf',  sep = "_")),
          width     = 10,
          height    = 5)

plot(plt)
dev.off()




# other -------------------------------------------------------------------



#facet wrap labels
labels <- c("0" = "Pre-Test", "1" = "Post-Test")

plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = intervention)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4, position = position_dodge(width = 0.5))+
  geom_line(aes(group=intervention), alpha=0.4,position = position_dodge(width = 0.5)) + 
  facet_wrap(~ time, labeller=labeller(time = labels))

plt3 = plt +  #details to make it look good
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-1,1, by = 0.5)), limits = c(-1,1)) +
  scale_color_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
  scale_x_discrete(labels=c("CSminus" = "CS-  ", "CSplus" = "  CS+")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0.1))) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x =  element_blank(), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.475, -0.1), legend.title=element_blank(),
        legend.direction = "horizontal", #legend.spacing.x = unit(1, 'cm'),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs( y = "Mobilized Effort (z)") #,
#caption = "\n \n \n \n \nThree-way interaction, p = 0.73, \u0394 AIC = -1.88\n
#Post-hoc test -> No differences found\n
#Main effect of condition, p < 0.0001, \u0394 AIC = 23.02, R\u00B2 = 0.030\n
#Error bars represent 95% CI for the emmeand marginal means\n
#Placebo (N = 29), Liraglutide (N = 32)\n
#LMM : Pleasantness ~ Condition*Time*Treatment + (Time*Condition|Id) + (1|Trial)\n
#Controling for Intensity, Familiarity, Age, Gender & Weight Loss (BMI pre - BMI post)")

plot(plt3)

cairo_pdf(file.path(figures_path,paste(task, 'condXtreatXtime_Lira.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt3)
dev.off()


# THE END - Special thanks to Ben Meulman and Yoann Stussi -----------------------------------------------------------------
mod <- lmer(gripC ~ condition*time*intervention + gender + ageC + diff_bmiC +likC +(time*condition |id) + (1|trialxcondition) , 
            data = PIT, control = control) #need to be fitted using ML so here I just use lmer function so its faster


con <- list(
  c10 = c(0, 0, 0, 0, -1, 0, 1, 0), #Post: CSp Placebo > CSm- Placebo
  c20 = c(0, 0, 0, 0, 0, -1, 0, 1), #Post: CSp Lira > CSm Lira
  c30 = c(0, -1, 0, 1, 0, 0, 0, 0), #Pre: CSp Lira > CSm Lira
  c40 = c(-1, 0, 1, 0, 0, 0, 0, 0) #Pre: CSp Placebo > CSm Placebo
)

#contrasts on emmeand means adjusted via the Multivariate normal t distribution
cont = emmeans(mod, ~ intervention:condition:time, contr = con, adjust = "mvt")
cont

#plot(cont$contrasts, comparisons = TRUE)
df.PIT = as.data.frame(cont$contrasts) 
intervention = c(0, 1, 1, 0)
time = c(1, 1, 0, 0)

df.PIT = cbind(df.PIT, intervention, time)
fac <- c("intervention", "time")
df.PIT[fac] <- lapply(df.PIT[fac], factor)

full.obs = ddply(PIT, .(id, intervention, time, condition), summarise, emmean = mean(gripC)) 
plus = subset(full.obs, condition == 'CSplus')
minus = subset(full.obs, condition == 'CSminus')
df.observed = minus
df.observed$emmean = plus$emmean - minus$emmean


labelsSES <- c("0" = "Pre-Test", "1" = "Post-Test")
labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")

pl <-  ggplot(df.PIT, aes(x = time, y = emmean, color = intervention)) +
  #geom_bar(stat="identity", alpha=0.6, width=0.3, ) +
  geom_errorbar(aes(ymax = emmean + SE, ymin = emmean - SE), width=0.05,  alpha=1, position = position_dodge(0.4))+
  geom_point(size = 0.5,  position = position_dodge(0.4)) +  #color = 'blue'
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) + 
  geom_point(data = df.observed, size = 0.1, alpha = 0.4,  position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.4))  #, color = 'royalblue'

plt = pl + 
  scale_y_continuous(expand = c(0, 0),
                     breaks = c(seq.int(-1,2, by = 0.5)), limits = c(-1,2)) +
  scale_x_discrete(labels=labelsSES) +
  scale_color_discrete(labels=labelsTRE) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        #axis.text.x =  element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16), 
        legend.title = element_blank(),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "PIT Effect by Session", 
       y =  "Mobilized Effort \u0394 CS", x = "",
       caption = "Error bars represent SEM for the model emmeand mean constrasts\n")
#Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")


plot(plt)

cairo_pdf(file.path(figures_path,paste(task, 'condXtreatXtime.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt)
dev.off()












full.obs = ddply(PIT, .(id, group2, intervention, time, condition), summarise, emmean = mean(gripC)) 
plus = subset(full.obs, condition == 'CSplus')
minus = subset(full.obs, condition == 'CSminus')
df.observed = minus
df.observed$emmean = plus$emmean - minus$emmean
df.observed$bmiT = df.observed$group2

con <- list(
  #group1
  c10 = c(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0), #Post: CSp Placebo > CSm- Placebo
  c20 = c(0, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0), #Post: CSp Lira > CSm Lira
  c30 = c(0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), #Pre: CSp Lira > CSm Lira
  c40 = c(-1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), #Pre: CSp Placebo > CSm Placebo
  #group2
  c11 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1, 0), #Post: CSp Placebo > CSm- Placebo
  c21 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1), #Post: CSp Lira > CSm Lira
  c31 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0), #Pre: CSp Lira > CSm Lira
  c41 = c(0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0) #Pre: CSp Placebo > CSm Placebo
)

