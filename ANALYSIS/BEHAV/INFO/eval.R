
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(readxl, ggplot2,  dplyr, plyr, doBy)

analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 

path  <- file.path('~/Desktop/Switchdrive/OBIWAN_FOLD') 
data <- read_excel("Switchdrive/OBIWAN (2)/Pré-test/Liking.xlsx")

#process data
#MS
data1  <- data %>%
  select("Sujet","Hédonicité...7", "Familiarité...8","Intensité...9") %>%
    setNames(c("id", "hed", "fam", "int"))
data1$cond <- rep(1, length(data1$hed)) #fill wih 0


#tasteless
data2  <- data %>%
  select("Sujet","Hédonicité...10", "Familiarité...11","Intensité...12") %>%
  setNames(c("id", "hed", "fam", "int"))
data2$cond <- rep(0, length(data2$hed)) #fill wih 1

data = rbind(data1,data2)


#save data
write.table(data, file = paste(analysis_path,'/eval_pre.txt', sep=""), quote=FALSE, sep='\t')


#
empty2 = subset(data, cond == 0)
MS2 = subset(data, cond == 1)
df = MS2

df$diff = MS2$hed - empty2$hed
df$diff = df$diff * 10

df$id <- as.factor(df$id)

df = na.omit(df)

dataID = ddply(df, .(id), summarise, diff = mean(diff, na.rm = TRUE)) 

idPLUS = subset(dataID, diff > 0)
idMINUS = subset(dataID, diff <= 0)


