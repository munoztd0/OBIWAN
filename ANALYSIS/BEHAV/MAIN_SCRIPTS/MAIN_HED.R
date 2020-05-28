## R code for FOR HEDONIC OBIWAN
# last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, ggplot2, sjPlot, emmeans)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
setwd(analysis_path)
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

load('HED.RData')


# open dataset
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
HED  <- subset(HED_full, group == 'obese') 

#merge with info
HED = merge(HED, info, by = "id")

#take out incomplete data #234 only have third session?
HED <-  HED[which(HED$id != c(242, 256)),] #, "234"

# define as.factors
fac <- c("id", "trial", "condition", "session", "trialxcondition", "gender", "intervention")
HED[fac] <- lapply(HED[fac], factor)


#check demo
n_tot = length(unique(HED$id))
bs = ddply(HED, .(id, session), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

n_pre = length(which(bs$session == "second"))
n_post = length(which(bs$session == "third"))

AGE = ddply(HED,~session,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(HED,~session,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(HED, .(id, session), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, session) %>%
  tally() #2 = female


#scale everything
HED$likZ = scale(HED$perceived_liking)
HED$famZ = scale(HED$perceived_familiarity)
HED$intZ = scale(HED$perceived_intensity)

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(ageZ = scale(HED$age))

#create BMI diff (I have still NAN because missing data)
HED <- HED %>% 
  group_by(id) %>% 
  mutate(diff_bmiZ = scale(HED$BMI_t1 - HED$BMI_t2))

#change value of sessions
HED$time = revalue(HED$session, c(second="0", third="1"))


# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_HED.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#save RData for cluster computing
save.image(file = "HED.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)
#Calculates p-values using parametric bootstrap takes forever #set to method LRT to quick check
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 

#takes ages even on the cluster!
# model = mixed(likZ ~ condition*time*intervention + gender + ageZ +  diff_bmiZ + famZ * intZ +(time*condition +famZ*intZ|id) + (1|trialxcondition) , 
#       data = HED, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 100))

model = mixed(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(time*condition +famZ*intZ|id) + (1|trialxcondition) , 
              data = HED, method = "LRT", control = control, REML = FALSE)


summary(model) #The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: likZ ~ condition * time * intervention + gender + ageZ + diff_bmiZ + 
#   Model:     famZ * intZ + (time * condition + famZ * intZ | id) + (1 | 
#                                                                       Model:     trialxcondition)
# Data: HED
# Df full model: 44
#                         Effect df     Chisq p.value
# 1                    condition  1 22.61 ***   <.001
# 2                         time  1    4.05 *    .044
# 3                 intervention  1      0.32    .570
# 4                       gender  1      1.01    .315
# 5                         ageZ  1      0.37    .541
# 6                    diff_bmiZ  1      0.01    .906
# 7                         famZ  1 30.71 ***   <.001
# 8                         intZ  1      0.05    .820
# 9               condition:time  1    4.96 *    .026
# 10      condition:intervention  1      0.29    .590
# 11           time:intervention  1      1.59    .208
# 12                   famZ:intZ  1      1.85    .173
# 13 condition:time:intervention  1      0.40    .529


# COMPUTE EFFECT SIZES (COMPUTE R Squared For Mixed Models VIA NAKAGAWA ESTIMATE)
mod <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(time*condition +famZ*intZ|id) + (1|trialxcondition) , 
            data = HED, control = control) #need to be fitted using ML so here I just use lmer function so its faster

R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors 

# MODEL ASSUMPTION CHECKS :  -----------------------------------

#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so no problem keeping everything

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points -> 228 & 235
#simple univariate boxplots
boxplot(scale(ranef(mod)$id), las=2)

#disgnostic plots -> Cook's distance
set.seed(101)
im <- influence(mod,maxfun=100,  group="id")  #takes forever
infIndexPlot(im,col="steelblue", vars=c("cookd"))


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

emm_options(pbkrtest.limit = 5000) #set emmeans options

# interaction plot interventionXconditionXtime 

#pred CI #takes forever
pred = confint(emmeans(model,list(pairwise ~ intervention:condition:time)), level = .95, type = "response")
df.predicted = data.frame(pred$`emmeans of intervention, condition, time`)

colnames(df.predicted) <- c("intervention", "condition", "time",  "fit", "SE", "df", "lowCI", "uppCI")

#custom contrasts
con <- list(
  c1 = c(0, 0, 0, 0, 1, -1, 0, 0), #Post: empty Placebo > empty- Lira
  c2 = c(0, 0, 0, 0, 0, 0, 1, -1), #Post: MS Placebo > MS Lira
  c3 = c(0, 0, 1, -1, 0, 0, 0, 0), #Pre: MS Placebo > MS Lira
  c4 = c(1, -1, 0, 0, 0, 0, 0, 0) #Pre: empty Placebo > empty Lira
)

#contrasts on estimated means adjusted via the Multivariate normal t distribution
cont = emmeans(model, ~ intervention:condition:time, contr = con, adjust = "mvt")

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
  scale_x_discrete(labels=c("Empty" = "Tasteless  ", "MilkShake" = "  Milkshake")) + 
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
  labs( y = "Plesantness Ratings (z)",
        caption = "\n \n \n \n \nThree-way interaction, p = 0.73, \u0394 AIC = -1.88\n
        Post-hoc test -> No differences found\n
        Main effect of condition, p < 0.0001, \u0394 AIC = 23.02, R\u00B2 = 0.030\n
        Error bars represent 95% CI for the estimated marginal means\n
        Placebo (N = 29), Liraglutide (N = 32)\n
        LMM : Pleasantness ~ Condition*Time*Treatment + (Time*Condition|Id) + (1|Trial)\n
        Controling for Intensity, Familiarity, Age, Gender & Weight Loss (BMI pre - BMI post)")

plot(plt3)

cairo_pdf(file.path(figures_path,paste(task, 'condXtreatXtime_Lira.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt3)
dev.off()


# THE END - Special thanks to Ben Meulman and Yoann Stussi -----------------------------------------------------------------

