## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, plyr,dplyr,readr, car, BayesFactor, tidyBF, sjmisc, afex)
#options(mc.cores = parallel::detectCores()) #to mulithread
#install.packages("~/Desktop/hBayesDM.tar.xz", repos = NULL) # your need to install this modfied version of hBayesDM where I implement a model of the PST task with one learning rate
#library(hBayesDM) #again only load after your installed my version of hBayesDM
# SETUP ------------------------------------------------------------------

task = 'PBlearning'


# Set working directory #change here if the switchdrive is not on your home folder
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

# open dataset 
full <- read_csv(file.path(analysis_path, "PBLearning.csv"), col_types = cols(Subject = col_integer()))
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$Subject = info$id

# Preprocess --------------------------------------------------------------

data  <- subset(full, Group == 'O') #subset #only session one 
data  <- subset(data, Phase == 'proc1') #only learning phase

#stil have to watch for 2225140
for (i in  1:length(data$Subject)) {
  if(data$Subject[i] > 2000) 
  {data$Subject[i] = data$Subject[i] - 2000}  
  else 
  {data$Subject[i] = data$Subject[i]}
}


data = merge(data, info, by = "Subject")

#factorize and rename
data$type = as.factor(revalue(data$imcor, c(A="AB", C="CD", E="EF")))
data$reward = revalue(data$feedback, c(Negatif=0, Positif=1))
data$side = revalue(data$Stim.RESP, c(x='L', n='R'))
data$subjID = data$Subject

#This loop is there to transform everything into one column "choice"
#this column takes a 1 if the action was to choose either A, C or E 
#and takes 0 if the response is either B, D or F (and that independently of the side)

data$choice = c(1:length(data$Trial)) #initialize variable
for (i in  1:length(data$Trial)) {
  if((data$side[i] == 'L')&(data$img[i] == 'A' || data$img[i] == 'C' || data$img[i] == 'E')) 
    {data$choice[i] = 1} 
  else if ((data$side[1] == 'R')&(data$imd[i] == 'A' || data$imd[i] == 'C' || data$imd[i] == 'E')) 
    {data$choice[i] = 1}
  else 
    {data$choice[i] = 0}
}

data$reward = as.numeric(data$reward)
data$type = revalue(data$type, c(AB=12, CD=34, EF=56))
data$type = as.numeric(as.character(data$type))

bs = ddply(data, .(Subject, Session, imcor), summarise, acc = mean(Stim.ACC, na.rm = TRUE)) 

# Crtierium chose A at 65%, C at 60% and E at 50% and min 30 trials.
bs_wide <- spread(bs, imcor, acc)
bs_wide$pass = c(1:length(bs_wide$Subject)) #initialize variable
for (i in  1:length(bs_wide$Subject)) {
  if((bs_wide$A[i] >= 0.65) && (bs_wide$C[i] >=  0.60) && (bs_wide$E[i] >= 0.50 )) 
  {bs_wide$pass[i] = 1} 
  else {bs_wide$pass[i] = 0}
}

data = merge(data, bs_wide[ , c("Subject", "pass")], by = "Subject", all.x=TRUE)

data = subset(data, pass == 1)

dataclean <- select(data, c(subjID, type, choice, reward, Session, intervention))
count_trial = dataclean %>% group_by(subjID, Session, type) %>%tally()


# Time to acquire reach criterium -----------------------------------------------------

df = tally(group_by(dataclean, subjID, Session, intervention))
densityPlot(df$n)
fac <- c("subjID", "Session", "intervention")
df[fac] <- lapply(df[fac], factor)


#bayesian 
BF <- anovaBF(n ~ Session*intervention  + subjID, data = df, 
                 whichRandom = "subjID", iterations = 50000)
BF; plot(BF)
#frequentist
frqaov <- aov_car(n ~ Session*intervention + Error (subjID/Session), data = df, anova_table = list(correction = "GG", es = "pes"))
frqaov

# Anova Table (Type 3 tests)
# 
# Response: n
#              Effect    df      MSE       F  pes   p.value
# 1         intervention 1, 40  6380.70 0.61  .015    .441
# 2              Session 1, 40 10872.25 0.00 <.001    .951
# 3 intervention:Session 1, 40 10872.25 0.36  .009    .550


