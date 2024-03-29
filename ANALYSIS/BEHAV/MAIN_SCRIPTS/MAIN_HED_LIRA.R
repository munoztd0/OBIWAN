## R code for FOR HEDONIC OBIWAN
# last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, ggplot2, sjPlot, emmeans, misty)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
setwd(analysis_path)
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset or load('HED_LIRA.RData')
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
HED  <- subset(HED_full, group == 'obese') 
intern  <- subset(intern, group == 'obese') 

#merge with info
HED = merge(HED, info, by = "id")

#take out incomplete data #234 only have third session?
`%notin%` <- Negate(`%in%`)
HED = HED %>% filter(id %notin% c(242, 256))
intern = intern %>% filter(id %notin% c(242, 256))


# INTERNAL STATES
baseINTERN = subset(intern, phase == 2)
HED = merge(x = HED, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
diffINTERN = subset(intern, phase == 2 | phase == 3) #before and after HED
before = subset(diffINTERN, phase == 2)
after = subset(diffINTERN, phase == 3)
diff = after
diff$diff_piss = diff$piss - before$piss
diff$diff_thirsty = diff$thirsty - before$thirsty
diff$diff_hungry = diff$hungry - before$hungry

HED = merge(x = HED, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)

# define as.factors
fac <- c("id", "trial", "condition", "session", "trialxcondition", "gender", "intervention")
HED[fac] <- lapply(HED[fac], factor)


#check demo
n_tot = length(unique(HED$id))
bs = ddply(HED, .(id, session), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

n_pre = length(which(bs$session == "second"))
n_post = length(which(bs$session == "third"))

AGE = ddply(HED,~session,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(HED,~session,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(HED, .(id, session), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, session) %>%
  tally() #2 = female

HED$idXsession = as.numeric(HED$id) * as.numeric(HED$session)

# Center level-1 predictor within cluster (CWC)
HED$likC = center(HED$perceived_liking, type = "CWC", group = HED$idXsession)
HED$famC = center(HED$perceived_familiarity, type = "CWC", group = HED$idXsession)
HED$intC = center(HED$perceived_intensity, type = "CWC", group = HED$idXsession)

# Center level-2 predictor at the grand mean (CGM)
HED <- HED %>% group_by(idXsession) %>% mutate(pissC = center(piss))
HED <- HED %>% group_by(idXsession) %>% mutate(thirstyC = center(thirsty))
HED <- HED %>% group_by(idXsession) %>% mutate(hungryC = center(hungry))
HED <- HED %>% group_by(idXsession) %>% mutate(diff_pissC = center(diff_piss)) 
HED <- HED %>% group_by(idXsession) %>% mutate(diff_thirstyC = center(diff_thirsty))
HED <- HED %>% group_by(idXsession) %>% mutate(diff_hungryC = center(diff_hungry))
HED <- HED %>% group_by(id) %>% mutate(ageC = center(age))
HED <- HED %>% group_by(id) %>% mutate(diff_bmiC = center(BMI_t1 - BMI_t2))
HED <- HED %>% group_by(id) %>% mutate(bmiC = center(BMI_t1))


#change value of sessions
HED$time = revalue(HED$session, c(second="0", third="1"))

#change value of condition
HED$condition = as.factor(revalue(HED$condition, c(Empty="-1", MilkShake="1")))
HED$condition <- factor(HED$condition, levels = c("1", "-1"))

# save RData for cluster computing
save.image(file = "HED_LIRA.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meuleman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_HED.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

# mdl.aov = aov_4(likC~ condition*intervention*time +gender + ageC+ bmiC+ diff_bmiC+  hungryC+ thirstyC+ pissC+  (condition * time |id) ,
#                 data = HED, factorize = FALSE, fun_aggregate = mean)
# 
# summary(mdl.aov)

model = mixed(likC ~ condition*intervention*time + diff_bmiC  + condition:intC + condition:famC +(time*condition|id) + (1|trialxcondition), 
              data = HED, method = "LRT", control = control, REML = FALSE)

model #The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 



# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: likC ~ condition * intervention * time + diff_bmiC:condition + 
#   Model:     pissC:condition + thirstyC:condition + hungryC:condition + 
#   Model:     condition:intC + condition:famC + (time * condition | id) + 
#   Model:     (1 | trialxcondition)
# Data: HED
# Df full model: 32
# Effect df       Chisq p.value
# 1                    condition  1   19.82 ***   <.001
# 2                 intervention  1        0.20    .656
# 3                         time  1     8.98 **    .003
# 4       condition:intervention  1        0.03    .871
# 5               condition:time  1      4.29 *    .038
# 6            intervention:time  1        1.37    .242
# 7          condition:diff_bmiC  2        0.17    .919
# 8              condition:pissC  2        0.04    .982
# 9           condition:thirstyC  2        0.13    .936
# 10           condition:hungryC  2        0.07    .966
# 11              condition:intC  2  333.74 ***   <.001
# 12              condition:famC  2 2120.00 ***   <.001
# 13 condition:intervention:time  1        0.05    .820


mod <- lmer(likC ~ condition*intervention*time + diff_bmiC+ condition:intC + condition:famC +(time*condition|id) + (1|trialxcondition) , 
            data = HED, control = control) #need to be fitted using ML so here I just use lmer function so its faster
#ref.grid(mod)

#get CI and pval for inter
p_inter = emmeans(mod, ~ condition:time)
con_inter <- contrast(p_inter, interaction = 'pairwise', by = c('time'), side = ">")
con_inter





con <- list(
  #group1
  c10 = c(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0), #Post: Milk Placebo > Tasteless- Placebo
  c20 = c(0, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0), #Post: Milk Lira > Tasteless Lira
  c30 = c(0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), #Pre: Milk Lira > Tasteless Lira
  c40 = c(-1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), #Pre: Milk Placebo > Tasteless Placebo
  #group2
  c11 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1, 0), #Post: Milk Placebo > Tasteless- Placebo
  c21 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1), #Post: Milk Lira > Tasteless Lira
  c31 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0), #Pre: Milk Lira > Tasteless Lira
  c41 = c(0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0) #Pre: Milk Placebo > Tasteless Placebo
)

#contrasts on estimated means adjusted via the Multivariate normal t distribution
cont = emmeans(mod, ~ intervention:condition:time:group2, contr = con, adjust = "mvt")
#cont = confint(emmeans(mod,~ intervention:condition:time:group2, contr = con,adjust = "mvt"), level = .95, type = "response")


#plot(cont$contrasts, comparisons = TRUE)
df.HED = as.data.frame(cont$contrasts) 
intervention = c(0, 1, 1, 0, 0, 1, 1, 0)
time = c(1, 1, 0, 0, 1, 1, 0, 0)
group2 = c(0, 0, 0, 0, 1, 1, 1, 1)
df.HED = cbind(df.HED, intervention, time, group2)
fac <- c("intervention", "time", "group2")
df.HED[fac] <- lapply(df.HED[fac], factor)

full.obs = ddply(HED, .(id, group2, intervention, time, condition), summarise, estimate = mean(likC)) 
plus = subset(full.obs, condition == 'MilkShake')
minus = subset(full.obs, condition == 'Empty')
df.observed = minus
df.observed$estimate = plus$estimate - minus$estimate
df.observed$bmiT = df.observed$group2

labelsSES <- c("0" = "Pre-Test", "1" = "Post-Test")
labelsOB <- c("0" = "Obese Class I" , "1" = "Class II-III")
labelsTRE <- c("0" = "Placebo" , "1" = "Liraglutide")

pl <-  ggplot(df.HED, aes(x = group2, y = estimate, color = intervention)) +
  geom_bar(aes(y = estimate, x = group2, group = intervention), stat="identity", alpha=0.6, width=0.3, color  = 'lightgrey', fill  = 'lightgrey', position = position_dodge(0.4)) +
  geom_errorbar(aes(ymax = estimate + SE, ymin = estimate - SE), width=0.1,  alpha=0.7, position = position_dodge(0.4))+
  geom_point(size = 0.5,  position = position_dodge(0.4)) +  #color = 'blue'
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) + 
  geom_point(data = df.observed, size = 0.1, alpha = 0.6,  position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.4)) + #, color = 'royalblue'
  facet_wrap(~ time, labeller=labeller(time = labelsSES))

plt = pl + 
  scale_y_continuous(expand = c(0, 0),
                     breaks = c(seq.int(-2,3, by = 1)), limits = c(-2,3)) +
  scale_x_discrete(labels=labelsOB) +
  scale_color_manual(labels=labelsTRE, values = c('seagreen3', 'royalblue')) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        #axis.text.x =  element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16), 
        legend.title = element_blank(),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "Taste contrast between solutions by Session", 
       y =  "\u0394 Pleasantness Ratings", x = "",
       caption = "Error bars represent SEM for the model estimated mean constrasts\n")
#Main effect of condition, p <.001, \u0394 AIC = 4.42, Controling for Fam, Int, Age & Gender")


plot(plt)

cairo_pdf(file.path(figures_path,paste(task, 'condXtreat.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt)
dev.off()











#save RData for cluster computing
save.image(file = "HED_LIRA.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)
#Calculates p-values using parametric bootstrap takes forever #set to method LRT to quick check
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 

#takes ages even on the cluster!
# model = mixed(likC ~ condition*time*intervention + gender + ageC +  diff_bmiC + famC * intC +(time*condition +famC*intC|id) + (1|trialxcondition) , 
#       data = HED, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 100))

model = mixed(likC ~ condition*time*intervention + gender + ageC + diff_bmiC + famC * condition:intC +(time*condition +famC +condition:intC|id) + (1|trialxcondition) , 
              data = HED, method = "LRT", control = control, REML = FALSE)

summary(model) #The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: likC ~ condition * time * intervention + gender + ageC + diff_bmiC + 
#   Model:     famC * intC + (time * condition + famC * intC | id) + (1 | 
#                                                                       Model:     trialxcondition)
# Data: HED
# Df full model: 44
#                         Effect df     Chisq p.value
# 1                    condition  1 22.61 ***   <.001
# 2                         time  1    4.05 *    .044
# 3                 intervention  1      0.32    .570
# 4                       gender  1      1.01    .315
# 5                         ageC  1      0.37    .541
# 6                    diff_bmiC  1      0.01    .906
# 7                         famC  1 30.71 ***   <.001
# 8                         intC  1      0.05    .820
# 9               condition:time  1    4.96 *    .026
# 10      condition:intervention  1      0.29    .590
# 11           time:intervention  1      1.59    .208
# 12                   famC:intC  1      1.85    .173
# 13 condition:time:intervention  1      0.40    .529


# COMPUTE EFFECT SICES (COMPUTE R Squared For Mixed Models VIA NAKAGAWA ESTIMATE)
mod <- lmer(likC ~ condition*time*intervention + gender + ageC + diff_bmiC + famC * intC +(time*condition +famC*intC|id) + (1|trialxcondition) , 
            data = HED, control = control) #need to be fitted using ML so here I just use lmer function so its faster

R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors 


#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so no problem keeping everything

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points -> 228 & 235
#simple univariate boxplots
boxplot(scale(ranef(mod)$id), las=2)

#disgnostic plots -> Cook's distance
set.seed(101)
im <- influence(mod,maxfun=100,  group="id")  #takes forever
infIndexPlot(im,col="steelblue", vars=c("cookd"))






#pred CI #takes forever
#pred = confint(emmeans(mod,list(pairwise ~ intervention:condition:time)), level = .95, type = "response")
pred = emmeans(mod,list(pairwise ~ intervention:condition:time))
df.predicted = data.frame(pred$`emmeans of intervention, condition, time`)
colnames(df.predicted) <- c("intervention", "condition", "time",  "fit", "SE", "df", "lowCI", "uppCI")


cont = emmeans(mod, pairwise~ condition|bmiT, at = list(bmiT = c(-1,0,1)), adjust = "mvt")
cont
#pwpp(cont$emmeans)
#plot(cont, comparisons = TRUE)
df.HED = as.data.frame(cont$contrasts) 
df.HED$bmiT <- as.character(df.HED$bmiT)

full.obs = ddply(HED, .(id, group2, condition), summarise, estimate = mean(likC)) 
milk = subset(full.obs, condition == '1')
tastless = subset(full.obs, condition == '-1')
df.observed = tastless
df.observed$estimate = milk$estimate - tastless$estimate
df.observed$bmiT = df.observed$group2

#custom contrasts
# con <- list(
#   c1 = c(0, 0, 0, 0, 1, -1, 0, 0), #Post: empty Placebo > empty- Lira
#   c2 = c(0, 0, 0, 0, 0, 0, 1, -1), #Post: MS Placebo > MS Lira
#   c3 = c(0, 0, 1, -1, 0, 0, 0, 0), #Pre: MS Placebo > MS Lira
#   c4 = c(1, -1, 0, 0, 0, 0, 0, 0) #Pre: empty Placebo > empty Lira
# )

#contrasts on estimated means adjusted via the Multivariate normal t distribution
#cont = emmeans(mod, ~ intervention:condition:time, contr = con, adjust = "mvt")

#facet wrap labels
labels <- c("0" = "Pre-Test", "1" = "Post-Test")

plt <-  ggplot(df.predicted, aes(x = condition, y = fit, color = intervention)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = fit + SE, ymin = fit - SE), width=0.1,  alpha=1, size=0.4, position = position_dodge(width = 0.5))+
  geom_line(aes(group=intervention), alpha=0.4,position = position_dodge(width = 0.5)) + 
  facet_wrap(~ time, labeller=labeller(time = labels))

plt3 = plt +  #details to make it look good
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-1,1, by = 0.5)), limits = c(-1,1)) +
  scale_color_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
  scale_x_discrete(labels=c("Empty" = "Tasteless  ", "MilkShake" = "  Milkshake")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0.1))) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_text(size=16), 
        axis.title.y = element_text(size=16),  
        legend.title = element_blank(),
        #legend.position = c(0.475, -0.2),
        #legend.direction = "horizontal", #legend.spacing.x = unit(1, 'cm'),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs( title = "Hedonic Pleasure by Session", 
        y = "Plesantness Ratings (z)",x = "",
        caption = "Error bars represent SEM for the estimated marginal means")
        #\n \n \n \n \nThree-way interaction, p = 0.73, \u0394 AIC = -1.88\n
        #Post-hoc test -> No differences found\n
        #Main effect of condition, p < 0.0001, \u0394 AIC = 23.02, R\u00B2 = 0.030\n
        #Error bars represent 95% CI for the estimated marginal means\n
        #Placebo (N = 29), Liraglutide (N = 32)\n
        #LMM : Pleasantness ~ Condition*Time*Treatment + (Time*Condition|Id) + (1|Trial)\n
        #Controling for Intensity, Familiarity, Age, Gender & Weight Loss (BMI pre - BMI post)")

plot(plt3)

cairo_pdf(file.path(figures_path,paste(task, 'condXtreatXtime_Lira.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt3)
dev.off()


# THE END - Special thanks to Ben Meuleman and Yoann Stussi -----------------------------------------------------------------

