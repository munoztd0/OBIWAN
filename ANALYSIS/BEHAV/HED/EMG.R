## R code for FOR REWOD GENERAL
# last modified on August 2019 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, mosaic, car, purrr)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}




#SETUP
task = 'hedonic'
GLM = '18'
con2 = 'reward-neutral'

mod2 = 'EMG'



## R code for FOR REWOD_HED
# Set working directory -------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS', task) 
setwd(analysis_path)

# open dataset 18 !
BETAS_R_N <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_', paste('GLM_',GLM,sep="") ,'.txt',sep="")), header = T, sep ='\t') # read in dataset


EMG_R_N <- read.delim(file.path(analysis_path, paste('GLM-',GLM,sep=""), 'group_covariates', paste('REV_', con2,'_', mod2, '_zscore.txt',sep="")), header = T, sep ='\t') # read in dataset

# merge
R_N_EMG = merge(BETAS_R_N, EMG_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)


# define factors
R_N_EMG$ID <- factor(R_N_EMG$ID)



# PLOT FUNCTIONS --------------------------------------------------------------------

ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                       #"Intercept =",signif(fit$coef[[1]],5 ),
                       #" Slope =",signif(fit$coef[[2]], 5),
                       "  &  P =",signif(summary(fit)$coef[2,4], 5)))+
    theme(plot.title = element_text(size = 10, hjust =1))
  
}




#  Plot for R_N  ----------------------------------------------------------
##################

R_N_EMG %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 

Boxplot(~vmPFC_betas, data= R_N_EMG, id=TRUE) # identify all outliers
Boxplot(~subgen_betas, data= R_N_EMG, id=TRUE) 

# For EMG ROI

R_N_EMG$EMG = zscore(R_N_EMG$EMG)
ggplotRegression(lm(R_N_EMG[[6]]~R_N_EMG$EMG)) + rremove("x.title")
ggplotRegression(lm(R_N_EMG[[7]]~R_N_EMG$EMG)) + rremove("x.title")


pcore_L <- ggplotRegression(lm(R_N_EMG[[2]]~R_N_EMG$EMG)) + rremove("x.title")
pcore_R <- ggplotRegression(lm(R_N_EMG[[3]]~R_N_EMG$EMG)) + rremove("x.title")
pshell_L <- ggplotRegression(lm(R_N_EMG[[4]]~R_N_EMG$EMG)) + rremove("x.title")
pshell_R <- ggplotRegression(lm(R_N_EMG[[5]]~R_N_EMG$EMG)) + rremove("x.title")

ggarrange(pcore_L, pcore_R, pshell_L, pshell_R,
                     labels = c("A: pcore_L", "B: pcore_R", "C: pshell_L", "D: pshell_R"),
                     ncol = 2, nrow = 2,
                     vjust=3, hjust=0) 



# 
# # open dataset 15 !
# R_N_EMG15 <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_GLM_15.txt',sep="")), header = T, sep ='\t') # read in dataset
# 
# 
# # PLOT FUNCTIONS --------------------------------------------------------------------
# 
# R_N_EMG15 %>%
#   keep(is.numeric) %>%
#   gather() %>%
#   ggplot(aes(value)) +
#   facet_wrap(~ key, scales = "free") +
#   geom_density()
# 
# 
# Boxplot(~OFC_betas, data= R_N_EMG15, id=TRUE) # identify all outliers
# Boxplot(~shell_R_betas, data= R_N_EMG15, id=TRUE)

#participant 05

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV/HED') 
setwd(analysis_path)
# open dataset (session two only)
REWOD_HED <- read.delim(file.path(analysis_path,'REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset
REWOD_HED <- filter(REWOD_HED,id == "5")

plot(REWOD_HED$trial, REWOD_HED$EMG)

emg_reward <- filter(REWOD_HED,  condition == "chocolate")
emg_neutral <- filter(REWOD_HED,  condition == "neutral")
emg_control <- filter(REWOD_HED,  condition == "empty")

plot(emg_reward$trial, emg_reward$EMG)
plot(emg_control$trial, emg_control$EMG)
plot(emg_neutral$trial, emg_neutral$EMG)

REWOD_HED %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 


# open dataset (session two only)
REWOD_HED <- read.delim(file.path(analysis_path,'REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset

#here 4 to compare
REWOD_HED <- filter(REWOD_HED,  id == "4")

plot(REWOD_HED$trial, REWOD_HED$EMG)

emg_reward4 <- filter(REWOD_HED,  condition == "chocolate")
emg_neutral4 <- filter(REWOD_HED,  condition == "neutral")
emg_control4 <- filter(REWOD_HED,  condition == "empty")

plot(emg_reward4$trial, emg_reward4$EMG)
plot(emg_control4$trial, emg_control4$EMG)
plot(emg_neutral4$trial, emg_neutral4$EMG)

REWOD_HED %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 
