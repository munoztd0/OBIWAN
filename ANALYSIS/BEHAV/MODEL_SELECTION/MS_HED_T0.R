## R code for FOR HED MODEL SELECTION
## following Barr et al. (2013) 
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, lmerTest, optimx, car, visreg, ggplot2, ggpubr, sjPlot, influence.ME, bayestestR)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


## LOADING AND INSPECTING THE DATA
load('HED.RData')

#View(HED)
dim(HED)
#str(HED)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

## BASIC RANDOM INTERCEPT MODEL

mod0 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+  (1|id) , data = HED, control = control) 
summary(mod0)


## COMPARING RANDOM EFFECTS MODELS
mod1 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (1|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod2 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition|id) , 
             data = HED, control = control) 
mod3 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition + famC*intC|id) + (condition|trialxcondition) , 
             data = HED, control = control) 
mod4 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition + famC|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod5 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition + intC|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod6 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition + famC + intC|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod7 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition + famC*intC|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod8 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition|id) + (famC*intC|trialxcondition) , 
             data = HED, control = control) 
mod9 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition|id) + (famC+intC|trialxcondition) , 
             data = HED, control = control) 
mod10 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition|id) + (famC|trialxcondition) , 
             data = HED, control = control) 
mod11 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition|id) + (intC|trialxcondition) , 
              data = HED, control = control) 
mod12 <- lmer(likC ~ condition*group  + gender + ageC + famC + intC + hungryC+   thirstyC+ (condition + famC*intC|id) + (condition|trialxcondition) , 
              data = HED, control = control) 

# comparing BIC measures, allowing a Bayesian comparison of non-nested frequentist models (Wagenmakers, 2007)
bayesfactor_models(mod0, mod1, mod2, denominator = mod0) #mod2 #best simple random structure
bayesfactor_models(mod2, mod3, mod4, mod5, mod6, mod7, mod8, mod9, mod10,mod11,mod12, denominator = mod2) #mod4 #best random structure


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


## COMPARING FIXED EFFECTS MODELS REML FALSE #takes hourssss 
mod0 <- lmer(likC ~ condition*group + (condition + famC|id) + (1|trialxcondition), data = HED,control = control, REML = FALSE)
mod1 <- lmer(likC ~ condition*group + gender  +  (condition + famC|id) + (1|trialxcondition), data = HED,control = control, REML = FALSE)
mod2 <- lmer(likC ~ condition*group + ageC +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod3 <- lmer(likC ~ condition*group + pissC+  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod4 <- lmer(likC ~ condition*group + thirstyC+  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod5 <- lmer(likC ~ condition*group + pissC+  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod6 <- lmer(likC ~ condition*group + hungryC+  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod7 <- lmer(likC ~ condition*group + famC+  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod8 <- lmer(likC ~ condition*group + intC+  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)

AIC(mod0) ; BIC(mod0) 
AIC(mod1) ; BIC(mod1) #worse than null
AIC(mod2) ; BIC(mod2) #worse than null
AIC(mod3) ; BIC(mod3) 
AIC(mod4) ; BIC(mod4) 
AIC(mod5) ; BIC(mod5)
AIC(mod6) ; BIC(mod6)
AIC(mod7) ; BIC(mod7)
AIC(mod8) ; BIC(mod8)

mod01 <- lmer(likC ~ condition*group + thirstyC +  hungryC + pissC + (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod02 <- lmer(likC ~ condition*group + thirstyC*hungryC + pissC +     (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod03 <- lmer(likC ~ condition*group + thirstyC + hungryC*pissC +     (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod04 <- lmer(likC ~ condition*group + thirstyC*hungryC*pissC +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod05 <- lmer(likC ~ condition*group + thirstyC*hungryC*pissC +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod06 <- lmer(likC ~ condition*group + thirstyC + thirstyC:condition +  hungryC + pissC +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod07 <- lmer(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC + pissC +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod08 <- lmer(likC ~ condition*group + thirstyC + pissC:condition +  hungryC + pissC +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod09 <- lmer(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod10 <- lmer(likC ~ condition*group + thirstyC + hungryC:condition +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)
mod11 <- lmer(likC ~ condition*group + hungryC:condition +  (condition + famC|id) + (1|trialxcondition), data = HED, control = control, REML = FALSE)

bayesfactor_models(mod01, mod02, mod03, mod04, mod05, mod06, mod07, mod08, mod09, mod10,mod11,  denominator = mod01) #mod09 #best simple fixed


mod12 <- lmer(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC + famC + intC + (condition + famC|id) + (1|trialxcondition) , data = HED, control = control, REML = FALSE)
mod13 <- lmer(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC + famC + famC:condition + intC + (condition + famC|id) + (1|trialxcondition) , data = HED, control = control, REML = FALSE)
mod14 <- lmer(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC + famC + intC:condition + intC + (condition + famC|id) + (1|trialxcondition) , data = HED, control = control, REML = FALSE)
mod15 <- lmer(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC + famC*intC + (condition + famC|id) + (1|trialxcondition) , data = HED, control = control, REML = FALSE)

bayesfactor_models(mod09, mod12, mod13, mod14, mod15, denominator = mod09) #mod14 #best full fixed



## BEST SIMPLE FIXED MODEL #keep it "simple"
mod <- mod14
summary(mod)
moddummy <- lm(likC ~ condition*group + thirstyC + hungryC:condition +  hungryC + famC + intC:condition + intC , data = HED)

## PLOTTING
visreg(mod,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

#for to continuous predictor by group
#visreg(mod1,xvar="group",by="condition",gg=TRUE,type="contrast",ylab="Liking (z)",breaks=c(-2,0,2),xlab="Intervention")


# MODEL ASSUMPTION CHECKS :  -----------------------------------

#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so no problem keeping everything

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points
boxplot(scale(ranef(mod)$id), las=2) #simple univariate boxplots 109 & 107

set.seed(101) #disgnostic plots -> Cook's distance ->  228 & 244 & 203 & 238 & 206
alt.est <- influence(mod,maxfun=100,  group="id")   #set to 100 to really have a good estimate BUT #takes forever
cookD = cooks.distance(alt.est)
df <- data.frame(id = row.names(cookD), cookD) 
df <- arrange(df, cookD)
df$id <- factor(df$id, levels = df$id)
n_tot = length(df$id)
cutoff = 4/(n_tot-length(moddummy$coefficients)-1) #rule of thumb cutoff not to take to seriously


#little function to plot the outlier because the car ones doesnt work anymore on merMod
ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dashed", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())


# The rest on MAIN_HED_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------
