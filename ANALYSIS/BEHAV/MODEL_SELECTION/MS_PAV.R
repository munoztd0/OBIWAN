## R code for FOR PAV MODEL SELECTION
## following Barr et al. (2013) 
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, optimx, car, visreg, ggplot2, ggpubr, sjPlot, influence.ME)

# SETUP ------------------------------------------------------------------

task = 'PAV'

# Set working directory
setwd(analysis_path)
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


## LOADING AND INSPECTING THE DATA
load('PAV.RData')

View(PAV)
dim(PAV)
str(PAV)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

## BASIC RANDOM INTERCEPT MODEL
rint = lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ +  likZ + (1|id) + (1|trialxcondition), data = PAV, control=control)
summary(rint)


## COMPARING RANDOM EFFECTS MODELS
mod1 <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (1|id) + (1|trialxcondition), data = PAV, control=control)
mod2 <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition|id) + (1|trialxcondition), data = PAV, control=control)
mod3 <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition+time|id) + (1|trialxcondition), data = PAV, control=control)
mod4 <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition*time|id) + (1|trialxcondition), data = PAV, control=control)
mod5 <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition*time|id) + (condition|trialxcondition), data = PAV, control=control)
mod6 <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition*time|id) + (1|trialxcondition), data = PAV, control=control)
mod7 <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition*time+likZ|id) + (1|trialxcondition), data = PAV, control=control)
mod8 <- lmer(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ + (condition*time*likZ|id) + (1|trialxcondition), data = PAV, control=control)


AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4) #
AIC(mod5) ; BIC(mod5)
AIC(mod6) ; BIC(mod6)
AIC(mod7) ; BIC(mod7)
AIC(mod8) ; BIC(mod8)


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
#We can see that the residuals from the random slope model 
#the range of fitted values, which suggests that the assumption of 
#homogeneity of variance is met in the random slope model


## TESTING THE RANDOM INTERCEPT
mod1 <- update(rint, REML = FALSE)
mod2 <- lm(RT_TZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + likZ, data = PAV)

AIC(mod1) ; BIC(mod1) #really better with random intercept
AIC(mod2) ; BIC(mod2) 


## PLOTTING
mod <- rslope
visreg(mod,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

#for to continuous predictor by group
#visreg(mod1,xvar="Intervention",by="Condition",gg=TRUE,type="contrast",ylab="Effort (z)",breaks=c(-2,0,2),xlab="Intervention")

# MODEL ASSUMPTION CHECKS :  -----------------------------------

#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so not really a problem keeping everything

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points -> 205 & 254 
boxplot(scale(ranef(mod)$id), las=2) #simple univariate boxplots

set.seed(101) #disgnostic plots -> Cook's distance 
alt.est <- influence(mod,maxfun=100,  group="id")   #set to 100 to really have a good estimate BUT #takes forever
cookD = cooks.distance(alt.est)
df <- data.frame(id = row.names(cookD), cookD) 
df <- arrange(df, cookD)
df$id <- factor(df$id, levels = df$id)
cutoff = 4/(n_tot-length(mod2$coefficients)-1)

ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dashed", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())


