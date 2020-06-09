## R code for FOR PIT OBIWAN
# last modified on April 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni)

# SETUP ------------------------------------------------------------------

task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

# open dataset or load('PIT.RData')
PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PIT  <- subset(PIT_full, session == 'second') 
HED  <- subset(HED_full, session == 'second') 

#merge with info
PIT = merge(PIT, info, by = "id")

#take out incomplete data ##218 only have the third ? influence -> 238 & 234 & 232 & 254
`%notin%` <- Negate(`%in%`)
PIT = PIT %>% filter(id %notin% c(242, 256, 106))
HED = HED %>% filter(id %notin% c(242, 256, 106))

# define as.factors
fac <- c("id", "trial", "condition", "trialxcondition", "gender", "group")
PIT[fac] <- lapply(PIT[fac], factor)

#check demo
n_tot = length(unique(PIT$id))
bs = ddply(PIT, .(id, group), summarise, gripFreq = mean(gripFreq, na.rm = TRUE), peak = mean(peak, na.rm = TRUE), AUC = mean(AUC, na.rm = TRUE)) 
bs$AUC = scale(bs$AUC)
densityPlot(bs$AUC)
#skewness(bs$AUC) not bad

AGE = ddply(PIT,~group,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PIT,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PIT, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #2 = female

#remove the baseline from other trials by id ##but double check
PIT =  subset(PIT, condition != 'BL') 

PIT_BL = ddply(PIT, .(id), summarise, freqA=mean(AUC), sdA=sd(AUC)) 
PIT = merge(PIT, PIT_BL, by = "id")
PIT$gripAUC = (PIT$AUC - PIT$freqA) / PIT$sdA

HED_BL = ddply(HED, .(id,condition), summarise, lik=mean(perceived_liking)) 
HED_BL = subset(HED_BL, condition == 'MilkShake') 
HED_BL = select(HED_BL, -c(condition) )
PIT = merge(PIT, HED_BL, by = "id")

#scale everything
PIT$gripAUCZ = scale(PIT$gripAUC)
densityPlot(PIT$gripAUCZ)

bsZ = ddply(PIT, .(id, condition), summarise, gripCOUNTZ = mean(gripCOUNTZ, na.rm = TRUE), gripAUCZ = mean(gripAUCZ, na.rm = TRUE)) 

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(likZ = scale(lik))

#agragate by subj and then scale 
PIT <- PIT %>% 
  group_by(id) %>% 
  mutate(ageZ = scale(age))

#agragate by subj and then scale 
control <- subset(PIT, group == '0') 
mean_con = mean(control$BMI_t1)

#densityPlot(PIT$bmiZ) #really bad in terms of normality
#ranktrans BMI
PIT$bmiT = RNOmni::rankNorm(PIT$BMI_t1)
densityPlot(PIT$bmiT)

#change value of groups
PIT$group = as.factor(revalue(PIT$group, c(control="0", obese="1")))


PIT$group2 = c(1:length(PIT$group))
PIT$group2[PIT$BMI_t1 < 30 ] <- '0' # control BMI = 22.25636 -> 1.03
PIT$group2[PIT$BMI_t1 >= 30 & PIT$BMI_t1 < 35] <- '1' # Class I obesity: BMI = 30 to 35. -> - 0.22
PIT$group2[PIT$BMI_t1 >= 35] <- '2' # Class II obesity: BMI = 35 to 40. -> 0.89
#PIT$group2[PIT$BMI_t1 > 40] <- '3' # Class III obesity: BMI 40 or higher -> 1.89

N_group = ddply(PIT, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

#change value of condition
PIT$condition = as.factor(revalue(PIT$condition, c(CSminus="-1", CSplus="1")))
PIT$condition <- factor(PIT$condition, levels = c("1", "-1"))

CSPlus <- subset(PIT, condition =="1" )
CSPlus <- CSPlus[order(as.numeric(levels(CSPlus$id))[CSPlus$id], CSPlus$trialxcondition),]
CSMinus <- subset(PIT, condition =="-1" )
CSMinus <- CSMinus[order(as.numeric(levels(CSMinus$id))[CSMinus$id], CSPlus$trialxcondition),]

PIT_ind = CSPlus
PIT_ind$gripdiff = CSPlus$gripAUCZ - CSMinus$gripAUCZ

mod <- lmer(gripdiff ~  group2 + gender + ageZ + likZ +(1 |id) + (1|trialxcondition) , 
            data = PIT_ind, control = control) #need to be fitted using ML so here I just use lmer function so its faster

#visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="group2", gg=TRUE,type="contrast",ylab="Effort (z)",breaks=c(-1.03,022,0.89,1.89),xlab="")

mdl.aov = aov_4(gripdiff ~ group2 + gender + ageZ +  (1|id) ,
                data = PIT_ind, observed = c("gender", "ageZ"), factorize = FALSE, fun_aggregate = mean)

summary(mdl.aov)

cont = emmeans(mod, pairwise~ group2, adjust = "mvt")
cont


model = mixed(gripdiffZ ~ bmiT + gender + ageZ  + (1|id), 
              data = PIT_ind, method = "LRT", control = control, REML = FALSE)
model

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PIT.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#save RData for cluster computing
# save.image(file = "PIT.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

#Calculates p-values using parametric bootstrap takes forever #set to method LRT to quick check
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 

#takes ages even on the cluster!
# method = "PB", control = control, REML = FALSE, args_test = list(nsim = 10))

PIT$gripZ = PIT$gripAUCZ
# mdl.aov = aov_4(gripZ ~ condition*bmiT + gender + ageZ  +  (condition|id) , 
#                 data = PIT, observed = c("gender", "ageZ"), factorize = FALSE, fun_aggregate = mean)
# 
# summary(mdl.aov)

# model = mixed(gripZ ~ condition*bmiT + gender + ageZ + likZ + (condition|id) + (1|trialxcondition), 
#               data = PIT, method = "LRT", control = control, REML = FALSE)
# 
# model #The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject. 

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: gripZ ~ condition * bmiT + gender + ageZ + likZ + (condition | 
#                                                             Model:     id) + (1 | trialxcondition)
# Data: PIT
# Df full model: 12
# Effect df  Chisq p.value
# 1      condition  1 5.23 *    .022
# 2           bmiT  NaN
# 3         gender  1   0.00    .969
# 4           ageZ  1   0.00    .984
# 5           likZ  1   0.00    .986
# 6 condition:bmiT  1 3.40 +    .065

mod <- lmer(gripZ ~ condition*bmiT  +(condition |id) + (1|trialxcondition) , 
            data = PIT, control = control) #need to be fitted using ML so here I just use lmer function so its faster
#+ gender + ageZ + likZ
# COMPUTE EFFECT SIZES (COMPUTE R Squared For Mixed Models VIA NAKAGAWA ESTIMATE)
R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors 
R2 #conditionCSplus 0.005    0.012    0.001

#LR test for condition 
full <- lmer(gripZ ~ condition*bmiT + gender + ageZ + likZ +(condition |id) + (1|trialxcondition) , 
            data = PIT, control = control, REML = FALSE) 
null <- lmer(gripZ ~ condition:bmiT + gender + ageZ + likZ +(condition |id) + (1|trialxcondition) , 
             data = PIT, control = control, REML = FALSE) 
test = anova(full, null, test = "Chisq") #4.5005  1    0.03388

#Δ AIC = 2.5
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC

# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions
visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="bmiT", gg=TRUE,type="contrast",ylab="Effort (z)",breaks=c(-1.03,022,0.89,1.89),xlab="")
#contrasts on estimated means adjusted via the Multivariate normal t distribution
cont = emmeans(mod, pairwise~ condition|bmiT, at = list(bmiT = c(-1.03,0.22,0.89,1.89)), adjust = "mvt")
cont
#pwpp(cont$emmeans)
#plot(cont, comparisons = TRUE)

df = as.data.frame(cont$contrasts) 
df.PIT = df[9:12,]
df.PIT$bmiT <- as.factor(df.PIT$bmiT)


labels <- c("-1.03" = "Lean", "0.22" = "Obese Class I" , "0.89" = "Obese Class II", "1.89" = "Obese Class III")

plt_PIT <-  ggplot(df.PIT, aes(x = bmiT, y = emmean)) +
  geom_bar(stat="identity", alpha=0.6, fill = 'royalblue', width=0.3, ) +
  geom_errorbar(aes(ymax = emmean + SE, ymin = emmean - SE), width=0.1,  alpha=1, size=0.4)+
  geom_point(size = 0.5)

 plt_PIT + 
   scale_y_continuous(expand = c(0, 0),
                      breaks = c(seq.int(-0.1,0.5, by = 0.1)), limits = c(-0.1,0.5)) +
   scale_x_discrete(labels=labels) + 
   theme_bw() +
   theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
         plot.caption = element_text(hjust = 0.5),
         panel.grid.major.x = element_line(size=.2, color="lightgrey") ,
         panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
         #axis.text.x =  element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
         axis.text.y = element_text(size=10,  colour = "black"),
         axis.title.x =  element_text(size=16), 
         axis.title.y = element_text(size=16),   
         axis.ticks.x = element_blank(), 
         axis.line.x = element_blank(),
         strip.background = element_rect(fill="white"))+ 
   labs(y = "PIT Effect (\u0394 Mobilized Effort CS+ & CS-)",
        caption = "Error bars represent SEM for the model estimated mean constrasts\n")
            #Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")
 

df.predicted <- ggeffects::ggpredict(
  model = mod,
  terms = c("condition", "bmiT [-1.03,0.22,0.89,1.89]"),
  ci.lvl = 0.95,
  type = "fe")

df.predicted <- tibble(df.predicted)
df.predicted$bmiT <- df.predicted$group
df.predicted$condition <- df.predicted$x
#get observed by ID

df.observed = ddply(PIT, .(id, condition, bmiT), summarise, predicted = mean(gripZ, na.rm = TRUE)) 

#facet wrap labels
labels <- c("-1.03" = "Lean", "0.22" = "Obese Class I" , "0.89" = "Obese Class II", "1.89" = "Obese Class III")

plt <-  ggplot(df.predicted, aes(x = condition, y = predicted, color=condition)) +
  geom_point(data = df.observed, alpha=0.1, position = position_jitter(width = 0.1)) +
  geom_point(data = df.predicted, position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = conf.low, ymin = conf.high), width=0.1,  alpha=1, size=0.4, position = position_dodge(width = 0.5))+
  facet_wrap(~ group, labeller=labeller(group = labels))

plt3 = plt +  #details to make it look good
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-1,1, by = 0.5)), limits = c(-1,1)) +
  #scale_color_discrete(name = "condition", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
  scale_color_discrete(labels=c("CSminus" = "CS-  ", "CSplus" = "  CS+")) + 
  #guides(color = guide_legend(override.aes = list(alpha = 0.1))) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x =  element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x =  element_blank(), #element_text(size=16), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.475, -0.1), legend.title=element_blank(),
        legend.direction = "horizontal", 
        legend.text = element_text(size=16),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(y = "Mobilized Effort (z)",
        caption = "\n \n \n \n \n
            Error bars represent 95% CI for the model estimated means\n
            Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")

plot(plt3)

cairo_pdf(file.path(figures_path,paste(task, 'condXbmi.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plt3)
dev.off()


# THE END - Special thanks to Ben Meulman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------

