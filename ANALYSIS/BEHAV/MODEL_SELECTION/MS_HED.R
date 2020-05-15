## R code for FOR HED MODEL SELECTION
## following Barr et al. (2013) 
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, optimx, car, visreg, ggplot2, ggpubr, sjPlot, influence.ME)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


## LOADING AND INSPECTING THE DATA
load('HED.RData')

View(HED)
dim(HED)
str(HED)


#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

## BASIC RANDOM INTERCEPT MODEL
rint = lmerlmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(1|id) + (1|trialxcondition) , 
                data = HED, control = control) 
summary(rint)


## COMPARING RANDOM EFFECTS MODELS
mod1 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod2 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition+time|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod3 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod4 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time + famZ|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod5 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time + intZ|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod6 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time + famZ + intZ|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod7 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time + famZ*intZ|id) + (1|trialxcondition) , 
             data = HED, control = control) 
#starting from here it takes aaaaages to compute
# mod8 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time*famZ*intZ|id) + (1|trialxcondition) , 
#              data = HED, control = control) 
# mod9 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time + famZ*intZ|id) + (condition|trialxcondition) , 
#              data = HED, control = control) 
# mod10 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time*famZ*intZ|id) + (condition|trialxcondition) , 
#              data = HED, control = control) 
mod11 <- lmer(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ +(condition*time + famZ*intZ|id) + (condition|trialxcondition) , 
             data = HED, control = control) 

AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)
AIC(mod5) ; BIC(mod5)
AIC(mod6) ; BIC(mod6) #
AIC(mod7) ; BIC(mod7)
# AIC(mod8) ; BIC(mod8)
# AIC(mod9) ; BIC(mod9)
AIC(mod10) ; BIC(mod10)
AIC(mod11) ; BIC(mod11)

## BEST RANDOM SLOPE MODEL
rslope <- mod6
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


## TESTING THE RANDOM INTERCEPT
mod1 <- update(rint, REML = FALSE)
mod2 <- lm(likZ ~ condition*time*intervention + gender + ageZ + diff_bmiZ + famZ * intZ, data = HED) 

AIC(mod1) ; BIC(mod1) #really better with random intercept
AIC(mod2) ; BIC(mod2) 

## PLOTTING
mod <- rslope
visreg(mod,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

#for to continuous predictor by group
#visreg(mod1,xvar="Intervention",by="Condition",gg=TRUE,type="contrast",ylab="Liking (z)",breaks=c(-2,0,2),xlab="Intervention")


# MODEL ASSUMPTION CHECKS :  -----------------------------------

#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so no problem keeping everything

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points
boxplot(scale(ranef(mod)$id), las=2) #simple univariate boxplots

set.seed(101) #disgnostic plots -> Cook's distance ->  228 & 244 & 203 & 238 & 206
alt.est <- influence(mod,maxfun=100,  group="id")   #set to 100 to really have a good estimate BUT #takes forever
cookD = cooks.distance(alt.est)
df <- data.frame(id = row.names(cookD), cookD) 
df <- arrange(df, cookD)
df$id <- factor(df$id, levels = df$id)

cutoff = 4/(n_tot-length(mod2$coefficients)-1) #rule of thumb cutoff

ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dashed", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())
