## R code for FOR HED OBIWAN
# last modified on April 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

# open dataset or load('HED.RData')
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
HED  <- subset(HED_full, session == 'second') 

#merge with info
HED = merge(HED, info, by = "id")

#take out incomplete data ##
`%notin%` <- Negate(`%in%`)
HED = HED %>% filter(id %notin% c(242, 256, 114))

#check for weird behaviors in BsC-> especially in ID.. 267 259 256 242
bs = ddply(HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), intensityZ = mean(intensityZ, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
#Visible outliers (in descriptive stats)
#"Loved (>80) Neutral" : 102 , 219 , 114
#"Hated (>20) Milkshake": 109, 114, 253, 259, 203, 210

# define as.factors
fac <- c("id", "trial", "condition", "trialxcondition", "gender", "group")
HED[fac] <- lapply(HED[fac], factor)

#check demo
n_tot = length(unique(HED$id))

AGE = ddply(HED,~group,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(HED,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(HED, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #2 = female


#scale everything
HED$likZ = scale(HED$perceived_liking)
HED$famZ = scale(HED$perceived_familiarity)
HED$intZ = scale(HED$perceived_intensity)

#agragate by subj and then scale 
HED <- HED %>% 
  group_by(id) %>% 
  mutate(ageZ = scale(age))

#densityPlot(HED$bmiZ) #really bad in terms of normality
#ranktrans BMI
HED$bmiT = RNOmni::rankNorm(HED$BMI_t1)
densityPlot(HED$bmiT)

#change value of groups
HED$group = as.factor(revalue(HED$group, c(control="0", obese="1")))

HED$group2 = c(1:length(HED$group))
HED$group2[HED$BMI_t1 < 30 ] <- '-1' # control BMI = 22.25636 -> 1.03
HED$group2[HED$BMI_t1 >= 30 & HED$BMI_t1 < 35] <- '0' # Class I obesity: BMI = 30 to 35. -> - 0.22
HED$group2[HED$BMI_t1 >= 35] <- '1' # Class II obesity: BMI = 35 to 40. -> 0.89
#HED$group2[HED$BMI_t1 > 40] <- '3' # Class III obesity: BMI 40 or higher -> 1.89

N_group = ddply(HED, .(id, group2), summarise, group=mean(as.numeric(group2)))  %>%
  group_by(group) %>% tally()

#change value of condition
HED$condition = as.factor(revalue(HED$condition, c(Empty="-1", MilkShake="1")))
HED$condition <- factor(HED$condition, levels = c("1", "-1"))

# STATS # LINEAR MIXED EFFECTS : REML = FALSE -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_HED.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))


# PLOT --------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

mod <- lmer(likZ ~ condition*bmiT  + gender + ageZ + famZ + condition*intZ + (condition*intZ + famZ |id) + (1|trialxcondition),
            data = HED, control = control) #need to be fitted using ML so here I just use lmer function so its faster


visreg(mod,overlay=TRUE,points.par=list( alpha = 0.05), xvar="bmiT", by='condition', gg=TRUE,type="contrast",ylab="Liking (z)",breaks=c(-1.03,022,0.89,1.89),xlab="")
#contrasts on estimated means adjusted via the Multivariate normal t distribution
cont = emmeans(mod, pairwise~ condition|bmiT, at = list(bmiT = c(-1,0,1)), adjust = "mvt")
cont
#pwpp(cont$emmeans)
#plot(cont, comparisons = TRUE)
df.HED = as.data.frame(cont$contrasts) 
df.HED$bmiT <- as.character(df.HED$bmiT)

# CSPlus <- subset(HED, condition =="1" )
# CSPlus <- CSPlus[order(as.numeric(levels(CSPlus$id))[CSPlus$id], CSPlus$trialxcondition),]
# CSMinus <- subset(HED, condition =="-1" )
# CSMinus <- CSMinus[order(as.numeric(levels(CSMinus$id))[CSMinus$id], CSPlus$trialxcondition),]
# df.observed = CSPlus
# df.observed$estimate = CSPlus$likZ - CSMinus$likZ
# df.observed$bmiT = df.observed$group2

full.obs = ddply(HED, .(id, group2, condition), summarise, estimate = mean(likZ))
milk = subset(full.obs, condition == '1')
tastless = subset(full.obs, condition == '-1')
df.observed = tastless
df.observed$estimate = milk$estimate - tastless$estimate
df.observed$bmiT = df.observed$group2

labels <- c("-1" = "Lean", "0" = "Class I" , "1" = "II-III")


pl <-  ggplot(df.HED, aes(x = bmiT, y = estimate)) +
  geom_point(data = df.observed, size = 0.1, alpha = 0.7, color = 'seagreen3', position = position_jitter(width = 0.2)) +
  geom_bar(stat="identity", alpha=0.6, width=0.3, ) +
  geom_errorbar(data =df.HED,  aes(ymax = estimate + SE, ymin = estimate - SE), color = 'black', width=0.05,  alpha=0.7)+
  geom_point(size = 0.7, color = 'black') + 
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) 

plt = pl + 
  scale_y_continuous(expand = c(0, 0),
                     breaks = c(seq.int(-3,4, by = 1)), limits = c(-3,4)) +
  scale_x_discrete(labels=labels) +
  theme_bw() +
  theme(aspect.ratio = 1.7/1,
    plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x =  element_text(size=10,  colour = "black"),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16),   
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(title = "Taste contrast between solutions by BMI Category", 
       y =  "\u0394 Pleasantness Ratings", x = "",
       caption = "Error bars represent SEM for the model estimated mean constrasts\n")
#Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")

plot(plt)

cairo_pdf(file.path(figures_path,paste(task, 'condXbmi.pdf',  sep = "_")),
          width     = 5,
          height    = 6)

plot(plt)
dev.off()


# STATS -------------------------------------------------------------------


#save RData for cluster computing
save.image(file = "HED.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)

#Calculates p-values using parametric bootstrap takes forever #set to method LRT to quick check
# PB calculates Nsim samples of the likelihood ratio test statistic (LRT) 

#takes ages even on the cluster!
# method = "PB", control = control, REML = FALSE, args_test = list(nsim = 10))

mdl.aov = aov_4(likZ ~ condition*bmiT + gender + ageZ  +  (condition|id) ,
                data = HED, observed = c("gender", "ageZ"), factorize = FALSE, fun_aggregate = mean)

summary(mdl.aov)

model = mixed(likZ ~ condition*bmiT + gender + ageZ + condition*famZ + condition*intZ + (condition*famZ +condition*intZ |id) + (1|trialxcondition),
              data = HED, method = "LRT", control = control, REML = FALSE)

model #The ‘intercept’ of the lmer model is the mean liking rate in Empty coniditon for an average subject.

# Model:     condition * intZ + (condition * famZ + condition * intZ | 
#   id) + (1 | trialxcondition)
# Data: HED
# Df full model: 33
# Effect df     Chisq p.value
# 1      condition  1 45.64 ***   <.001
# 2           bmiT  1      0.00    .989
# 3         gender  1    3.24 +    .072
# 4           ageZ  1      0.18    .672
# 5           famZ  1 22.49 ***   <.001
# 6           intZ  1      0.01    .921
# 7 condition:bmiT  1      1.22    .269
# 8 condition:famZ  1    3.12 +    .077
# 9 condition:intZ  1 11.28 ***   <.001

mod <- lmer(likZ ~ condition*bmiT  + gender + ageZ + famZ + condition*intZ + (condition*intZ + famZ |id) + (1|trialxcondition),
            data = HED, control = control) #need to be fitted using ML so here I just use lmer function so its faster

# COMPUTE EFFECT SIZES (COMPUTE R Squared For Mixed Models VIA NAKAGAWA ESTIMATE)
R2 = r2beta(mod,method="nsj") #R(m)2, the proportion of variance explained by the fixed predictors
R2 #condition-1 0.069    0.086    0.054

#LR test for condition 
full <- lmer(likZ ~ condition*bmiT  + gender + ageZ + famZ + condition:intZ + (condition*intZ + famZ |id) + (1|trialxcondition),
             data = HED, control = control, REML = FALSE) 
null <- lmer(likZ ~ condition:bmiT  + gender + ageZ + famZ + condition:intZ + (condition*intZ + famZ |id) + (1|trialxcondition),
             data = HED, control = control, REML = FALSE) 
test = anova(full, null, test = "Chisq") #0.472  1  1.994e-10
#Δ AIC = 38.47
delta_AIC = test$AIC[1] - test$AIC[2] 
delta_AIC


# THE END - Special thanks to Ben Meulman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------

