## R code for FOR PIT OBIWAN
# last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, ggplot2, sjPlot, emmeans)

# SETUP ------------------------------------------------------------------

task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


# open dataset or load('PIT_Lira.RData')
PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PIT  <- subset(PIT_full, group == 'obese')
HED  <- subset(HED_full, group == 'obese') 

#merge with info
PIT = merge(PIT, info, by = "id")

#take out incomplete data ##218 only have the third ? influence -> 238 & 234 & 232 & 254
`%notin%` <- Negate(`%in%`)
PIT = PIT %>% filter(id %notin% c(242, 256, 201, 218, 219, 221, 225, 230, 241,  244, 246, 247))
HED = HED %>% filter(id %notin% c(242, 256, 201, 218, 219, 221, 225, 230, 241,  244, 246, 247))
#, 201, 218, 219, 221, 225, 230, 241,  244, 246, 247
#242 245 bc MRI & behav

# define as.factors
fac <- c("id", "trial", "condition", "session", "trialxcondition", "gender", "intervention")
PIT[fac] <- lapply(PIT[fac], factor)

#check demo
n_tot = length(unique(PIT$id))
n_pre = length(which(bs$session == "second"))
n_post = length(which(bs$session == "third"))

AGE = ddply(PIT,~session,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PIT,~session,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PIT, .(id, session), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, session) %>%
  tally() #2 = female

N_inter = ddply(PIT, .(id, intervention), summarise, intervention=mean(as.numeric(intervention)))  %>%
  group_by(intervention) %>% tally() # 1 = placebo 2 = treart

#remove the baseline from other trials and then scale  by id  
PIT =  subset(PIT, condition != 'BL') 

PIT_BL = ddply(PIT, .(id), summarise, freqA=mean(AUC), sdA=sd(AUC)) 
PIT = merge(PIT, PIT_BL, by = "id")
PIT$gripAUC = (PIT$AUC - PIT$freqA) / PIT$sdA

HED_BL = ddply(HED, .(id,condition), summarise, lik=mean(perceived_liking)) 
HED_BL = subset(HED_BL, condition == 'MilkShake') 
HED_BL = select(HED_BL, -c(condition) )
PIT = merge(PIT, HED_BL, by = "id")

#scale everything

#agragate by subj and then scale
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(likZ = scale(lik))

PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(ageZ = scale(age))

#create BMI diff (I have still NAN because missing data)
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(diff_bmiZ = scale(BMI_t1 - BMI_t2))

PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(bmiZ = scale(BMI_t1))

#change value of sessions
PIT$time = as.factor(revalue(PIT$session, c(second="0", third="1")))

PIT$group2 = c(1:length(PIT$group))
PIT$group2[PIT$BMI_t1 >= 30 & PIT$BMI_t1 < 35] <- '0' # Class I obesity: BMI = 30 to 35. -> - 0.22
PIT$group2[PIT$BMI_t1 >= 35] <- '1' # Class II obesity: BMI = 35 to 40. -> 0.89

Ngroup = ddply(PIT, .(id, intervention, group2), summarise, gender=mean(as.numeric(group2)))  %>%
  group_by(intervention, group2) %>%
  tally() #2 = female


# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/CSp_PIT.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

emm_options(pbkrtest.limit = 5000) #set emmeans options

# interaction plot interventionXconditionXtime 
PIT$gripZ = PIT$gripAUC
PIT$group2 <- as.factor(PIT$group2)
mod <- lmer(gripZ ~ condition*time*intervention*group2 + gender + ageZ + diff_bmiZ +likZ +(time*condition |id) + (1|trialxcondition) , 
            data = PIT, control = control) #need to be fitted using ML so here I just use lmer function so its faster

#pred CI #takes forever
# pred = confint(emmeans(mod,list(pairwise ~ intervention:condition:time:group2)), level = .95, type = "response")
# df.predicted = data.frame(pred$`emmeans of intervention, condition, time, group2`)
# colnames(df.predicted) <- c("intervention", "condition", "time", "group2","fit", "SE", "df", "lowCI", "uppCI")

#custom contrasts
# con <- list(
#   c1 = c(0, 0, 0, 0, 1, -1, 0, 0), #Post: CSm Placebo > CSm- Lira
#   c2 = c(0, 0, 0, 0, 0, 0, 1, -1), #Post: CSp Placebo > CSp Lira
#   c3 = c(0, 0, 1, -1, 0, 0, 0, 0), #Pre: CSp Placebo > CSp Lira
#   c4 = c(1, -1, 0, 0, 0, 0, 0, 0) #Pre: CSm Placebo > CSm Lira
# )

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

#contrasts on estimated means adjusted via the Multivariate normal t distribution
cont = emmeans(mod, ~ intervention:condition:time:group2, contr = con, adjust = "mvt")
#cont = confint(emmeans(mod,~ intervention:condition:time:group2, contr = con,adjust = "mvt"), level = .95, type = "response")


#plot(cont$contrasts, comparisons = TRUE)
df.PIT = as.data.frame(cont$contrasts) 
intervention = c(0, 1, 1, 0, 0, 1, 1, 0)
time = c(1, 1, 0, 0, 1, 1, 0, 0)
group2 = c(0, 0, 0, 0, 1, 1, 1, 1)
df.PIT = cbind(df.PIT, intervention, time, group2)
fac <- c("intervention", "time", "group2")
df.PIT[fac] <- lapply(df.PIT[fac], factor)

# CSPlus <- subset(PIT, condition =="CSplus" )
# CSPlus <- CSPlus[order(as.numeric(levels(CSPlus$id))[CSPlus$id], CSPlus$trialxcondition),]
# CSMinus <- subset(PIT, condition =="CSminus" )
# CSMinus <- CSMinus[order(as.numeric(levels(CSMinus$id))[CSMinus$id], CSPlus$trialxcondition),]
# df.observed = CSPlus
# df.observed$estimate = CSPlus$gripZ - CSMinus$gripZ

full.obs = ddply(PIT, .(id, group2, intervention, time, condition), summarise, estimate = mean(gripZ)) 
plus = subset(full.obs, condition == 'CSplus')
minus = subset(full.obs, condition == 'CSminus')
df.observed = minus
df.observed$estimate = plus$estimate - minus$estimate
df.observed$bmiT = df.observed$group2

labelsSES <- c("0" = "Pre-Test", "1" = "Post-Test")
labelsOB <- c( "0" = "Class I" , "1" = "Class II-III")
labelsTRE <- c( "0" = "Placebo" , "1" = "Liraglutide")

pl <-  ggplot(df.PIT, aes(x = group2, y = estimate, color = intervention)) +
  geom_bar(aes(y = estimate, x = group2, group = intervention), stat="identity", alpha=0.6, width=0.3, color  = 'lightgrey', fill  = 'lightgrey', position = position_dodge(0.4)) +
  geom_errorbar(aes(ymax = estimate + SE, ymin = estimate - SE), width=0.1,  alpha=0.7, position = position_dodge(0.4))+
  geom_point(size = 0.5,  position = position_dodge(0.4)) +  #color = 'blue'
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) + 
  geom_point(data = df.observed, size = 0.1, alpha = 0.6,  position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.4)) + #, color = 'royalblue'
  facet_wrap(~ time, labeller=labeller(time = labelsSES))

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




#save RData for cluster computing
save.image(file = "PIT_Lira.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)



#Calculates p-values using parametric bootstrap takes forever #set to method LRT to quick check
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 

#takes ages even on the cluster!
# method = "PB", control = control, REML = FALSE, args_test = list(nsim = 10))

PIT$gripZ = PIT$gripAUC
bs = ddply(PIT, .(id, session), summarise, gripZ = mean(gripZ, na.rm = TRUE))


mdl.aov = aov_4(gripZ ~ condition*time*intervention + bmiZ + likZ + diff_bmiZ + gender + ageZ +  (time*condition|id) , 
                data = PIT, observed = c("gender", "ageZ", "diff_bmiZ"), factorize = FALSE, fun_aggregate = mean)

summary(mdl.aov)

model = mixed(gripZ ~ condition*time*intervention + bmiZ + likZ + diff_bmiZ + gender + ageZ + diff_bmiZ + bmiZ + likZ +  (time*condition|id) + (1|trialxcondition), 
              data = PIT, method = "LRT", control = control, REML = FALSE)

model #The ‘intercept’ of the lmer model is the mean force rate in CS- coniditon for an average subject. 

# Model:   gripZ ~ condition * time * intervention + gender + ageZ + diff_bmiZ +   (time * condition | id) + (1 | trialxcondition)
# Data: PIT
# Df full model: 23
# Effect df    Chisq p.value
# 1                    condition  1  7.06 **    .008
# 2                         time  0 0.00        NaN
# 3                 intervention  0 0.00        NaN
# 4                       gender  1     0.00    .993
# 5                         ageZ  1     0.00    .997
# 6                    diff_bmiZ  1     0.00    .995
# 7               condition:time  1     0.06    .804
# 8       condition:intervention  1     1.37    .242
# 9            time:intervention  0     0.00   >.999
# 10 condition:time:intervention  1     0.25    .615

# COMPUTE EFFECT SIZES (COMPUTE R Squared For Mixed Models VIA NAKAGAWA ESTIMATE)
mod <- lmer(gripZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ +likZ +(time*condition |id) + (1|trialxcondition) , 
            data = PIT, control = control) #need to be fitted using ML so here I just use lmer function so its faster

# R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors 
# R2 #0.005    0.011    0.001

#LR test for condition 
full <- lmer(gripZ ~ condition + time*intervention + gender + ageZ + diff_bmiZ +likZ +(time*condition |id) + (1|trialxcondition) , 
             data = PIT, control = control, REML = FALSE) 
null <- lmer(gripZ ~  time*intervention + gender + ageZ + diff_bmiZ +likZ +(time*condition |id) + (1|trialxcondition) , 
             data = PIT, control = control, REML = FALSE) 
test = anova(full, null, test = "Chisq") #4.50  1    0.03388
#Δ AIC = 5.12
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC








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
mod <- lmer(gripZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ +likZ +(time*condition |id) + (1|trialxcondition) , 
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

full.obs = ddply(PIT, .(id, intervention, time, condition), summarise, estimate = mean(gripZ)) 
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












full.obs = ddply(PIT, .(id, group2, intervention, time, condition), summarise, estimate = mean(gripZ)) 
plus = subset(full.obs, condition == 'CSplus')
minus = subset(full.obs, condition == 'CSminus')
df.observed = minus
df.observed$estimate = plus$estimate - minus$estimate
df.observed$bmiT = df.observed$group2
