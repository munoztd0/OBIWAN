## R code for FOR PAV OBIWAN
# last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, ggplot2, sjPlot, influence.ME, emmeans) # BayesFactor
#the order of loading is extremely important !!!

# SETUP ------------------------------------------------------------------

task = 'PAV'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


# open dataset or load('PAV.RData')
PAV_full <- read.delim(file.path(analysis_path,'OBIWAN_PAV.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PAV  <- subset(PAV_full, group == 'obese') 

#merge with info
PAV = merge(PAV, info, by = "id")

#take out incomplete data 
PAV <-  PAV[which(PAV$id != c(242, 256)),] #  influence 205 & 254 

# define as.factors
fac <- c("id", "trial", "condition", "session", "trialxcondition", "gender", "intervention")
PAV[fac] <- lapply(PAV[fac], factor)

PAV$RT <- as.numeric(PAV$RT)*1000 # transform in millisecond

#check demo
n_tot = length(unique(PAV$id))
bs = ddply(PAV, .(id, session), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

n_pre = length(which(bs$session == "second"))
n_post = length(which(bs$session == "third"))

AGE = ddply(PAV,~session,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PAV,~session,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PAV, .(id, session), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, session) %>%
  tally() #2 = female


# Cleaning Up -------------------------------------------------------------
#shorter than 100ms and longer than 3sd+mean

densityPlot(PAV$RT) # not that bad actually for RT

full = length(PAV$RT)
PAV.clean <- PAV %>% filter(RT <= mean(RT, na.rm = TRUE) + 3*sd(RT, na.rm = TRUE) &  RT >= 200) 

clean= length(PAV.clean$RT)

dropped = full-clean
(dropped*100)/full  #dropped 13%

densityPlot(PAV.clean$RT) 

PAV = PAV.clean 

#log transform
t_log_scale <- function(x){
  if(x==0){
    y <- 1} 
  else {
    y <- (sign(x)) * (log(abs(x)))}
  y }

plot(density(sapply(PAV$RT,FUN=t_log_scale))) # but this is much better !

PAV$RT_T <- sapply(PAV$RT,FUN=t_log_scale)

#accuracy is to 95 (was 96 before cleaning)
mean(PAV$ACC, na.rm = TRUE)

#scale everything
PAV$likZ = scale(PAV$liking) #but is it nested ? ##check 
PAV$RT_TZ = scale(PAV$RT_T)

#agragate by subj and then scale 
PAV <- PAV %>% 
  group_by(id) %>% 
  mutate(ageZ = scale(age))

#create BMI diff (I have still NAN because missing data)
PAV <- PAV %>% 
  group_by(id) %>% 
  mutate(diff_bmiZ = scale(BMI_t1 - BMI_t2))

#change value of sessions
PAV$time = revalue(PAV$session, c(second="0", third="1"))

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION following Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PAV.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#save RData for cluster computing
save.image(file = "PAV.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)


#Calculates p-values using parametric bootstrap takes forever #set to method LRT to quick check
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 

#takes ages even on the cluster!
#model = mixed(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition*time|id) + (1|trialxcondition), 
#data = PAV, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 100))

model = mixed(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition*time|id) + (1|trialxcondition), 
              data = PAV, method = "LRT", control = control, REML = FALSE)

summary(model) #The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: RT_TZ ~ condition * time * intervention + gender + ageZ + diff_bmiZ + 
#   Model:     likZ + (condition * time | id) + (1 | trialxcondition)
# Data: PAV
# Df full model: 24
# Effect df   Chisq p.value
# 1                    condition  1    0.15     .70
# 2                         time  1    0.36     .55
# 3                 intervention  1    2.23     .14
# 4                       gender  1    0.50     .48
# 5                         ageZ  1  5.79 *     .02
# 6                    diff_bmiZ  1    0.43     .51
# 7                         likZ  1 9.66 **    .002
# 8               condition:time  1    0.26     .61
# 9       condition:intervention  1    1.84     .17
# 10           time:intervention  1    0.08     .77
# 11 condition:time:intervention  1    0.03     .87

# COMPUTE EFFECT SIZES (COMPUTE R Squared For Mixed Models VIA NAKAGAWA ESTIMATE)
mod <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition*time|id) + (1|trialxcondition), 
            data = PAV, control = control) #need to be fitted using ML so here I just use lmer function so its faster

R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors 
R2

# BAYESIAN ANOVA
# N.B. Please note that the estimated Bayes factors might (slightly) vary due to Monte Carlo sampling noise
# PAV.aov_BF  <- anovaBF(RT_TZ ~ condition*time*intervention + id, data = PAV, whichRandom=c('id','condition:id', 'time:id', 'time:condition:id'), iterations = 5000)
#   
# # Interaction effect
# PAV.aov_BF[4]/PAV.aov_BF[3]


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

emm_options(pbkrtest.limit = 5000) #set emmeans options

# interaction plot interventionXconditionXtime 

#pred CI #takes forever
pred = confint(emmeans(model,list(pairwise ~ intervention:condition:time)), level = .95, type = "response")
df.predicted = data.frame(pred$`emmeans of intervention, condition, time`)

colnames(df.predicted) <- c("intervention", "condition", "time",  "fit", "SE", "df", "lowCI", "uppCI")

#custom contrasts
# con <- list(
#   c1 = c(0, 0, 0, 0, 1, -1, 0, 0), #Post: empty Placebo > empty- Lira
#   c2 = c(0, 0, 0, 0, 0, 0, 1, -1), #Post: MS Placebo > MS Lira
#   c3 = c(0, 0, 1, -1, 0, 0, 0, 0), #Pre: MS Placebo > MS Lira
#   c4 = c(1, -1, 0, 0, 0, 0, 0, 0) #Pre: empty Placebo > empty Lira
# )

#contrasts on estimated means adjusted via the Multivariate normal t distribution
#cont = emmeans(model, ~ intervention:condition:time, contr = con, adjust = "mvt")

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
        legend.position = c(0.475, -0.2), legend.title=element_blank(),
        legend.direction = "horizontal", #legend.spacing.x = unit(1, 'cm'),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs( y = "Reaction Times (log z)", #    Post-hoc test -> No differences found\n
        caption = "\n \n \n \n \nThree-way interaction, p = .87, \n
        Main effect of condition, p = .70\n
        Error bars represent 95% CI for the estimated marginal means\n
        Placebo (N = 29), Liraglutide (N = 32)\n
        LMM : Reaction Times ~ Condition*Time*Treatment + (Time*Condition|Id) + (1|Trial)\n
        Controling for Liking, Age, Gender & Weight Loss (BMI pre - BMI post)")

plot(plt3)

cairo_pdf(file.path(figures_path,paste(task, 'condXtreatXtime_Lira.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt3)
dev.off()


# THE END - Special thanks to Ben Meulman and Yoann Stussi -----------------------------------------------------------------

# 1                    condition  1    0.15     .70
# 2                         time  1    0.36     .55
# 3                 intervention  1    2.23     .14
# 4                       gender  1    0.50     .48
# 5                         ageZ  1  5.79 *     .02
# 6                    diff_bmiZ  1    0.43     .51
# 7                         likZ  1 9.66 **    .002
# 8               condition:time  1    0.26     .61
# 9       condition:intervention  1    1.84     .17
# 10           time:intervention  1    0.08     .77
# 11 condition:time:intervention  1    0.03     .87


  