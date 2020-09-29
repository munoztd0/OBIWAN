
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
   install.packages("pacman")
   library(pacman)
 }
 pacman::p_load(tidyverse, dplyr, plyr, zoo, PupillometryR, BayesFactor, mgcv)
 # SETUP ------------------------------------------------------------------
 task = 'PAV_pup'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 
setwd(analysis_path)

group_pav <- read_delim(file.path(analysis_path,'PAV_pup.txt'), "\t")

df = subset(group_pav, session == 1) # only first session
#df =  group_pav %>% filter(ID %in% c(100, 102))
nID = length(unique(df$ID))
nID

#Create  groups!
df$group = 1:length(df$ID)
for (i in  1:length(df$ID)) {
  if(df$ID[i] > 199) {
    df$group[i] = 'obese'}
  else {
    df$group[i] = 'control'}
}

df$condition = df$marker
df$condition[df$condition == 1 | df$condition == 2 | df$condition == 3 | df$condition == 5 | df$condition == 48] <-0
# data$condition[data$condition == 3]<-64
df$condition[df$condition == 0] <- NaN
df$trial[df$trial == 0] <- NaN
# little trick to fill the missing value for trials and condition
data = df %>% mutate(condition = na.locf(condition,na.rm=F), trial = na.locf(trial,na.rm=F)) # na.locf fills with the last non-empty value
data = na.omit(data) 
max(data$trial) #should be 80

a = table(data$marker) #check it out eveything is normal (~20 CS+ per ID)
check = a[6]/nID #second number should be =~ 20
check
data$trial = as.factor(data$trial)
bs = data %>% ddply(.(ID, trial), summarise, timeZ = min(time)) 
data <- bs %>% right_join(data, by=c("ID","trial"))

data$timeO = data$time - data$timeZ
 data = data %>% filter(timeO < 10000)
 data = select(data, c(ID, trial,  timeO,  marker, pupil, condition))
 #save RData for cluster computing
#  save.image(file = "PAV_pup.RData", version = NULL, ascii = FALSE,
#                +            compress = FALSE, safe = TRUE)
pupil_data = data 

#Check that IDs are not numeric
 pupil_data$ID <- as.factor(pupil_data$ID)
#taking of baesline for now
  

  Sdata <- make_pupillometryr_data(data = pupil_data,
                    subject = ID,
                          trial = trial,
                           time = timeO,
                            condition = condition)

  Sdata$condition = as.factor(Sdata$condition)
  
  
mean_data <- downsample_time_data(data = Sdata,
                               pupil = pupil,
                         timebin_size = 50,
                           option = 'median')

plot(mean_data, pupil = pupil, group = 'condition')

#plot(Sdata, pupil = pupil, group = 'subject') 
missing <- calculate_missing_data(mean_data, pupil)
missing[with(missing,order(-Missing)),] #chekc missing head

mean_data2 <- clean_missing_data(mean_data,
                              pupil = pupil,
                                  trial_threshold = .75,
                            subject_trial_threshold = .75)

`%notin%` <- Negate(`%in%`)
mean_datafil = mean_data2 %>% filter(ID %notin% c(115, 132, 210, 224, 249)) #participant with more than 70% missing data

# hanning filtering the data c("median", "hanning", "lowpass") # check here
filtered_data <- filter_data(data = mean_datafil,
                                  pupil = pupil,
                                  filter = 'median',
                                     degree = 11)

plot(filtered_data, pupil = pupil, group = 'condition')

# interpolate across blinks (linear or cubic)
int_data <- interpolate_data(data = filtered_data,
                       pupil = pupil,
                       type = 'linear')

plot(int_data, pupil = pupil, group = 'condition')

#Baselining #its the data is a powerful way of making sure we control for between-participant variance of average pupil size. If we are looking at analyses that are largely within-subject, as we do here, this may not be such an issue, but we will do this anyway. This function allows us to baseline to the mean pupil size within a time window. Here we are just taking the first 100ms of the trial. If your baseline period is just outside of your analysis window (which it often will be), you can use subset_data() to remove that after baselining.
#check
base_data <- baseline_data(data = int_data,
                          pupil = pupil,
                          start = 8000,
                        stop = 10000)

plot(base_data, pupil = pupil, group = 'condition')

# ggplot(base_data, aes(x = pupil)) +
#   geom_histogram(aes(y = ..count..), colour = "green", binwidth = 0.5)  +
#   #geom_vline(xintercept = 10, linetype="dotted") +
#   #geom_vline(xintercept = 40, linetype="dotted") +
#   xlab("Pupil Size (z)") +
#   ylab("Count") +
#   theme_bw()


bst = summarySE(base_data, measurevar="pupil", groupvars=c("condition", "Timebin"), na.rm = TRUE)
bst$condition = revalue(bst$condition, c("32"="CS+", "16"="CS-", "64" ="Baseline"))

bst$Timebin = bst$Timebin * 50

SE_plot <- ggplot(bst)+
  aes(Timebin, pupil, linetype=condition, color=condition) + 
  stat_summary(fun = "mean", geom = "line", size = 1) + 
  theme_bw() +
  labs(x = "Time (ms)",y = "Pupil Dilation") + #(change from baseline (a.u.)
  geom_hline(yintercept=0.0) + 
  geom_ribbon(aes(ymin = pupil - se, ymax = pupil + se), alpha = 0.1) 

SE_plot

#exclude baseline
data_func = filter(base_data, condition != 64)



# Estimating divergences with functional data analysis --------------------

#The above analyses may well suffice for what we have planned. However, sometimes it's useful for analysis to examine change over time, especially how and when two conditions diverge, and we can do that with Functional Data Analysis (FDA). 
#To do this, first we want get the difference between the two conditions for each participant. By default this package wil take condition 2 - condition 1, so reorder the factors if required.

# base_data$condition = as.factor(base_data$condition)
# levels(base_data$condition)  = unique(levels(base_data$condition))
# levels(base_data$condition)




differences <- create_difference_data(data = data_func,pupil = pupil)

#CS+ minus CS-
plot(differences, pupil = pupil, geom = 'line')


#We can now convert this to a functional data structure, made up of curves. To do this for this data we are going to make it up of cubics (order = 4) with 10 knots (basis = 10).
spline_data <- create_functional_data(data = differences,
                                      pupil = pupil,
                                      basis = 10,
                                      order = 4)

plot(spline_data, pupil = pupil, geom = 'line', colour = 'blue')

#That looks like it's done a pretty good job capturing the data. The advantage of this kind of analysis is that we can treat each curve as a function, and run a single functional t-test to work out during which window there are divergences. This package allows us to do that directly, and to observe the results.

ft_data <- run_functional_t_test(data = spline_data,
                                 pupil = pupil,
                                 alpha = 0.5)


plot(ft_data, show_divergence = T, colour = 'red', fill = 'orange')



#windowing

window <- create_time_windows(data = data_func, #base_data,
                            pupil = pupil,
                            breaks = c(0, 1600, 2000,10000))

# I only want timewin 3
timeslot1 = window %>% filter(Window == 3)

timeslot1$condition = as.factor(timeslot1$condition)
timeslot1$condition = revalue(timeslot1$condition, c("32"="CS+", "16"="CS-"))

plot(timeslot1, pupil = pupil, windows = T, geom = 'raincloud')

#average= subset(average, ID != 132) #Nan
t.test(pupil ~ condition, paired = T, data = timeslot1)


# average$condition = as.numeric(average$condition)
# ttestBF(x = average$pupil, y = average$condition, paired=TRUE)

# Error: ID
# Df Sum Sq Mean Sq F value Pr(>F)
# condition  1    3.5   3.530   0.478  0.492
# Residuals 59  435.8   7.386               
# 
# Error: Within
# Df Sum Sq Mean Sq F value Pr(>F)    
# Window             4  149.4   37.34  57.874 <2e-16 ***
#   condition          1    1.0    1.00   1.556  0.213    
# Window:condition   4    0.3    0.06   0.098  0.983    
# Residuals        535  345.2    0.65                   
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

timeslots1 <- create_time_windows(data = base_data,
                                 pupil = pupil,
                                 breaks = c(0, 1000, 4000, 5000, 8000, 10000))
# I only want timewin 2 VS 4
`%notin%` <- Negate(`%in%`)
timeslots1 = timeslots1 %>% filter(Window %in% c(2, 4))

timeslots1$condition = as.factor(timeslots1$condition)
timeslots1$condition = revalue(timeslots1$condition, c("32"="CS+", "16"="CS-"))
head(timeslots1)

freqAno = summary(aov(pupil ~ Window * condition + Error(ID), data = timeslots1))
freqAno

plot(timeslots1, pupil = pupil, windows = T, geom = 'raincloud')

# Pupil dilation
# A prestimulus baseline pupil size average of 1 s was calculated for each trial and subtracted from each subsequent data point to establish baseline-corrected pupil response.
# The statistical analysis was conducted using the average pupil diameter between 0.5 and 1.8 s after stimulus onset. This is the time window after stimulus presentation that was previously found to be responsive during conditioning
# As predicted, a planned contrast analysis using F-tests conducted on the CS condition (CS+ L, CS+ R, CS–) with the following weights (+0.5, +0.5, −1) revealed that the pupil was less constricted for CS+ L and CS+ R compared to CS– (F(1,39) = 4.45; P = 0.041; η2p = 0.102; 90% CI (0.002, 0.259); see Fig. 2a).

# Modelling with Generalised Additive Models ------------------------------


data_func$cond <- ifelse(data_func$condition == '32', .5, -.5)
m1 <- bam(pupil ~ s(timeO) +
            s(timeO,  by = cond),
         data = data_func,
         family = gaussian)

summary(m1) # bs model to test

data_func$Event <- interaction(data_func$ID, data_func$trial, drop = T)

model_data <- data_func
model_data <- itsadug::start_event(model_data,column = 'timeO', event = 'Event')

model_data <- droplevels(model_data[order(model_data$ID,
                                       model_data$trial,
                                        model_data$timeO),])
m2 <- bam(pupil ~ cond +  s(timeO,  by = cond) + s(timeO, Event, bs = 'fs', m = 1),
        data = data_func,
         family = gaussian,
        discrete = T,
        AR.start = model_data$start.event, rho = .6)

save.image(file = "m2.RData", version = NULL, ascii = FALSE, compress = FALSE, safe = TRUE)

# m3 <- bam(pupil ~ 
#   s(timeO,  by = cond) +
#   s(timeO, Event, bs = 'fs', m = 1),
# data = base_data,
# family = scat,
# discrete = T,
# AR.start = model_data$start.event, rho = .6)

summary(m2)
qqnorm(resid(m2))
itsadug::acf_resid(m2)
plot(base_data, pupil = pupil, group = 'condition', model = m2)

#The summary from our second model indicates that there may be marginal evidence for this effect of condition. But how and when do they diverge???

