## R code for FOR PAV MODEL SELECTION
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
load('PAV.RData')

#View(PAV)
dim(PAV)
#str(PAV)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

## BASIC RANDOM INTERCEPT MODEL
mod0 = lmer(RT_TC ~ condition*group + gender + ageC + pissC+   hungryC+   thirstyC+   likC + (1|id), data = PAV, control=control)
summary(mod0)


## COMPARING RANDOM EFFECTS MODELS REML
mod1 <- lmer(RT_TC ~ condition*group + gender + ageC  + pissC+   hungryC+   thirstyC+   likC + (1|id) + (1|trialxcondition), data = PAV, control=control)
mod2 <- lmer(RT_TC ~ condition*group + gender + ageC  + pissC+   hungryC+   thirstyC+   likC + (condition|id) + (1|trialxcondition), data = PAV, control=control)
mod3 <- lmer(RT_TC ~ condition*group + gender + ageC  + pissC+   hungryC+   thirstyC+   likC + (condition|id) + (condition|trialxcondition), data = PAV, control=control)
mod4 <- lmer(RT_TC ~ condition*group + gender + ageC  + pissC+   hungryC+   thirstyC+   likC + (condition+likC|id) + (1|trialxcondition), data = PAV, control=control)
mod5 <- lmer(RT_TC ~ condition*group + gender + ageC  + pissC+   hungryC+   thirstyC+   likC + (condition*likC|id) + (1|trialxcondition), data = PAV, control=control)

# comparing BIC measures, allowing a Bayesian comparison of non-nested frequentist models (Wagenmakers, 2007)
bayesfactor_models(mod0, mod1, mod2, mod3, mod4, mod5, denominator = mod0) #mod2 #best simple random structure


## BEST RANDOM SLOPE MODEL
rslope <- mod2
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
#We can see that the residuals from the random slope model 
#the range of fitted values, which suggests that the assumption of 
#homogeneity of variance is met in the random slope model


## COMPARING FIXED EFFECTS MODELS REML FALSE
mod0 <- lmer(RT_TC ~ condition*group + (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod1 <- lmer(RT_TC ~ condition*group + gender  + (condition|id) + (1|trialxcondition), data = PAV,control = control, REML = FALSE)
mod2 <- lmer(RT_TC ~ condition*group + ageC + (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod3 <- lmer(RT_TC ~ condition*group + pissC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod4 <- lmer(RT_TC ~ condition*group + likC + (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod5 <- lmer(RT_TC ~ condition*group + thirstyC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod6 <- lmer(RT_TC ~ condition*group + pissC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod7 <- lmer(RT_TC ~ condition*group + hungryC+  (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
#variantes
# mod5 <- lmer(RT_TC ~ condition*group + diff_thirstyC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
# mod6 <- lmer(RT_TC ~ condition*group + diff_pissC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
# mod7 <- lmer(RT_TC ~ condition*group + diff_hungryC+  (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
# mod5 <- lmer(RT_TC ~ condition*group + condition:thirstyC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
# mod6 <- lmer(RT_TC ~ condition*group + condition:pissC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
# mod7 <- lmer(RT_TC ~ condition*group + condition:hungryC+  (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
# mod5 <- lmer(RT_TC ~ condition*group + group:thirstyC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
# mod6 <- lmer(RT_TC ~ condition*group + group:pissC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
# mod7 <- lmer(RT_TC ~ condition*group + group:hungryC+  (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)

AIC(mod0) ; BIC(mod0) 
AIC(mod1) ; BIC(mod1) #worse than null
AIC(mod2) ; BIC(mod2) #worse than null
AIC(mod3) ; BIC(mod3) #worse than null
AIC(mod4) ; BIC(mod4) 
AIC(mod5) ; BIC(mod5) #worse than null
AIC(mod6) ; BIC(mod6) #worse than null
AIC(mod7) ; BIC(mod7) #worse than null

mod01 <- lmer(RT_TC ~ condition*group + condition:likC + likC + (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod02 <- lmer(RT_TC ~ condition*group + group:likC + likC +  (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod03 <- lmer(RT_TC ~ condition*group*likC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)
mod04 <- lmer(RT_TC ~ condition*group + condition:likC:group + likC+ (condition|id) + (1|trialxcondition), data = PAV, control = control, REML = FALSE)

bayesfactor_models(mod01, mod02, mod03, mod04, denominator = mod01) #mod02 #best simple random structure

## BEST SIMPLE FIXED MODEL #keep it simple
mod <- mod02
summary(mod)
moddummy <- lm(RT_TC ~ condition*group + group:likC + likC, data = PAV)

## PLOTTING
visreg(mod,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

#for to continuous predictor by group
#visreg(mod1,xvar="condition",by="group",gg=TRUE,type="contrast",ylab="Reaction Time (z)")

# MODEL ASSUMPTION CHECKS :  -----------------------------------

#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so not really a problem keeping everything

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points 
boxplot(scale(ranef(mod)$id), las=2) #simple univariate boxplots -> 122 & 254 high // 110 & 120 low

set.seed(101) #disgnostic plots -> Cook's distance // 122 & 219 & 110 & 254
alt.est <- influence(mod,maxfun=100,  group="id")   #set to 100 to really have a good estimate BUT #takes forever
cookD = cooks.distance(alt.est)
df <- data.frame(id = row.names(cookD), cookD) 
df <- arrange(df, cookD)
df$id <- factor(df$id, levels = df$id)
cutoff = 4/(n_tot-length(moddummy$coefficients)-1)
n_tot = length(df$id)
ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dashed", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())

### THE END thanks for watching!