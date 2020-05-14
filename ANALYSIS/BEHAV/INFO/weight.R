## R code for FOR OBIWAN GENERAL
# last modified on August 2020 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, ggplot2, Rmisc, dplyr, lmerTest, car, r2glmm, optimx, visreg, MuMIn,  pbkrtest, bootpredictlme4, sjPlot, emmeans, bayestestR)


# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

info$bmi_diff = info$BMI_t1 - info$BMI_t2 

info <- info %>% drop_na("bmi_diff")


# QUICK STATS -------------------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

#scale everything
info$ageZ = hscale(info$age, info$id) #agragate by subj and then scale
info$diffZ = hscale(info$bmi_diff, info$id) #agragate by subj and then scale
info$bmi_T0 = hscale(info$BMI_t1, info$id) #agragate by subj and then scale
info$gender      <- as.factor(info$gender)
info$intervention      <- as.factor(info$intervention)

#************************************************** test (BAD)
mdl.weight = aov_4(diffZ ~ intervention + gender + ageZ + intervention:gender + intervention:ageZ + bmi_T0 + (1|id), 
                    data = info, observed = c("gender", "ageZ", "bmi_T0"), factorize = FALSE)

res = summary(mdl.weight)
#                   num Df den Df    MSE       F     ges    Pr(>F)    
# intervention             1     49 0.48512 45.6974 0.42686 1.562e-08 ***
#   gender                   1     49 0.48512  0.0232 0.00038   0.87946    
# ageZ                     1     49 0.48512  6.7561 0.11011   0.01231 *  
#   bmi_T0                   1     49 0.48512  1.7202 0.02804   0.19578    
# intervention:gender      1     49 0.48512  0.7189 0.01172   0.40061    
# intervention:ageZ        1     49 0.48512  3.1379 0.05114   0.08271 .


source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/pes_ci.R') #calculate PES and CI modified from Yoann

PES.weight = pes_ci(diffZ ~ intervention + gender + ageZ + intervention:gender + intervention:ageZ + bmi_T0 + Error(id), data = info, 
       conf.level = .90, anova.type = 2, observed = c("gender", "ageZ", "bmi_T0"), factorize = FALSE) #type 2 because inter no sign

#drop inter so the bootstrpping is faster but doesnt change CI
model = mdl.weight

#get observed by ID
df.observed = ddply(info, .(id, intervention), summarise, fit = mean(diffZ, na.rm = TRUE)) 

#set options 
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#pred CI #takes aaa whiiile!
pred1 = confint(emmeans(model,list(pairwise ~ intervention)), level = .95, type = "response")
df.predicted = data.frame(pred1$`emmeans of intervention`)

colnames(df.predicted) <- c("intervention", "fit", "SE", "df", "lowCI", "uppCI")

#ploting _____
df_pred_PL  <- subset(df.predicted, intervention == '0')
df_pred_LI  <- subset(df.predicted, intervention == '1')

df_obs_PL  <- subset(df.observed, intervention == '0')
df_obs_LI  <- subset(df.observed, intervention == '1')

#helpful functions
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')

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
  #geom_line(data = df.observed, aes(x = as.numeric(intervention) +0.25, group=id),  color ="lightgrey", alpha=0.4,  
            #position = position_jitter(width = 0.025, seed = 123)) 


plt1 =  plt +   #details
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

