## R code for FOR OBIWAN_PIT Obese
# last modified on April by David
# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, ggplot2, Rmisc, dplyr, lmerTest, car, r2glmm, optimx, visreg, MuMIn,  emmeans, sjPlot, bayestestR)

#SETUP
task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$id      <- as.factor(info$id)

#subset
OBIWAN_PIT  <- subset(OBIWAN_PIT_full, session == 'second') #only session 2

# define as.factors
OBIWAN_PIT$id      <- as.factor(OBIWAN_PIT$id)
OBIWAN_PIT$trial    <- as.factor(OBIWAN_PIT$trial)
OBIWAN_PIT$group    <- as.factor(OBIWAN_PIT$group)

#remove baseline grip of the other two
# x = ddply(OBIWAN_PIT, .(id, trial, condition),   summarise, gripFreq = mean(gripFreq, na.rm = TRUE))
# BASE = subset(x, condition == 'BL',select = -c(condition))
# names(BASE)[2] <- "Baseline"

# OBIWAN_PIT = full_join(OBIWAN_PIT, BASE, by = "id")
#OBIWAN_PIT$gripFreqB = OBIWAN_PIT$gripFreq - OBIWAN_PIT$Baseline 

#now drop baseline trials
OBIWAN_PIT = subset(OBIWAN_PIT, condition != 'BL')
OBIWAN_PIT$condition <- factor(OBIWAN_PIT$condition)

OBIWAN_PIT$trialxcondition <- as.factor(OBIWAN_PIT$trialxcondition)
OBIWAN_PIT = full_join(OBIWAN_PIT, info, by = "id")
OBIWAN_PIT <- OBIWAN_PIT %>% drop_na("condition")
OBIWAN_PIT$gender   <- as.factor(OBIWAN_PIT$gender) #M=0

#take out participants with corrupted data (missing trials or problem during the passation)
OBIWAN_PIT  <- subset(OBIWAN_PIT, id != 242 & id != 256 & id != 106) # missing info or technical issue
#influential data points -> XX

n_tot = length(unique(OBIWAN_PIT$id))

#check for weird behaviors in BsC-> especially in ID.. 201 218 239 242 249 256 259 266 269 267
bs = ddply(OBIWAN_PIT, .(id, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE)) 
#Visible outliers (in descriptive stats) -> stat outliers 130 and 225
#con_106 -> didn't press at all for any -> OUT
#con_122 -> only press for the baseline
#ob_242 -> didn't have the tubes during PIT -. OUT
#ob_249 -> ne fait plus la tache apes 3 essais
#ob_256 -> arrive pas a faire la tache ("pas doué avec les ordis") -> OUT
#ob_259 -> detest le milkshake
#ob_266 -> comprends pas la tache

con = subset(OBIWAN_PIT, group == 'control')
obe = subset(OBIWAN_PIT, group == 'obese')
n_con = length(unique(con$id))
n_obe = length(unique(obe$id))

#check demo
AGE = ddply(OBIWAN_PIT,~group,summarise,mean=mean(age),sd=sd(age))
BMI = ddply(OBIWAN_PIT,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1))
GENDER = ddply(OBIWAN_PIT, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #2 = female

#in other way
CSp = subset(OBIWAN_PIT, condition == 'CSplus')
CSm = subset(OBIWAN_PIT, condition == 'CSminus')
PIT = CSp

PIT$PIT_IND = CSp$gripFreq - CSm$gripFreq

# QUICK STATS -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#scale everything
OBIWAN_PIT$gripsZ = scale(OBIWAN_PIT$gripFreq)
#OBIWAN_PIT$gripsBZ = scale(OBIWAN_PIT$gripFreqB)
OBIWAN_PIT$ageZ = hscale(OBIWAN_PIT$age, OBIWAN_PIT$id) #agragate by subj and then scale 
OBIWAN_PIT$bmiZ = hscale(OBIWAN_PIT$BMI_t1, OBIWAN_PIT$id) #agragate by subj and then scale 

PIT$indZ = scale(PIT$gripFreq)

#************************************************** test (BAD)
mdl.PIT = lmer(gripsZ ~ condition*group + trialxcondition  + (condition|id)+ (condition|trialxcondition), data = OBIWAN_PIT, REML=FALSE)
anova(mdl.PIT)

mdl.ind = lmer(indZ ~ group + trialxcondition  + (1|id)+ (1|trialxcondition), data = PIT, REML=FALSE)
anova(mdl.ind)


# STATS LMM -------------------------------------------------------------------

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

# new ---------------------------------------------------------------------

#model selection #already tried the combination for trialxcondition in another script (we dont have enought to estimate variance)

mod1 = lmer(gripsZ ~ condition*group   + gender + ageZ + (group*condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)
mod2 = lmer(gripsZ ~ condition*group   + gender + ageZ + (group+condition|id)+ (1|trialxcondition), data = OBIWAN_PIT, control=control)
mod3 = lmer(gripsZ ~ condition*group   + gender + ageZ + (condition|id)+ (1|trialxcondition), data = OBIWAN_PIT, control=control)
mod4 = lmer(gripsZ ~ condition*group   + gender + ageZ + (group|id)+ (1|trialxcondition), data = OBIWAN_PIT, control=control)

AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3) # keep it max
AIC(mod4) ; BIC(mod4)

slope.model = lmer(gripsZ ~ condition*group   + gender + ageZ + (1|id)+ (1|trialxcondition), data = OBIWAN_PIT, control=control)
random.slope.model = mod3
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
  geom_abline(aes(intercept=`(Intercept)`, slope=`conditionCSplus` , color=Subject)) +
  # add axis label
  xlab("Condition (CS+) * time (Post)") + ylab("Residual Effort") +
  # set the scale of the plot to something sensible
  scale_x_discrete(limits=c(0,100), expand=c(0,0)) +
  scale_y_continuous(limits=c(-4, 4))

#explicitly check this correlation (between individuals’ intercept and slope residuals)
VarCorr(random.slope.model)
#The correlation between the random intercept and slopes is pretty high, so we keep them


# #model selection #fixed REML FALSE sequential drop --------------------------------------

# 
# mod1 = lmer(gripsZ ~ condition*group  + gender + ageZ + (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
# mod2 = lmer(gripsZ ~ condition*group  + ageZ + (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
# mod3 = lmer(gripsZ ~ condition*group  + gender + (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)
mod4 = lmer(gripsZ ~ condition*group  + (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#mod5 = lmer(gripsZ ~ condition*bmiZ +(condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

# AIC(mod1) ; BIC(mod1)
# AIC(mod2) ; BIC(mod2)
# AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4) # keep it "simple"
#AIC(mod5) ; BIC(mod5)

#CHECK ASSUMPTIONS: REML = TRUE -------------
mod = update(mod4, REML = TRUE)

#1) Multicollinearity / VIF larger than 4 is considered problematic. 
vif(mod) #well good nothing above 4 so no problem keeping everything

#2)Linearity    #3)Homoscedasticity AND #4)Normality of residuals

#super cool sjPlots for checking assumptions ->  weird standard normal qunatiles by random effect (talk to ben)
plot_model(mod, type = "diag")

#5) Absence of influential data points -> 114 & 203

#simple boxplots
boxplot(scale(ranef(mod)$id), las=2)

#disgnostic plots -> Cook's distance / 130 and 225
set.seed(101)
im <- influence(mod,maxfun=100,  group="id")  #takes aa  WHILLLLE

infIndexPlot(im,col="steelblue",
             vars=c("cookd"))


# TEST marginal effects ---------------------------------------------------------
# guidelines of sequential drop 
# m0 <- lmer(Response ~ Y1 + X:Y1 + Y2 + X:Y2 + (XY|subj) + (XY|item),dat,REML=F)
# m1 <- lmer(Response ~ X*Y + (XY|subj) + (XY|item),dat,REML=F)

#___REML=F
##TEST condition:group
full = mod4
#drop inter
null1 = lmer(gripsZ ~ condition + group +  (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.91
test = anova(full, null1, test = "Chisq")
test

#Δ AIC = -1.98
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

#___
##TEST group drop inter
full = null1
#drop main
null = lmer(gripsZ ~ condition + (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.99
test = anova(full, null, test = "Chisq")
test

#Δ AIC = -2.00
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

#_____
##TEST condition drop inter
full = null1
#drop main
null = lmer(gripsZ ~ group +  (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control, REML = FALSE)

#LR test for condition inter p = 0.021
test = anova(full, null, test = "Chisq")
test

#Δ AIC = 3.36
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

#BF Due to the transitive property of Bayes factors, we can easily change the reference model to the main effects model #update(comparison, reference = 3)
#comparison <- bayesfactor_models(full, null, denominator = null) 
#comparison

#EFFECT SIZES # R squared -> really debated though

#Compute the R2 statistic using Nakagawa and Schielzeth's approach
R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors cond = 0.001   + 0.005   - 0.000
R2
#The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 
summary(mod)

#get observed by ID
df.observed = ddply(OBIWAN_PIT, .(id, condition), summarise, fit = mean(gripsZ, na.rm = TRUE)) 

#drop inter so the bootstrpping is faster but doesnt change CI
model = lmer(gripsZ ~ condition + group + (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)

#set options 
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#pred CI #takes aaa whiiile!
pred1 = confint(emmeans(model,list(pairwise ~ condition)), level = .95, type = "response")
df.predicted = data.frame(pred1$`emmeans of condition`)

colnames(df.predicted) <- c("condition", "fit", "SE", "df", "lowCI", "uppCI")

#ploting
df_pred_MI  <- subset(df.predicted, condition == 'CSminus')
df_pred_PL  <- subset(df.predicted, condition == 'CSplus')

df_obs_MI  <- subset(df.observed, condition == 'CSminus')
df_obs_PL  <- subset(df.observed, condition == 'CSplus')

#helpful functions
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')


plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = condition, fill = condition)) +
  #left = empty
  geom_left_violin(data = df_obs_MI, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_errorbar(data= df_pred_MI, aes(x = as.numeric(condition)+0.1, ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4)+
  geom_point(data = df_pred_MI, aes(x = as.numeric(condition)+0.1), shape = 18, color ="black") +
  #right = milkshake
  geom_right_violin(data = df_obs_PL, alpha = .4, position = position_nudge(x = +0.5, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_errorbar(data= df_pred_PL, aes(x = as.numeric(condition)+0.4, ymax = lowCI, ymin = uppCI), width=0.1, alpha=1, size=0.4)+
  geom_point(data = df_pred_PL, aes(x = as.numeric(condition)+0.4,), color ="black", shape = 18) +
  #make it raaiiin
  geom_point(data = df.observed, aes(x = as.numeric(condition) +0.25), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) +
  geom_line(data = df.observed, aes(x = as.numeric(condition) +0.25, group=id),  color ="lightgrey", alpha=0.4,  
            position = position_jitter(width = 0.025, seed = 123)) 


plt1 =  plt +   #details
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-3,3, by = 1)), limits = c(-3,3)) +
  scale_fill_discrete(name = "condition", labels = c("CS-   ", "    CS+")) +
  scale_color_discrete(name = "condition", labels = c("CS-   ", "    CS+")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_blank(),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_blank(), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.4, -0.07),
        legend.title = element_blank(),
        legend.direction = "horizontal",
        legend.text=element_text(size=12),
        legend.spacing.x = unit(0.7, 'cm'),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs(  y = "Mobilized Effort (z)",
         caption = "\n \n \n \nError bars represent 95% CI for the estimated marginal means\n
        Marginal effect (p = 0.021, \u0394 AIC = 3.92, R\u00B2 = 0.00), N = 89") #r2 + 0.038   - 0.017 BF = 4350

plot(plt1)


cairo_pdf(file.path(figures_path,paste(task, 'MAIN_cond_T0.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt1)
dev.off()


# group X condition ------------------------------------------------------------
model = lmer(gripsZ ~ condition + group + condition:group + (condition|id) + (1|trialxcondition), data = OBIWAN_PIT, control=control)

#pred CI #takes aaa whiiile!
pred2 = confint(emmeans(model,list(pairwise ~ condition:group)), level = .95, type = "response")
df.predicted = data.frame(pred2$`emmeans of condition, group`)
colnames(df.predicted) <- c("condition", "group", "fit", "SE", "df", "lowCI", "uppCI")


#custom contrast
con <- list(
  c1 = c(-1, 1, -1, 1) #CS+ Obese&Control > CS- Obese%control, p = 0.035
)

#takes a while
cont = emmeans(model, ~ condition:group, contr = con, adjust = "none")

#ploting
plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = group)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4, position = position_dodge(width = 0.5))+
  geom_line(aes(group=group), alpha=0.4,position = position_dodge(width = 0.5))


plt2 = plt +  #details
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-1,1, by = 0.5)), limits = c(-1,1)) +
  scale_color_discrete(name = "group", labels = c("Lean", "Obese")) +
  scale_x_discrete(labels=c("CSminus" = "CS-", "CSplus" = "CS+")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0.1))) +
  theme_classic() +
  theme(plot.margin = unit(c(1.5, 1, 1.2, 1), units = "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=12,  colour = "black"),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_blank(), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.525, 1.1), legend.title=element_blank(),
        legend.direction = "horizontal",
        legend.text=element_text(size=12),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs( #x = "\nSolution", 
        y = "Mobilized Effort (z)",
        caption = "\n \nTwo-way interaction, p = 0.98, \u0394 AIC = -1.99\n
               Post-hoc test -> No differences found\n
               Main effect of condition, p = 0.035, \u0394 AIC = 3.35, R\u00B2c = 0.001\n
               Error bars represent 95% CI for the estimated marginal means\n                   
               Lean (N = 29), Obese (N = 60)\n  
               LMM : Effort ~ Condition*Group + (Condition|Id) + (1|Trial)\n
               Controling for Age, Gender")


plot(plt2)


cairo_pdf(file.path(figures_path,paste(task, 'condXgroup_T0.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt2)
dev.off()



# interventionxconditionxtime ---------------------------------------------
# plt + 
#   facet_wrap(~ time, labeller=labeller(time = labels))
# 
# 
# plt3 = plt +  #details
#   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-1,1, by = 0.5)), limits = c(-1,1)) +
#   scale_color_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
#   scale_x_discrete(labels=c("Empty" = "Tasteless  ", "MilkShake" = "  Milkshake")) + 
#   guides(fill = guide_legend(override.aes = list(alpha = 0.1))) +
#   theme_bw() +
#   theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
#         panel.grid.major.x = element_blank() ,
#         panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
#         axis.text.x = element_text(size=10,  colour = "black", vjust = 0.5),
#         axis.text.y = element_text(size=12,  colour = "black"),
#         axis.title.x =  element_blank(), 
#         axis.title.y = element_text(size=16),   
#         legend.position = c(0.475, -0.15), legend.title=element_blank(),
#         legend.direction = "horizontal",
#         #legend.spacing.x = unit(1, 'cm'),
#         axis.ticks.x = element_blank(), 
#         axis.line.x = element_blank(),
#         strip.background = element_rect(fill="white"))+ 
#   labs( y = "Plesantness Ratings (z)",
#         caption = "\n \n \n \n \nError bars represent 95% CI for the estimated marginal means\n
#         Placebo (N = 29), Liraglutide (N = 32)\n
#         Three-way interaction (p = 0.73, \u0394 AIC = -1.88)")

#c1 = c(-1, 0, 1, 0), #CS- Obese > CS- Control,  p = 0.9978
#c2 = c(0, -1, 0, 1), #CS+ Obese > CS+ Obese, p = 0.9997

