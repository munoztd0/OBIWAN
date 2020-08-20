## R code for FOR PAV cond OBIWAN PUPIL
# last modified on August 2020 by David MUNOZ TORD
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, gazer, zoo, foreach, car, parallel, doParallel)

# SETUP ------------------------------------------------------------------

task = 'PAV_pup'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)
load('PAV_pup.RData')
group_pav <- read_delim(file.path(analysis_path,'PAV_pup.txt'), "\t", escape_double = FALSE, trim_ws = TRUE)
#fooock

group_pav<- as_tibble(group_pav)
group_pav$subj = group_pav$subject
#summary(df)
`%notin%` <- Negate(`%in%`)
df = group_pav %>% filter(ID %notin% c(115, 132, 210, 224, 249)) #participant with more than 70% missing data
#df = group_pav %>% filter(ID %in% c(100))
df = subset(df, session == 1) # only first session

# nID = length(unique(df$ID))
# nID
# 
# df$marker[df$marker == 0] <- NaN
# df$trial[df$trial == 0] <- NaN
# 
# # little trick to fill the missing value for trials and condition
# data = df %>% mutate(condition = na.locf(marker,na.rm=F), trial = na.locf(trial,na.rm=F)) # na.locf fills with the last non-empty value
# 
# #data$trial[is.nan(data$trial)]<-0
# data$condition[is.nan(data$condition)]<-0
# data$condition[data$condition == 5]<-0
# data$condition[data$condition == 3]<-64


# for loop ----------------------------------------------------------------
#well I went bonkers on this one .. this loops takes foreeeeever even with foreach computing (should find another way..)
# but i guess i was too lazy
# 
# lenT = length(data$pupil)
# data$trial = c(1:lenT)
# data$trialxcon = c(1:lenT)
# k = 0
# l = 0
# m = 0
# n = 0
# id = 100
# pb = txtProgressBar(min = 0, max = lenT, initial = 0, style = 3)

#for cluster computing
#cl <- parallel::makeCluster(2)
#doParallel::registerDoParallel(cl)
# foreach(i = 1:lenT) %do% {
#   setTxtProgressBar(pb,i)
#   if(data$ID[i] != id) {
#     id = data$ID[i]
#     k = 0
#     l = 0
#     m = 0
#     n = 0
#     if(data$condition[i] == 16) {
#       if(data$condition[i-1] != 16) {
#         k = k+ 1
#         data$trial[i] = k
#         l = l+ 1
#         data$trialxcon[i] = l}
#       else {
#         data$trial[i] = k
#         data$trialxcon[i] = l}
#     } else if (data$condition[i] == 32) {
#       if(data$condition[i-1] != 32) {
#         k = k+ 1
#         data$trial[i] = k
#         m = m+ 1
#         data$trialxcon[i] = m}
#       else {
#         data$trial[i] = k
#         data$trialxcon[i] = m}
#     } else if (data$condition[i] == 64) {
#       if(data$condition[i-1] != 64) {
#         k = k+ 1
#         data$trial[i] = k
#         n = n+ 1
#         data$trialxcon[i] = n
#       } else {
#         data$trial[i] = k
#         data$trialxcon[i] = n}
#     } else {
#       data$trial[i] = k
#       data$trialxcon[i] = l}
#   } else {
#     if(data$condition[i] == 16) {
#       if(data$condition[i-1] != 16) {
#         k = k+ 1
#         data$trial[i] = k
#         l = l+ 1
#         data$trialxcon[i] = l}
#       else {
#         data$trial[i] = k
#         data$trialxcon[i] = l}
#     } else if (data$condition[i] == 32) {
#       if(data$condition[i-1] != 32) {
#         k = k+ 1
#         data$trial[i] = k
#         m = m+ 1
#         data$trialxcon[i] = m}
#       else {
#         data$trial[i] = k
#         data$trialxcon[i] = m}
#     } else if (data$condition[i] == 64) {
#       if(data$condition[i-1] != 64) {
#         k = k+ 1
#         data$trial[i] = k
#         n = n+ 1
#         data$trialxcon[i] = n}
#       else {
#         data$trial[i] = k
#         data$trialxcon[i] = n}
#     } else {
#       data$trial[i] = k
#       data$trialxcon[i] = l}
#   }
# }

# end loop ----------------------------------------------------------------

# data = subset(data, trial <= 80) #trim data within pav session
# a = table(data$marker) #check it out eveything is normal (~20 CS+ per ID)
# check = a[6]/nID #second number should be =~ 20
# check
# 
# data = data %>%
#   group_by(trial) %>%
#   mutate(time = (time - first(time) -1000)) #reset time epochs
# 
# data$subject <- data$ID
# data = select(data, c(subject, trial,  time,  marker, pupil, condition))

#save RData for cluster computing
# save.image(file = "PAV_pup.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

#scale data for each participant #not that great idea
data <- data %>%
  group_by(subject) %>%
  mutate(pupilz = scale(pupil))

#timebinsmm <- baseline_pupil %>%  #or actual sizes
# mutate(pupilmm = (pup_interp * 5)/5570.29)


#60 Hz = 1 every 16 ms so to extend 100 ms  we need to fill 6.25

pup_extend<- data %>% 
  group_by(subject, trial) %>% 
  mutate(extendpupil=extend_blinks(pupil, fillback=6.25, fillforward=6.25, hz=60))

smooth_interp <- smooth_interpolate_pupil(pup_extend, pupil="pupil", extendpupil="extendpupil", extendblinks=TRUE, step.first="interp", filter="moving", maxgap=Inf, type="linear", hz=60, n=5)

baseline_pupil <- baseline_correction_pupil(smooth_interp, pupil_colname='pup_interp', baseline_window=c(7500,8500)) #baseline window when swallowing

#head(baseline_pupil)

#pup_missing <- count_missing_pupil(baseline_pupil, pupil= "pupil", missingthresh = .2)

puphist <- ggplot(baseline_pupil, aes(x = pup_interp)) + 
  geom_histogram(aes(y = ..count..), colour = "green", binwidth = 0.5)  + 
  geom_vline(xintercept = 10, linetype="dotted") +
  geom_vline(xintercept = 40, linetype="dotted") + 
  xlab("Pupil Size (z)") + 
  ylab("Count") + 
  theme_bw()

plot(puphist)

pup_outliers <- baseline_pupil %>% # based on visual inspection
  filter(pup_interp  >= 10, pup_interp <= 40) 

mad_removal <- pup_outliers  %>% 
  group_by(subject, trial) %>% 
  mutate(speed=speed_pupil(pup_interp,time)) %>% 
  mutate(MAD=calc_mad(speed, n = 16)) %>% 
  filter(speed < MAD)

# 
# foreach(i = 1:length(mad_removal$trial)) %do% {
#   if(mad_removal$time[i] > 200 & mad_removal$time[i] < 400) {
#     mad_removal$time[i] = 200
#   }else if(mad_removal$time[i] < 200) {
#       mad_removal$time[i] = 0
#   }else if(mad_removal$time[i] > 400) {
#     mad_removal$time[i] = 400}
# }

# mad_removal$timebins = cut(mad_removal$time,breaks = c(-1000,0,1000,2000,3000, 4000, 5000, 6000, 7000, 8000))
# 
# 
# test = mad_removal %>% filter(subject %in% c(102)) 
# x = subset(x, marker == 16)

# baseline_pupil_onset<-baseline_pupil %>% filter(timebins>1000) %>% mutate(timebinonset=timebins-timebins[[1]]) %>% filter(timebinonset <=3000)

baseline_pupil_onset <- mad_removal %>%  
  group_by(subject, trial) %>%  
  #mutate(time_zero=onset_pupil(time, condition, event=c('16'))) %>%
  #ungroup() %>% 
  filter(time >= -1000 & time <= 80000) %>%
  select(subject, trial, time, condition, baseline, baselinecorrectedp, pupil, pup_interp)

head(baseline_pupil_onset)

bin.length = 100
downsample_pupil <- baseline_pupil_onset %>% mutate(timebins = round(time/bin.length)*bin.length)
aggvars=c("subject", "condition","timebins")

downsample <- downsample_pupil %>%
  dplyr::group_by_(.dots = aggvars) %>%
  dplyr::summarize(aggbaseline=mean(baselinecorrectedp), sdbaseline=sd(baselinecorrectedp)) 

df = subset(downsample, condition %in% c(16,32))

bs = ddply(df, .(condition, timebins), summarise, au = mean(aggbaseline, na.rm = TRUE), sd = mean(sdbaseline, na.rm = TRUE)) 
bs$condition = as.factor(bs$condition)


cursive_plot <- ggplot(bs)+
  aes(timebins, au, linetype=condition, color=condition) + 
  #stat_summary(fun = "mean", geom = "line", size = 1) + 
  stat_summary(fun = "mean", geom = "line", size = 1) + 
  theme_bw() +
  labs(x = "Time (ms)",y = "Pupil Dilation (change from baseline (a.u.))") +
  geom_hline(yintercept=0.0) + 
  geom_ribbon(aes(ymin = au - sd, ymax = au + sd), alpha = 0.1) 

cursive_plot




cursive_plot <- ggplot(df)+
  aes(timebins, aggbaseline, linetype=condition, color=condition) + 
  stat_summary(fun = "mean", geom = "line", size = 1) +
 theme_bw() +
  labs(x = "Time (ms)",y = "Pupil Dilation (change from baseline (a.u.))") +
  geom_hline(yintercept=0.0)

cursive_plot

# try sd ------------------------------------------------------------------



timebins<- downsample_pupil(baseline_pupil_onset, bin.length=100, timevar = "time_zero", aggvars = c("subject", "condition", "timebins"))

bs = ddply(timebins, .(condition, timebins), summarise, au = mean(aggbaseline, na.rm = TRUE), sd = mean(sdbaseline, na.rm = TRUE)) 
bs$condition = as.factor(bs$condition)

cursive_plot <- ggplot(bs)+
  aes(timebins, au, linetype=condition, color=condition) + 
  #stat_summary(fun = "mean", geom = "line", size = 1) + 
  stat_summary(fun = "mean", geom = "line", size = 1) + 
  theme_bw() +
  labs(x = "Time (ms)",y = "Pupil Dilation (change from baseline (a.u.))") +
  geom_hline(yintercept=0.0) + 
  geom_ribbon(aes(ymin = au - sd, ymax = au + sd), alpha = 0.1) 

cursive_plot

