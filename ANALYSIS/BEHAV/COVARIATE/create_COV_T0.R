##################################################################################################
# Created  by D.M.T. on AUGUST 2020                                                             
##################################################################################################
#                                      PRELIMINARY STUFF ----------------------------------------

#load libraries

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(tidyverse, dplyr, plyr)


# -------------------------------------------------------------------------
# *************************************** SETUP **************************************
# -------------------------------------------------------------------------


# Set path
home_path       <- '~/OBIWAN'

#datasets dictory
analysis_path <- file.path(home_path,'DERIVATIVES/BEHAV') 
physio_path <- file.path(home_path,'DERIVATIVES/PHYSIO') 
setwd(analysis_path)

# open datasets
PAV  <- read.delim(file.path(analysis_path,'OBIWAN_PAV.txt'), header = T, sep ='') # 
INST <- read.delim(file.path(analysis_path,'OBIWAN_INST.txt'), header = T, sep ='') # 
PIT  <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # 
HED  <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # 
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # 
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # 
medic <- read.delim(file.path(physio_path,'medic.txt'), header = T, sep ='') # 
medic$session = as.factor(revalue(as.factor(medic$session), c('1'="second", '2'="third"))) #change value of session

#subset only pretest
tables <- c("PAV","INST","PIT","HED", "intern", "medic")
dflist <- lapply(mget(tables),function(x)subset(x, session == 'second'))
list2env(dflist, envir=.GlobalEnv)

#exclude participants (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123 and 124 have imcomplete data
`%notin%` <- Negate(`%in%`)
dflist <- lapply(mget(tables),function(x)filter(x, id %notin% c(242, 256, 114, 228, 123, 124)))
list2env(dflist, envir=.GlobalEnv)

# creates internal states variables for each data
tables <- c("PAV","INST","PIT","HED")
listA = 2:5
def = function(data, number){
  baseINTERN = subset(intern, phase == number)
  data = merge(x = get(data), y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
  return(data)
}
dflist = mapply(def,tables,listA)
list2env(dflist, envir=.GlobalEnv)



# HED ---------------------------------------------------------------------
`%notin%` <- Negate(`%in%`)
#exclude participants for behavior (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123 and 124 have imcomplete data
HED <- filter(HED, id %notin% c(242, 256, 114, 228, 123, 124))
#exclude participants for missing fmri data #check that
HED <- filter(HED, id %notin% c(226, 243, 255, 257, 260, 261))

bs = ddply(HED, .(id, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 
bs$id = as.factor(bs$id)

emp = subset(bs, condition == "Empty")
ms = subset(bs, condition == "MilkShake")

diff = ms
diff$lik = diff$lik - emp$lik
diff$int = diff$int - emp$int
diff$fam = diff$fam - emp$fam
lik = diff %>% select(id, lik, int, fam)
numer <- c("lik", "int",   "fam")

lik_c = lik %>% group_by %>% mutate_at(numer, scale)


ms = ms %>% select(id, lik, int, fam)


ms_c = ms %>% group_by %>% mutate_at(numer, scale)

emp = emp %>% select(id, lik, int, fam)
emp_c = emp %>% group_by %>% mutate_at(numer, scale)


intern = ddply(HED, .(id), summarise, piss = mean(piss, na.rm = TRUE), hungry = mean(hungry, na.rm = TRUE), thirsty = mean(thirsty, na.rm = TRUE)) 

d = merge(lik, intern, by = "id")
dt = merge(d, medic, by = "id", all.x  = T)
dtf = merge(dt, info, by = "id")
numer <- c("lik", "int",   "fam",  "piss"   ,      "hungry"  ,  "thirsty",  "GLP1",      "OEA",  "PEA","X2.AG","AEA","Leptin","Resistin","MCP","TNFalpha","Ghrelin","reelin", "glucagon" ,"adiponectin" ,"obestatin","age")
dtf_c = dtf %>% group_by %>% mutate_at(numer, scale)

write.table(lik_c, (file.path(analysis_path, "HED_covariateT0_Ratings.tsv")), row.names = F, sep="\t")
write.table(ms_c, (file.path(analysis_path, "HED_covariateT0_REWARD.tsv")), row.names = F, sep="\t")
write.table(emp_c, (file.path(analysis_path, "HED_covariateT0_CONTROL.tsv")), row.names = F, sep="\t")
write.table(dtf_c, (file.path(analysis_path, "HED_covariateT0.tsv")), row.names = F, sep="\t")

# EFORT ------------------------------------------------------------------
#remove the baseline
PIT =  subset(PIT, condition != 'BL') 

#exclude participants for behavior (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123 and 124 have imcomplete data
PIT <- filter(PIT, id %notin% c(242, 256, 114, 228, 123, 124))
#exclude participants for missing fmri data 
PIT <- filter(PIT, id %notin% c(218, 224, 226, 243, 255, 257, 260, 261))



bs = ddply(PIT, .(id, condition), summarise, eff = mean(AUC, na.rm = TRUE)) 
bs$id = as.factor(bs$id)
CSp = subset(bs, condition == "CSplus")
CSp_c = CSp %>% group_by %>% mutate(eff, scale)
CSm = subset(bs, condition == "CSminus")
CSm_c = CSm %>% group_by %>% mutate(eff, scale)

diff = CSp
diff$eff = CSp$eff - CSm$eff


eff = diff %>% select(id, eff)
eff_c = eff %>% group_by %>% mutate(eff, scale)

d = merge(eff, intern, by = "id", all.x  = T)
dt = merge(d, medic, by = "id", all.x  = T)
dtf = merge(dt, info, by = "id")

numer <- c("eff",  "piss"   ,      "hungry"  ,  "thirsty",  "GLP1",      "OEA",  "PEA","X2.AG","AEA","Leptin","Resistin","MCP","TNFalpha","Ghrelin","reelin", "glucagon" ,"adiponectin" ,"obestatin","age")
dtf_c = dtf %>% group_by %>% mutate_at(numer, scale)


write.table(eff_c, (file.path(analysis_path, "PIT_covariateT0_Force.tsv")), row.names = F, sep="\t")
write.table(dtf_c, (file.path(analysis_path, "PIT_covariateT0.tsv")), row.names = F, sep="\t")
