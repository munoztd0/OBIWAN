
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
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV/LIRA') 
setwd(analysis_path)

session_pav <- read_delim(file.path(analysis_path,'PAV_pup.txt'), "\t")
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # 
info$ID = info$id

df = subset(session_pav, group == 1) # only obese
#df =  session_pav %>% filter(ID %in% c(100, 102))
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

bst = data %>% ddply(.(ID, session), summarise, timeZ = min(time)) 
#create ID-session
x = tidyr::unite_(data, paste(colnames(data)[c(3,4)], collapse="_"), colnames(data)[c(3,4)])
data$IDxSes = x$ID_session

bs = data %>% ddply(.(IDxSes), summarise, timeZ = min(time)) 
data$trial = as.factor(data$trial)
check = a[6]/length(bs$ID) #second number should be =~ 20
check

bs = data %>% ddply(.(IDxSes, trial), summarise, timef = min(time)) 
data <- bs %>% right_join(data, by=c("IDxSes","trial"))

data$timeO = data$time - data$timeZ
data$timeO = data$timeO - 100 # to put back the shift in order !  # because until here I have 0 that means -100 and 12100 means 12000
data = data %>% filter(timeO < 12000)


pupil_data = data 

#Check that IDs are not numeric
pupil_data$ID <- as.factor(pupil_data$IDxSes)


pupil_data = select(pupil_data, c(ID, trial,  timeO,  marker, pupil, condition, session, intervention))

#save RData for cluster computing
# save.image(file = "PAV_pup_ses2.RData", version = NULL, ascii = FALSE, compress = FALSE, safe = TRUE)

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


# here  -------------------------------------------------------------------

#theme
averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position= 'none',
        legend.title  = element_text(size = 12),
        legend.text  = element_text(size = 10),
        legend.key.size = unit(0.2, "cm"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size =  30),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())



bst = summarySE(base_data, measurevar="pupil", groupvars=c("condition", "session", "Timebin"), na.rm = TRUE)
bst = subset(bst, N > 5)
bst$Timebin = bst$Timebin * 50
bst$condition = revalue(bst$condition, c("32"="CS+", "16"="CS-")) #, "64" ="Baseline"

pal = viridis::inferno(n=5) # specialy conceived for colorblindness
pal[6] = "#21908CFF" # add one

SE_plot <- ggplot(bst)+
  aes(Timebin, pupil, linetype=condition, color=condition, fill = condition) + 
  stat_summary(fun = "mean", geom = "line", size = 1) + 
  theme_bw() +
  labs(x = "Time (ms)",y = "Change in Pupil size (au)") + #(change from baseline (a.u.)
  geom_hline(yintercept=0.0) + 
  geom_ribbon(aes(ymin = pupil - se, ymax = pupil + se), alpha = 0.1) + 
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = '')+
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = '')+
  scale_linetype_manual(values=c("CS+"= 1, "CS-"= 2), guide = 'none')+ 
  scale_x_continuous(breaks = c(seq.int(0,12000, by = 2000)), limits = c(-100,12000)) +
facet_wrap(~session, labeller=labeller(session = labels)) 


ppp <- SE_plot +averaged_theme+ theme_bw() + theme(strip.background = element_rect(fill="white"), axis.text.x = element_text(angle = 90))
ppp

cairo_pdf(file.path(figures_path,'Figure_pupilXsession.pdf'))
print(ppp)
dev.off()



# Estimating divergences with functional data analysis --------------------

#The above analyses may well suffice for what we have planned. However, sometimes it's useful for analysis to examine change over time, especially how and when two conditions diverge, and we can do that with Functional Data Analysis (FDA). 
#To do this, first we want get the difference between the two conditions for each participant. By default this package wil take condition 2 - condition 1, so reorder the factors if required.

# base_data$condition = as.factor(base_data$condition)
# levels(base_data$condition)  = unique(levels(base_data$condition))
# levels(base_data$condition)

differences <- create_difference_data(data = base_data,pupil = pupil)

#CS+ minus CS-
pp = plot(differences, pupil = pupil, geom = 'line')
pp + scale_x_continuous(breaks = c(seq.int(0,12000, by = 500)), limits = c(-100,12000))

#We can now convert this to a functional data structure, made up of curves. To do this for this data we are going to make it up of cubics (order = 4) with 10 knots (basis = 10).
spline_data <- create_functional_data(data = differences,
                                      pupil = pupil,
                                      basis = 10,
                                      order = 4)

plot(spline_data, pupil = pupil, geom = 'line', colour = 'blue')

#That looks like it's done a pretty good job capturing the data. The advantage of this kind of analysis is that we can treat each curve as a function, and run a single functional t-test to work out during which window there are divergences. This package allows us to do that directly, and to observe the results.

ft_data <- run_functional_t_test(data = spline_data,
                                 pupil = pupil,
                                 alpha = 0.05)


plot(ft_data, show_divergence = T, colour = 'red', fill = 'orange')





# windowing ---------------------------------------------------------------

window <- create_time_windows(data = base_data, 
                              pupil = pupil,
                              breaks = c(-100, 800, 1800, 5800, 6800,11900))

# I only want timewin 3
timeslot = window %>% filter(Window %in% c(2,4))

timeslot$condition = as.factor(timeslot$condition)
timeslot$condition = revalue(timeslot$condition, c("32"="CS+", "16"="CS-"))

#overall
plot(timeslot, pupil = pupil, windows = T, geom = 'raincloud')

bs$ID = bst$ID
bs$session = bst$session

timeslot2 = merge(timeslot, bs, by.x="ID", by.y = "IDxSes")
timeslot2 = merge(timeslot2, info, by="ID")
timeslot2 = select(timeslot2, -c("ID", "timeZ"))
timeslot2$ID = timeslot2$ID.y
pal = viridis::inferno(n=5) # specialy conceived for colorblindness
pal[6] = "#21908CFF" # add one

#timeslot$Window = timeslot$session #just do that for plotting
labels <- c("1" = "Pre", "2" = "Post")
timeslot$ID = timeslot2$ID
timeslot$session = timeslot2$session
timeslot$intervention = as.factor(timeslot2$intervention)
#little detour to change defaults of pupillometryR
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R', echo=TRUE)
org <- PupillometryR::geom_flat_violin;
myfct <- geom_flat_violin
R.utils::reassignInPackage("geom_flat_violin", pkgName="PupillometryR", myfct);


pp = plot(timeslot, pupil = pupil, windows = T, geom = 'raincloud')

ppp = pp + scale_x_discrete(labels=c("Cue", "Stimulus")) +
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = '') +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = '') +
  ylab('Change in Pupil size (au)') +
  theme_bw() + 
  facet_wrap(~session, labeller=labeller(session = labels))+ 
  theme(strip.background = element_rect(fill="white"))  +  xlab('Time Window') + averaged_theme

p = ppp +  geom_point(aes(shape=intervention ))  +   scale_shape_discrete(labels=c("Placebo", "Liraglutide"), name = '') + theme(legend.position = "top", legend.direction = 'horizontal')

cairo_pdf(file.path(figures_path,'Figure_time_pupilXsession.pdf'))
print(p)
dev.off()


# ANOVA -------------------------------------------------------------------

mod = lmerTest::lmer(pupil ~ Window*condition* intervention * session + (condition + session | ID), data = timeslot)
anova(mod)

p_g = emmeans::emmeans(freqAno, pairwise~ session); p_g

pp = plot(timeslot, pupil = pupil, windows = T, geom = 'raincloud')

ppp = pp + scale_x_discrete(labels=c("Cue", "Stimulus")) +
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = 'Condition') +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = 'Condition') +
  ylab('Change in Pupil size (au)') +
  theme_bw() + 
  facet_wrap(~session, labeller=labeller(group = labels))+ 
  theme(strip.background = element_rect(fill="white")) 

ppp

bd = summarySE(timeslot, measurevar="pupil", groupvars=c("session", "condition"), na.rm = TRUE)






timeslots1 <- create_time_windows(data = data_func,
                                  pupil = pupil,
                                  breaks = c(0, 1000, 4000, 5000, 8000, 10000))
# I only want timewin 2 VS 4
`%notin%` <- Negate(`%in%`)
timeslots1 = timeslots1 %>% filter(Window %in% c(2, 4))

timeslots1$condition = as.factor(timeslots1$condition)
timeslots1$condition = revalue(timeslots1$condition, c("32"="CS+", "16"="CS-"))

timeslots1$ID =  as.numeric(as.character(timeslots1$ID))
timeslots1$group = 1:length(timeslots1$ID)
for (i in  1:length(timeslots1$ID)) {
  if(timeslots1$ID[i] > 199) {
    timeslots1$session[i] = 'obese'
  }
  else {
    timeslots1$session[i] = 'control'
  }
}


freqAno = summary(aov(pupil ~ Window * condition * session + Error(ID), data = timeslots1))
freqAno
timeslots10 = subset(timeslots1, session == 'control')
timeslots11 = subset(timeslots1, session == 'obese')
plot(timeslots10, pupil = pupil, windows = T, geom = 'raincloud')


pupil_data = select(pupil_data, c(ID, trial,  timeO,  marker, pupil, condition, session))

#save RData for cluster computing
# save.image(file = "PAV_pup_ses2.RData", version = NULL, ascii = FALSE, compress = FALSE, safe = TRUE)



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


# test --------------------------------------------------------------------




bst1 = summarySE(base_data, measurevar="pupil", groupvars=c("condition", "Timebin"), na.rm = TRUE)
bst1$Timebin = bst1$Timebin * 50
bst1$condition = revalue(bst1$condition, c("32"="CS+", "16"="CS-")) #, "64" ="Baseline"

pal = viridis::inferno(n=5) # specialy conceived for colorblindness
pal[6] = "#21908CFF" # add one

SE_plot <- ggplot(bst1)+
  aes(Timebin, pupil, linetype=condition, color=condition) + 
  stat_summary(fun = "mean", geom = "line", size = 1) + 
  theme_bw() +
  labs(x = "Time (ms)",y = "Change in Pupil size (au)") + #(change from baseline (a.u.)
  #geom_hline(yintercept=0.0) + 
  geom_ribbon(aes(ymin = pupil - se, ymax = pupil + se), alpha = 0.1) +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = 'Condition') + 
  scale_linetype_manual(values=c("CS+"= 1, "CS-"= 2), guide = 'none')

ppp <- SE_plot + theme_bw() + theme(strip.background = element_rect(fill="white"))
ppp

cairo_pdf(file.path(figures_path,'Figure_pupil.pdf'))
print(ppp)
dev.off()


bst = summarySE(base_data, measurevar="pupil", groupvars=c("ID","condition", "Timebin"), na.rm = TRUE)
bst$ID =  as.numeric(as.character(bst$ID))
bst$group = 1:length(bst$ID)
for (i in  1:length(bst$ID)) {
  if(bst$ID[i] > 199) {
    bst$session[i] = 'obese'
  }
  else {
    bst$session[i] = 'control'
  }
}

bst$ID = as.factor(bst$ID)

bst$condition = revalue(bst$condition, c("32"="CS+", "16"="CS-"))

bst2 = summarySE(bst, measurevar="pupil", groupvars=c("session", "condition", "Timebin"), na.rm = TRUE)
bst2$Timebin = bst2$Timebin * 50
labels <- c("1" = "Pre", "2" = "Post")

SE2_plot <- ggplot(bst2)+
  aes(Timebin, pupil, linetype=condition, color=condition, fill = condition) + 
  stat_summary(fun = "mean", geom = "line", size = 1) + 
  theme_bw() +
  labs(x = "Time (ms)",y = "Change in Pupil size (au)") + #(change from baseline (a.u.)
  geom_hline(yintercept=0.0) + 
  geom_ribbon(aes(ymin = pupil - se, ymax = pupil + se), alpha = 0.1) + 
  facet_wrap(~session, labeller=labeller(group = labels)) + 
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = '')+
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = '')+
  scale_linetype_manual(values=c("CS+"= 1, "CS-"= 2), guide = 'none')+ 
  scale_x_continuous(breaks = c(seq.int(0,12000, by = 2000)), limits = c(-100,12000))


ppp <- SE2_plot + theme_bw() + theme(strip.background = element_rect(fill="white"), axis.text.x = element_text(angle = 90))
ppp

cairo_pdf(file.path(figures_path,'Figure_pupilXsession.pdf'))
print(ppp)
dev.off()



# Estimating divergences with functional data analysis --------------------

#The above analyses may well suffice for what we have planned. However, sometimes it's useful for analysis to examine change over time, especially how and when two conditions diverge, and we can do that with Functional Data Analysis (FDA). 
#To do this, first we want get the difference between the two conditions for each participant. By default this package wil take condition 2 - condition 1, so reorder the factors if required.

# base_data$condition = as.factor(base_data$condition)
# levels(base_data$condition)  = unique(levels(base_data$condition))
# levels(base_data$condition)

differences <- create_difference_data(data = base_data,pupil = pupil)

#CS+ minus CS-
pp = plot(differences, pupil = pupil, geom = 'line')
pp + scale_x_continuous(breaks = c(seq.int(0,12000, by = 500)), limits = c(-100,12000))

#We can now convert this to a functional data structure, made up of curves. To do this for this data we are going to make it up of cubics (order = 4) with 10 knots (basis = 10).
spline_data <- create_functional_data(data = differences,
                                      pupil = pupil,
                                      basis = 10,
                                      order = 4)

plot(spline_data, pupil = pupil, geom = 'line', colour = 'blue')

#That looks like it's done a pretty good job capturing the data. The advantage of this kind of analysis is that we can treat each curve as a function, and run a single functional t-test to work out during which window there are divergences. This package allows us to do that directly, and to observe the results.

ft_data <- run_functional_t_test(data = spline_data,
                                 pupil = pupil,
                                 alpha = 0.05)


plot(ft_data, show_divergence = T, colour = 'red', fill = 'orange')




# windowing ---------------------------------------------------------------

window <- create_time_windows(data = base_data, #base_data,
                              pupil = pupil,
                              breaks = c(-100, 750, 1750, 5000, 6000,11900))

# I only want timewin 3
timeslot = window %>% filter(Window %in% c(2,4))

# data --------------------------------------------------------------------

timeslots1$ID =  as.numeric(as.character(timeslots1$ID))
timeslots1$group = 1:length(timeslots1$ID)
for (i in  1:length(timeslots1$ID)) {
  if(timeslots1$ID[i] > 199) {
    timeslots1$group[i] = 'obese'
  }
  else {
    timeslots1$group[i] = 'control'
  }
}

timeslot$condition = as.factor(timeslot$condition)
timeslot$condition = revalue(timeslot$condition, c("32"="CS+", "16"="CS-"))

#overall
plot(timeslot, pupil = pupil, windows = T, geom = 'raincloud')


#session controlVSobese
timeslot$ID =  as.numeric(as.character(timeslot$ID))
timeslot$group = 1:length(timeslot$ID)
for (i in  1:length(timeslot$ID)) {
  if(timeslot$ID[i] > 199) {
    timeslot$session[i] = 'obese'
  }
  else {
    timeslot$session[i] = 'control'
  }
}


#theme
averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.title  = element_text(size = 12),
        legend.text  = element_text(size = 10),
        legend.key = element_rect(fill = "transparent", colour = "transparent"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size =  30),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())


pal = viridis::inferno(n=5) # specialy conceived for colorblindness
pal[6] = "#21908CFF" # add one

#timeslot$Window = timeslot$session #just do that for plotting
labels <- c("control" = "Lean", "obese" = "Obese")

#little detour to change defaults of pupillometryR
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R', echo=TRUE)
org <- PupillometryR::geom_flat_violin;
myfct <- geom_flat_violin
reassignInPackage("geom_flat_violin", pkgName="PupillometryR", myfct);


pp = plot(timeslot, pupil = pupil, windows = T, geom = 'raincloud')

ppp = pp + scale_x_discrete(labels=c("Cue", "Stimulus")) +
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = '', guide = 'none') +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = '') +
  ylab('Change in Pupil size (au)') +
  theme_bw() + 
  facet_wrap(~session, labeller=labeller(group = labels))+ 
  theme(strip.background = element_rect(fill="white"))  +  xlab('Time Window') + averaged_theme

ppp

cairo_pdf(file.path(figures_path,'Figure_time_pupilXsession.pdf'))
print(ppp)
dev.off()


# ANOVA -------------------------------------------------------------------

freqAno = aov(pupil ~ condition * session + Error(ID), data = timeslot)
summary(freqAno)

p_g = emmeans::emmeans(freqAno, pairwise~ session); p_g

pp = plot(timeslot, pupil = pupil, windows = T, geom = 'raincloud')

ppp = pp + scale_x_discrete(labels=c("Cue", "Stimulus")) +
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = 'Condition') +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), name = 'Condition') +
  ylab('Change in Pupil size (au)') +
  theme_bw() + 
  facet_wrap(~session, labeller=labeller(group = labels))+ 
  theme(strip.background = element_rect(fill="white")) 

ppp

bd = summarySE(timeslot, measurevar="pupil", groupvars=c("session", "condition"), na.rm = TRUE)






timeslots1 <- create_time_windows(data = data_func,
                                  pupil = pupil,
                                  breaks = c(0, 1000, 4000, 5000, 8000, 10000))
# I only want timewin 2 VS 4
`%notin%` <- Negate(`%in%`)
timeslots1 = timeslots1 %>% filter(Window %in% c(2, 4))

timeslots1$condition = as.factor(timeslots1$condition)
timeslots1$condition = revalue(timeslots1$condition, c("32"="CS+", "16"="CS-"))

timeslots1$ID =  as.numeric(as.character(timeslots1$ID))
timeslots1$group = 1:length(timeslots1$ID)
for (i in  1:length(timeslots1$ID)) {
  if(timeslots1$ID[i] > 199) {
    timeslots1$session[i] = 'obese'
  }
  else {
    timeslots1$session[i] = 'control'
  }
}


freqAno = summary(aov(pupil ~ Window * condition * session + Error(ID), data = timeslots1))
freqAno
timeslots10 = subset(timeslots1, session == 'control')
timeslots11 = subset(timeslots1, session == 'obese')
plot(timeslots10, pupil = pupil, windows = T, geom = 'raincloud')

