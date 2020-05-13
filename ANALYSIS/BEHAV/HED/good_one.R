## R code for FOR OBIWAN_HED Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, ggplot2, Rmisc, dplyr, lmerTest, car, r2glmm, optimx, visreg, MuMIn,  pbkrtest, bootpredictlme4, sjPlot)
#lme4
#Influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, Bayesas.factor)

#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$id      <- as.factor(info$id)

#subset
OBIWAN_HED  <- subset(OBIWAN_HED_full, group == 'obese') #only group obese 

# define as.factors
OBIWAN_HED$id      <- as.factor(OBIWAN_HED$id)
OBIWAN_HED$trial    <- as.factor(OBIWAN_HED$trial)
OBIWAN_HED$group    <- as.factor(OBIWAN_HED$group)
OBIWAN_HED$condition <- as.factor(OBIWAN_HED$condition)

OBIWAN_HED$trialxcondition <- as.factor(OBIWAN_HED$trialxcondition)

OBIWAN_HED = full_join(OBIWAN_HED, info, by = "id")

OBIWAN_HED <-OBIWAN_HED %>% drop_na("condition")

OBIWAN_HED  <- subset(OBIWAN_HED, id != 242 & id != 256)

OBIWAN_HED$gender   <- as.factor(OBIWAN_HED$gender) #M=0
OBIWAN_HED$intervention   <- as.factor(OBIWAN_HED$intervention) #blind

n_tot = length(unique(OBIWAN_HED$id))

#missing data.. for now I will just keep th participant that have both session

second = subset(OBIWAN_HED, session == 'second')
third = subset(OBIWAN_HED, session == 'third')
n_sec = length(unique(second$id))
n_thi = length(unique(third$id))

a = unique(second$id)
b = unique(third$id)
match = intersect(a,b)  #get subject that have done both session!

n_clean = length(match)

OBIWAN_HED = filter(OBIWAN_HED, id %in% match) # filter n = 47 now

bsC= ddply(OBIWAN_HED, .(id, session, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 


# QUICK STATS -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#scale everything
OBIWAN_HED$perceived_liking= scale(OBIWAN_HED$perceived_liking)
OBIWAN_HED$perceived_familiarity = scale(OBIWAN_HED$perceived_familiarity)
OBIWAN_HED$perceived_intensity = scale(OBIWAN_HED$perceived_intensity)
OBIWAN_HED$ageZ = hscale(OBIWAN_HED$age, OBIWAN_HED$id) #agragate by subj and then scale 

#create BMI diff #double check
OBIWAN_HED$bmi_diff = OBIWAN_HED$BMI_t1 - OBIWAN_HED$BMI_t2 
OBIWAN_HED$bmi_diff_z = hscale(OBIWAN_HED$bmi_diff , OBIWAN_HED$id) #agregate by subj and then scale 


#************************************************** test (BAD)
mdl.liking = lmer(perceived_liking ~ condition*session*intervention + trialxcondition + bmi_diff_z + gender + ageZ + (condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.liking)


# STATS LMM -------------------------------------------------------------------

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))


#random intercept id
slope.model <- lmer(perceived_liking ~  condition  + (1|id) , data = OBIWAN_HED)
anova(slope.model)


#plot
bsC= ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

bsC %>%
  ggplot(aes(condition, perceived_liking, group=id, color=id)) +
  geom_smooth(method="lm", se=F) +
  geom_jitter(size=1) +
  theme_minimal()

#test whether there was significant variation in the effects of condition between subjects, 
#by adding a random slope to the model.

#random slope cond
random.slope.model <- lmer(perceived_liking ~  condition  + (condition|id) , data = OBIWAN_HED)

ranova(random.slope.model)
#there is statistically significant variation in slopes between individuals, using the likelihood ratio test:


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
  geom_abline(aes(intercept=`(Intercept)`, slope=conditionMilkShake, color=Subject)) +
  # add axis label
  xlab("Condition (Milkshake)") + ylab("Residual Liking") +
  # set the scale of the plot to something sensible
  #scale_x_discrete(limits=c(0,0), expand=c(0,0)) +
  scale_y_continuous(limits=c(-2, 2))

#explicitly check this correlation (between individuals’ intercept and slope residuals)
VarCorr(random.slope.model)
#The correlation between the random intercept and slopes is -0.64 so pretty high, we keep it!


#drop and update to ML to get LRT
drop1(update(random.slope.model, REML = F), test = "Chisq")

#The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 
summary(random.slope.model)

#then  deriv CI
confint(random.slope.model, level = 0.95)
#The 5th term is the CI for liking within an average subject. 
#The next term correspond to the difference in liking for the Milkshake conidtion, 
#relative to the mapty condition. Each of these effects are statistically significantly 
#different to the baseline (empty) at the 5% level (does not contain 0)


## COMPARING RANDOM EFFECTS MODELS #REML = TRUE (commented out to run faster) -------------------
OBIWAN_HED$id      <- as.factor(OBIWAN_HED$id)
OBIWAN_HED$condition <- as.factor(OBIWAN_HED$condition)

## new data to predict to
newdata <- expand.grid(
  condition = levels(OBIWAN_HED$condition),
  id = levels(OBIWAN_HED$id)
)

## prediction function to use in bootstrap routine
predFun <- function(mod) {
  predict(mod, newdata = newdata, re.form = NA)
}

## produce 1000 bootstrapped samples
boot1 <- bootMer(random.slope.model, predFun, nsim = 100, type = "parametric", re.form = NA)

## function to produce percentile based CIs
sumBoot <- function(merBoot) {
  data.frame(
    perceived_liking = apply(merBoot$t, 2, function(x){  #change here
      mean(x, na.rm = T)
    }),
    lci = apply(merBoot$t, 2, function(x){
      quantile(x, probs = 0.025, na.rm = T)
    }),
    uci = apply(merBoot$t, 2, function(x){
      quantile(x, probs = 0.975, na.rm = T)
    })
  )
}

## bind CIs to newdata to get predicted with CI for plotting
CI_pred <- cbind(newdata, sumBoot(boot1))



# new ---------------------------------------------------------------------
#model selection
#OUTmod1 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session*intervention*condition|id), data = OBIWAN_HED)
#OUTmod2 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session*intervention+condition|id), data = OBIWAN_HED)
#OUTmod3 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session+intervention*condition|id), data = OBIWAN_HED)
# mod4 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session*condition+intervention|id), data = OBIWAN_HED)
mod5 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED)
# mod6 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session:condition + condition + intervention|id), data = OBIWAN_HED)
# mod7 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session:condition + session + intervention|id), data = OBIWAN_HED)
# mod8 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session:condition + condition |id), data = OBIWAN_HED)
# mod9 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session:condition + session |id), data = OBIWAN_HED)
# mod10 = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session:condition |id), data = OBIWAN_HED)


# AIC(mod4) ; BIC(mod4)
AIC(mod5) ; BIC(mod5) #
# AIC(mod6) ; BIC(mod6)
# AIC(mod7) ; BIC(mod7)
# 
# AIC(mod8) ; BIC(mod8)
# AIC(mod9) ; BIC(mod9) 
# AIC(mod10) ; BIC(mod10)


slope.model = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (1|id), data = OBIWAN_HED)
random.slope.model = mod5
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
  geom_abline(aes(intercept=`(Intercept)`, slope=sessionthird , color=Subject)) +
  # add axis label
  xlab("Condition (Milkshake)") + ylab("Residual Liking") +
  # set the scale of the plot to something sensible
  #scale_x_discrete(limits=c(0,0), expand=c(0,0)) +
  scale_y_continuous(limits=c(-2, 2))

ranef(random.slope.model)$id %>%
  # implicitly convert them to a dataframe and add a column with the subject number
  rownames_to_column(var=c("Subject")) %>%
  # plot the intercept and slobe values with geom_abline()
  ggplot(aes()) +
  geom_abline(aes(intercept=`(Intercept)`, slope=sessionthird , color=Subject)) +
  # add axis label
  xlab("Session (Post)") + ylab("Residual Liking") +
  # set the scale of the plot to something sensible
  scale_x_discrete(limits=c(0,100), expand=c(0,0)) +
  scale_y_continuous(limits=c(-4, 4))

ranef(random.slope.model)$id %>%
  # implicitly convert them to a dataframe and add a column with the subject number
  rownames_to_column(var=c("Subject")) %>%
  # plot the intercept and slobe values with geom_abline()
  ggplot(aes()) +
  geom_abline(aes(intercept=`(Intercept)`, slope=conditionMilkShake , color=Subject)) +
  # add axis label
  xlab("Condition (Milkshake)") + ylab("Residual Liking") +
  # set the scale of the plot to something sensible
  scale_x_discrete(limits=c(0,100), expand=c(0,0)) +
  scale_y_continuous(limits=c(-4, 4))

ranef(random.slope.model)$id %>%
  # implicitly convert them to a dataframe and add a column with the subject number
  rownames_to_column(var=c("Subject")) %>%
  # plot the intercept and slobe values with geom_abline()
  ggplot(aes()) +
  geom_abline(aes(intercept=`(Intercept)`, slope=`sessionthird:conditionMilkShake` , color=Subject)) +
  # add axis label
  xlab("Condition (Milkshake) * Session (Post)") + ylab("Residual Liking") +
  # set the scale of the plot to something sensible
  scale_x_discrete(limits=c(0,100), expand=c(0,0)) +
  scale_y_continuous(limits=c(-4, 4))

#explicitly check this correlation (between individuals’ intercept and slope residuals)
VarCorr(random.slope.model)
#The correlation between the random intercept and slopes is pretty high, so we keep them


# testing effects ---------------------------------------------------------

# m0 <- lmer(Response ~ Y1 + X:Y1 + Y2 + X:Y2 + (XY|subj) + (XY|item),dat,REML=F)
# m1 <- lmer(Response ~ X*Y + (XY|subj) + (XY|item),dat,REML=F)

##TEST condition:intervetion:session
full = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention + session:intervention:condition +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention  +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)

#LR test for condition inter p = 0.09
test = anova(full, null, test = "Chisq")
test
#Δ AIC = 0.72 
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

##TEST  session:intervention
full = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention + session:intervention  +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention  +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)

#LR test for condition inter p = 0.46
test = anova(full, null, test = "Chisq")
test
#Δ AIC = -1.47 
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  condition:intervention
full = lmer(perceived_liking ~ condition + session + intervention + trialxcondition  + condition:intervention  +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~ condition + session + intervention + trialxcondition   +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)

#LR test for condition inter p = 0.84
test = anova(full, null, test = "Chisq")
test
#Δ AIC = -1.96 
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

##TEST  + intervention
full = lmer(perceived_liking ~ condition + session + intervention + trialxcondition   +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~ condition + session  + trialxcondition   +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)

#LR test for condition inter p = 0.91
test = anova(full, null, test = "Chisq")
test
#Δ AIC =  -1.99
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


##TEST  + session
full = lmer(perceived_liking ~ condition + session + intervention + trialxcondition   +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~ condition  + intervention +  trialxcondition   +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)

#LR test for condition inter p = 0.153
test = anova(full, null, test = "Chisq")
test
#Δ AIC =  0.041 
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

##TEST  + condition
full = lmer(perceived_liking ~ condition + session + intervention + trialxcondition   +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)
#drop inter
null = lmer(perceived_liking ~session + intervention +  trialxcondition   +  bmi_diff_z + gender + ageZ + (session*condition|id), data = OBIWAN_HED, REML = FALSE)

#LR test for condition inter p <  0.0001
test = anova(full, null, test = "Chisq")
test
#Δ AIC =  17.9 -> evidence for model with condition
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


#The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 
summary(random.slope.model)


#The 5th term is the CI for liking within an average subject. 
#The next term correspond to the difference in liking for the Milkshake conidtion, 
#relative to the mapty condition. Each of these effects are statistically significantly 
#different to the baseline (empty) at the 5% level (does not contain 0)

dat <- ggeffects::ggpredict(
  model = random.slope.model,
  terms = c("condition"),
  ci.lvl = 0.95,
  type = "fe")

library(bootpredictlme4)
pred = predict(random.slope.model, newdata=OBIWAN_HED, re.form=NA, se.fit=TRUE, nsim = 50) #or options(bootnsim = 500)

confint(random.slope.model, level = 0.95,
        method = "boot",
        nsim = 50,
        boot.type = "perc")


model = random.slope.model

## new data to predict condition with all other predictor fixed to intercept
newdata <- expand.grid(
  condition = levels(OBIWAN_HED$condition),
  session = "second",
  intervention = "0", #placebo
  trialxcondition = "1",
  gender = "0", #male
  bmi_diff_z = 0,
  ageZ = 0,
  id = "0" #(population-level)
)

predict.fun <- function(my.lmm) {
  predict(my.lmm, newdata = newdata, re.form = NA)   # This is predict.merMod 
}

newdata$ml.value <- predict.fun(model)

lmm.boots <- bootMer(model, predict.fun, nsim = 50)

df.predicted <- cbind(newdata, confint(lmm.boots))
df.predicted


df.observed= ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE)) 


plot <- ggplot(data=df.observed, aes(x=condition, y=perceived_liking, colour=id)) + geom_point()
# Plot the ML prediction and its confidence intervals
plot + geom_line(data=df.predicted, aes(x=condition, y=df.predicted$ml.value)) +
  geom_ribbon(data=df.predicted, aes(x=condition, ymin=df.predicted$`2.5 %`,
                                     ymax=pred$`97.5 %`),
              fill="gray", alpha=0.5, inherit.aes = FALSE)

## produce 1000 bootstrapped samples #then  deriv CI
# 1 empty and 2 = milkshake
boot1 <- predict(random.slope.model, newdata=newdata, re.form=NA, se.fit=TRUE, nsim = 1000) 

        
BC = ddply(CI_pred, .(condition), summarise,  liking = mean(perceived_liking), lci = mean(lci), uci = mean(uci))

#RATINGS

dfLIK_C  <- subset(dat, x == 'Empty')
#dfLIK_Co  <- subset(dfLIK_C, session == 'obese')
#dfLIK_Cc  <- subset(dfLIK_C, session == 'control')
dfLIK_R  <- subset(dat, x == 'MilkShake')
#dfLIK_Ro  <- subset(dfLIK_R, session == 'obese')
#dfLIK_Rc  <- subset(dfLIK_R, session == 'control')

bsC_C  <- subset(raw, x == 'Empty')
#bsC_Co  <- subset(bsC_C , session == 'obese')
#bsC_Cc  <- subset(bsC_C , session == 'control')
bsC_R  <- subset(raw, x == 'MilkShake')
#bsC_Ro  <- subset(bsC_R , session == 'obese')
#bsC_Rc  <- subset(bsC_R , session == 'control')

plt1 <- ggplot(data = dat, aes(x = x, y = predicted, color = x, fill = x)) +
  #left 
  geom_left_violin(data = bsC_C, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_C, aes(x = as.numeric(x)+0.15), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_C, aes(x = as.numeric(x)+0.15, ymax = conf.high, ymin =conf.low), width=0.05,  alpha=1, size=0.4)+
  
  #right 
  geom_right_violin(data = bsC_R, aes(x= x, y = response), alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_R, aes(x = as.numeric(x)+0.15, y = predicted), color ="black", shape = 18) +
  geom_errorbar(data=dfLIK_R, aes(x = as.numeric(x)+0.15, y = predicted, ymax = conf.high, ymin = conf.low) , width=0.05, alpha=1, size=0.4)+
  #make it raaiiin
  geom_point(data = raw, aes(x = as.numeric(x) +0.15, y = response), alpha=0.1, size = 0.5, 
             position = position_jitter(width = 0.05, seed = 123), color ="lightgrey") +
  #geom_line(data = dat, aes(x = as.numeric(x) +0.15, y = predicted), alpha=0.4) +
  
  #details
  #scale_fill_manual(values = c("Empty"="blue", "Milkshake"="red")) +
  #scale_color_manual(values = c("Empty"="blue", "Milkshake"="red")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-3,2, by = 1)), limits = c(-3,2)) +
  #scale_x_discrete(expand = c(0, 2)) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 2, 1), units = "cm"),
        axis.text.x = element_blank(), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = "none", #c(0.525, 1,1), 
        legend.title = element_blank(),
        #legend.direction = "horizontal",
        plot.caption = element_text(size=8,  colour = "black"),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( x = "    Empty                  Milshake", 
        y = "Plesantness Ratings (z)",
        caption = "Marginal Effect Condition\n 
        ajusted for BMI, Trial, Familiarity & Subject \n 
        Plesantness ~ Condition*BMI + Trial + Familiarity  + (Condition|Subject) \n 
        Control (BMI < 30) n = 27, Obese (BMI > 30) n = 63 \n  
        Bootstrapped (i = 5000) p-values & 95% CI \n 
        Condition effect (p < 0.001, \u0394 BIC = 15.36, R\u00B2c = 0.16)") 

plot(plt1)

pdf(file.path(figures_path,paste(task, 'Liking_condition_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()

save(boot1, 'boot')



## produce 1000 bootstrapped samples #then  deriv CI 
#confint(model)

#predBOOT = predict(model, newdata=newdata, re.form=NA, se.fit=TRUE, nsim = 5000) #takes a whileeeee!
df.predicted = data.frame(predBOOT)


dat <- ggeffects::ggpredict(
  model = model,
  terms = c("condition", "id"),
  ci.lvl = 0.95,
  type = "fe")

#wrapper function
predict.fun <- function(my.lmm) {
  predict(my.lmm, newdata = newdata, re.form = NA)   # This is predict.merMod 
}

#model estimates
newdata$ml.value <- predict.fun(model)

lmm.boots <- bootMer(model, predict.fun, nsim = 5000)

df.predicted <- cbind(newdata, confint(lmm.boots))
df.predicted

df.observed= ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE)) 


plot <- ggplot(data=df.observed, aes(x=condition, y=perceived_liking, colour=id)) + geom_point()
# Plot the ML prediction and its confidence intervals
plot + geom_line(data=df.predicted, aes(x=condition, y=df.predicted$ml.value)) +
  geom_ribbon(data=df.predicted, aes(x=condition, ymin=df.predicted$`2.5 %`,
                                     ymax=pred$`97.5 %`),
              fill="gray", alpha=0.5, inherit.aes = FALSE)




BC = ddply(CI_pred, .(condition), summarise,  liking = mean(perceived_liking), lci = mean(lci), uci = mean(uci))

#RATINGS

dfLIK_C  <- subset(dat, x == 'Empty')
#dfLIK_Co  <- subset(dfLIK_C, time == 'obese')
#dfLIK_Cc  <- subset(dfLIK_C, time == 'control')
dfLIK_R  <- subset(dat, x == 'MilkShake')
#dfLIK_Ro  <- subset(dfLIK_R, time == 'obese')
#dfLIK_Rc  <- subset(dfLIK_R, time == 'control')

bsC_C  <- subset(raw, x == 'Empty')
#bsC_Co  <- subset(bsC_C , time == 'obese')
#bsC_Cc  <- subset(bsC_C , time == 'control')
bsC_R  <- subset(raw, x == 'MilkShake')
#bsC_Ro  <- subset(bsC_R , time == 'obese')
#bsC_Rc  <- subset(bsC_R , time == 'control')

plt1 <- ggplot(data = dat, aes(x = x, y = predicted, color = x, fill = x)) +
  #left 
  geom_left_violin(data = bsC_C, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_C, aes(x = as.numeric(x)+0.15), shape = 18, color ="black") +
  geom_errorbar(data=dfLIK_C, aes(x = as.numeric(x)+0.15, ymax = conf.high, ymin =conf.low), width=0.05,  alpha=1, size=0.4)+
  
  #right 
  geom_right_violin(data = bsC_R, aes(x= x, y = response), alpha = .4, position = position_nudge(x = +0.3, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_point(data = dfLIK_R, aes(x = as.numeric(x)+0.15, y = predicted), color ="black", shape = 18) +
  geom_errorbar(data=dfLIK_R, aes(x = as.numeric(x)+0.15, y = predicted, ymax = conf.high, ymin = conf.low) , width=0.05, alpha=1, size=0.4)+
  #make it raaiiin
  geom_point(data = raw, aes(x = as.numeric(x) +0.15, y = response), alpha=0.1, size = 0.5, 
             position = position_jitter(width = 0.05, seed = 123), color ="lightgrey") +
  #geom_line(data = dat, aes(x = as.numeric(x) +0.15, y = predicted), alpha=0.4) +
  
  #details
  #scale_fill_manual(values = c("Empty"="blue", "Milkshake"="red")) +
  #scale_color_manual(values = c("Empty"="blue", "Milkshake"="red")) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-3,2, by = 1)), limits = c(-3,2)) +
  #scale_x_discrete(expand = c(0, 2)) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 2, 1), units = "cm"),
        axis.text.x = element_blank(), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = "none", 
        legend.title = element_blank(),
        #legend.direction = "horizontal",
        plot.caption = element_text(size=8,  colour = "black"),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( x = "    Empty                  Milshake", 
        y = "Plesantness Ratings (z)",
        caption = "Marginal Effect Condition\n 
        ajusted for BMI, Trial, Familiarity & Subject \n 
        Plesantness ~ Condition*BMI + Trial + Familiarity  + (Condition|Subject) \n 
        Control (BMI < 30) n = 27, Obese (BMI > 30) n = 63 \n  
        Bootstrapped (i = 5000) p-values & 95% CI \n 
        Condition effect (p < 0.001, \u0394 BIC = 15.36, R\u00B2c = 0.16)") 

plot(plt1)

pdf(file.path(figures_path,paste(task, 'Liking_condition_ses2.pdf',  sep = "_")),
    width     = 5.5,
    height    = 6)

plot(plt1)
dev.off()

#save(boot1, 'boot')

#go full bayesian
#library(BayesFactor)
#lmeFit = lmer(a ~ factor1*factor2 + (1+factor1+factor2|factorRandom),data=dat)
#bf = generalTestBF(a ~ factor1*factor2 + factor1:factorRandom+factor2:factorRandom + factorRandom,data=dat)
#bf = generalTestBF(perceived_liking ~ condition*session*intervention + condition:id+session:id + id, data=OBIWAN_HED, whichRandom = "id", everExclude=c('id'), whichModels = 'top')
#bf


plot <- ggplot(data=df.observed, aes(x=condition, y=perceived_liking, colour=id)) + geom_point(position = jitter)
# Plot the ML prediction and its confidence intervals
plot + geom_line(data=df.predicted, aes(x=condition, y=df.predicted$ml.value)) +
  geom_ribbon(data=df.predicted, aes(x=condition, ymin=df.predicted$`2.5 %`,
                                     ymax=pred$`97.5 %`),
              fill="gray", alpha=0.5, inherit.aes = FALSE)
dat <- ggeffects::ggpredict(
  model = model,
  terms = c("condition", "id"),
  ci.lvl = 0.95,
  type = "fe")
