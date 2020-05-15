## R code for FOR OBIWAN effect of TREATMENT on the OVERALL WEIGHT LOSS
## last modified on August 2020 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, ggplot2, sjPlot, influence.ME, emmeans, MBESS)


# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV')
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 
setwd(analysis_path)


# open dataset or load('info.RData')
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

info$bmi_diff = info$BMI_t1 - info$BMI_t2 

info <- info %>% drop_na("bmi_diff")


#check demo
n_tot = length(unique(info$id))

AGE = ddply(info,~intervention,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI_T1 = ddply(info,~intervention,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
BMI_T2 = ddply(info,~intervention,summarise,mean=mean(BMI_t2),sd=sd(BMI_t2), min = min(BMI_t2), max = max(BMI_t2))
BMI_diff = ddply(info,~intervention,summarise,mean=mean(bmi_diff),sd=sd(bmi_diff), min = min(bmi_diff), max = max(bmi_diff))
GENDER = ddply(info, .(id, intervention), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, intervention) %>%
  tally() #2 = female

#scale everything and recode everything
info$ageZ = scale(info$age)
info$diffZ = scale(info$bmi_diff)
info$bmi_pre = scale(info$BMI_t1)
info$gender    <- as.factor(info$gender)
info$intervention   <- as.factor(info$intervention)

# STATS -------------------------------------------------------------------

#save RData for cluster computing
save.image(file = "info.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman


mdl.weight = aov_4(diffZ ~ intervention + gender + ageZ + intervention:gender + intervention:ageZ + bmi_pre + (1|id), 
                   data = info, observed = c("gender", "ageZ", "bmi_pre"), factorize = FALSE, afex_options(type = 2)) # bc interaction are not sign

res = nice(mdl.weight) #create nice table
res

# Anova Table (Type 2 tests)
# 
# Response: diffZ
# Effect    df  MSE         F  ges p.value
# 1        intervention 1, 49 0.49 50.15 ***  .46  <.0001
# 2              gender 1, 49 0.49      0.08 .001     .78
# 3                ageZ 1, 49 0.49    4.83 *  .08     .03
# 4             bmi_pre 1, 49 0.49      1.72  .03     .20
# 5 intervention:gender 1, 49 0.49      0.72  .01     .40
# 6   intervention:ageZ 1, 49 0.49    3.14 +  .05     .08

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/pes_ci.R') #calculate PES and CI modified from Yoann

PES = pes_ci(diffZ ~ intervention + gender + ageZ + intervention:gender + intervention:ageZ + bmi_pre + Error(id), data = info, 
                    conf.level = .90, anova.type = 2, observed = c("gender", "ageZ", "bmi_T0"), factorize = FALSE) #type 2 because inter no sign

#drop inter so the bootstrpping is faster but doesnt change CI
model = mdl.weight

#get observed by ID and call it $fit so its easier to plot
df.observed = ddply(info, .(id, intervention), summarise, fit = mean(diffZ, na.rm = TRUE)) 

emm_options(pbkrtest.limit = 5000) #set options 

#pred CI 
pred = confint(emmeans(model,list(pairwise ~ intervention)), level = .95, type = "response")
df.predicted = data.frame(pred$`emmeans of intervention`)

colnames(df.predicted) <- c("intervention", "fit", "SE", "df", "lowCI", "uppCI")

#ploting _____
df_pred_PL  <- subset(df.predicted, intervention == '0')
df_pred_LI  <- subset(df.predicted, intervention == '1')

df_obs_PL  <- subset(df.observed, intervention == '0')
df_obs_LI  <- subset(df.observed, intervention == '1')

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful [plotting functions

plt <-  ggplot(df.predicted, aes(x = intervention, y = fit, color = intervention, fill = intervention)) +
  #left = PL
  geom_left_violin(data = df_obs_PL, alpha = .4, adjust = 1.5, trim = F, color = NA) + 
  geom_errorbar(data= df_pred_PL, aes(x = as.numeric(intervention)+0.1, ymax = lowCI, ymin = uppCI), width=0.1,  alpha=1, size=0.4)+
  geom_point(data = df_pred_PL, aes(x = as.numeric(intervention)+0.1), shape = 18, color ="black") +
  #right = LI
  geom_right_violin(data = df_obs_LI, alpha = .4, position = position_nudge(x = +0.5, y = 0), adjust = 1.5, trim = F, color = NA) + 
  geom_errorbar(data= df_pred_LI, aes(x = as.numeric(intervention)+0.4, ymax = lowCI, ymin = uppCI), width=0.1, alpha=1, size=0.4)+
  geom_point(data = df_pred_LI, aes(x = as.numeric(intervention)+0.4,), color ="black", shape = 18) +
  #make it raaiiin
  geom_point(data = df.observed, aes(x = as.numeric(intervention) +0.25), alpha=0.5, size = 0.5, 
             position = position_jitter(width = 0.025, seed = 123)) 


plt1 =  plt +   #details to make it look good
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-2,3, by = 1)), limits = c(-2,3)) +
  scale_fill_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) +
  scale_color_discrete(name = "intervention", labels = c("Placebo", "Liraglutide (3.0 mg) ")) + 
  guides(fill = guide_legend(override.aes = list(alpha = 0))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_blank(),
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.title.x = element_blank(), 
        axis.title.y = element_text(size=16),   
        legend.position = c(0.45, -0.15),
        legend.title = element_blank(),
        legend.direction = "horizontal",
        legend.text=element_text(size=12),
        legend.spacing.x = unit(0.7, 'cm'),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank()) + 
  labs(  y = "\u0394 BMI (z)",
         caption = "\n \n \n \nMain effect of Treatment, p < 0.0001\n
         Effect size, \u03B7p\u00B2 = 0.51, 90%CI [0.33,0.62]\n
         Error bars represent 95% CI for the estimated marginal means\n
         Placebo (N = 31), Liraglutide (N = 25)\n
         Controling for Age, Gender & Baseline BMI")


plot(plt1)


cairo_pdf(file.path(figures_path,'WeightXTreat.pdf'),
          width     = 5.5,
          height    = 6)

plot(plt1)
dev.off()

# pla  <- subset(info, intervention == '0')
# length(unique(pla$id))
# lir  <- subset(info, intervention == '1')
# length(unique(lir$id))

