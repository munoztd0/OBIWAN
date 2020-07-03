## R code for FOR PIT MODEL SELECTION
## following Barr et al. (2013) 
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, lmerTest, optimx, car, visreg, ggplot2, ggpubr, sjPlot, glmmTMB, influence.ME)

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
str(PIT)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

## BASIC RANDOM INTERCEPT MODEL
rint = lmer(gripZ ~ condition*bmiZ + gender + ageZ + pissZ+   hungryZ+   thirstyZ+   likZ + (1|id), data = PIT, control=control)
summary(rint)


## COMPARING RANDOM EFFECTS MODELS
mod1 <- lmer(gripZ ~ condition*bmiZ + gender + ageZ + pissZ+   hungryZ+   thirstyZ+   likZ + (1|id) , data = PIT, control=control)
mod2 <- lmer(gripZ ~ condition*bmiZ + gender + ageZ + pissZ+   hungryZ+   thirstyZ+   likZ + (condition|id) , data = PIT, control=control)
mod3 <- lmer(gripZ ~ condition*bmiZ + gender + ageZ + pissZ+   hungryZ+   thirstyZ+   likZ + (1|id) + (1|trialxcondition), data = PIT, control=control)
mod4 <- lmer(gripZ ~ condition*bmiZ + gender + ageZ + pissZ+   hungryZ+   thirstyZ+   likZ + (condition|id) + (1|trialxcondition), data = PIT, control=control)
#after mod4 doesn't converge properly correlation = 1, negative Hessian -> we stop

AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)

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



## PLOTTING
mod <- rslope
visreg(mod,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

#for to continuous predictor by group
#visreg(mod1,xvar="Intervention",by="Condition",gg=TRUE,type="contrast",ylab="Effort (z)",breaks=c(-2,0,2),xlab="Intervention")


## COMPARING FIXED EFFECTS MODELS REML FALSE
mod0 <- lmer(gripZ ~ condition*bmiZ  + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod1 <- lmer(gripZ ~ condition*bmiZ + gender  + (condition|id) + (1|trialxcondition), data = PIT,control = control, REML = FALSE)
mod2 <- lmer(gripZ ~ condition*bmiZ + ageZ + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod3 <- lmer(gripZ ~ condition*bmiZ + pissZ+ (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod4 <- lmer(gripZ ~ condition*bmiZ + likZ + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod5 <- lmer(gripZ ~ condition*bmiZ  + thirstyZ+ (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod6 <- lmer(gripZ ~ condition*bmiZ + pissZ+ (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod7 <- lmer(gripZ ~ condition*bmiZ + hungryZ+  (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)

mod01 <- lmer(gripZ ~ condition*bmiZ   + thirstyZ +  hungryZ + pissZ + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod02 <- lmer(gripZ ~ condition*bmiZ   + thirstyZ*hungryZ + pissZ +        (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod03 <- lmer(gripZ ~ condition*bmiZ   + thirstyZ + hungryZ*pissZ +        (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod04 <- lmer(gripZ ~ condition*bmiZ   + thirstyZ*hungryZ*pissZ + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod05 <- lmer(gripZ ~ condition*bmiZ   + thirstyZ*hungryZ*pissZ + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod06 <- lmer(gripZ ~ condition*bmiZ   + thirstyZ + thirstyZ:condition +  hungryZ + pissZ + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod07 <- lmer(gripZ ~ condition*bmiZ   + thirstyZ + hungryZ:condition +  hungryZ + pissZ + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)
mod08 <- lmer(gripZ ~ condition*bmiZ   + thirstyZ + pissZ:condition +  hungryZ + pissZ + (condition|id) + (1|trialxcondition), data = PIT, control = control, REML = FALSE)

AIC(mod0) ; BIC(mod0) 
AIC(mod1) ; BIC(mod1) #worse than null
AIC(mod2) ; BIC(mod2) #worse than null
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4) #worse than null
AIC(mod5) ; BIC(mod5)
AIC(mod6) ; BIC(mod6)
AIC(mod7) ; BIC(mod7)



AIC(mod01) ; BIC(mod01) 
AIC(mod02) ; BIC(mod02)
AIC(mod03) ; BIC(mod03)
AIC(mod04) ; BIC(mod04)
AIC(mod05) ; BIC(mod05)
AIC(mod06) ; BIC(mod06)
AIC(mod07) ; BIC(mod07) #best simplest
AIC(mod08) ; BIC(mod08) 

## BEST SIMPLE FIXED MODEL #keep it simple
mod <- mod08
summary(mod)
moddummy <- lm(gripZ ~ condition*bmiZ + thirstyZ + pissZ:condition +  hungryZ + pissZ, data = PIT)

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

cutoff = 4/(n_tot-length(moddummy$coefficients)-1) #rule of thumb cutoff

ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dashed", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())



