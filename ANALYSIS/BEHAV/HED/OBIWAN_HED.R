## R code for FOR OBIWAN_HED
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(ggplot2, Rmisc, dplyr, ggplot2, lmerTest, lme4, car, r2glmm, optimx, visreg, MuMIn)

#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset

OBIWAN_HED  <- subset(OBIWAN_HED_full, group == 'control') #wihtout obese

# define factors
OBIWAN_HED$id      <- factor(OBIWAN_HED$id)
OBIWAN_HED$trial    <- factor(OBIWAN_HED$trial)
OBIWAN_HED$group    <- factor(OBIWAN_HED$group)

#OBIWAN_HED$condition[OBIWAN_HED$condition== 'MilkShake']     <- 'Reward'
#OBIWAN_HED$condition[OBIWAN_HED$condition== 'Empty']     <- 'Control'
OBIWAN_HED$condition <- factor(OBIWAN_HED$condition)

OBIWAN_HED$trialxcondition <- factor(OBIWAN_HED$trialxcondition)




# get means by condition 
bt = ddply(OBIWAN_HED, .(trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
# get means by condition and trialxcondition
btc = ddply(OBIWAN_HED, .(condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

# get means by participant 
bsT = ddply(OBIWAN_HED, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsC= ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsTC = ddply(OBIWAN_HED, .(id, trialxcondition, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 



# PLOTS -------------------------------------------------------------------


#  Liking  


#********************************** PLOT 1 main effect by subject ########### rainplot Liking
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')


#ratings

dfLIK <- summarySEwithin(bsC,
                         measurevar = "perceived_liking",
                         withinvars = c("condition"), 
                         idvar = "id")

dfLIK_C  <- subset(dfLIK, condition == 'Empty')
dfLIK_R  <- subset(dfLIK, condition == 'MilkShake')

bsC_C  <- subset(bsC, condition == 'Empty')
bsC_R  <- subset(bsC, condition == 'MilkShake')

  
plt1 <- ggplot(data = bsC, aes(x = condition, y = perceived_liking, color = condition, fill = condition)) +
  #left
  geom_left_violin(data = bsC_C, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_C, shape = 18) +
  geom_errorbar(data=dfLIK_C, aes(ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
  
  #right
  geom_right_violin(data = bsC_R, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_R, aes(x = as.numeric(condition)+0.3, y = perceived_liking), shape = 18) +
  geom_errorbar(data=dfLIK_R, aes(x = as.numeric(condition)+0.3, y = perceived_liking, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsC, aes(x = as.numeric(condition) +0.15, y = perceived_liking), alpha=0.5, size = 0.5, position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = bsC, aes(x = as.numeric(condition) +0.15, y = perceived_liking, group=id), col="grey", alpha=0.4,  position = position_jitter(width = 0.025, seed = 123)) +
  
  #details
  scale_fill_manual(values = c("MilkShake"="blue", "Empty"="black")) +
  scale_color_manual(values = c("MilkShake"="blue", "Empty"="black")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  guides(fill = guide_legend(override.aes = list(alpha = 0.3))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
        axis.text.x = element_blank(), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.525, 0.99), legend.title=element_blank(),
        legend.direction = "horizontal",
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( x = "     Taste Stimulus", y = "Plesantness Ratings")


pdf(file.path(figures_path,paste(task, 'Liking_ratings_control.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()
plot(plt1)

#**********************************  PLOT 2 main effect by trial # # plot liking by time by condition  

dfLIK <- summarySEwithin(bsTC,
                         measurevar = "perceived_liking",
                         withinvars = c("condition", "trialxcondition"), 
                         idvar = "id")

dfLIK$condition <- factor(dfLIK$condition, levels = rev(levels(dfLIK$condition)))

dfLIK$trialxcondition =as.numeric(dfLIK$trialxcondition)

plt2 <- ggplot(dfLIK, aes(x = trialxcondition, y = perceived_liking, fill = condition, color=condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_ribbon(aes(ymax = perceived_liking +se, ymin = perceived_liking -se), alpha=0.2, linetype = 0 ) +
  scale_fill_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_color_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(30,80),  breaks=c(seq.int(30,80, by = 5))) +
  scale_x_continuous(expand = c(0, 0), limits = c(0,20.25), breaks=c(seq.int(1,20, by = 1)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.text.x = element_text(size=11,  colour = "black"),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), 
        legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Pleasantness Ratings")


pdf(file.path(figures_path,paste(task, 'Liking_time_control.pdf',  sep = "_")),
    width     = 7.5,
    height    = 6)

plot(plt2)
dev.off()
plot(plt2)




#************************************************** Intensity


#ratings

dfINT <- summarySEwithin(bsC,
                         measurevar = "perceived_intensity",
                         withinvars = c("condition"), 
                         idvar = "id")

dfINT_C  <- subset(dfINT, condition == 'Empty')
dfINT_R  <- subset(dfINT, condition == 'MilkShake')


plt3 <- ggplot(data = bsC, aes(x = condition, y = perceived_intensity, color = condition, fill = condition)) +
  #left
  geom_left_violin(data = bsC_C, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfINT_C, shape = 18) +
  geom_errorbar(data=dfINT_C, aes(ymax = perceived_intensity + se, ymin = perceived_intensity - se), width=0.1, colour="black", alpha=1, size=0.4)+
  
  #right
  geom_right_violin(data = bsC_R, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfINT_R, aes(x = as.numeric(condition)+0.3, y = perceived_intensity), shape = 18) +
  geom_errorbar(data=dfINT_R, aes(x = as.numeric(condition)+0.3, y = perceived_intensity, ymax = perceived_intensity + se, ymin = perceived_intensity - se), width=0.1, colour="black", alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsC, aes(x = as.numeric(condition) +0.15, y = perceived_intensity), alpha=0.5, size = 0.5, position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = bsC, aes(x = as.numeric(condition) +0.15, y = perceived_intensity, group=id), col="grey", alpha=0.4,  position = position_jitter(width = 0.025, seed = 123)) +
  
  #details
  scale_fill_manual(values = c("MilkShake"="blue", "Empty"="black")) +
  scale_color_manual(values = c("MilkShake"="blue", "Empty"="black")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  guides(fill = guide_legend(override.aes = list(alpha = 0.3))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
        axis.text.x = element_blank(), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.525, 0.99), legend.title=element_blank(),
        legend.direction = "horizontal",
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( x = "     Taste Stimulus", y = "Intensity Ratings")


pdf(file.path(figures_path,paste(task, 'Intensity_ratings_control.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt3)
dev.off()
plot(plt3)

#**********************************  PLOT 4 main effect by trial # # plot intensity by time by condition  

dfINT <- summarySEwithin(bsTC,
                         measurevar = "perceived_intensity",
                         withinvars = c("condition", "trialxcondition"), 
                         idvar = "id")

dfINT$condition <- factor(dfINT$condition, levels = rev(levels(dfINT$condition)))

dfINT$trialxcondition =as.numeric(dfINT$trialxcondition)

plt4 <- ggplot(dfINT, aes(x = trialxcondition, y = perceived_intensity, fill = condition, color=condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_ribbon(aes(ymax = perceived_intensity +se, ymin = perceived_intensity -se), alpha=0.2, linetype = 0 ) +
  scale_fill_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_color_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(30,80),  breaks=c(seq.int(30,80, by = 5))) + 
  scale_x_continuous(expand = c(0, 0), limits = c(0,20.25), breaks=c(seq.int(1,20, by = 1)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.text.x = element_text(size=11,  colour = "black"),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), 
        legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Intensity Ratings")


pdf(file.path(figures_path,paste(task, 'Intensity_time_control.pdf',  sep = "_")),
    width     = 7.5,
    height    = 6)

plot(plt4)
dev.off()
plot(plt4)


# Familiarity 

#ratings

dfFAM <- summarySEwithin(bsC,
                         measurevar = "perceived_familiarity",
                         withinvars = c("condition"), 
                         idvar = "id")
dfFAM_C  <- subset(dfFAM, condition == 'Empty')
dfFAM_R  <- subset(dfFAM, condition == 'MilkShake')


plt5 <- ggplot(data = bsC, aes(x = condition, y = perceived_familiarity, color = condition, fill = condition)) +
  #left
  geom_left_violin(data = bsC_C, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfFAM_C, shape = 18) +
  geom_errorbar(data=dfFAM_C, aes(ymax = perceived_familiarity + se, ymin = perceived_familiarity - se), width=0.1, colour="black", alpha=1, size=0.4)+
  
  #right
  geom_right_violin(data = bsC_R, alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfFAM_R, aes(x = as.numeric(condition)+0.3, y = perceived_familiarity), shape = 18) +
  geom_errorbar(data=dfFAM_R, aes(x = as.numeric(condition)+0.3, y = perceived_familiarity, ymax = perceived_familiarity + se, ymin = perceived_familiarity - se), width=0.1, colour="black", alpha=1, size=0.4)+
  
  #make it raaiiin
  geom_point(data = bsC, aes(x = as.numeric(condition) +0.15, y = perceived_familiarity), alpha=0.5, size = 0.5, position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = bsC, aes(x = as.numeric(condition) +0.15, y = perceived_familiarity, group=id), col="grey", alpha=0.4,  position = position_jitter(width = 0.025, seed = 123)) +
  
  #details
  scale_fill_manual(values = c("MilkShake"="blue", "Empty"="black")) +
  scale_color_manual(values = c("MilkShake"="blue", "Empty"="black")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  guides(fill = guide_legend(override.aes = list(alpha = 0.3))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
        axis.text.x = element_blank(), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.525, 0.99), legend.title=element_blank(),
        legend.direction = "horizontal",
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( x = "     Taste Stimulus", y = "Familiarity Ratings")


pdf(file.path(figures_path,paste(task, 'Familiarity_ratings_control.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt5)
dev.off()
plot(plt5)

#**********************************  PLOT 6 main effect by trial # # plot familiarity by time by condition  

dfFAM <- summarySEwithin(bsTC,
                         measurevar = "perceived_familiarity",
                         withinvars = c("condition", "trialxcondition"), 
                         idvar = "id")

dfFAM$condition <- factor(dfFAM$condition, levels = rev(levels(dfFAM$condition)))

dfFAM$trialxcondition =as.numeric(dfFAM$trialxcondition)

plt6 <- ggplot(dfFAM, aes(x = trialxcondition, y = perceived_familiarity, fill = condition, color=condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_ribbon(aes(ymax = perceived_familiarity +se, ymin = perceived_familiarity -se), alpha=0.2, linetype = 0 ) +
  scale_fill_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_color_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(30,80),  breaks=c(seq.int(30,80, by = 5))) + 
  scale_x_continuous(expand = c(0, 0), limits = c(0,20.25), breaks=c(seq.int(1,20, by = 1)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.text.x = element_text(size=11,  colour = "black"),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), 
        legend.position = c(0.9, 0.99), legend.title=element_blank()) +
  labs(x = "Trials",y = "Familiarity Ratings")


pdf(file.path(figures_path,paste(task, 'Familiarity_time_control.pdf',  sep = "_")),
    width     = 7.5,
    height    = 6)

plot(plt6)
dev.off()

plot(plt6)






#  ANALYSIS ---------------------------------------------------------------
#scale everything!
OBIWAN_HED$perceived_liking = scale(OBIWAN_HED$perceived_liking)
OBIWAN_HED$perceived_familiarity = scale(OBIWAN_HED$perceived_familiarity)
OBIWAN_HED$perceived_intensity = scale(OBIWAN_HED$perceived_intensity)


#eva
#************************************************** test
mdl.liking = lmer(perceived_liking ~ condition*trialxcondition+(condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.liking)

#************************************************** test
mdl.intensity = lmer(perceived_intensity ~ condition*trialxcondition+(condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.intensity)

#************************************************** test
mdl.familiarity= lmer(perceived_familiarity ~ condition*trialxcondition+(condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.familiarity)

n = length(unique(OBIWAN_HED$id))

#ben #MODEL SELECTION
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R')

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

# Bates et al. 2015 seems to be that one starts with the maximal model a la Barr et al. 2013 
# and then decreases the complexity until the covariance matrix is full rank. 
# (Moreover, they would often recommend to reduce the complexity even further, 
# in order to increase the power.) Update: In contrast, Barr et al. recommend to reduce complexity 
# ONLY if the model did not converge; they are willing to tolerate singular covariance matrices.



## COMPARING RANDOM EFFECTS MODELS #REML

mod1 <-  lmer(perceived_liking ~  condition*trialxcondition + perceived_familiarity + perceived_intensity +(condition|id) +  (condition|trialxcondition) , data = OBIWAN_HED)
mod2 <-  lmer(perceived_liking ~  condition*trialxcondition + perceived_familiarity + perceived_intensity +(condition|id) +  (1|trialxcondition) , data = OBIWAN_HED)
mod3 <- lmer(perceived_liking ~  condition*trialxcondition + perceived_familiarity + perceived_intensity + (1|trialxcondition) , data = OBIWAN_HED)
mod4 <- lmer(perceived_liking ~  condition*trialxcondition + perceived_familiarity + perceived_intensity + (condition|id) , data = OBIWAN_HED)
mod5 <- lmer(perceived_liking ~  condition*trialxcondition + perceived_familiarity + perceived_intensity + (1|id) , data = OBIWAN_HED)


AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)
AIC(mod5) ; BIC(mod5) 


## BEST RANDOM SLOPE MODEL
rslope = mod4
summary(rslope) #win #check cor is Not 1 #var is not 0  # not warnings #AIC and BIC are congruent!



## COMPARE FIXED #ML
mod1 <- lmer(perceived_liking ~  condition*trialxcondition + perceived_familiarity + perceived_intensity +(condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod2 <- lmer(perceived_liking ~  condition*trialxcondition + perceived_familiarity +  (condition|id) , data = OBIWAN_HED, REML=FALSE, control= control)
mod3 <- lmer(perceived_liking ~  condition*trialxcondition + perceived_intensity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod4 <- lmer(perceived_liking ~  condition*trialxcondition +  (condition|id) , data = OBIWAN_HED, REML=FALSE, control= control)
mod5 <- lmer(perceived_liking ~  condition + trialxcondition + perceived_familiarity + perceived_intensity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod6 <- lmer(perceived_liking ~  condition + perceived_familiarity + perceived_intensity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod7 <- lmer(perceived_liking ~  condition + trialxcondition + perceived_familiarity + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod8 <- lmer(perceived_liking ~  condition + trialxcondition + perceived_intensity+ (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod9 <- lmer(perceived_liking ~  condition + trialxcondition + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)
mod10 <- lmer(perceived_liking ~  condition + (condition|id) , data = OBIWAN_HED,  REML=FALSE, control= control)

AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)
AIC(mod5) ; BIC(mod5) 
AIC(mod6) ; BIC(mod6)
AIC(mod7) ; BIC(mod7)
AIC(mod8) ; BIC(mod8)
AIC(mod9) ; BIC(mod9)
AIC(mod10) ; BIC(mod10)



## BEST MODEL
model = mod5
summary(model) #win #check cor is Not 1  #var is not 0 # not warnings #AIC and BIC are congruent!


## TESTING THE RANDOM INTERCEPT
mod1 <- lmer(perceived_liking ~  condition + trialxcondition + perceived_familiarity + perceived_intensity + (condition|id) , data = OBIWAN_HED,  REML=FALSE)
mod2 <- lm(perceived_liking ~  condition + trialxcondition + perceived_familiarity + perceived_intensity , data = OBIWAN_HED)

AIC(mod1) ; BIC(mod1) # largely better !
AIC(mod2) ; BIC(mod2)


## R-SQUARED IN MULTILEVEL MODELS

r2beta(rslope,method="nsj")

#drop the condition random because its condtional we want
mod1 <- lmer(perceived_liking ~  condition + trialxcondition + perceived_familiarity + perceived_intensity + (1|id) , data = OBIWAN_HED,  REML=FALSE)
#drop the condition fixed AND random
mod2 <- lmer(perceived_liking ~  trialxcondition + perceived_familiarity + perceived_intensity + (1|id) , data = OBIWAN_HED,  REML=FALSE)
r.squaredGLMM(mod1)
r.squaredGLMM(mod2)
#well nothing to see here..this value thus reflects the partial marginal R2 for the condition effect


main.model.lik = model
#only remove fixed ef cond
null.model.lik = lmer(perceived_liking ~ trialxcondition + perceived_familiarity + perceived_intensity + (condition|id) , data = OBIWAN_HED,  REML=FALSE)

test = anova(main.model.lik, null.model.lik, test = 'Chisq')
test

#Δ BIC = -5.271089 -> evidence for model without condition...
delta_BIC = test$BIC[1] -test$BIC[2] 
delta_BIC


#inter
## PLOTTING MODEL ##
visreg(model,points.par=list(col="lightblue"),line.par=list(col="royalblue4",lwd=4))

inter <- lmer(perceived_liking ~ condition*trialxcondition + (condition|id) , data = OBIWAN_HED,  REML=FALSE , control= control)

#confusing
visreg(inter,xvar="condition",by="trialxcondition",gg=TRUE,type="contrast",ylab="Liking (z)",breaks=c(-2,0,2),xlab="condition")

#clearer #but whatcha interptr
visreg(inter,xvar="id",by="condition",gg=TRUE,type="contrast",ylab="Liking (z)",breaks=c(-2,0,2),xlab="condition")



#Assumptions: REML = TRUE
mod = lmer(perceived_liking ~  condition + trialxcondition + perceived_familiarity + perceived_intensity + (condition|id) , data = OBIWAN_HED)

#1)Linearity 
plot(mod)

#2) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod)

#3)Homoscedasticity AND #4)Normality of residuals
#par(mfrow=c(2,2))
hist(residuals(mod),breaks=100,main="Untransformed",freq=FALSE,col="slategray",border="white")
lines(density(residuals(mod)),lwd=3,col="firebrick")
hist(tdiagnostic(mod)$tres,breaks=100,main="Transformed",freq=FALSE,col="slategray",border="white")
lines(density(tdiagnostic(mod)$tres),lwd=3,col="firebrick")
qqnorm(residuals(mod),pch=4,col="bisque3") ; qqline(residuals(mod),col="darkblue",lwd=2)
qqnorm(tdiagnostic(mod)$tres,pch=4,col="bisque3") ; qqline(tdiagnostic(mod)$tres,col="darkblue",lwd=2)
#dev.off()


#5) Absence of influential data points (109) 116

boxplot(scale(ranef(mod)$id))

set.seed(1816)
im <- influence(mod,maxfun=100,  group="id")

infIndexPlot(im,col="steelblue",
                   vars=c("cookd"))




# 
# 
# # other ------------------------------------------------------------------
# 
# 
# main.model.lik = lmer(perceived_liking ~ condition + trialxcondition  + (1+condition|id), data = OBIWAN_HED, REML=FALSE)
# summary(main.model.lik)
# 
# null.model.lik = lmer(perceived_liking ~ trialxcondition  + (1+condition|id), data = OBIWAN_HED, REML=FALSE)
# 
# test = anova(main.model.lik, null.model.lik, test = 'Chisq')
# test
# 
# # main.model.lik = lmer(perceived_liking ~ condition + EMG +  trialxcondition  + (1+condition|id), data = OBIWAN_HED, REML=FALSE)
# # summary(main.model.lik)
# # 
# # null.model.lik = lmer(perceived_liking ~ trialxcondition + condition + (1+condition|id), data = OBIWAN_HED, REML=FALSE)
# # 
# # test = anova(main.model.lik, null.model.lik, test = 'Chisq')
# # test
# 
# 
# #sentence => main.liking is 'signifincatly' better than the null model wihtout condition a fixe effect
# # condition affected liking rating (χ2 (1)= 868.41, p<2.20×10ˆ-16), rising reward ratings by 17.63 points ± 0.57 (SEE) compared to neutral condition and,
# # 17.63 ± 0.56 (SEE) compared to the control condition.
# 
# #Δ BIC = 847.92
# delta_BIC = test$BIC[1] -test$BIC[2] 
# delta_BIC
# 
# 
# #
# ems = emmeans(main.model.lik, list(pairwise ~ condition), adjust = "none")
# confint(emmeans(main.model.lik, list(pairwise ~ condition)), level = .95, type = "response", adjust = "none")
# plot(ems)
# ems
# 
# #compute ptukey because ems rounds everything !!
# #pR_N = 1 - ptukey(11.692 * sqrt(2), 3, 25.04)
# #pR_C = 1 - ptukey(12.652 * sqrt(2), 3, 25.04)
# 
# # Neutral VS Control (so we do that to be less bias and more conservator)
# # playing against ourselvees
# cont = emmeans(main.model.lik, ~ condition)
# contr_mat <- coef(pairs(cont))[c("c.3")]
# emmeans(main.model.lik, ~ condition, contr = contr_mat, adjust = "none")$contrasts
# confint(emmeans(main.model.lik, ~ condition, contr = contr_mat, adjust = "none")$contrasts)
# 
# 
# # planned contrast
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'chocolate']     <- 2
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'empty']     <- -1
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'neutral']     <- -1
# 
# 
# #
# main.cont.lik = lmer(perceived_liking ~ cvalue + trialxcondition + (1|id), data = OBIWAN_HED, REML=FALSE)
# summary(main.cont.lik)
# 
# null.cont.lik = lmer(perceived_liking ~ trialxcondition + (1|id), data = OBIWAN_HED, REML=FALSE)
# 
# test2 = anova(main.cont.lik, null.cont.lik, test = 'Chisq')
# test2
# #sentence => main.liking is 'signifincatly' better than the null model wihtout condition a fixe effect
# # condition affected liking rating (χ2 (1)= 866.73, p<2.20×10ˆ-16), rising reward ratings by 17.27 points ± 0.49 (SEE) compared to the other two conditions
# #Δ BIC = 847.92
# delta_BIC = test2$BIC[1] -test2$BIC[2] 
# delta_BIC
# 
# 
# 
# 
# #INTENSITY
# 
# main.model.int = lmer(perceived_intensity ~ condition + trialxcondition + (1+condition|id), data = OBIWAN_HED, REML=FALSE)
# summary(main.model.int)
# 
# null.model.int = lmer(perceived_intensity ~ trialxcondition + (1+condition|id), data = OBIWAN_HED, REML=FALSE)
# 
# testint = anova(main.model.int, null.model.int, test = 'Chisq')
# testint
# #sentence => main.intensity is 'signifincatly' better than the null model wihtout condition a fixe effect
# # condition affected intensity rating (χ2 (1)= 868.41, p<2.20×10ˆ-16), rising reward ratings by 17.63 points ± 0.57 (SEE) compared to neutral condition and,
# # 17.63 ± 0.56 (SEE) compared to the control condition.
# 
# #Δ BIC = XX
# delta_BIC = testint$BIC[1] -testint$BIC[2] 
# delta_BIC
# 
# ems = emmeans(main.model.int, list(pairwise ~ condition), adjust = "tukey")
# confint(emmeans(main.model.int,list(pairwise ~ condition)), level = .95, type = "response", adjust = "tukey")
# plot(ems)
# ems
# 
# 
# 
# #compute ptukey because ems rounds everything !!
# pR_C = 1 - ptukey(9.657 * sqrt(2), 3, 25.06)
# pR_C 
# 
# # Neutral VS Control (so we do that to be less bias and more conservator)
# cont = emmeans(main.model.lik, ~ condition)
# contr_mat <- coef(pairs(cont))[c("c.3")]
# emmeans(main.model.lik, ~ condition, contr = contr_mat, adjust = "none")$contrasts
# 
# 
# # planned contrast
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'chocolate']     <- 2
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'empty']     <- -1
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'neutral']     <- -1
# 
# 
# # planned contrast
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'chocolate']     <- 2
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'empty']     <- -1
# OBIWAN_HED$cvalue[OBIWAN_HED$condition== 'neutral']     <- -1
# 
# #
# main.cont.int = lmer(perceived_intensity ~ cvalue + trialxcondition + (1|id), data = OBIWAN_HED, REML=FALSE)
# summary(main.cont.int)
# 
# null.cont.int = lmer(perceived_intensity ~ trialxcondition + (1|id), data = OBIWAN_HED, REML=FALSE)
# 
# testint2 = anova(main.cont.int, null.cont.int, test = 'Chisq')
# testint2
# #sentence => main.intensity is 'signifincatly' better than the null model without condition as fixed effect
# # condition affected intensity rating (χ2 (1)= XX p<2.20×10ˆ-16), rising reward intensity ratings by XX points ± X.X (SEE) compared to the other two conditions
# #Δ BIC = XX
# delta_BIC = test2$BIC[1] -test2$BIC[2] 
# delta_BIC
# 
# 
# # 
# # #  contrast NEUTRAL - EMPTY "we play against ourselves by oding this contrast and being conservator"
# # OBIWAN_HED$cvalue1[OBIWAN_HED$condition== 'chocolate']     <- 0
# # OBIWAN_HED$cvalue1[OBIWAN_HED$condition== 'empty']     <- 1
# # OBIWAN_HED$cvalue1[OBIWAN_HED$condition== 'neutral']     <- -1
# # OBIWAN_HED$cvalue1       <- factor(OBIWAN_HED$cvalue1)
# # 
# # #
# # main.cont1 = lmer(perceived_intensity ~ cvalue1 + trialxcondition + (1|id), data = OBIWAN_HED, REML=FALSE)
# # summary(main.cont1)
# 
