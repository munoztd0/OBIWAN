## R code for FOR PAV cond OBIWAN PUPIL
# last modified on August 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, gazer, zoo, foreach, car, parallel, doParallel)

# SETUP ------------------------------------------------------------------

task = 'PAV_pup'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

group_pav <- read_delim(file.path(analysis_path,'PAV_pup.txt'), "\t", escape_double = FALSE, trim_ws = TRUE)

group_pav<- as_tibble(group_pav)
#summary(df)
`%notin%` <- Negate(`%in%`)
df = group_pav %>% filter(ID %notin% c(115, 132, 210, 224, 249)) #participant with more than 70% missing data
#df = group_pav %>% filter(ID %in% c(100)) #participant with more than 70% missing data
df = subset(df, session == 1) #  n only first session
df$marker[df$marker == 0] <- NaN

data = df %>% mutate(condition = na.locf(marker,na.rm=F)) # na.locf fills with the last non-empty value
data$condition[is.nan(data$condition)]<-0
data$condition[data$condition == 5]<-0
 

nID = length(unique(data$ID))
nID
# but i guess i was too lazy
lenT = length(data$pupil)
data$trial = c(1:lenT)
data$trialxcon = c(1:lenT)

#well I went bonkers on this one .. this loops takes foreeeeever even with foreach computing (should find another way..)
k = 0
l = 0
m = 0
n = 0
id = 100
pb = txtProgressBar(min = 0, max = lenT, initial = 0, style = 3) 
#for cluster computing
#cl <- parallel::makeCluster(2)
#doParallel::registerDoParallel(cl)
foreach(i = 1:lenT) %do% {
  setTxtProgressBar(pb,i)
  if(data$ID[i] != id) {
    id = data$ID[i]
    k = 0
    l = 0
    m = 0
    n = 0
    if(data$condition[i] == 16) {
      if(data$condition[i-1] != 16) {
        k = k+ 1
        data$trial[i] = k
        l = l+ 1
        data$trialxcon[i] = l}
      else {
        data$trial[i] = k
        data$trialxcon[i] = l}
    } else if (data$condition[i] == 32) {
      if(data$condition[i-1] != 32) {
        k = k+ 1
        data$trial[i] = k
        m = m+ 1
        data$trialxcon[i] = m}
      else {
        data$trial[i] = k
        data$trialxcon[i] = m}
    } else if (data$condition[i] == 64) {
      if(data$condition[i-1] != 64) {
        k = k+ 1
        data$trial[i] = k
        n = n+ 1
        data$trialxcon[i] = n
      } else {
        data$trial[i] = k
        data$trialxcon[i] = n}
    } else {
      data$trial[i] = k
      data$trialxcon[i] = l}
  } else {
    if(data$condition[i] == 16) {
      if(data$condition[i-1] != 16) {
        k = k+ 1
        data$trial[i] = k
        l = l+ 1
        data$trialxcon[i] = l}
      else {
        data$trial[i] = k
        data$trialxcon[i] = l}
    } else if (data$condition[i] == 32) {
      if(data$condition[i-1] != 32) {
        k = k+ 1
        data$trial[i] = k
        m = m+ 1
        data$trialxcon[i] = m}
      else {
        data$trial[i] = k
        data$trialxcon[i] = m}
    } else if (data$condition[i] == 64) {
      if(data$condition[i-1] != 64) {
        k = k+ 1
        data$trial[i] = k
        n = n+ 1
        data$trialxcon[i] = n}
      else {
        data$trial[i] = k
        data$trialxcon[i] = n}
    } else {
      data$trial[i] = k
      data$trialxcon[i] = l}
  }
}

data = subset(data, trial <= 80) #trim data within pav session
table(data$marker) #check it out eveything is normal (~20 CS+ per ID)
a = table(data$marker) #check it out eveything is normal (~20 CS+ per ID)
check = a[6]/nID #second number should be =~ 20
check

print('done ! ')

data = data %>%
  group_by(trial) %>%
  mutate(time = (time - first(time) -1000)) #reset time epochs

data$subject = data$ID
data = select(data, c(subject, trial,  time,  marker, pupil, condition, trialxcon))

#save RData for cluster computing
save.image(file = "PAV_pup.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)
path <-'~/OBIWAN/DERIVATIVES/BEHAV/'
write.table(data, (file.path(path, "PAV_pup.txt")), row.names = F, sep="\t")
