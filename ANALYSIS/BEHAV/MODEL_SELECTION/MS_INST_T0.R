## R code for FOR INST MODEL SELECTION
## following Barr et al. (2013) 
## last modified on April 2020 by David MUNOZ TORD


# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, lmerTest, optimx, car, visreg, ggplot2, ggpubr, sjPlot, glmmTMB, influence.ME, lspline,  bayestestR)

# SETUP ------------------------------------------------------------------

task = 'INST'

# Set working directory
setwd(analysis_path)
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


## LOADING AND INSPECTING THE DATA
load('INST.RData')

#View(INST)
dim(INST)
#str(INST)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

## BASIC RANDOM INTERCEPT MODEL
mod0 = lmer(gripC ~ trial*trial*group + gender + ageC + pissC+ hungryC+ thirstyC + (1|id), data = INST, control=control)
summary(mod0)

## COMPARING RANDOM EFFECTS MODELS REML
mod1 <- lmer(gripC ~ trial*group + gender + ageC  + pissC+   hungryC+   thirstyC + (trial|id), data = INST, control=control)

bayesfactor_models(mod0, mod1,  denominator = mod0) #mod1 #best random structure



## BEST RANDOM SLOPE MODEL
rslope <- mod1
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
mod0 <- lmer(gripC ~ trial*group + (trial|id) , data = INST, control = control, REML = FALSE)
mod1 <- lmer(gripC ~ trial*group + gender  + (trial|id) , data = INST,control = control, REML = FALSE)
mod2 <- lmer(gripC ~ trial*group + ageC + (trial|id) , data = INST, control = control, REML = FALSE)
mod3 <- lmer(gripC ~ trial*group + pissC+ (trial|id) , data = INST, control = control, REML = FALSE)
mod4 <- lmer(gripC ~ trial*group + thirstyC+ (trial|id) , data = INST, control = control, REML = FALSE)
mod5 <- lmer(gripC ~ trial*group + pissC+ (trial|id) , data = INST, control = control, REML = FALSE)
mod6 <- lmer(gripC ~ trial*group + hungryC+  (trial|id) , data = INST, control = control, REML = FALSE)

bayesfactor_models(mod2, mod3, mod4, mod5, mod6,  denominator = mod2) #mod4 #best random structure

AIC(mod0) ; BIC(mod0) 
AIC(mod1) ; BIC(mod1) #worse than null
AIC(mod2) ; BIC(mod2) #worse than null
AIC(mod3) ; BIC(mod3) 
AIC(mod4) ; BIC(mod4) 
AIC(mod5) ; BIC(mod5) 
AIC(mod6) ; BIC(mod6) 


mod01 <- lmer(gripC ~ trial*group + thirstyC +  hungryC + pissC + (1|id) , data = INST, control = control, REML = FALSE)
mod02 <- lmer(gripC ~ trial*group + thirstyC*hungryC + pissC +    (1|id) , data = INST, control = control, REML = FALSE)
mod03 <- lmer(gripC ~ trial*group + thirstyC + hungryC*pissC +    (1|id) , data = INST, control = control, REML = FALSE)
mod04 <- lmer(gripC ~ trial*group + thirstyC*hungryC*pissC + (1|id) , data = INST, control = control, REML = FALSE)
mod05 <- lmer(gripC ~ trial*group + thirstyC*hungryC*pissC + (1|id) , data = INST, control = control, REML = FALSE)
mod06 <- lmer(gripC ~ trial*group + thirstyC + thirstyC:trial +  hungryC + pissC + (1|id) , data = INST, control = control, REML = FALSE)
mod07 <- lmer(gripC ~ trial*group + thirstyC + hungryC:trial +  hungryC + pissC + (1|id) , data = INST, control = control, REML = FALSE)
mod08 <- lmer(gripC ~ trial*group + thirstyC + pissC:trial +  hungryC + pissC + (1|id) , data = INST, control = control, REML = FALSE)
mod10 <- lmer(gripC ~ trial*group + thirstyC + hungryC:trial +  hungryC + (1|id) , data = INST, control = control, REML = FALSE)
mod11 <- lmer(gripC ~ trial*group + thirstyC + hungryC:trial + (1|id) , data = INST, control = control, REML = FALSE)
mod12 <- lmer(gripC ~ trial*group + hungryC:trial + (1|id) , data = INST, control = control, REML = FALSE)

AIC(mod01) ; BIC(mod01) 
AIC(mod02) ; BIC(mod02)
AIC(mod03) ; BIC(mod03)
AIC(mod04) ; BIC(mod04)
AIC(mod05) ; BIC(mod05)
AIC(mod06) ; BIC(mod06) #best simple
AIC(mod07) ; BIC(mod07)  
AIC(mod08) ; BIC(mod08)
AIC(mod10) ; BIC(mod10) 
AIC(mod11) ; BIC(mod11)
AIC(mod12) ; BIC(mod12)


## BEST SIMPLE FIXED MODEL #keep it simple
mod <- mod06
summary(mod)
moddummy <- lm(gripC ~trial*group + thirstyC + thirstyC:trial +  hungryC + pissC, data = INST)

## PLOTTING
visreg(mod,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

ggplot(bt, aes(x = trial, y = grips)) +
  geom_point() #clearly doesn't look like a linear fit !

#Now we test different fit

## POLYNOMIAL FIT 
quadmod <- lmer(grips~trial*group+I(trial^2)  +  thirstyC + thirstyC:trial +  hungryC + pissC + (1 |id),data=INST, control = control, REML = FALSE)
polymod <- lmer(grips~trial*group+I(trial^2)+I(trial^3)  +  thirstyC + thirstyC:trial +  hungryC + pissC + (1 |id),data=INST, control = control, REML = FALSE)
## PIECEWISE REGRESSION WITH SPLINES##
splinemod <- lmer(gripC ~ lspline(trial, 5) *group + thirstyC + thirstyC:trial +  hungryC + pissC + (1 |id) ,  data = INST, control = control, REML = FALSE)

AIC(mod) ; BIC(mod)
AIC(quadmod) ; BIC(quadmod)
AIC(polymod) ; BIC(polymod)
AIC(splinemod) ; BIC(splinemod) #best model fit with spline at 5

mod <- splinemod 
#for to continuous predictor by trial*group
#visreg(mod1,xvar="",by="trial*group",gg=TRUE,type="contrast",ylab="Reaction Time (z)")

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
alt.est <- influence(mod,maxfun=100,  trial*group="id")   #set to 100 to really have a good estimate BUT #takes forever
cookD = cooks.distance(alt.est)
df <- data.frame(id = row.names(cookD), cookD) 
df <- arrange(df, cookD)
df$id <- factor(df$id, levels = df$id)
cutoff = 4/(n_tot-length(moddummy$coefficients)-1)

ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dasINST", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())

### THE END thanks for watching!