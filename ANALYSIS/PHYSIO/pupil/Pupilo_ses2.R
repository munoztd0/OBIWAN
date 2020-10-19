
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, zoo, PupillometryR, BayesFactor, mgcv, Rmisc, itsadug)

# SETUP ------------------------------------------------------------------
task = 'PAV_pup'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 
setwd(analysis_path)

group_pav <- read_delim(file.path(analysis_path,'PAV_pup.txt'), "\t")

df = subset(group_pav, group == 1) # only first session
#df =  group_pav %>% filter(ID %in% c(100, 102))
nID = length(unique(df$ID))
nID

#removed because more than 75% missing data
#ses 2 205 221 249 266


# really important, I shifted the marker's onset so that they start 100 ms BEFORE there actual onset
df$condition = df$marker
#df$condition[ df$condition == 5 | df$condition == 48] <-0

df$condition[df$condition == 1 | df$condition == 2 | df$condition == 3 | df$condition == 5 | df$condition == 48] <-0
# data$condition[data$condition == 3]<-64
df$condition[df$condition == 0] <- NaN
df$trial[df$trial == 0] <- NaN
# little trick to fill the missing value for trials and condition
data = df %>% mutate(condition = na.locf(condition,na.rm=F), trial = na.locf(trial,na.rm=F)) # na.locf fills with the last non-empty value
data = na.omit(data) 
max(data$trial) #should be 80

a = table(data$marker) #check it out eveything is normal (~20 CS+ per ID)

data$trial = as.factor(data$trial)
bd = data %>% ddply(.(ID, session), summarise, timeZ = min(time)) 
check = a[6]/length(bd$ID) #second number should be =~ 20
check
bs = data %>% ddply(.(ID, session, trial), summarise, timeZ = min(time)) 

bs$ID <- as.numeric(bs$ID)
bs$IDxSes = 1:length(bs$ID)
for (i in  1:length(bs$ID)) {
  if(bs$session[i] == 1) {
    bs$IDxSes[i] = bs$ID[i]
  }
  else {
    bs$IDxSes[i] = bs$ID[i] + 1000
  }
}

data <- bs %>% right_join(data, by=c("ID","session", "trial"))


data$timeO = data$time - data$timeZ
data$timeO = data$timeO - 100 # to put back the shift in order !  # because until here I have 0 that means -100 and 12100 means 12000
data = data %>% filter(timeO < 12000)


pupil_data = data 

#Check that IDs are not numeric
pupil_data$ID <- as.factor(pupil_data$IDxSes)

pupil_data = select(pupil_data, c(ID, trial,  timeO,  marker, pupil, condition, session))

#save RData for cluster computing
save.image(file = "PAV_pup_ses2.RData", version = NULL, ascii = FALSE, compress = FALSE, safe = TRUE)



Sdata <- make_pupillometryr_data(data = pupil_data,
                                 subject = ID,
                                 trial = trial,
                                 time = timeO,
                                 condition = condition,
                                 other = session)

Sdata = filter(Sdata, condition != 64)

Sdata$condition = as.factor(Sdata$condition)

#check this 
mean_data <- downsample_time_data(data = Sdata,
                                  pupil = pupil,
                                  timebin_size = 50,
                                  option = 'median')

plot(mean_data, pupil = pupil, group = 'subject')

# #plot(Sdata, pupil = pupil, group = 'subject') 
# missing <- calculate_missing_data(mean_data, pupil)
# missing[with(missing,order(-Missing)),] #chekc missing head
# 
# mean_data2 <- clean_missing_data(mean_data,
#                               pupil = pupil,
#                             trial_threshold = .75,
#                             subject_trial_threshold = .75)


# hanning filtering the data c("median", "hanning", "lowpass") # check here
filtered_data <- filter_data(data = mean_data,
                             pupil = pupil,
                             filter = 'median',
                             degree = 11)

plot(filtered_data, pupil = pupil, group = 'condition')

# interpolate across blinks (linear or cubic)
int_data <- interpolate_data(data = filtered_data,
                             pupil = pupil,
                             type = 'linear')

plot(int_data, pupil = pupil, group = 'subject')
#plot(int_data, pupil = pupil, group = 'condition')

#Baselining #its the data is a powerful way of making sure we control for between-participant variance of average pupil size. If we are looking at analyses that are largely within-subject, as we do here, this may not be such an issue, but we will do this anyway. This function allows us to baseline to the mean pupil size within a time window. Here we are just taking the first 100ms of the trial. If your baseline period is just outside of your analysis window (which it often will be), you can use subset_data() to remove that after baselining.
#check
base_data <- baseline_data(data = int_data,
                           pupil = pupil,
                           start = -100,
                           stop = 0)

plot(base_data, pupil = pupil, group = 'condition')

# ggplot(base_data, aes(x = pupil)) +
#   geom_histogram(aes(y = ..count..), colour = "green", binwidth = 0.5)  +
#   #geom_vline(xintercept = 10, linetype="dotted") +
#   #geom_vline(xintercept = 40, linetype="dotted") +
#   xlab("Pupil Size (z)") +
#   ylab("Count") +
#   theme_bw()

bst = summarySE(base_data, measurevar="pupil", groupvars=c("condition", "timeO"), na.rm = TRUE)
bst$condition = revalue(bst$condition, c("32"="CS+", "16"="CS-")) #, "64" ="Baseline"

SE_plot <- ggplot(bst)+
  aes(timeO, pupil, linetype=condition, color=condition) + 
  stat_summary(fun = "mean", geom = "line", size = 1) + 
  theme_bw() +
  labs(x = "Time (ms)",y = "Pupil Dilation") + #(change from baseline (a.u.)
  #geom_hline(yintercept=0.0) + 
  geom_ribbon(aes(ymin = pupil - se, ymax = pupil + se), alpha = 0.1) + 
  scale_x_continuous(expand = c(0, 0),  limits = c(-100,12000),  breaks=c(seq.int(-100,12000, by = 250)))  + theme(axis.text.x = element_text(angle=90))

SE_plot

#800 -1200

bst2 = summarySE(base_data, measurevar="pupil", groupvars=c("session", "condition", "timeO"), na.rm = TRUE)

bst2$condition = revalue(bst2$condition, c("32"="CS+", "16"="CS-"))


SE2_plot <- ggplot(bst2)+
  aes(timeO, pupil, linetype=condition, color=condition) + 
  stat_summary(fun = "mean", geom = "line", size = 1) + 
  theme_bw() +
  labs(x = "Time (ms)",y = "Pupil Dilation") + #(change from baseline (a.u.)
  geom_hline(yintercept=0.0) + 
  geom_ribbon(aes(ymin = pupil - se, ymax = pupil + se), alpha = 0.1) + 
  facet_wrap(~session)

SE2_plot



# Estimating divergences with functional data analysis --------------------

#The above analyses may well suffice for what we have planned. However, sometimes it's useful for analysis to examine change over time, especially how and when two conditions diverge, and we can do that with Functional Data Analysis (FDA). 
#To do this, first we want get the difference between the two conditions for each participant. By default this package wil take condition 2 - condition 1, so reorder the factors if required.

# base_data$condition = as.factor(base_data$condition)
# levels(base_data$condition)  = unique(levels(base_data$condition))
# levels(base_data$condition)

differences <- create_difference_data(data = base_data,pupil = pupil)

#CS+ minus CS-
plot(differences, pupil = pupil, geom = 'line')


#We can now convert this to a functional data structure, made up of curves. To do this for this data we are going to make it up of cubics (order = 4) with 10 knots (basis = 10).
spline_data <- create_functional_data(data = differences,
                                      pupil = pupil,
                                      basis = 10,
                                      order = 10)

plot(spline_data, pupil = pupil, geom = 'line', colour = 'blue')

#That looks like it's done a pretty good job capturing the data. The advantage of this kind of analysis is that we can treat each curve as a function, and run a single functional t-test to work out during which window there are divergences. This package allows us to do that directly, and to observe the results.

ft_data <- run_functional_t_test(data = spline_data,
                                 pupil = pupil,
                                 alpha = 0.05)


plot(ft_data, show_divergence = T, colour = 'red', fill = 'orange')



# windowing ---------------------------------------------------------------

window <- create_time_windows(data = base_data, #base_data,
                              pupil = pupil,
                              breaks = c(0, 600, 1200,10000))

# I only want timewin 3
timeslot = window %>% filter(Window == 3)

timeslot$condition = as.factor(timeslot$condition)
timeslot$condition = revalue(timeslot$condition, c("32"="CS+", "16"="CS-"))

#overall
plot(timeslot, pupil = pupil, windows = T, geom = 'raincloud')


#group controlVSobese
timeslot$ID =  as.numeric(as.character(timeslot$ID))
timeslot$ses = 1:length(timeslot$ID)
for (i in  1:length(timeslot$ID)) {
  if(timeslot$ID[i] > 1000) {
    timeslot$ID[i] = timeslot$ID[i] - 1000
    timeslot$ses[i] = 1
  }
  else {
    timeslot$ID[i] = timeslot$ID[i]
    timeslot$ses[i] = 0
  }
}

timeslot$Window = timeslot$ses #just do that for plotting
timeslot$Window = as.factor(timeslot$Window)
plot(timeslot, pupil = pupil, windows = T, geom = 'raincloud') # plot session



# ANOVA -------------------------------------------------------------------

freqAno = summary(aov(pupil ~ condition * ses + Error(ID), data = timeslot))
freqAno


bd = summarySE(timeslot, measurevar="pupil", groupvars=c("ses", "condition"), na.rm = TRUE)




timeslot1 <- create_time_windows(data = base_data,
                                  pupil = pupil,
                                  breaks = c(0, 800, 4000, 5000, 8000, 10000))
# I only want timewin 2 VS 4
`%notin%` <- Negate(`%in%`)
timeslot1 = timeslot1 %>% filter(Window %in% c(2, 4))

timeslot1$condition = as.factor(timeslot1$condition)
timeslot1$condition = revalue(timeslot1$condition, c("32"="CS+", "16"="CS-"))

timeslot1$ID =  as.numeric(as.character(timeslot1$ID))
timeslot1$ses = 1:length(timeslot1$ID)
for (i in  1:length(timeslot1$ID)) {
  if(timeslot1$ID[i] > 1000) {
    timeslot1$ID[i] = timeslot1$ID[i] - 1000
    timeslot1$ses[i] = 1
  }
  else {
    timeslot1$ID[i] = timeslot1$ID[i]
    timeslot1$ses[i] = 0
  }
}


freqAno = summary(aov(pupil ~ Window * condition * ses + Error(ID), data = timeslot1))
freqAno
timeslot10 = subset(timeslot1, ses == 0)
timeslot11 = subset(timeslot1, ses == 1)
plot(timeslot1, pupil = pupil, windows = T, geom = 'raincloud')


# Pupil dilation
# A prestimulus baseline pupil size average of 1 s was calculated for each trial and subtracted from each subsequent data point to establish baseline-corrected pupil response.
# The statistical analysis was conducted using the average pupil diameter between 0.5 and 1.8 s after stimulus onset. This is the time window after stimulus presentation that was previously found to be responsive during conditioning
# As predicted, a planned contrast analysis using F-tests conducted on the CS condition (CS+ L, CS+ R, CS–) with the following weights (+0.5, +0.5, −1) revealed that the pupil was less constricted for CS+ L and CS+ R compared to CS– (F(1,39) = 4.45; P = 0.041; η2p = 0.102; 90% CI (0.002, 0.259); see Fig. 2a).

# Modelling with Generalised Additive Models ------------------------------
# 
# 
# data_func$cond <- ifelse(data_func$condition == '32', .5, -.5)
# m1 <- bam(pupil ~ s(timeO) +
#             s(timeO,  by = cond),
#           data = data_func,
#           family = gaussian)
# 
# summary(m1) # bs model to test
# 
# data_func$Event <- interaction(data_func$ID, data_func$trial, drop = T)
# 
# model_data <- data_func
# model_data <- start_event(model_data,column = 'timeO', event = 'Event')
# 
# model_data <- droplevels(model_data[order(model_data$ID,
#                                           model_data$trial,
#                                           model_data$timeO),])
# m2 <- bam(pupil ~ cond +  s(timeO,  by = cond) + s(timeO, Event, bs = 'fs', m = 1),
#           data = data_func,
#           family = gaussian,
#           discrete = T,
#           AR.start = model_data$start.event, rho = .6)
# 
# save.image(file = "m2.RData", version = NULL, ascii = FALSE, compress = FALSE, safe = TRUE)
# 
# # m3 <- bam(pupil ~ 
# #   s(timeO,  by = cond) +
# #   s(timeO, Event, bs = 'fs', m = 1),
# # data = base_data,
# # family = scat,
# # discrete = T,
# # AR.start = model_data$start.event, rho = .6)
# 
# summary(m2)
# qqnorm(resid(m2))
# itsadug::acf_resid(m2)
# plot(base_data, pupil = pupil, group = 'condition', model = m2)
# 
# #The summary from our second model indicates that there may be marginal evidence for this effect of condition. But how and when do they diverge???
# 
