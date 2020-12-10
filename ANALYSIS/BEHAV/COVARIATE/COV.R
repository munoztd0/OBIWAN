  ##################################################################################################
  # Created  by D.M.T. on AUGUST 2020                                                             
  ##################################################################################################
  #                                      PRELIMINARY STUFF ----------------------------------------
  #load libraries
  
  if(!require(pacman)) {
    install.packages("pacman")
    library(pacman)
  }
  
  pacman::p_load(tidyverse, dplyr, plyr, tidyr)
  
  
  # Set path
  home_path       <- '~/OBIWAN'
  
  # Set working directory
  analysis_path <- file.path(home_path, 'DERIVATIVES/GLM/SPM/PIT/covariates/T0')
  setwd(analysis_path)
  
  #datasets dictory
  data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 
  
  
  
  # PIT ---------------------------------------------------------------------
  
  # open datasets
  cov <- read.delim(file.path(data_path,'covariateT0.txt'), header = T, sep ='\t') # 
  force <- read.delim(file.path(data_path,'PIT_covariateT0_Force.tsv'), header = T, sep ='\t') # 
  intern <- read.delim(file.path(data_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset
  
  # clean INTERNAL STATES
  base = subset(intern, phase == 3 & session == 'second') #before PIT and pre test 
  cov = merge(x = cov, y = base[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
  
  
  `%notin%` <- Negate(`%in%`)
  #exclude participants for behavior (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123 and 124 have imcomplete data
  cov <- filter(cov, id %notin% c(242, 256, 114, 228, 123, 124))
  #exclude participants for missing fmri data 
  cov <- filter(cov, id %notin% c(218, 224, 226, 243, 255, 257, 260, 261))
  
  #exclude participants for missing data 
  force <- filter(force, id %notin% c(242, 256, 114, 228, 123, 124, 218, 224, 226, 243, 255, 257, 260, 261))
  
  cov = merge(cov, force, by = 'id')
  
  
  #center covariates
  numer <- c("adiponectin_V3", "obestatin_V3",   "glucagon_V3",    "reelin_V3",      "Creat_V3",  "GFR_V3","ALT_V3","AST_V3","Na_V3","K_V3","ChTot_V3","HDL_V3","LDL_V3","TG_V3", "Gly_v3" ,"HbA1c_V3" ,"Insulin_V3","TSH_V3","RBC_V3","Hb_V3" ,"Ht_V3","Leu_V3","Tr_v3","BMI_t1","age", "piss", "thirsty", 'hungry','eff', 'grip')
  cov_c = cov %>% group_by %>% mutate_at(numer, scale)
  
  fac <- c("id", "gender", "Group", "intervention" )
  cov_c[fac] <- lapply(cov_c[fac], factor)
  
  #impute mean by group
  impute.mean <- function(x) replace(x, is.na(x), mean(x, na.rm = TRUE))
  cov_i <- ddply(cov_c, ~ Group, transform, piss = impute.mean(piss),
                 thirsty = impute.mean(thirsty), hungry = impute.mean(hungry))
  
  cov_i = cov_i[order(cov_i$id), ] #plyr orders by group so we have to reorder
  
  write_delim(cov_i, 'PIT_covariateT0_center.tsv', delim = "\t")
  
  
  # HED ---------------------------------------------------------------------
  
  
  # Set working directory
  analysis_path <- file.path(home_path, 'DERIVATIVES/GLM/SPM/hedonicreactivity/covariates/T0')
  setwd(analysis_path)
  
  #datasets dictory
  data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 
  
  # open datasets
  cov <- read.delim(file.path(data_path,'covariateT0.txt'), header = T, sep ='\t') # 
  ratings <- read.delim(file.path(data_path,'HED_covariateT0_Ratings.tsv'), header = T, sep ='\t') # 
  intern <- read.delim(file.path(data_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset
  
  # clean INTERNAL STATES
  base = subset(intern, phase == 4 & session == 'second') #before PIT and pre test 
  cov = merge(x = cov, y = base[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
  
  
  `%notin%` <- Negate(`%in%`)
  #exclude participants for behavior (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123 and 124 have imcomplete data
  cov <- filter(cov, id %notin% c(242, 256, 114, 228, 123, 124))
  #exclude participants for missing fmri data #check that
  cov <- filter(cov, id %notin% c(226, 243, 255, 257, 260, 261))
  
  #exclude participants for missing data 
  #ratings <- filter(force, id %notin% c(242, 256, 114, 228, 123, 124, 218, 224, 226, 243, 255, 257, 260, 261))
  #chnage that!!
  cov = merge(cov, ratings, by = 'id')
  
  
  #center covariates
  numer <- c("adiponectin_V3", "obestatin_V3",   "glucagon_V3",    "reelin_V3",      "Creat_V3",  "GFR_V3","ALT_V3","AST_V3","Na_V3","K_V3","ChTot_V3","HDL_V3","LDL_V3","TG_V3", "Gly_v3" ,"HbA1c_V3" ,"Insulin_V3","TSH_V3","RBC_V3","Hb_V3" ,"Ht_V3","Leu_V3","Tr_v3","BMI_t1","age", "piss", "thirsty", 'hungry','lik', 'int', 'fam')
  cov_c = cov %>% group_by %>% mutate_at(numer, scale)
  
  fac <- c("id", "gender", "Group", "intervention" )
  cov_c[fac] <- lapply(cov_c[fac], factor)
  
  #impute mean by group
  impute.mean <- function(x) replace(x, is.na(x), mean(x, na.rm = TRUE))
  cov_i <- ddply(cov_c, ~ Group, transform, piss = impute.mean(piss),
                 thirsty = impute.mean(thirsty), hungry = impute.mean(hungry))
  
  cov_i = cov_i[order(cov_i$id), ] #plyr orders by group so we have to reorder
  
  write_delim(cov_i, 'HED_covariateT0_center.tsv', delim = "\t")
