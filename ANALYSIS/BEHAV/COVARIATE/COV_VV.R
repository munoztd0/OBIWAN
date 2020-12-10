  if(!require(pacman)) {
    install.packages("pacman")
    library(pacman)}
  
  pacman::p_load(tidyverse, dplyr, plyr)
  
  analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
  
  setwd(analysis_path)
  
  # LIKING ------------------------------------------------------------------
  load("HED.RData")
  scale2 <- function(x, na.rm = TRUE) (x - mean(x, na.rm = na.rm)) # global functions
  
  bs = ddply(HED, .(id, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 
  bs$id = as.numeric(as.character(bs$id))
  
  emp = subset(bs, condition == "-1")
  ms = subset(bs, condition == "1")
  emp$group = ifelse(emp$id>199, "obese", "lean") 
  ms$group = ifelse(ms$id>199, "obese", "lean") 
    
    
  #center covariates
  numer <- c("lik", "int", "fam")
  emp = emp %>% group_by %>% mutate_at(numer, scale2)
  ms = ms %>% group_by %>% mutate_at(numer, scale2)
   
  #then vut into two file for each group for the different folders 
  emp_OB =  emp %>% subset(group == "obese")  %>% select(id, lik, int, fam)
  emp_HW = emp %>% subset(group == "lean") %>% select(id, lik, int, fam)
  ms_OB = ms %>% subset(group == "obese") %>% select(id, lik, int, fam)
  ms_HW = ms %>% subset(group == "lean") %>% select(id, lik, int, fam)
  
  
      write.table(emp_OB, (file.path('~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/covariates/T0/neu_lik_OB.txt')), row.names = F, sep="\t")
      write.table(emp_HW, (file.path('~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/covariates/T0/neu_lik_HW.txt')), row.names = F, sep="\t")
      
      write.table(ms_OB, (file.path('~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/covariates/T0/rew_lik_OB.txt')), row.names = F, sep="\t")
      write.table(ms_HW, (file.path('~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/covariates/T0/rew_lik_HW.txt')), row.names = F, sep="\t")
