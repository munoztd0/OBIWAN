##################################################################################################
# Created  by D.M.T. on AUGUST 2021                                                           
##################################################################################################
#                                      PRELIMINARY STUFF ----------------------------------------


#load libraries

if(!require(pacman)) {
  install.packages("pacman")

  library(pacman)
}

pacman::p_load(tidyverse, dplyr, plyr, Rmisc) 




# -------------------------------------------------------------------------
# *************************************** SETUP **************************************
# -------------------------------------------------------------------------




# Set path
home_path       <- '~/OBIWAN'


# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/BEHAV/ForPaper')
figures_path  <- file.path(home_path, 'DERIVATIVES/FIGURES/BEHAV/T0') 
setwd(analysis_path)
#datasets dictory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 
physio_path <- file.path(home_path,'DERIVATIVES/PHYSIO') 

# open datasets
HED  <- read.delim(file.path(data_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # 
info <- read.delim(file.path(data_path,'info_expe.txt'), header = T, sep ='') # 
intern <- read.delim(file.path(data_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # 
medic <- read.delim(file.path(physio_path,'medic.txt'), header = T, sep =',') # 
medic$session = as.factor(revalue(as.factor(medic$session), c('1'="second", '2'="third"))) #change value of session
medic$group = as.factor(revalue(as.factor(medic$group), c('0'="control", '1'="obese"))) #change value of session


intern = subset(intern, phase == 5)
HED = merge(x = HED, y = intern[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)


#subset only pretest
HED = subset(HED, group == 'obese')
#HED = subset(HED, session == 'second')

subjects = c(202, 203, 204, 209, 213, 217, 220, 224, 225, 235, 236, 237, 238, 239, 241, 246, 250, 259, 264, 265, 266, 269, 270, 205, 206, 207, 211, 215, 218, 221, 227, 229, 230, 231, 232, 244, 248, 251, 252, 253, 254, 262, 268)

HED = filter(HED, id %in% subjects)

HED = merge(HED, info, by = "id")
HED = merge(HED, medic, by = c("id", "group", "session"), all.x = T)

#fasting blood glucose, insulin, glucagon, ghrelin, leptin, obestatin,
#reelin, endocannabinoids (AEA, 2-AG) and endocannabinoid-related compounds (OEA, PEA)

cov = ddply(HED, .(id,session, intervention,gender),  summarize, age = mean(age, na.rm = TRUE), piss = mean(piss, na.rm = TRUE), thirsty = mean(thirsty, na.rm = TRUE), hungry = mean(hungry, na.rm = TRUE), bmi1 = mean(BMI_t1, na.rm = TRUE), bmi2 = mean(BMI_t2, na.rm = TRUE), 
            OEA = mean(OEA, na.rm = TRUE),PEA = mean(PEA, na.rm = TRUE), X2.AG = mean(X2.AG, na.rm = TRUE), AEA = mean(AEA, na.rm = TRUE), Leptin = mean(Leptin, na.rm = TRUE), glucagon = mean(glucagon, na.rm = TRUE), Ghrelin = mean(Ghrelin, na.rm = TRUE), obestatin = mean(obestatin, na.rm = TRUE), GLP1 = mean(GLP1, na.rm = TRUE), insulin = mean(insulin, na.rm = TRUE), Fast_glu = mean(Fast_glu, na.rm = TRUE)) ; 

pre = subset(cov, session == "second"); post = subset(cov, session == "third"); diff= post; diff$bmi = post$bmi2 - pre$bmi1 ;diff$OEA = post$OEA - pre$OEA;diff$PEA = post$PEA - pre$PEA;
diff$X2.AG = post$X2.AG - pre$X2.AG;diff$AEA = post$AEA - pre$AEA;diff$Leptin = post$Leptin - pre$Leptin;diff$glucagon = post$glucagon - pre$glucagon;diff$Ghrelin = post$Ghrelin - pre$Ghrelin;
diff$obestatin = post$obestatin - pre$obestatin;diff$GLP1 = post$GLP1 - pre$GLP1;
diff$insulin = post$insulin - pre$insulin;diff$Fast_glu = post$Fast_glu - pre$Fast_glu;
#diff$piss = post$piss - pre$piss;diff$thirsty = post$thirsty - pre$thirsty; diff$hungry = post$hungry - pre$hungry;

numer = c("age", "piss" , "thirsty",  "hungry" , "OEA",   "PEA", "X2.AG",   "AEA"  ,  "Leptin" ,"glucagon" , "Ghrelin","obestatin" ,"GLP1" , "insulin" ,"Fast_glu")

cov_c = diff %>% group_by %>% mutate_at(numer, scale); cov_c = select(cov_c, -c('session', 'bmi1', 'bmi2'))

cov_c = cov_c[match(subjects, cov_c$id),] #reorder to have same as matlab design

#imput mean for missing data
cov_c[is.na(cov_c)] <- 0 


write.table(cov_c, (file.path(data_path, "covariate_LIRA.txt")), row.names = F, sep="\t")

