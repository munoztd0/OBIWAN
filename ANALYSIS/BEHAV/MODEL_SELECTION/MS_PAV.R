## R code for FOR PAV LIRA MODEL SELECTION
## following Barr et al. (2013) 
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, lmerTest, optimx, car, visreg, ggplot2, ggpubr, sjPlot, glmmTMB, influence.ME, bayestestR, interactions)

# SETUP ------------------------------------------------------------------

task = 'PAV'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

## LOADING AND INSPECTING THE DATA
load('PAV_LIRA.RData')

View(PAV)
# dim(PAV)
# str(PAV)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))


# RANDOM STRUCTURE --------------------------------------------------------

## BASIC RANDOM INTERCEPT MODEL WITH EVERYTHING
mod0 = lmer(RT_TC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC +  (1|id), data = PAV, control=control)

## COMPARING RANDOM INTERCEPT MODELS
mod1 <- lmer(RT_TC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC +  (1|id) + (1|trialxcondition), data = PAV, control=control)

# comparing BIC measures, allowing a Bayesian comparison of non-nested frequentist models (Wagenmakers, 2007)
bayesfactor_models(mod0, mod1,  denominator = mod0) #mod2 #best random INTERCEPT

rint <- mod1

## COMPARING RANDOM SLOPE MODELS
mod4 <- lmer(RT_TC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC + (condition|id) + (1|trialxcondition), data = PAV, control=control)
mod5 <- lmer(RT_TC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC + (1|id) + (condition|trialxcondition), data = PAV, control=control)
mod6 <- lmer(RT_TC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC + (condition|id) + (condition|trialxcondition), data = PAV, control=control)
mod7 <- lmer(RT_TC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC + (condition+time|id) + (1|trialxcondition), data = PAV, control=control)
mod8 <- lmer(RT_TC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control)
#after that too complex

bayesfactor_models(mod1, mod4, mod5, mod6, mod7, mod8, denominator = mod1) #mod8 #best random SLOPE

AIC(mod2) ; BIC(mod2) 
AIC(mod4) ; BIC(mod4) 
AIC(mod5) ; BIC(mod5) #better than Full
AIC(mod6) ; BIC(mod6) 

## BEST RANDOM SLOPE MODEL
rslope <- mod8
summary(rslope)
ranova(rslope) #there is statistically "significant" variation in slopes between times\individuals\trials

# create data frames containing residuals and fitted
# values for each model we ran above
a <-  data_frame(model = "random.slope",fitted = predict(rslope),residual = residuals(rslope))
b <- data_frame(model = "random.intercept",fitted = predict(rint),residual = residuals(rint))

# join the two data frames together
residual.fitted.data <- bind_rows(a,b)
#residual.fitted.data = a # or plot them individually
# plots residuals against fitted values for each model
residual.fitted.data %>%
  ggplot(aes(fitted, residual)) +
  geom_point() +
  geom_smooth(se=F) +
  facet_wrap(~model)

#We can see that the residuals from the random slope model are much more evenly 
#distributed across the range of fitted values, which suggests that the assumption 
#of homogeneity of variance is met in the random slope model


# FIXED STRUCTURE ---------------------------------------------------------

## COMPARING FIXED EFFECTS MODELS (REML=FALSE)
mod10 <- lmer(RT_TC ~ condition*intervention*time + gender + ageC + pissC+   hungryC+   thirstyC+   likC + diff_bmiC + bmiC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control, REML = FALSE)
mod11 = update(mod10, . ~ . - bmiC)
mod12 = update(mod10, . ~ . - diff_bmiC)
mod13 = update(mod10, . ~ . - likC)
mod14 = update(mod10, . ~ . - thirstyC)
mod15 = update(mod10, . ~ . - hungryC)
mod16 = update(mod10, . ~ . - pissC)
mod17 = update(mod10, . ~ . - ageC)
mod18 = update(mod10, . ~ . - gender)

# remove everything that is #better than Full
AIC(mod10) ; BIC(mod10) 
AIC(mod11) ; BIC(mod11) #better than Full
AIC(mod12) ; BIC(mod12) 
AIC(mod13) ; BIC(mod13) 
AIC(mod14) ; BIC(mod14) #better than Full
AIC(mod15) ; BIC(mod15) #better than Full
AIC(mod16) ; BIC(mod16) #better than Full
AIC(mod17) ; BIC(mod17) #better than Full
AIC(mod18) ; BIC(mod18) #better than Full

#look at interactions
mod21 <- lmer(RT_TC ~ condition*intervention*time + diff_bmiC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control, REML = FALSE)
mod22 <- lmer(RT_TC ~ condition*intervention*time*diff_bmiC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control, REML = FALSE)
mod23 <- lmer(RT_TC ~ condition*intervention*time + likC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control, REML = FALSE)
mod24 <- lmer(RT_TC ~ condition*intervention*time*likC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control, REML = FALSE)

bayesfactor_models(mod21, mod22, denominator = mod21) #mod21 #best FIXED 1
bayesfactor_models(mod23, mod24, denominator = mod23) #mod23 #best FIXED 2

## BEST SIMPLE FIXED MODEL #keep it simple
mod <- lmer(RT_TC ~ condition*intervention*time + likC + diff_bmiC + (condition*time|id) + (1|trialxcondition), data = PAV, control=control)
summary(mod)
moddummy <- lm(RT_TC ~ condition*intervention*time + likC + diff_bmiC, data = PAV)


## PLOTTING
visreg(mod,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

#for to continuous predictor by group
cat_plot(mod, pred = intervention, modx = condition, mod2 = time)
# MODEL ASSUMPTION CHECKS :  -----------------------------------

#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) 

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points 
boxplot(scale(ranef(mod)$id), las=2) #simple univariate boxplots

set.seed(101) #disgnostic plots -> Cook's distance -> check 224 254 227
alt.est <- influence(mod,maxfun=10,  group="id")   #set to 1000 to really have a good estimate BUT #takes forever
cookD = cooks.distance(alt.est)
df <- data.frame(id = row.names(cookD), cookD) 
df <- arrange(df, cookD)
df$id <- factor(df$id, levels = df$id)

cutoff = 4/(n_tot-length(moddummy$coefficients)-1) #rule of thumb cutoff

ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dashed", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())

# The rest on MAIN_PAV_LIRA - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------

