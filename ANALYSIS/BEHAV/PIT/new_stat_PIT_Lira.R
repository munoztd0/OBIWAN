## R code for FOR OBIWAN_PIT Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, ggplot2, Rmisc, dplyr, lmerTest, car, r2glmm, optimx, visreg, MuMIn,  pbkrtest, bootpredictlme4, sjPlot, emmeans, bayestestR)

#SETUP
task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$id      <- as.factor(info$id)

#subset
OBIWAN_PIT  <- subset(OBIWAN_PIT_full, group == 'obese') #only group obese 

# define as.factors
OBIWAN_PIT$id      <- as.factor(OBIWAN_PIT$id)
OBIWAN_PIT$trial    <- as.factor(OBIWAN_PIT$trial)
OBIWAN_PIT$group    <- as.factor(OBIWAN_PIT$group)

#remove the baseline trials for now
OBIWAN_PIT = subset(OBIWAN_PIT, condition != 'BL')
OBIWAN_PIT$condition <- factor(OBIWAN_PIT$condition)

OBIWAN_PIT$time    <- as.factor(OBIWAN_PIT$session)

OBIWAN_PIT$trialxcondition <- as.factor(OBIWAN_PIT$trialxcondition)

OBIWAN_PIT = full_join(OBIWAN_PIT, info, by = "id")

OBIWAN_PIT <-OBIWAN_PIT %>% drop_na("condition")

OBIWAN_PIT  <- subset(OBIWAN_PIT, id != 242 & id != 256 & id != 218) #218 only have the third 
#outlier -> -> 238 & 234

OBIWAN_PIT$gender   <- as.factor(OBIWAN_PIT$gender) #M=0
OBIWAN_PIT$intervention   <- as.factor(OBIWAN_PIT$intervention) #blind

n_tot = length(unique(OBIWAN_PIT$id))

#check
bs = ddply(OBIWAN_PIT, .(id, session), summarise, gripFreq = mean(gripFreq, na.rm = TRUE))

#check demo
AGE = ddply(OBIWAN_PIT,~group,summarise,mean=mean(age),sd=sd(age))
BMI = ddply(OBIWAN_PIT,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1))
GENDER = ddply(OBIWAN_PIT, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #2 = female

#in other way
CSp = subset(OBIWAN_PIT, condition == 'CSplus')
CSm = subset(OBIWAN_PIT, condition == 'CSminus')
PIT = CSp

PIT$PIT_IND = CSp$gripFreq - CSm$gripFreq

# QUICK STATS -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#scale everything
OBIWAN_PIT$gripsZ = scale(OBIWAN_PIT$gripFreq)
#OBIWAN_PIT$gripsBZ = scale(OBIWAN_PIT$gripFreqB)
OBIWAN_PIT$ageZ = hscale(OBIWAN_PIT$age, OBIWAN_PIT$id) #agragate by subj and then scale 
#OBIWAN_PIT$bmiZ = hscale(OBIWAN_PIT$BMI_t1, OBIWAN_PIT$id) #agragate by subj and then scale 

PIT$indZ = scale(PIT$gripFreq)

#create BMI diff #double check
OBIWAN_PIT$bmi_diff = OBIWAN_PIT$BMI_t1 - OBIWAN_PIT$BMI_t2 



#************************************************** test (BAD)
mdl.PIT = lmer(gripsZ ~ condition*time*intervention + trialxcondition + bmi_diff + gender + ageZ + (condition|id)+ (condition|trialxcondition), data = OBIWAN_PIT, REML=FALSE)
anova(mdl.PIT)


# STATS LMM -------------------------------------------------------------------

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))


# new ---------------------------------------------------------------------

#model selection #already tried the combination for trialxcondition in another script (we dont have enought to estimate variance)

mod5 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)
# mod6 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time:condition + condition + intervention|id) + (1|trialxcondition), data = OBIWAN_PIT , control=control)
# mod7 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time:condition + time + intervention|id) + (1|trialxcondition), data = OBIWAN_PIT , control=control)
# mod8 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time:condition + condition |id) + (1|trialxcondition), data = OBIWAN_PIT , control=control)
# mod9 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time:condition + time |id) + (1|trialxcondition), data = OBIWAN_PIT , control=control)
# mod10 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time:condition |id) + (1|trialxcondition), data = OBIWAN_PIT , control=control)
# mod11 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time+condition |id) + (1|trialxcondition), data = OBIWAN_PIT , control=control)
# mod12 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (condition |id) + (1|trialxcondition), data = OBIWAN_PIT , control=control)
# mod13 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time |id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)
# mod14 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (1 |id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)

#after it doesnt converge anymore

AIC(mod5) ; BIC(mod5) #keep it max
# AIC(mod6) ; BIC(mod6)
# AIC(mod7) ; BIC(mod7)
# AIC(mod8) ; BIC(mod8)
# AIC(mod9) ; BIC(mod9)
# AIC(mod10) ; BIC(mod10)
# AIC(mod11) ; BIC(mod11)
# AIC(mod12) ; BIC(mod12)
# AIC(mod13) ; BIC(mod13)
# AIC(mod14) ; BIC(mod14)



slope.model = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (1|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)
random.slope.model = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)
ranova(random.slope.model)
#there is statistically significant variation in slopes between individuals and trials, using the likelihood ratio test:


# create data frames containing residuals and fitted
# values for each model we ran above
a <-  data_frame(
  model = "random.slope",
  fitted = predict(random.slope.model),
  residual = residuals(random.slope.model))

b <- data_frame(
  model = "random.intercept",
  fitted = predict(slope.model),
  residual = residuals(slope.model))

# join the two data frames together
residual.fitted.data <- bind_rows(a,b)

# plots residuals against fitted values for each model
residual.fitted.data %>%
  ggplot(aes(fitted, residual)) +
  geom_point() +
  geom_smooth(se=F) +
  facet_wrap(~model)
#We can see that the residuals from the random slope model XX problem here ##
#the range of fitted values, which suggests that the assumption of homogeneity of variance is met in the random slope model

# extract the random effects from the model (intercept and slope)
ranef(random.slope.model)$id %>%
  # implicitly convert them to a dataframe and add a column with the subject number
  rownames_to_column(var=c("Subject")) %>%
  # plot the intercept and slobe values with geom_abline()
  ggplot(aes()) +
  geom_abline(aes(intercept=`(Intercept)`, slope=`timethird:conditionCSplus` , color=Subject)) +
  # add axis label
  xlab("Condition (Milkshake) * time (Post)") + ylab("Residual Liking") +
  # set the scale of the plot to something sensible
  scale_x_discrete(limits=c(0,100), expand=c(0,0)) +
  scale_y_continuous(limits=c(-4, 4))

#explicitly check this correlation (between individuals’ intercept and slope residuals)
VarCorr(random.slope.model)
#The correlation between the random intercept and slopes is pretty high, so we keep them


# #model selection #fixed REML FALSE sequential drop --------------------------------------


mod1 = lmer(gripsZ ~ condition*time*intervention    + gender + ageZ + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
mod2 = lmer(gripsZ ~ condition*time*intervention    + ageZ + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
mod3 = lmer(gripsZ ~ condition*time*intervention    + gender + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
mod4 = lmer(gripsZ ~ condition*time*intervention   + gender + ageZ  + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

mod7 = lmer(gripsZ ~ condition*time*intervention  + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)

AIC(mod7) ; BIC(mod7)  # keep it "simplle"


#CHECK ASSUMPTIONS: REML = TRUE -------------
mod = update(mod7, REML = TRUE)

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so no problem keeping everything

#2)Linearity    #3)Homoscedasticity AND #4)Normality of residuals

#super cool sjPlots for checking assumptions -> weird CS plut random effect curve
plot_model(mod, type = "diag")


#5) Absence of influential data points -> 238 & 234

#simple boxplots
boxplot(scale(ranef(mod)$id), las=2)  #outlier in CS plus

#disgnostic plots -> Cook's distance
set.seed(101)
im <- influence(mod,maxfun=100,  group="id")  #takes aa  WHILLLLE

infIndexPlot(im,col="steelblue",
             vars=c("cookd"))


# TEST marginal effects REML=F ---------------------------------------------------------
# guidelines of sequential drop 
# m0 <- lmer(Response ~ Y1 + X:Y1 + Y2 + X:Y2 + (XY|subj) + (XY|item),dat,REML=F)
# m1 <- lmer(Response ~ X*Y + (XY|subj) + (XY|item),dat,REML=F)

##TEST condition:intervention:time
full = mod7
#drop inter
null = lmer(gripsZ ~ condition + time + intervention  + condition:time + condition:intervention + time:intervention  + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.53
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -1.61
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

##TEST time:intervention 
full = lmer(gripsZ ~ condition + time + intervention  + condition:time + condition:intervention + time:intervention      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
#drop inter
null = lmer(gripsZ ~ condition + time + intervention  + condition:time + condition:intervention     + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.16
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -0.069
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

##TEST  condition:intervention
full = lmer(gripsZ ~ condition + time + intervention   + condition:time + condition:intervention + time:intervention      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
#drop inter
null = lmer(gripsZ ~ condition + time + intervention   + condition:time + time:intervention      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.21
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -0.43
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  + condition:time
full = lmer(gripsZ ~ condition + time + intervention   + condition:time + condition:intervention + time:intervention      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
#drop inter
null = lmer(gripsZ ~ condition + time + intervention   + time:intervention      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.41
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -2.21
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  intervention drop inter
full = lmer(gripsZ ~ condition + time + intervention   + condition:time      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
#drop main
null = lmer(gripsZ ~ condition + time + condition:time       + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.045
test = anova(full, null, test = "Chisq")
test

#Δ AIC = 2.02
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  time drop inter
full = lmer(gripsZ ~ condition + time + intervention  + condition:intervention     + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
#drop main
null = lmer(gripsZ ~ condition + intervention   + condition:intervention      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.24
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -0.64
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  condition drop inter
full = lmer(gripsZ ~ condition + time + intervention  + time:intervention      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
#drop main
null = lmer(gripsZ ~  time + intervention  + time:intervention      + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.052
PBtest.cond = PBmodcomp(full,null,nsim=500, seed = 101, details = 10)
PBtest.cond

#LRT    3.7688  1 0.05222 .
#PBtest 3.7688    0.06786 .

# test = anova(full, null, test = "Chisq")
# test

#Δ AIC =  1.77
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


#BF Due to the transitive property of Bayes factors, we can easily change the reference model to the main effects model #update(comparison, reference = 3)
#comparison <- bayesfactor_models(full, null, denominator = null) 
#comparison  # BF 

#EFFECT SIZES # R squared -> really debated though

#Compute the R2 statistic using Nakagawa and Schielzeth's approach
R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors cond = 0.002   0.0006    0.000
R2

#The ‘intercept’ of the lmer model is the mean PIT rate in CS+ coniditon for an average subject. 
summary(mod)

#get observed by ID
df.observed = ddply(OBIWAN_PIT, .(id, condition), summarise, fit = mean(gripsZ, na.rm = TRUE)) 

#helpful functions
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')

#set options 
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#drop inter so its quicker but doesnt change CI
model = lmer(gripsZ ~ condition+time+intervention + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)

#pred CI #takes a while!
pred1 = confint(emmeans(model,list(pairwise ~ condition)), level = .95, type = "response")
df.predicted = data.frame(pred1$`emmeans of condition`)

colnames(df.predicted) <- c("condition", "fit", "SE", "df", "lowCI", "uppCI")

#ploting
df_pred_MI  <- subset(df.predicted, condition == 'CSminus')
df_pred_PL  <- subset(df.predicted, condition == 'CSplus')

df_obs_MI  <- subset(df.observed, condition == 'CSminus')
df_obs_PL  <- subset(df.observed, condition == 'CSplus')

plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = condition, fill = condition)) +
  #left = CS-
  geom_left_violin(data = df_obs_MI, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_errorbar(data= df_pred_MI, aes(x = as.numeric(condition)+0.1, ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4)+
  geom_point(data = df_pred_MI, aes(x = as.numeric(condition)+0.1), shape = 18, color ="black") +
  #right = CS+
  geom_right_violin(data = df_obs_PL, alpha = .4, position = position_nudge(x = +0.5, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_errorbar(data= df_pred_PL, aes(x = as.numeric(condition)+0.4, ymax = lowCI, ymin = uppCI), width=0.1, alpha=1, size=0.4)+
  geom_point(data = df_pred_PL, aes(x = as.numeric(condition)+0.4,), color ="black", shape = 18) +
  #make it raaiiin
  geom_point(data = df.observed, aes(x = as.numeric(condition) +0.25), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = df.observed, aes(x = as.numeric(condition) +0.25, group=id),  color ="lightgrey", alpha=0.4,  
            position = position_jitter(width = 0.025, seed = 123)) 


plt1 =  plt +   #details
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-3,3, by = 1)), limits = c(-3,3)) +
  scale_fill_discrete(name = "condition", labels = c("CS-   ", "    CS+")) +
  scale_color_discrete(name = "condition", labels = c("CS-   ", "    CS+")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_blank(),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_blank(), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.4, -0.07),
        legend.title = element_blank(),
        legend.direction = "horizontal",
        legend.text=element_text(size=12),
        legend.spacing.x = unit(0.7, 'cm'),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs(  y = "Mobilized Effort (z)",
         caption = "\n \n \n \nError bars represent 95% CI for the estimated marginal means\n
        Marginal effect (p = 0.052, \u0394 AIC = 1.77, R\u00B2 = 0.02), N = 61") #r2 + 0.038   - 0.017 BF = 4350

plot(plt1)

cairo_pdf(file.path(figures_path,paste(task, 'MAIN_cond_Lira.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt1)
dev.off()


# intervention X condition ------------------------------------------------------------

#drop triple inter so its quicker but doesnt change CI
model = lmer(gripsZ ~ condition+time+intervention + condition:intervention + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)


#pred CI #takes aaa whiiile!
pred2 = confint(emmeans(model,list(pairwise ~ condition:intervention)), level = .95, type = "response")
df.predicted = data.frame(pred2$`emmeans of condition, intervention`)
colnames(df.predicted) <- c("condition", "intervention", "fit", "SE", "df", "lowCI", "uppCI")


#ploting
plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = intervention)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4, position = position_dodge(width = 0.5))+
  geom_line(aes(group=intervention), alpha=0.4,position = position_dodge(width = 0.5))


plt2 = plt +  #details
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-1,1, by = 0.5)), limits = c(-1,1)) +
  scale_color_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
  scale_x_discrete(labels=c("CSminus" = "CS-", "CSplus" = "CS+")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0.1))) +
  theme_classic() +
  theme(plot.margin = unit(c(1.5, 1, 1.2, 1), units = "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=12,  colour = "black"),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_blank(), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.525, 1.1), legend.title=element_blank(),
        legend.direction = "horizontal",
        legend.text=element_text(size=12),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( #x = "\nSolution", 
    y = "Mobilized Effort (z)",
    caption = "\n \nError bars represent 95% CI for the estimated marginal means\n
        Placebo (N = 30), Liraglutide (N = 31)\n
        Two-way interaction (p = 0.21, \u0394 AIC = -0.43)") 

plot(plt2)

# plac = subset(OBIWAN_PIT, intervention == '0')
# lira = subset(OBIWAN_PIT, intervention == '1')
# n_plac = length(unique(plac$id))
# n_lira = length(unique(lira$id))


cairo_pdf(file.path(figures_path,paste(task, 'condXgroup_Lira.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt2)
dev.off()


# interventionxconditionxtime ---------------------------------------------

model = lmer(gripsZ ~ condition*time*intervention + (time*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)

#pred CI #takes aaa whiiile!
pred3 = confint(emmeans(model,list(pairwise ~ intervention:condition:time)), level = .95, type = "response")
df.predicted = data.frame(pred3$`emmeans of intervention, condition, time`)

colnames(df.predicted) <- c("intervention", "condition", "time",  "fit", "SE", "df", "lowCI", "uppCI")

#custom contrast
con <- list(
  c1 = c(0, 0, 0, 0, 1, -1, 0, 0), #Post: CS- Placebo > CS- Lira
  c2 = c(0, 0, 0, 0, 0, 0, 1, -1), #Post: CS+ Placebo > CS+ Lira
  c3 = c(0, 0, 1, -1, 0, 0, 0, 0), #Pre: CS+ Placebo > CS+ Lira
  c4 = c(1, -1, 0, 0, 0, 0, 0, 0) #Pre: CS- Placebo > CS- Lira
)

#takes a while
cont = emmeans(model, ~ intervention:condition:time, contr = con, adjust = "mvt")

#ploting 
labels <- c(second = "Pre-Test", third = "Post-Test")

plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = intervention)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4, position = position_dodge(width = 0.5))+
  geom_line(aes(group=intervention), alpha=0.4,position = position_dodge(width = 0.5)) + 
  facet_wrap(~ time, labeller=labeller(time = labels))


plt3 = plt +  #details
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-1,1, by = 0.5)), limits = c(-1,1)) +
  scale_color_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
  scale_x_discrete(labels=c("CSminus" = "CS-", "CSplus" = "CS+")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0.1))) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x =  element_blank(), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.475, -0.20), legend.title=element_blank(),
        legend.direction = "horizontal",
        #legend.spacing.x = unit(1, 'cm'),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(     y = "Mobilized Effort (z)",
        caption = "\n \n \n \n \nThree-way interaction, p = 0.53, \u0394 AIC = -1.61\n
        Post-test (Placebo): CS+  > Post-test (Liraglutide): CS+, p = 0.028\n
        Post-hoc test adjusted for multiple comparison using MVT method\n
        Main effect of condition, p = 0.052, \u0394 AIC = 1.77, R\u00B2 = 0.002\n
        Error bars represent 95% CI for the estimated marginal means\n
        Placebo (N = 29), Liraglutide (N = 32)\n
        LMM : Effort ~ Condition*Time*Treatment + (Time*Condition|Id) + (1|Trial)\n
        Controling for Age, Gender & Weight Loss (BMI pre - BMI post)")

plot(plt3)


cairo_pdf(file.path(figures_path,paste(task, 'condXtreatXtime_Lira.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt3)
dev.off()

# 
# #P values associated with pairwise comparisons of estimated marginal means.
# cells <- emmeans(model, ~ intervention:condition:time)
# 
# cont = emmeans(model, ~ intervention:condition:time,  at = list(time = c("third") ) )
# 
# 
# cells <- emmeans(model, ~ intervention:condition:time)
# 
# #labels <- c(condition: CSminus= "CS-", condition: CSplus= "CS+")
# #side = ">"
# plt = pwpp(cells, type = "response", by =  "condition", sort = FALSE)
# 
# plt4 = plt +  #details
#   scale_y_discrete(labels=c("Placebo Post-Test" = "Placebo Pre-Test", "Liraglutide Pre-Test" = "Liraglutide Post-Test")) +
#   #scale_color_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
#   #scale_x_discrete(labels=c("CSminus" = "CS-", "CSplus" = "CS+")) + 
#   guides(fill = guide_legend(override.aes = list(alpha = 0.1))) +
#   theme_bw() +
#   theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
#         panel.grid.major.x = element_blank() ,
#         panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
#         axis.text.x = element_text(size=10,  colour = "black", vjust = 0.5),
#         axis.text.y = element_text(size=12,  colour = "black"),
#         axis.title.x =  element_blank(), 
#         axis.title.y = element_text(size=16),   
#         legend.position = c(0.475, -0.15), legend.title=element_blank(),
#         legend.direction = "horizontal",
#         #legend.spacing.x = unit(1, 'cm'),
#         axis.ticks.x = element_blank(), 
#         axis.line.x = element_blank(),
#         strip.background = element_rect(fill="white"))+ 
#   labs(     y = "Mobilized Effort (z)",
#             caption = "\n \n \n \n \nError bars represent 95% CI for the estimated marginal means\n
#         Placebo (N = 29), Liraglutide (N = 32)\n
#         Three-way interaction (p = 0.53, \u0394 AIC = -1.61)")
# 
# plot(plt4)



