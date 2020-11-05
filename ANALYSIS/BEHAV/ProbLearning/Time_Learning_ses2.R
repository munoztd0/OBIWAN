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
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV/LIRA') 

setwd(analysis_path)

# open dataset 
full <- read_csv(file.path(analysis_path, "PBLearning.csv"), col_types = cols(Subject = col_integer()))
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
info$Subject = info$id

# Preprocess Sess 1--------------------------------------------------------------

data  <- subset(full, Session == 1) #subset #only session one 
data  <- subset(data, Group == 'O') #subset #only group )
data  <- subset(data, Phase == 'proc1') #only learning phase

#recode participants
for (i in  1:length(data$Subject)) {
  if(data$Subject[i] == 2251) #fix the bug
  {data$Subject[i] = 245}
  else if(data$Subject[i] == 2512210) 
  {data$Subject[i] = 251}
  else if(data$Subject[i] > 2000) 
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

bs = ddply(data, .(Subject, imcor), summarise, acc = mean(Stim.ACC, na.rm = TRUE)) 

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

dataclean <- select(data, c(subjID, type, choice, reward, intervention))
count_trial = dataclean %>% group_by(subjID, type) %>%tally()


# Time to acquire reach criterium -----------------------------------------------------
dataclean$count = 1
bs1 = dataclean %>% ddply(.(subjID, intervention), summarise, n = sum(count)) 
densityPlot(bs1$n)
bs1$Session =1

# Preprocess Sess 2--------------------------------------------------------------

data  <- subset(full, Session == 2) #subset #only session one 
data  <- subset(data, group == 'O') #subset #only session one 
data  <- subset(data, Phase == 'proc1') #only learning phase

#recode participants
for (i in  1:length(data$Subject)) {
  if(data$Subject[i] == 2251) #fix the bug
  {data$Subject[i] = 245}
  else if(data$Subject[i] == 2512210) 
  {data$Subject[i] = 251}
  else if(data$Subject[i] > 2000) 
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

bs = ddply(data, .(Subject, imcor), summarise, acc = mean(Stim.ACC, na.rm = TRUE)) 

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

dataclean <- select(data, c(subjID, type, choice, reward, intervention))
count_trial = dataclean %>% group_by(subjID, type) %>%tally()


# Time to acquire reach criterium -----------------------------------------------------
dataclean$count = 1
bs2 = dataclean %>% ddply(.(subjID, intervention), summarise, n = sum(count)) 
densityPlot(bs2$n)

bs2$Session = 2

# test --------------------------------------------------------------------
df = rbind(bs1, bs2)

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


pal= "#21908CFF" # add color
pal[2] = "black" # add one


averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position=c(.9,.9),
        plot.subtitle  = element_text(size = 14),
        legend.text  = element_text(size = 10),
        legend.key = element_rect(fill = "transparent", colour = "transparent"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size =  30),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())


mod <- lmerTest::lmer(n ~ Session*intervention + (1|subjID) + (1|Session), data = df)

plot = interactions::cat_plot(mod, pred = Session, modx = intervention, geom = "bar", interval = T, plot.points = TRUE)

ppp = plot + labs(subtitle = "", x ='', y ='Trials to achieve criterion') + 
  scale_color_manual(name = "", labels=c("Placebo", "Liraglutide"), values=c("0" = pal[2],"1"=pal[1])) + 
  scale_fill_manual(name = "", labels=c("Placebo", "Liraglutide"), values=c("0" = pal[2],"1"=pal[1])) + 
  #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,3500, by = 500)), limits = c(-100, 3500)) +
  scale_x_discrete(labels=c("Pre", "Post")) + theme_bw() + averaged_theme
ppp

cairo_pdf(file.path(figures_path,'Figure_learningXtrials.pdf'))
print(ppp)
dev.off()
