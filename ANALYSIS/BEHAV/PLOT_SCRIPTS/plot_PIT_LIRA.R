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

# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

mod <- lmer(gripC ~ condition*intervention*time + diff_bmiC + (condition * time|id) + (1|trialxcondition))

N_group = ddply(PIT, .(id, intervention, time), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(c(intervention, time)) %>% tally()

emm_options(pbkrtest.limit = 15000) #set emmeans options


#get contrasts for intervention X condition by sessiuon
CI_inter = confint(emmeans(mod, pairwise~ condition|intervention|session, adjust = "tukey"),level = 0.95,method = c("boot"),nsim = 5000)

#get predicted by ind
rand = ranef(mod)
ran = data.frame(rand$id)
fix = t(data.frame(fixef(mod)))
df = ran + fix[col(ran)]
df$CSp = df$X.Intercept.
df$base = df$CSp + df$condition0
df$CSm = df$CSp + df$condition.1
df = select(df, c(CSp,base, CSm))
df$id = as.factor(c(1:length(df$CSm)))
df.observed <- gather(df, condition, emmean, CSp:CSm, factor_key=TRUE)
#df.observed = ddply(PIT, .(id, trial, condition), summarise, emmean = mean(perceived_liking, na.rm = TRUE)) 

df.observed$condition = as.factor(revalue(df.observed$condition, c(CSm="-1", base="0",CSp="1")))
df.observed$condition = factor(df.observed$condition,levels(df.observed$condition)[c(1,3,2)])

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

#contrasts on estimated means adjusted via the Multivariate normal t distribution
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
# df.observed$estimate = CSPlus$gripZ - CSMinus$gripZ

full.obs = ddply(PIT, .(id, intervention, time, condition), summarise, estimate = mean(gripZ)) 
plus = subset(full.obs, condition == 'CSplus')
minus = subset(full.obs, condition == 'CSminus')
df.observed = minus
df.observed$estimate = plus$estimate - minus$estimate
#df.observed$group = df.observed$group

labelsSES <- c("0" = "Pre-Test", "1" = "Post-Test")
#labelsOB <- c( "0" = "Class I" , "1" = "Class II-III")
labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")


pl <-  ggplot(df.PIT, aes(x = time, y = estimate, color = intervention)) +
  geom_bar(aes(y = estimate, x = time, group = intervention), stat="identity", alpha=0.6, width=0.3, color  = 'lightgrey', fill  = 'lightgrey') +
  geom_errorbar(aes(ymax = estimate + SE, ymin = estimate - SE), width=0.1,  alpha=0.7)+
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
       caption = "Error bars represent SEM for the model estimated mean constrasts\n")
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
#Error bars represent 95% CI for the estimated marginal means\n
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

#contrasts on estimated means adjusted via the Multivariate normal t distribution
cont = emmeans(mod, ~ intervention:condition:time, contr = con, adjust = "mvt")
cont

#plot(cont$contrasts, comparisons = TRUE)
df.PIT = as.data.frame(cont$contrasts) 
intervention = c(0, 1, 1, 0)
time = c(1, 1, 0, 0)

df.PIT = cbind(df.PIT, intervention, time)
fac <- c("intervention", "time")
df.PIT[fac] <- lapply(df.PIT[fac], factor)

full.obs = ddply(PIT, .(id, intervention, time, condition), summarise, estimate = mean(gripC)) 
plus = subset(full.obs, condition == 'CSplus')
minus = subset(full.obs, condition == 'CSminus')
df.observed = minus
df.observed$estimate = plus$estimate - minus$estimate


labelsSES <- c("0" = "Pre-Test", "1" = "Post-Test")
labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")

pl <-  ggplot(df.PIT, aes(x = time, y = estimate, color = intervention)) +
  #geom_bar(stat="identity", alpha=0.6, width=0.3, ) +
  geom_errorbar(aes(ymax = estimate + SE, ymin = estimate - SE), width=0.05,  alpha=1, position = position_dodge(0.4))+
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
       caption = "Error bars represent SEM for the model estimated mean constrasts\n")
#Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")


plot(plt)

cairo_pdf(file.path(figures_path,paste(task, 'condXtreatXtime.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt)
dev.off()












full.obs = ddply(PIT, .(id, group2, intervention, time, condition), summarise, estimate = mean(gripC)) 
plus = subset(full.obs, condition == 'CSplus')
minus = subset(full.obs, condition == 'CSminus')
df.observed = minus
df.observed$estimate = plus$estimate - minus$estimate
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

