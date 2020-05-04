#this is a real R script

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(readxl, ggplot2,  dplyr, doBy)

#path =  dirname(rstudioapi::getSourceEditorContext()$path) #find the  directory from where you opened this file
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 
#data <- read_excel(paste(path, "/data.xlsx", sep="")) #read the data
data <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
age <- read.delim(file.path('~/OBIWAN/participants.tsv') , sep = '\t', header = TRUE)

#subset
data  <- subset(data, id != 255 & id != 256 & id != 260 & id != 261) #only session 260

data = orderBy(~id, data=data)

age = orderBy(~participant_id, data=age)

data$age <- age$age

#process data
#info_expe  <- data %>% 
  #select("Gender","Random_Code", "BMI_V1","BMI_V10", "code OBIWAN", "age")  %>% 
  #setNames(c("gender", "intervention", "BMI_t1", "BMI_t2", "id", "age")) #%>% 
  #filter(raison == 1)  %>%
  #mutate(annee_migr = 2019 - annee_migr)  %>%
  #mutate(age_sui = annee_migr - annee_nais) #%>%
  #mutate(new_form = replace(form,  form== 7 |form == 2, 'X')) 

#save data
write.table(data, file =paste(analysis_path,'/info_expe.txt', sep=""), quote=FALSE, sep='\t')


