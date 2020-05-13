
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(readxl, ggplot2,  dplyr, doBy)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

path  <- file.path('~/Desktop/Switchdrive/OBIWAN_FOLD') 
data <- read_excel(paste(path, "/data.xlsx", sep="")) #read the data

#process data
info_expe  <- data %>%
  select("Gender","Random_Code", "BMI_V1","BMI_V10", "code OBIWAN", "AGE")  %>%
  setNames(c("gender", "intervention", "BMI_t1", "BMI_t2", "id", "age")) #%>%



#save data
write.table(info_expe, file = paste(analysis_path,'/info_expe.txt', sep=""), quote=FALSE, sep='\t')


