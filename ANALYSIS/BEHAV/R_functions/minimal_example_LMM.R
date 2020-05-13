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

# get means by condition 
bt = ddply(OBIWAN_HED, .(trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
btg = ddply(OBIWAN_HED, .(session, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

# get means by condition and trialxcondition
btc = ddply(OBIWAN_HED, .(condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
btcg = ddply(OBIWAN_HED, .(session, condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

# get means by participant 
bsT = ddply(OBIWAN_HED, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsC= ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsTC = ddply(OBIWAN_HED, .(id, trialxcondition, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

bsTg = ddply(OBIWAN_HED, .(id, session, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsCg= ddply(OBIWAN_HED, .(id, session, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bsTCg = ddply(OBIWAN_HED, .(id, session, trialxcondition, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 


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

## add bmi and session as a ranodm
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


