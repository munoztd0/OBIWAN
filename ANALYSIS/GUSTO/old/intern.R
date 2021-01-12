##################################################################################################
# Created  by D.M.T. on AUGUST 2021                                                           
##################################################################################################
#                                      PRELIMINARY STUFF ----------------------------------------

#load libraries

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(tidyverse, dplyr, plyr, tidyr) 
#                reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, parallel,
#                lsmeans, BayesFactor, effectsize, devtools, misty, bayestestR, lspline)



# -------------------------------------------------------------------------
# *************************************** SETUP **************************************
# -------------------------------------------------------------------------




# Set path
home_path       <- '~/OBIWAN'

# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/GUSTO')
figures_path  <- file.path(home_path, 'CODE/ANALYSIS/GUSTO/FIGURES') 
setwd(analysis_path)

#datasets dictory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 

# open datasets
HED  <- read.delim(file.path(data_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # 
info <- read.delim(file.path(data_path,'info_expe.txt'), header = T, sep ='') # 
#intern <- read.delim(file.path(data_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # 

#subset only pretest
tables <- c("HED", "intern")
dflist <- lapply(mget(tables),function(x)subset(x, session == 'second'))
list2env(dflist, envir=.GlobalEnv)

#exclude participants (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123, 124 and 226 have imcomplete data
`%notin%` <- Negate(`%in%`)
dflist <- lapply(mget(tables),function(x)filter(x, id %notin% c(242, 256, 114, 228, 123, 124, 226)))
list2env(dflist, envir=.GlobalEnv)

#merge with info
tables = tables[-length(tables)] # remove intern
dflist <- lapply(mget(tables),function(x)merge(x, info, by = "id"))
list2env(dflist, envir=.GlobalEnv)

# creates internal states variables for each data

baseINTERN = subset(intern, phase == 5)
HED = merge(x = HED, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)


# -------------------------------------- themes for plots --------------------------------------------------------

averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position=c(.9,.9),
        legend.title  = element_text(size = 12),
        legend.text  = element_text(size = 10),
        legend.key.size = unit(0.2, "cm"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size =  30),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())


pal = viridis::inferno(n=5) # specialy conceived for colorblindness
pal[6] = "#21908CFF" # add one





# # Check Demo
# HED$group = as.numeric(as.factor(HED$group))
# AGE = ddply(HED,~group,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
# BMI = ddply(HED,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
# GENDER = ddply(HED, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
#   group_by(gender, group) %>%
#   tally() #1 = women
# 
# N_group = ddply(HED, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
#   group_by(group) %>% tally()

# Check Demo
AGE = ddply(HED,.(), summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age)); AGE
GENDER = ddply(HED, .(id), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender) %>%
  tally() ; GENDER #1 = women

cov = ddply(HED, .(id), summarise, piss = mean(piss, na.rm = TRUE), hungry = mean(hungry, na.rm = TRUE), thirsty = mean(thirsty, na.rm = TRUE), age = mean(age, na.rm = TRUE), gender = mean(as.numeric(gender), na.rm = TRUE)) 

numer <- c("piss", "hungry",   "thirsty",  "age")
cov_c = cov  %>% mutate_at(numer, scale); #missing covariate = 102 & 217

write.table(lik_c, (file.path(analysis_path, "HED_covariateT0_Ratings.tsv")), row.names = F, sep="\t")
