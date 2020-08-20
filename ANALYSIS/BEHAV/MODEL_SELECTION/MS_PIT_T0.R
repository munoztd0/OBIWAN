## R code for FOR PIT MODEL SELECTION
## following Barr et al. (2013) 
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, lmerTest, optimx, car, visreg, ggplot2, ggpubr, sjPlot, glmmTMB, influence.ME, bayestestR)

# SETUP ------------------------------------------------------------------

task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

## LOADING AND INSPECTING THE DATA
load('PIT.RData')

#View(PIT)
dim(PIT)
#str(PIT)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

## BASIC RANDOM INTERCEPT MODEL
rint = lmer(gripC ~ condition*group + gender + ageC + pissC+   hungryC+   thirstyC+   likC + (1|id), data = PIT, control=control)
summary(rint)


## COMPARING RANDOM EFFECTS MODELS
mod1 <- lmer(gripC ~ condition*group + gender + ageC + pissC+   hungryC+   thirstyC+   likC + (1|id) , data = PIT, control=control)
mod2 <- lmer(gripC ~ condition*group + gender + ageC + pissC+   hungryC+   thirstyC+   likC + (condition|id) , data = PIT, control=control)
mod3 <- lmer(gripC ~ condition*group + gender + ageC + pissC+   hungryC+   thirstyC+   likC + (1|id) + (1|trialxcondition), data = PIT, control=control)
mod4 <- lmer(gripC ~ condition*group + gender + ageC + pissC+   hungryC+   thirstyC+   likC + (condition|id) + (1|trialxcondition), data = PIT, control=control)
mod5 <- lmer(gripC ~ condition*group + gender + ageC + pissC+   hungryC+   thirstyC+   likC + (condition|id) + (condition|trialxcondition), data = PIT, control=control)

# comparing BIC measures, allowing a Bayesian comparison of non-nested frequentist models (Wagenmakers, 2007)
bayesfactor_models(mod1, mod2, mod3, mod4, mod5, denominator = mod1) #mod4 #best random structure

## BEST RANDOM SLOPE MODEL
rslope <- mod4
summary(rslope)
ranova(rslope) #there is statistically "significant" variation in slopes between individuals and trials


# create data frames containing residuals and fitted
# values for each model we ran above
a <-  data_frame(
  model = "random.slope",
  fitted = predict(rslope),
  residual = residuals(rslope))

b <- data_frame(
  model = "random.intercept",
  fitted = predict(rint),
  residual = residuals(rint))

# join the two data frames together
residual.fitted.data <- bind_rows(a,b)

# plots residuals against fitted values for each model
residual.fitted.data %>%
  ggplot(aes(fitted, residual)) +
  geom_point() +
  geom_smooth(se=F) +
  facet_wrap(~model)
#We can see that the residuals from the random slope model XX problem here ##
#the range of fitted values, which suggests that the assumption of 
#homogeneity of variance is met in the random slope model



## COMPARING FIXED EFFECTS MODELS REML FALSE
mod10 <- lmer(gripC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC + (condition * time|id) + (1|trialxcondition), data = PIT, control=control, REML = FALSE)
mod11 = update(mod10, . ~ . - gender)
mod12 = update(mod10, . ~ . - ageC)
mod13 = update(mod10, . ~ . - likC)
mod14 = update(mod10, . ~ . - thirstyC)
mod15 = update(mod10, . ~ . - pissC)
mod16 = update(mod10, . ~ . - hungryC)

# remove everything that is #better than Full
AIC(mod0) ; BIC(mod0) 
AIC(mod1) ; BIC(mod1) #better than Full
AIC(mod2) ; BIC(mod2) #better than Full
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4) #better than Full
AIC(mod5) ; BIC(mod5)
AIC(mod6) ; BIC(mod6)

mod01 <- lmer(gripC ~ condition*group   + thirstyC +  hungryC + pissC + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod02 <- lmer(gripC ~ condition*group   + thirstyC*hungryC + pissC +        (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod03 <- lmer(gripC ~ condition*group   + thirstyC + hungryC*pissC +        (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod04 <- lmer(gripC ~ condition*group   + thirstyC*hungryC*pissC + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod05 <- lmer(gripC ~ condition*group   + thirstyC*hungryC*pissC + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod06 <- lmer(gripC ~ condition*group   + thirstyC + thirstyC:condition +  hungryC + pissC + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod07 <- lmer(gripC ~ condition*group   + thirstyC + hungryC:condition +  hungryC + pissC + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod08 <- lmer(gripC ~ condition*group   + thirstyC + pissC:condition +  hungryC + pissC + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)

bayesfactor_models(mod01, mod02, mod03, mod04, mod05, mod06, mod07, mod08, denominator = mod01) #mod07 is the best simplest model

## BEST SIMPLE FIXED MODEL #keep it simple
mod <- mod07
summary(mod)
moddummy <- lm(gripC ~ condition*group + thirstyC + pissC:condition +  hungryC + pissC, data = PIT)

# MODEL ASSUMPTION CHECKS :  -----------------------------------

#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so no problem keeping everything

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points 
boxplot(scale(ranef(mod)$id), las=2) #simple univariate boxplots 102 238+ 239++

set.seed(101) #disgnostic plots -> Cook's distance -> 238 & 234 & 232 & 254
alt.est <- influence(mod,maxfun=100,  group="id")   #set to 100 to really have a good estimate BUT #takes forever
cookD = cooks.distance(alt.est)
df <- data.frame(id = row.names(cookD), cookD) 
df <- arrange(df, cookD)
df$id <- factor(df$id, levels = df$id)
n_tot = length(df$id)
cutoff = 4/(n_tot-length(moddummy$coefficients)-1) #rule of thumb cutoff

ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dashed", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())


# The rest on MAIN_PIT_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------

