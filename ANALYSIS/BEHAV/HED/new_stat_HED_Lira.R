## R code for FOR HED Obese
# last modified on April 2020 by David MUNOZ
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, ggplot2, Rmisc, dplyr, lmerTest, car, afex, r2glmm, optimx, visreg, MuMIn,  pbkrtest, bootpredictlme4, sjPlot, emmeans, bayestestR)

#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$id      <- as.factor(info$id)

#subset
HED  <- subset(HED_full, group == 'obese') #only group obese 

# define as.factors
HED$id      <- as.factor(HED$id)
HED$trial    <- as.factor(HED$trial)
HED$group    <- as.factor(HED$group)
HED$condition <- as.factor(HED$condition)
HED$time    <- as.factor(HED$session)

HED$trialxcondition <- as.factor(HED$trialxcondition)

HED = full_join(HED, info, by = "id")

HED <-HED %>% drop_na("condition")

HED  <- subset(HED, id != 242 & id != 256 & id != 234) #234 only have third session

HED$gender   <- as.factor(HED$gender) #M=0
HED$intervention   <- as.factor(HED$intervention) #blind

n_tot = length(unique(HED$id))

#check
bs = ddply(HED, .(id, session), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 


# QUICK STATS -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#scale everything
HED$likZ= scale(HED$perceived_liking)
HED$famZ = scale(HED$perceived_familiarity)
HED$intZ = scale(HED$perceived_intensity)
HED$ageZ = hscale(HED$age, HED$id) #agragate by subj and then scale 

#create BMI diff #double check
HED$diff_Z = hscale(HED$BMI_t1 - HED$BMI_t2, HED$id)
HED$bmi_T0 = hscale(HED$BMI_t1, HED$id)


#************************************************** quick anova test (BAD) aov_4 only allows one random effect term
#remove Missing values for following ID(s):
#c(201, 208, 210, 214, 216, 219, 222, 223, 233, 240, 245, 247, 249, 258, 263, 267)
HED_test <-  HED[!HED$id %in% c("201", "208", "210", "214", "216", "219", "222", "223", "233", "240", "245", "247", "249", "258", "263", "267"), ] #, 208, "210", "214", "216", "219", "222", "223", "233", "240", "245", "247", "249", "258", "263", "267")) #all  that didnt have Post test

#scale everything
HED_test$likZ= scale(HED_test$perceived_liking)
HED_test$famZ = scale(HED_test$perceived_familiarity)
HED_test$intZ = scale(HED_test$perceived_intensity)
HED_test$ageZ = hscale(HED_test$age, HED_test$id) #agragate by subj and then scale 

#create BMI diff #double check
HED_test$diff_Z = hscale(HED_test$BMI_t1 - HED_test$BMI_t2, HED_test$id)
HED_test$bmi_T0 = hscale(HED_test$BMI_t1, HED_test$id)

mdl.aov = aov_4(likZ ~ condition*time*intervention + gender + ageZ + bmi_T0 + (time*condition|id) , 
                   data = HED_test, observed = c("gender", "ageZ", "bmi_T0"), factorize = FALSE, fun_aggregate = mean)
summary(mdl.aov)

#VS LMER
mdl.lmm = mixed(likZ ~ condition*time*intervention + gender + ageZ + bmi_T0 + (time*condition|id) , 
                data = HED_test, method = "PB", args.test = list(nsim = 100))
summary(mdl.lmm)


# STATS LMM -------------------------------------------------------------------

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))


# new ---------------------------------------------------------------------

#scale everything
HED_test$likZ= scale(HED_test$perceived_liking)
HED_test$famZ = scale(HED_test$perceived_familiarity)
HED_test$intZ = scale(HED_test$perceived_intensity)
HED_test$ageZ = hscale(HED_test$age, HED_test$id) #agragate by subj and then scale 

#create BMI diff #double check
HED_test$diff_Z = hscale(HED_test$BMI_t1 - HED_test$BMI_t2, HED_test$id)
HED_test$bmi_T0 = hscale(HED_test$BMI_t1, HED_test$id)



#model selection #already tried the combination for trialxcondition in another script (we dont have enought to estimate variance)



mod1 = lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(time*condition|id) , 
            data = HED, control = control)

mod2 = lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ*intZ +(time*condition+famZ|id) , 
            data = HED, control = control)

mod3 = lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ*intZ +(time*condition+intZ|id) , 
            data = HED, control = control)

mod4 = lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ*intZ +(time*condition+famz+intZ|id) , 
            data = HED, control = control)

mod5 = lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ*intZ +(time*condition+famZ*intZ|id) , 
            data = HED, control = control)

mod6 = lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ*intZ +(time*condition+famZ*intZ|id) + (1|trialxcondition), 
            data = HED, control = control) #were are hiting the singular fit already 

#mod7 = lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ*intZ +(time*condition*famZ*intZ|id) + (1|trialxcondition), 
            #data = HED, control = control) #here its a mess



AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)
AIC(mod5) ; BIC(mod5) 
AIC(mod6) ; BIC(mod6) # keep it max

#---

mod11 = lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ*intZ +(time*condition+famZ*intZ|id) + (1|trialxcondition), 
            data = HED, control = control, REML = FALSE) 

mod21 = lmer(likZ ~ condition*time*intervention*famZ*intZ + gender + ageZ + diff_bmiZ +(time*condition+famZ*intZ|id) + (1|trialxcondition), 
            data = HED, control = control, REML = FALSE) 

mod31 = lmer(likZ ~ condition*time*intervention*famZ + intZ + famZ:intZ + gender + ageZ + diff_bmiZ +(time*condition+famZ*intZ|id) + (1|trialxcondition), 
             data = HED, control = control, REML = FALSE) 

AIC(mod11) ; BIC(mod11)  #largely the best BIC
AIC(mod21) ; BIC(mod21)
AIC(mod31) ; BIC(mod31)

#OUT bc degenerated hessian mod1 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*intervention*condition|id), data = HED)
#OUT bc degenerated hessian mod2 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*intervention+condition|id), data = HED)
#OUT bc degenerated hessian mod3 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time+intervention*condition|id), data = HED)
#OUT bc degenerated hessian  mod4 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition+intervention|id)  + (1|trialxcondition), data = HED, control=control)
# mod5 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition|id) + (1|trialxcondition), data = HED, control=control)
# mod6 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time:condition + condition + intervention|id) + (1|trialxcondition), data = HED , control=control)
# mod7 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time:condition + time + intervention|id) + (1|trialxcondition), data = HED , control=control)
# mod8 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time:condition + condition |id) + (1|trialxcondition), data = HED , control=control)
# mod9 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time:condition + time |id) + (1|trialxcondition), data = HED , control=control)
#OUT bc degenerated hessian mod10 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time:condition |id) + (1|trialxcondition), data = HED , control=control)
# mod11 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time+condition |id) + (1|trialxcondition), data = HED , control=control)
# mod12 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (condition |id) + (1|trialxcondition), data = HED , control=control)
# mod13 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time |id) + (1|trialxcondition), data = HED, control=control)
# mod14 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (1 |id) + (1|trialxcondition), data = HED, control=control)
# mod15 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition+perceived_familiarity|id) + (1|trialxcondition), data = HED, control=control)
# mod16 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition+perceived_intensity|id) + (1|trialxcondition), data = HED, control=control)
# mod17 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control)
mod18 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control)
#mod19 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition+perceived_familiarity*condition|id) + (1|trialxcondition), data = HED, control=control)

#after it doesnt converge anymore

# AIC(mod4) ; BIC(mod4)
# AIC(mod5) ; BIC(mod5) 
# AIC(mod6) ; BIC(mod6)
# AIC(mod7) ; BIC(mod7)
# AIC(mod8) ; BIC(mod8)
# AIC(mod9) ; BIC(mod9)
# AIC(mod10) ; BIC(mod10)
# AIC(mod11) ; BIC(mod11)
# AIC(mod12) ; BIC(mod12)
# AIC(mod13) ; BIC(mod13)
# AIC(mod14) ; BIC(mod14)
# AIC(mod15) ; BIC(mod15)
# AIC(mod16) ; BIC(mod16)
# AIC(mod17) ; BIC(mod17)
AIC(mod18) ; BIC(mod18) # keep it max
#AIC(mod19) ; BIC(mod19) 


slope.model = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (1|id) + (1|trialxcondition), data = HED, control=control)
random.slope.model = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control)
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
#We can see that the residuals from the random slope model are much more evenly distributed across 
#the range of fitted values, which suggests that the assumption of homogeneity of variance is met in the random slope model

# extract the random effects from the model (intercept and slope)
ranef(random.slope.model)$id %>%
  # implicitly convert them to a dataframe and add a column with the subject number
  rownames_to_column(var=c("Subject")) %>%
  # plot the intercept and slobe values with geom_abline()
  ggplot(aes()) +
  geom_abline(aes(intercept=`(Intercept)`, slope=`timethird:conditionMilkShake` , color=Subject)) +
  # add axis label
  xlab("Condition (Milkshake) * time (Post)") + ylab("Residual Liking") +
  # set the scale of the plot to something sensible
  scale_x_discrete(limits=c(0,100), expand=c(0,0)) +
  scale_y_continuous(limits=c(-4, 4))

#explicitly check this correlation (between individuals’ intercept and slope residuals)
VarCorr(random.slope.model)
#The correlation between the random intercept and slopes is pretty high, so we keep them




# #model selection #fixed REML FALSE sequential drop --------------------------------------


# mod1 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + ageZ + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
# mod2 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + ageZ + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
# mod3 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity +  bmi_diff + gender + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
# mod4 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity + gender + ageZ  + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

mod7 = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity   + perceived_intensity +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

# AIC(mod1) ; BIC(mod1)
# AIC(mod2) ; BIC(mod2)
# AIC(mod3) ; BIC(mod3)
# AIC(mod4) ; BIC(mod4)

AIC(mod7) ; BIC(mod7)  # keep it "simplle"


#CHECK ASSUMPTIONS: REML = TRUE -------------
mod = update(mod7, REML = TRUE)

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so no problem keeping everything

#2)Linearity    #3)Homoscedasticity AND #4)Normality of residuals

#super cool sjPlots for checking assumptions -> not bad
plot_model(mod, type = "diag")


#5) Absence of influential data points -> 228 & 235

#simple boxplots
boxplot(scale(ranef(mod)$id), las=2)

#disgnostic plots -> Cook's distance
set.seed(101)
# im <- influence(mod,maxfun=100,  group="id")  #takes aa  WHILLLLE
# 
# infIndexPlot(im,col="steelblue",
#              vars=c("cookd"))


# TEST marginal effects ---------------------------------------------------------
# guidelines of sequential drop 
# m0 <- lmer(Response ~ Y1 + X:Y1 + Y2 + X:Y2 + (XY|subj) + (XY|item),dat,REML=F)
# m1 <- lmer(Response ~ X*Y + (XY|subj) + (XY|item),dat,REML=F)

##TEST condition:intervetion:time
full = mod7
#drop inter
null = lmer(perceived_liking ~ condition + time + intervention  + condition:time + condition:intervention + time:intervention + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

#LR test for condition inter p = 0.73
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -1.88
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

##TEST time:intervention 
full = lmer(perceived_liking ~ condition + time + intervention  + condition:time + condition:intervention + time:intervention  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~ condition + time + intervention  + condition:time + condition:intervention + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

#LR test for condition inter p = 0.06
test = anova(full, null, test = "Chisq")
test

#Δ AIC = 1.54
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  condition:intervention
full = lmer(perceived_liking ~ condition + time + intervention   + condition:time + condition:intervention + time:intervention  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~ condition + time + intervention   + condition:time + time:intervention  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

#LR test for condition inter p = 0.39
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -1.26
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  + condition:time
full = lmer(perceived_liking ~ condition + time + intervention   + condition:time + condition:intervention + time:intervention  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~ condition + time + intervention   + time:intervention  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

#LR test for condition inter p = 0.13
test = anova(full, null, test = "Chisq")
test

#Δ AIC = 0.15
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  intervention drop inter
full = lmer(perceived_liking ~ condition + time + intervention   + condition:time  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
#drop main
null = lmer(perceived_liking ~ condition + time + condition:time   + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

#LR test for condition inter p = 0.97
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -2.00
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC



##TEST  time drop inter
full = lmer(perceived_liking ~ condition + time + intervention  + condition:intervention + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
#drop main
null = lmer(perceived_liking ~ condition + intervention   + condition:intervention  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

#LR test for condition inter p = 0.14
test = anova(full, null, test = "Chisq")
test

#Δ AIC = 0.17
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  condition drop inter
full = lmer(perceived_liking ~ condition + time + intervention  + time:intervention  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)
#drop main
null = lmer(perceived_liking ~  time + intervention  + time:intervention  + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control, REML = FALSE)

#LR test for condition inter p < 0.0001
test = anova(full, null, test = "Chisq")
test

#Δ AIC = 23.02
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


#BF Due to the transitive property of Bayes factors, we can easily change the reference model to the main effects model #update(comparison, reference = 3)
comparison <- bayesfactor_models(full, null, denominator = null) 
comparison  # BF = 8840

#EFFECT SIZES # R squared -> really debated though

#Compute the R2 statistic using Nakagawa and Schielzeth's approach
R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors cond = 0.030    0.042    0.021

#The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 
summary(mod)


#get observed by ID
df.observed = ddply(HED, .(id, condition), summarise, fit = mean(perceived_liking, na.rm = TRUE)) 

#drop inter so the bootstrpping is faster but doesnt change CI
model = lmer(perceived_liking ~ condition + time + intervention   + perceived_familiarity  +  bmi_diff + (time*condition+perceived_familiarity*condition|id) + (1|trialxcondition), data = HED, control=control)

#set options 
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#pred CI #takes aaa whiiile!
pred1 = confint(emmeans(model,list(pairwise ~ condition)), level = .95, type = "response")
df.predicted = data.frame(pred1$`emmeans of condition`)

colnames(df.predicted) <- c("condition", "fit", "SE", "df", "lowCI", "uppCI")

#ploting
df_pred_EM  <- subset(df.predicted, condition == 'Empty')
df_pred_MS  <- subset(df.predicted, condition == 'MilkShake')

df_obs_EM  <- subset(df.observed, condition == 'Empty')
df_obs_MS  <- subset(df.observed, condition == 'MilkShake')

#helpful functions
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')


plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = condition, fill = condition)) +
  #left = empty
  geom_left_violin(data = df_obs_EM, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_pred_EM, aes(x = as.numeric(condition)+0.1), shape = 18, color ="black") +
  geom_errorbar(data= df_pred_EM, aes(x = as.numeric(condition)+0.1, ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4)+
  #right = milkshake
  geom_right_violin(data = df_obs_MS, alpha = .4, position = position_nudge(x = +0.5, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = df_pred_MS, aes(x = as.numeric(condition)+0.4,), color ="black", shape = 18) +
  geom_errorbar(data= df_pred_MS, aes(x = as.numeric(condition)+0.4, ymax = lowCI, ymin = uppCI), width=0.1, alpha=1, size=0.4)+
  #make it raaiiin
  geom_point(data = df.observed, aes(x = as.numeric(condition) +0.25), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = df.observed, aes(x = as.numeric(condition) +0.25, group=id),  color ="lightgrey", alpha=0.4,  
            position = position_jitter(width = 0.025, seed = 123)) 


plt1 =  plt +   #details
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-2,2, by = 1)), limits = c(-2,2)) +
  scale_fill_discrete(name = "condition", labels = c("Tasteless Solution", "Milkshake")) +
  scale_color_discrete(name = "condition", labels = c("Tasteless Solution", "Milkshake")) + 
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
  labs(  y = "Plesantness Ratings (z)",
         caption = "\n \n \n \nError bars represent 95% CI for the estimated marginal means\n
        Marginal effect (p < 0.0001, \u0394 AIC = 23.02, R\u00B2 = 0.030), N = 61") #r2 + c  0.042   - 0.021

plot(plt1)


cairo_pdf(file.path(figures_path,paste(task, 'Liking_MAIN_cond.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt1)
dev.off()


# intervention X condition ------------------------------------------------------------
model = lmer(perceived_liking ~ condition + time + intervention   + perceived_familiarity + perceived_intensity  +  bmi_diff + intervention:condition + (time*condition+perceived_familiarity*perceived_intensity|id) + (1|trialxcondition), data = HED, control=control)

#pred CI #takes aaa whiiile!
pred2 = confint(emmeans(model,list(pairwise ~ intervention:condition)), level = .95, type = "response")
df.predicted = data.frame(pred2$`emmeans of intervention, condition`)
colnames(df.predicted) <- c("intervention", "condition", "fit", "SE", "df", "lowCI", "uppCI")


#ploting
plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = intervention)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4, position = position_dodge(width = 0.5))+
  geom_line(aes(group=intervention), alpha=0.4,position = position_dodge(width = 0.5))


plt2 = plt +  #details
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-1,1, by = 0.5)), limits = c(-1,1)) +
  scale_color_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
  scale_x_discrete(labels=c("Empty" = "Tasteless", "MilkShake" = "Milkshake")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0.1))) +
  theme_classic() +
  theme(plot.margin = unit(c(1.5, 1, 1.2, 1), units = "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=12,  colour = "black"),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.525, 1.1), legend.title=element_blank(),
        legend.direction = "horizontal",
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( x = "\nSolution", 
        y = "Plesantness Ratings (z)",
        caption = "\n \nError bars represent 95% CI for the estimated marginal means\n
        Placebo (N = 29), Liraglutide (N = 32)\n
        Two-way interaction (p = 0.39, \u0394 AIC = -1.26)")

plot(plt2)

# plac = subset(HED, intervention == '0')
# lira = subset(HED, intervention == '1')
# n_plac = length(unique(plac$id))
# n_lira = length(unique(lira$id))


cairo_pdf(file.path(figures_path,paste(task, 'Liking_condXtreat.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt2)
dev.off()



# interventionxconditionxtime ---------------------------------------------

model = lmer(perceived_liking ~ condition*time*intervention + perceived_familiarity + perceived_intensity  +  bmi_diff + (time*condition|id) + (1|trialxcondition), data = HED, control=control)

#pred CI #takes aaa whiiile!
pred3 = confint(emmeans(model,list(pairwise ~ intervention:condition:time)), level = .95, type = "response")
df.predicted = data.frame(pred3$`emmeans of intervention, condition, time`)

colnames(df.predicted) <- c("intervention", "condition", "time",  "fit", "SE", "df", "lowCI", "uppCI")

#custom contrast
con <- list(
  c1 = c(0, 0, 0, 0, 1, -1, 0, 0), #Post: empty Placebo > empty- Lira
  c2 = c(0, 0, 0, 0, 0, 0, 1, -1), #Post: MS Placebo > MS Lira
  c3 = c(0, 0, 1, -1, 0, 0, 0, 0), #Pre: MS Placebo > MS Lira
  c4 = c(1, -1, 0, 0, 0, 0, 0, 0) #Pre: empty Placebo > empty Lira
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
        legend.direction = "horizontal",
        #legend.spacing.x = unit(1, 'cm'),
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

cairo_pdf(file.path(figures_path,paste(task, 'Liking_condXtreatXtime_Lira.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt3)
dev.off()



