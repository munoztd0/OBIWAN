####################################################################################################
#                                                                                                  #
#                                                                                                  # #                                                                                                  # 
#                                    TITLE OF THE PAPER                                            #
#                                                                                                  #
#                                                                                                  #
#                                                                                                  #
# Created by E.R.P on NOVEMBER 2018                                                               #
# modified by D.M.T. on AUGUST 2020                                                                 #
####################################################################################################




#--------------------------------------  PRELIMINARY STUFF ----------------------------------------
#load libraries

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, 
               reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, 
               lsmeans, BayesFactor, effectsize, devtools, misty)

if(!require(devtools)) {
  install.packages("devtools")
  library(devtools)
}

# get tool
devtools::source_gist("2a1bb0133ff568cbe28d", 
                      filename = "geom_flat_violin.R")

#SETUP

# Set path
#home_path       <- '/Users/evapool/mountpoint2'
home_path       <- '~/OBIWAN'

# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/BEHAV/ForPaper')
figures_path <- file.path(analysis_path, 'figures')
setwd(analysis_path)

#datasets dictory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 

# open datasets
PAV  <- read.delim(file.path(data_path,'PAV/REWOD_PAVCOND_ses_first.txt'), header = T, sep ='') # read in dataset
INST <- read.delim(file.path(data_path,'INSTRU/REWOD_INSTRU_ses_first.txt'), header = T, sep ='') # read in dataset
PIT  <- read.delim(file.path(data_path,'PIT/REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset
HED  <- read.delim(file.path(data_path,'HED/REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset

# themes for plots

averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        legend.text  = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 32),
        axis.title.y = element_text(size =  32),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())

timeline_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.text  = element_text(size =  14),
        legend.title = element_text(size =  14),
        axis.title.x = element_text(size = 32),
        axis.title.y = element_text(size =  32),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())

pal = viridis::inferno(n=5)

# -------------------------------------------------------------------------------------------------
#                                             PAVLOVIAN
# -------------------------------------------------------------------------------------------------

# -------------------------------------- PREPROCESSING RT ----------------------------------------

# define factors
PAV$id               <- factor(PAV$id)
PAV$trial            <- factor(PAV$trial)
PAV$session          <- factor(PAV$session)
PAV$condition        <- factor(PAV$condition)

# get times in milliseconds 
PAV$RT               <- PAV$RT * 1000

# remove sub 8 (bc we dont have scans)
PAV <- subset (PAV,!id == '8') 

#Preprocessing
##only first round
PAV.clean <- filter(PAV, rounds == 1)
PAV.clean$condition <- droplevels(PAV.clean$condition, exclude = "Baseline")
full = length(PAV.clean$RT)

##shorter than 100ms and longer than 3sd+mean
PAV.clean <- filter(PAV.clean, RT >= 100) # min RT is 106ms
PAV.clean <- ddply(PAV.clean, .(id), transform, RTm = mean(RT))
PAV.clean <- ddply(PAV.clean, .(id), transform, RTsd = sd(RT))
PAV.clean <- filter(PAV.clean, RT <= RTm+3*RTsd) 

# calculate the dropped data in the preprocessing
clean= length(PAV.clean$RT)
dropped = full-clean
(dropped*100)/full

# -------------------------------------- STATS -----------------------------------------------
PAV.means <- aggregate(PAV.clean$RT, by = list(PAV.clean$id, PAV.clean$condition, PAV.clean$liking_ratings), FUN='mean') # extract means
colnames(PAV.means) <- c('id','condition','liking','RT')

# -------------------------------------- RT
# stat
anova.RT <- aov_car(RT ~ condition+ Error (id/condition), data = PAV.means, anova_table = list(correction = "GG", es = "pes"))

# effect sizes (90%CI)
F_to_eta2(f = c(6.67), df = c(1), df_error = c(23))

# Bayes factors
RT.BF <- anovaBF(RT ~ condition  + id, data = PAV.means, 
                 whichRandom = "id", iterations = 50000)
RT.BF <- recompute(RT.BF, iterations = 50000)
RT.BF

# -------------------------------------- Liking
# stat
anova.liking <- aov_car(liking ~ condition+ Error (id/condition), data = PAV.means, anova_table = list(correction = "GG", es = "pes"))

# effect sizes (90%CI)
F_to_eta2(f = c(6.70), df = c(1), df_error = c(23))

# Bayes factors
liking.BF <- anovaBF(liking ~ condition  + id, data = PAV.means, 
                     whichRandom = "id", iterations = 50000)
liking.BF <- recompute(liking.BF, iterations = 50000)
liking.BF

# -------------------------------------- PLOT -----------------------------------------------
# rename factor levels for plot
PAV.means$condition  <- dplyr::recode(PAV.means$condition, "CSplus" = "CS+", "CSminus" = "CS-" )

dfL <- summarySEwithin(PAV.means,
                       measurevar = "liking",
                       withinvars = "condition", 
                       idvar = "id")

dfL$cond <- ifelse(dfL$condition == "CS+", -0.25, 0.25)
PAV.means$cond <- ifelse(PAV.means$condition == "CS+", -0.25, 0.25)
set.seed(666)
PAV.means <- PAV.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))

# Liking
pp <- ggplot(PAV.means, aes(x = cond, y = liking, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = liking), alpha = .5, size = 0.5, color = 'gray' ) +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA)) +
  geom_point(aes(x = condjit), alpha = .3) +
  geom_crossbar(data = dfL, aes(y = liking, ymin=liking-se, ymax=liking+se), width = 0.2 , alpha = 0.1)+
  ylab('Liking Ratings')+
  xlab('Conditioned stimulus')+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 25)), limits = c(-0.5,100.5)) +
  scale_x_continuous(labels=c("CS+", "CS-"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), guide = 'none') +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), guide = 'none') +
  theme_bw()


ppp <- pp + averaged_theme 


pdf(file.path(figures_path,'Figure_PavlovianLiking.pdf'))
print(ppp)
dev.off()

# RT
dfR <- summarySEwithin(PAV.means,
                       measurevar = "RT",
                       withinvars = "condition", 
                       idvar = "id")

dfR$cond <- ifelse(dfL$condition == "CS+", -0.25, 0.25)

pp <- ggplot(PAV.means, aes(x = cond, y = RT, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = RT), alpha = .5, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA))+
  geom_point(aes(x = condjit), alpha = .3,) +
  geom_crossbar(data = dfR, aes(y = RT, ymin=RT-se, ymax=RT+se), width = 0.2 , alpha = 0.1)+
  ylab('Reaction Times (ms)')+
  xlab('Conditioned stimulus')+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(200,700, by = 100)), limits = c(180,700.5)) +
  scale_x_continuous(labels=c("CS+", "CS-"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), guide = 'none') +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), guide = 'none') +
  theme_bw()


ppp <- pp + averaged_theme 


pdf(file.path(figures_path,'Figure_PavlovianRT.pdf'))
print(ppp)
dev.off()




# -------------------------------------------------------------------------------------------------
#                                             INSTRUMENTAL
# -------------------------------------------------------------------------------------------------

# -------------------------------------- PREPROC  --------------------------------------------------

## remove sub 8 (we dont have scans)
INST <- subset (INST,!id == '8') 

# define factors
INST$id                       <- factor(INST$id)
INST$session                  <- factor(INST$session)
INST$rewarded_response        <- factor(INST$rewarded_response)
INST$trial                    <- factor(INST$trial)

# CREATE BINS OF 6
INST$trial        <- as.numeric(INST$trial)
INST  <- ddply(INST, "id", transform, bin = as.numeric(cut2(trial, g = 6)))
INST$trial                    <- factor(INST$trial)


# get the averaged dataset
INST.means <- aggregate(INST$n_grips, by = list(INST$id, INST$trial), FUN='mean') # extract means
colnames(INST.means) <- c('id','trial','n_grips')

# -------------------------------------- STAT -----------------------------------------------------


# --------------------------------------- all trials

# stat
anova.Ins.all <- aov_car(n_grips ~ trial+ Error (id/trial), data = INST.means, anova_table = list(correction = "GG", es = "pes"))

# effect sizes (90%CI)
F_to_eta2(f = c(1.54), df = c(5.08), df_error = c(116.84))

# Bayes factors
inst.BF.all <- anovaBF(n_grips ~ trial  + id, data = INST.means, 
                       whichRandom = "id", iterations = 50000)
inst.BF.all  <- recompute(inst.BF.all  , iterations = 50000)
inst.BF.all 



# --------------------------------------- first trials
INST.T <- subset(INST, trial == 1 | trial == 2)
INST.T$trial <- factor(INST.T$trial)

# stat
anova.Ins <- aov_car(n_grips ~ trial+ Error (id/trial), data = INST.T, anova_table = list(correction = "GG", es = "pes"))

# effect sizes (90%CI)
F_to_eta2(f = c(24.77), df = c(1), df_error = c(23))

# Bayes factors
inst.BF <- anovaBF(n_grips ~ trial  + id, data = INST.T, 
                   whichRandom = "id", iterations = 50000)
inst.BF <- recompute(inst.BF , iterations = 50000)
inst.BF 


# -------------------------------------- PLOT  ---------------------------------------------------------

#over time
dfTRIAL <- summarySEwithin(INST.means,
                           measurevar = "n_grips",
                           withinvars = "trial", 
                           idvar = "id")
dfTRIAL$trial       <- as.numeric(dfTRIAL$trial)


pp <- ggplot(INST.means, aes(x =trial, y = n_grips)) +
  geom_point(data = dfTRIAL, alpha = 0.5, color = pal[4]) +
  geom_line(data = dfTRIAL, color = pal[4]) +
  geom_ribbon(data = dfTRIAL,aes(ymin=n_grips-se, ymax=n_grips+se), fill = pal[4], alpha = 0.3)+
  ylab('Number of Grips')+
  xlab('Trial') +
  scale_y_continuous(expand = c(0, 0),  limits = c(0,25),  breaks=c(seq.int(0,25, by = 5))) +
  scale_x_continuous(expand = c(0, 0),  limits = c(0,25),  breaks=c(seq.int(0,25, by = 5))) +
  theme_bw()

ppp <- pp + averaged_theme

pdf(file.path(figures_path,'Figure_Instrumental_trial.pdf'))
print(ppp)
dev.off()


# first to second trial
INST.T <- subset(INST, trial == 1 | trial == 2)
dfT <- summarySEwithin(INST.T,
                       measurevar = "n_grips",
                       withinvars = "trial", 
                       idvar = "id")

dfT$trial <- ifelse(dfT$trial == 1, -0.25, 0.25)
INST.T$trial <- ifelse(INST.T$trial == 1, -0.25, 0.25)
set.seed(666)
INST.T <- INST.T %>% mutate(trialjit = jitter(as.numeric(trial), 0.3),
                            grouping = interaction(id, trial))


pp <- ggplot(INST.T, aes(x = trial, y = n_grips, 
                         fill = factor(trial), color = factor(trial))) +
  geom_line(aes(x = trialjit, group = id, y = n_grips), alpha = .5, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = factor(trial), color = NA))+
  geom_point(aes(x = trialjit), alpha = .3) +
  geom_crossbar(data = dfT, aes(y = n_grips, ymin=n_grips-se, ymax=n_grips+se), width = 0.2 , alpha = 0.1)+
  ylab('Number of Grips')+
  xlab('Trial')+
  scale_fill_manual(values=c(pal[4], pal[4]), guide = 'none') +
  scale_color_manual(values=c(pal[4], pal[4]), guide = 'none') +
  scale_y_continuous(expand = c(0, 0),  limits = c(-.5,25.5),  breaks=c(seq.int(0,25, by = 5))) +
  scale_x_continuous(labels=c("1", "2"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  theme_bw()


ppp <- pp + averaged_theme

pdf(file.path(figures_path,'Figure_Instrumental_1_2.pdf'))
print(ppp)
dev.off()





# -------------------------------------------------------------------------------------------------
#                                             PIT
# -------------------------------------------------------------------------------------------------

#--------------------------------------- PREPROC  -----------------------------------------------------

## remove sub 8 (we dont have scans)
PIT <- subset (PIT,!id == '8') 

## subsetting into 3 differents tasks
PIT.all <- PIT
# define factors
fac <- c("id", "session", "condition",  "trialxcondition")
PIT.all[fac] <- lapply(PIT.all[fac], factor)

#subset phases
RIM <- subset (PIT.all,task == 'Reminder') 
PE <- subset (PIT.all,task == 'Partial_Extinction') 
PIT <- subset (PIT.all,task == 'PIT') 

# create bin for each mini block
PIT$trialxcondition        <- as.numeric(PIT$trialxcondition)
PIT  <- ddply(PIT, "id", transform, bin = as.numeric(cut2(trialxcondition, g = 5)))




# -------------------------------------- STATS -----------------------------------------------
PIT.s <- subset (PIT, condition == 'CSplus'| condition == 'CSminus')
PIT.s$trialxcondition <- factor(PIT.s$trialxcondition)
PIT.means <- aggregate(PIT.s$n_grips, by = list(PIT.s$id, PIT.s$condition), FUN='mean') # extract means
colnames(PIT.means) <- c('id','condition','n_grips')

PIT.trial <- aggregate(PIT.s$n_grips, by = list(PIT.s$id, PIT.s$trialxcondition), FUN='mean') # extract means
colnames(PIT.trial) <- c('id','trialxcondition','n_grips')


# stat
PIT.stat <- aov_car(n_grips ~ condition*trialxcondition + Error (id/condition*trialxcondition), data = PIT.s, anova_table = list(correction = "GG", es = "pes"))


# effect sizes (90%CI)
F_to_eta2(f = c(13.58), df = c(1), df_error = c(23))

F_to_eta2(f = c(1.39), df = c(5.07), df_error = c(116.52))

F_to_eta2(f = c(0.99), df = c(5.31), df_error = c(122.12))

# Bayes factors CS effect
PIT.BF.CS <- anovaBF(n_grips ~ condition + id, data = PIT.means, 
                     whichRandom = "id", iterations = 50000)
PIT.BF.CS <- recompute(PIT.BF.CS, iterations = 50000)
PIT.BF.CS

# Bayes factors trial effect
PIT.BF.trial <- anovaBF(n_grips ~ trialxcondition + id, data = PIT.trial, 
                        whichRandom = "id", iterations = 50000)
PIT.BF.trial <- recompute(PIT.BF.trial, iterations = 50000)
PIT.BF.trial

# Bayes factors trial effect
PIT.BF.int <- anovaBF(n_grips ~ condition*trialxcondition + id, data = PIT.s, 
                      whichRandom = "id", iterations = 50000)
PIT.BF.int  <- recompute(PIT.BF.int, iterations = 50000)
PIT.BF.int[4]/ PIT.BF.int[3]

# -------------------------------------- PLOTS -----------------------------------------------
# rename factor levels for plot
PIT.means$condition  <- dplyr::recode(PIT.means$condition, "CSplus" = "CS+", "CSminus" = "CS-" )


# AVERAGED EFFECT
dfG <- summarySEwithin(PIT.means,
                       measurevar = "n_grips",
                       withinvars = "condition", 
                       idvar = "id")

dfG$cond <- ifelse(dfG$condition == "CS+", -0.25, 0.25)
PIT.means$cond <- ifelse(PIT.means$condition == "CS+", -0.25, 0.25)
set.seed(666)
PIT.means <- PIT.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))


pp <- ggplot(PIT.means, aes(x = cond, y = n_grips, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = n_grips), alpha = .5, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA))+
  geom_point(aes(x = condjit), alpha = .3,) +
  geom_crossbar(data = dfG, aes(y = n_grips, ymin=n_grips-se, ymax=n_grips+se), width = 0.2 , alpha = 0.1)+
  ylab('Number of Grips')+
  xlab('Conditioned stimulus')+
  scale_fill_manual(values=c("CS+" = pal[2],"CS-"=pal[1]), guide = 'none') +
  scale_color_manual(values=c("CS+" = pal[2],"CS-"=pal[1]), guide = 'none')  +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,30, by = 5)), limits = c(-1,30.5)) +
  scale_x_continuous(labels=c("CS+", "CS-"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  theme_bw()


ppp <- pp + averaged_theme


pdf(file.path(figures_path,'Figure_PIT.pdf'))
print(ppp)
dev.off()


# OVERTIME

#reminder
RIM.p <- summarySEwithin(RIM,
                         measurevar = "n_grips",
                         withinvars = c("trial"),
                         idvar = "id")
RIM.p$Task_Name <- paste0("Reminder")
RIM.p$condition <- paste0("Reminder")

#partial extinction
PE.p <- summarySEwithin(PE,
                        measurevar = "n_grips",
                        withinvars = c("trial"),
                        idvar = "id")
PE.p$Task_Name <- paste0("Partial Extinction")
PE.p$condition <- paste0("Partial Extinction")

# PIT
PIT.p <- summarySEwithin(PIT.s,
                         measurevar = "n_grips",
                         withinvars = c("trialxcondition","condition"),
                         idvar = "id")
PIT.p$trial <- as.numeric(PIT.p$trialxcondition)+9
PIT.p$Task_Name <- paste0("PIT")
PIT.p = select(PIT.p, c('trial', 'N' , 'n_grips', 'sd', 'se', 'ci', 'Task_Name', 'condition'))

# merge all data bases
newdf <- rbind(RIM.p,PE.p)
df <- rbind(PIT.p, newdf)
df$condition <- droplevels(df$condition)



# plot
pp <- ggplot(df, aes(x = as.numeric(trial), y = n_grips,
                     color = condition, 
                     fill  = condition))+
  geom_line(alpha = .7, size = 1, show.legend = F) +
  geom_ribbon(aes(ymax = n_grips + se, ymin = n_grips - se, fill = condition, color =NA),  alpha=0.4) + 
  geom_point() +
  ylab('Number of Grips')+
  xlab('Trial')+
  scale_color_manual(labels = c( 'PIT: CS-', 'PIT: CS+','Part. Ext.', 'Rem.'), 
                     values = c("Reminder"=pal[4], "Partial Extinction"=pal[4], "CSplus" =pal[2], 'CSminus'=pal[1])) +
  scale_fill_manual(labels = c('PIT: CS-', 'PIT: CS+','Part. Ext.', 'Rem.'), 
                    values = c("Reminder"=pal[4], "Partial Extinction"=pal[4], "CSplus"= pal[2], 'CSminus'=pal[1])) +
  #ylim(low=0, high=17)+
  labs(fill = 'Phase', color = 'Phase') +
  
  scale_y_continuous(expand = c(0, 0),  limits = c(-2,30),  breaks=c(seq.int(0,30, by = 5))) +
  scale_x_continuous(expand = c(0, 0),  limits = c(0,25),  breaks=c(seq.int(0,25, by = 5))) +
  
  annotate("rect", xmin=0.3, xmax=3.5, ymin=0, ymax=27, alpha=0.2, fill="gray") +
  annotate("text", x = 1.8,  y =28, label="Rem.", fontface =2, size=6.5) +
  annotate("rect", xmin=3.8, xmax=9.5, ymin=0, ymax=27, alpha=0.2, fill="gray") +
  annotate("text", x = 6.65,  y =28, label="Part. Ext.",fontface =2, size=6.5) +
  annotate("rect", xmin=9.8, xmax=12.5, ymin=0, ymax=27, alpha=0.2, fill="gray") +
  annotate("rect", xmin=12.8, xmax=15.5, ymin=0, ymax=27, alpha=0.2, fill="gray") +
  annotate("rect", xmin=15.8, xmax=18.5, ymin=0, ymax=27, alpha=0.2, fill="gray") +
  annotate("rect", xmin=18.8, xmax=21.5, ymin=0, ymax=27, alpha=0.2, fill="gray") +
  annotate("rect", xmin=21.8, xmax=24.5, ymin=0, ymax=27, alpha=0.2, fill="gray") +
  
  annotate("text", x = 17.16,  y =28, label="PIT",fontface =2, size=6.5) +
  theme_bw()



ppp <- pp + theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position="none",
        legend.text  = element_blank(),
        legend.title = element_blank(),
        axis.title.x = element_text(size = 32),
        axis.title.y = element_text(size =  32),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())

pdf(file.path(figures_path,'Figure_PIT_time.pdf'))
print(ppp)
dev.off()





# -------------------------------------------------------------------------------------------------
#                                          HEDONIC
# -------------------------------------------------------------------------------------------------

#--------------------------------------- PREPROC 
## remove sub 8 (we dont have scans)
HED <- subset (HED,!id == '8') 
HED$condition <- factor(HED$condition)
HED$trialxcondition <- factor(HED$trialxcondition)
HED$id<- factor(HED$id)

# code presentation within blocl
Trial <- as.numeric(HED$trialxcondition)
HED$rep <-Trial
for (i in 4:length(Trial)) {
  if(Trial[i-1]%%3 == 0) {HED$rep[i] = 1}
  else if (Trial[i-2]%%3 == 0) {HED$rep[i] = 2}
  else if (Trial[i-3]%%3 == 0) {HED$rep[i] = 3}
}

HED$rep <- factor(HED$rep)


# -------------------------------------- STATS -----------------------------------------------

#------------------------------ pleastness
HED.s <- subset (HED, condition == 'neutral'| condition == 'chocolate')

HED.means <- aggregate(HED.s$perceived_liking, by = list(HED.s$id, HED.s$condition), FUN='mean') # extract means
colnames(HED.means) <- c('id','condition','perceived_liking')

HED.trial <- aggregate(HED.s$perceived_liking, by = list(HED.s$id, HED.s$trialxcondition), FUN='mean') # extract means
colnames(HED.trial) <- c('id','trialxcondition','perceived_liking')

# stat
HED.stat     <- aov_car(perceived_liking ~ condition*trialxcondition + Error (id/condition*trialxcondition), data = HED.s, anova_table = list(correction = "GG", es = "pes"))
# effect sizes (90%CI)
F_to_eta2(f = c(1136.66,2.19,4.29), df = c(1,8.42,8.94), df_error = c(23,193.55,205.52))


# Bayes factors  ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

#condition
HED.BF.c <- anovaBF(perceived_liking ~ condition  + id, data = HED.means, 
                    whichRandom = "id", iterations = 50000)
HED.BF.c <- recompute(HED.BF.c, iterations = 50000)

#trial
HED.BF.trial <- anovaBF(perceived_liking ~ trialxcondition  + id, data = HED.trial, 
                        whichRandom = "id", iterations = 50000)
HED.BF.trial <- recompute(HED.BF.trial, iterations = 50000)

# interation
HED.BF <- anovaBF(perceived_liking ~ condition*trialxcondition  + id, data = HED.s, 
                  whichRandom = "id", iterations = 50000)
HED.BF <- recompute(HED.BF, iterations = 50000)
HED.BF[4]/HED.BF[3]

# Follow up analysis  ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨  ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

HED.chocolate <- subset (HED,  condition == 'chocolate')
HED.neutral <- subset (HED,  condition == 'neutral')

HED.means.choco <- aggregate(HED.chocolate$perceived_liking, by = list(HED.chocolate$id, HED.chocolate$rep), FUN='mean') # extract means
colnames(HED.means.choco) <- c('id','rep','perceived_liking')

HED.means.neutral <- aggregate(HED.neutral$perceived_liking, by = list(HED.neutral$id, HED.neutral$rep), FUN='mean') # extract means
colnames(HED.means.neutral) <- c('id','rep','perceived_liking')


HED.stat.choco.rep     <- aov_car(perceived_liking ~ rep + Error (id/rep), data = HED.means.choco, anova_table = list(correction = "GG", es = "pes"))
# effect sizes (90%CI)
F_to_eta2(f = c(17.95), df = c(1.70), df_error = c(39.04))
# BF
HED.BF.choco <- anovaBF(perceived_liking ~ rep  + id, data = HED.means.choco, 
                        whichRandom = "id", iterations = 50000)
HED.BF.choco <- recompute(HED.BF.choco, iterations = 50000)


HED.stat.neutral.rep   <- aov_car(perceived_liking ~ rep + Error (id/rep), data = HED.means.neutral, anova_table = list(correction = "GG", es = "pes"))
# effect sizes (90%CI)
F_to_eta2(f = c(1.43), df = c(1.34), df_error = c(30.93))
# BF
HED.BF.neutral <- anovaBF(perceived_liking ~ rep  + id, data = HED.means.neutral, 
                          whichRandom = "id", iterations = 50000)
HED.BF.neutral <- recompute(HED.BF.neutral, iterations = 50000)





#------------------------------ intensity
INT.s <- subset (HED, condition == 'neutral'| condition == 'chocolate')


# stat
INT.stat <- aov_car(perceived_intensity ~ condition*trialxcondition + Error (id/condition*trialxcondition), data = INT.s, anova_table = list(correction = "GG", es = "pes"))
INT.stat.rep <- aov_car(perceived_intensity ~ condition*rep + Error (id/condition*rep), data = INT.s, anova_table = list(correction = "GG", es = "pes"))


# effect sizes (90%CI)
F_to_eta2(f = c(15.87,9.25), df = c(1,7.90), df_error = c(23,181.80))

# Bayes factors
INT.BF <- anovaBF(perceived_intensity ~ condition*trialxcondition  + id, data = INT.s, 
                  whichRandom = "id", iterations = 50000)
INT.BF <- recompute(INT.BF, iterations = 50000)
INT.BF


# -------------------------------------- PLOTS -----------------------------------------------
HED.means$condition  <- dplyr::recode(HED.means$condition, "chocolate" = "pleasant")
HED.s$condition      <- dplyr::recode(HED.s$condition, "chocolate" = "pleasant")

# AVERAGED EFFECT
dfG <- summarySEwithin(HED.means,
                       measurevar = "perceived_liking",
                       withinvars = "condition", 
                       idvar = "id")

dfG$cond <- ifelse(dfG$condition == "pleasant", -0.25, 0.25)
HED.means$cond <- ifelse(HED.means$condition == "pleasant", -0.25, 0.25)
set.seed(666)
HED.means <- HED.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))


maxl = 95
minl = 0

pp <- ggplot(HED.means, aes(x = cond, y = perceived_liking, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = perceived_liking), alpha = .5, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA))+
  geom_point(aes(x = condjit), alpha = .3,) +
  geom_crossbar(data = dfG, aes(y = perceived_liking, ymin=perceived_liking-se, ymax=perceived_liking+se), width = 0.2 , alpha = 0.1)+
  ylab('Perceived liking') +
  xlab('Odorant') +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(-0.5,100.5)) +
  scale_x_continuous(labels=c("Pleasant", "Neutral"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("pleasant"= pal[3], "neutral"=pal[1]), guide = 'none') +
  scale_color_manual(values=c("pleasant"=pal[3], "neutral"=pal[1]), guide = 'none') +
  theme_bw()


ppp <- pp + averaged_theme


pdf(file.path(figures_path,'Figure_HEDONIC.pdf'))
print(ppp)
dev.off()


# OVERTIME
HED.p <- summarySEwithin(HED.s,
                         measurevar = "perceived_liking",
                         withinvars = c("trialxcondition","condition"),
                         idvar = "id")

df <- rbind(HED.p)
df$condition <- droplevels(df$condition)


# plot
pp <- ggplot(df, aes(x = as.numeric(trialxcondition), y = perceived_liking,
                     color =condition, fill = condition)) +
  geom_line(alpha = .7, size = 1, show.legend = F) +
  geom_ribbon(aes(ymax = perceived_liking + se, ymin = perceived_liking - se, fill = condition, color =NA),  alpha=0.4) + 
  geom_point() +
  ylab('Perceived liking')+
  xlab('Trial') +
  scale_color_manual(labels = c('pleasant', 'neutral'), 
                     values = c( "pleasant"=pal[3], 'neutral'=pal[1])) +
  scale_fill_manual(labels = c('pleasant', 'neutral'), 
                    values = c( "pleasant"=pal[3], 'neutral'=pal[1])) +
  scale_y_continuous(expand = c(0, 0),  limits = c(0,100),  breaks=c(seq.int(0,100, by = 20))) +
  labs(color='Odorant', fill= 'Odorant') +
  annotate("rect", xmin=0.8, xmax=3.5, ymin=minl, ymax=maxl, alpha=0.2, fill="gray") +
  annotate("rect", xmin=3.8, xmax=6.5, ymin=minl, ymax=maxl, alpha=0.2, fill="gray") +
  annotate("rect", xmin=6.8, xmax=9.5, ymin=minl, ymax=maxl, alpha=0.2, fill="gray") +
  annotate("rect", xmin=9.8, xmax=12.5, ymin=minl, ymax=maxl, alpha=0.2, fill="gray") +
  annotate("rect", xmin=12.8, xmax=15.5, ymin=minl, ymax=maxl, alpha=0.2, fill="gray") +
  annotate("rect", xmin=15.8, xmax=18.5, ymin=minl, ymax=maxl, alpha=0.2, fill="gray") +
  annotate("text", x = 10,  y =maxl+3, label="Hedonic Reactivity Test",fontface =2, size=7) +
  theme_bw()



ppp <- pp + averaged_theme

pdf(file.path(figures_path,'Figure_Hedonic_time.pdf'))
print(ppp)
dev.off()


