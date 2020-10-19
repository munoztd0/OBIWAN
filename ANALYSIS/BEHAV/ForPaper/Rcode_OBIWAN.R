##################################################################################################
# Created by E.R.P on NOVEMBER 2018                                                               
# modified by D.M.T. on AUGUST 2020                                                               
##################################################################################################


#--------------------------------------  PRELIMINARY STUFF ----------------------------------------
#load libraries

if(!require(pacman)) {
  install.packages("pacman")
  install.packages("devtools")
  library(pacman)
}

pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, 
               reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, 
               lsmeans, BayesFactor, effectsize, devtools, misty, bayestestR, lspline)


# get tool
devtools::source_gist("2a1bb0133ff568cbe28d", 
                      filename = "geom_flat_violin.R")

#SETUP

# Set path
home_path       <- '~/OBIWAN'

# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/BEHAV/ForPaper')
figures_path  <- file.path(home_path, 'DERIVATIVES/FIGURES/BEHAV') 
setwd(analysis_path)

#datasets dictory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 

# open datasets
PAV  <- read.delim(file.path(data_path,'OBIWAN_PAV.txt'), header = T, sep ='') # 
INST <- read.delim(file.path(data_path,'OBIWAN_INST.txt'), header = T, sep ='') # 
PIT  <- read.delim(file.path(data_path,'OBIWAN_PIT.txt'), header = T, sep ='') # 
HED  <- read.delim(file.path(data_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # 
info <- read.delim(file.path(data_path,'info_expe.txt'), header = T, sep ='') # 
intern <- read.delim(file.path(data_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # 

#subset only pretest
tables <- c("PAV","INST","PIT","HED", "intern")
dflist <- lapply(mget(tables),function(x)subset(x, session == 'second'))
list2env(dflist, envir=.GlobalEnv)

#exclude participants (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning)
`%notin%` <- Negate(`%in%`)
dflist <- lapply(mget(tables),function(x)filter(x, id %notin% c(242, 256, 114, 228)))
list2env(dflist, envir=.GlobalEnv)

#merge with info
tables = tables[-length(tables)] # remove intern
dflist <- lapply(mget(tables),function(x)merge(x, info, by = "id"))
list2env(dflist, envir=.GlobalEnv)

# creates internal states variables for each data
listA = 2:5
def = function(data, number){
  baseINTERN = subset(intern, phase == number)
  data = merge(x = get(data), y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
  diffINTERN = subset(intern, phase == number | phase == number+1) #before and after 
  before = subset(diffINTERN, phase == number); after = subset(diffINTERN, phase == number+1); diff = after
  diff$diff_piss = diff$piss - before$piss
  diff$diff_thirsty = diff$thirsty - before$thirsty
  diff$diff_hungry = diff$hungry - before$hungry
  data= merge(data, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)
  return(data)
}
dflist = mapply(def,tables,listA)
list2env(dflist, envir=.GlobalEnv)


# themes for plots
averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position=c(.9,.9),
        legend.title  = element_text(size = 12),
        legend.text  = element_text(size = 10),
        legend.key.size = unit(0.2, "cm"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
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



# Miscellaneous  ----------------------------------------------------------

options(contrasts = rep("contr.sum", 2)) #set options
set.seed(666) #set random seed

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/pes_ci.R', echo=F) #source PES function

# global functions
scale2 <- function(x, na.rm = TRUE) (x - mean(x, na.rm = na.rm)) / sd(x, na.rm)


# Check Demo
AGE = ddply(PAV,~group,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PAV,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PAV, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #2 = female

N_group = ddply(PAV, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

# -------------------------------------------------------------------------------------------------
#                                             PAVLOVIAN
# -------------------------------------------------------------------------------------------------

# define as.factors
fac <- c("id", "trial", "condition", "group" ,"trialxcondition", "gender")
PAV[fac] <- lapply(PAV[fac], factor)

#center covariates
numer <- c("piss", "thirsty", "hungry", "diff_piss", "diff_thirsty", "diff_hungry", "age")
PAV = PAV %>% group_by %>% mutate_at(numer, scale)

# -------------------------------------- PREPROCESSING RT ----------------------------------------


# get times in milliseconds 
PAV$RT               <- PAV$RT * 1000

#Preprocessing
PAV$condition <- droplevels(PAV$condition, exclude = "Baseline")
acc_bef = mean(PAV$ACC, na.rm = TRUE) #0.93
full = length(PAV$RT)

##shorter than 100ms and longer than 3sd+mean
PAV.clean <- filter(PAV, RT >= 100) # min RT is 
PAV.clean <- ddply(PAV.clean, .(id), transform, RTm = mean(RT))
PAV.clean <- ddply(PAV.clean, .(id), transform, RTsd = sd(RT))
PAV.clean <- filter(PAV.clean, RT <= RTm+3*RTsd) 

# calculate the dropped data in the preprocessing
clean = length(PAV.clean$RT)
dropped = full-clean
(dropped*100)/full

densityPlot(PAV.clean$RT) #not that skewed 

# #log transform function
# t_log_scale <- function(x){
#   if(x==0){y <- 1} 
#   else {y <- (sign(x)) * (log(abs(x)))}
#   y }
# 
# PAV.clean$RT_T <- sapply(PAV.clean$RT,FUN=t_log_scale)
# densityPlot(PAV.clean$RT_T) # much better !

# -------------------------------------- STATS -----------------------------------------------
PAV.means <- aggregate(PAV.clean$RT, by = list(PAV.clean$id, PAV.clean$condition, PAV.clean$liking, PAV.clean$group), FUN='mean') # extract means
colnames(PAV.means) <- c('id','condition','liking','group', 'RT')

# -------------------------------------- RT
# stat
anova.RT <- aov_car(RT ~ condition*group + Error (id/condition), data = PAV.means, anova_table = list(correction = "GG", es = "pes")); anova.RT
pes_RT = pes_ci(RT ~ condition*group + Error (id/condition), PAV.means); pes_RT

# Bayes factors
RT.BF <- anovaBF(RT ~ condition *group  + id, data = PAV.means, 
                 whichRandom = "id", iterations = 50000); RT.BF
#plot(RT.BF)

# -------------------------------------- Liking
# stat
anova.liking <- aov_car(liking ~ condition*group+ Error (id/condition), data = PAV.means, anova_table = list(correction = "GG", es = "pes")); anova.liking
pes_lik = pes_ci(liking ~ condition*group+ Error (id/condition), PAV.means); pes_lik


# Bayes factors
liking.BF <- anovaBF(liking ~ condition*group + id, data = PAV.means, 
                     whichRandom = "id", iterations = 50000); liking.BF
#plot(liking.BF)

# -------------------------------------- PLOT -----------------------------------------------
# rename factor levels for plot
PAV.means$condition  <- dplyr::recode(PAV.means$condition, "CSplus" = "CS+", "CSminus" = "CS-" )


# RT
dfR <- summarySEwithin(PAV.means,
                       measurevar = "RT",
                       withinvars = "condition", 
                       idvar = "id")

dfR$cond <- ifelse(dfL$condition == "CS+", -0.25, 0.25)

pp <- ggplot(PAV.means, aes(x = cond, y = RT, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = RT), alpha = .3, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA))+
  geom_point(aes(x = condjit, shape = group), alpha = .3,) +
  geom_crossbar(data = dfR, aes(y = RT, ymin=RT-se, ymax=RT+se), width = 0.2 , alpha = 0.1)+
  ylab('Reaction Times (ms)')+
  xlab('Conditioned stimulus')+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(200,700, by = 100)), limits = c(180,700.5)) +
  scale_x_continuous(labels=c("CS+", "CS-"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), guide = 'none') +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), guide = 'none') +
  scale_shape_manual(name="Group", labels=c("Lean", "Obese"), values = c(1, 2)) +
  theme_bw()


ppp <- pp + averaged_theme 
ppp

pdf(file.path(figures_path,'Figure_PavlovianRT.pdf'))
print(ppp)
dev.off()



dfL <- summarySEwithin(PAV.means,
                       measurevar = "liking",
                       withinvars = "condition", 
                       idvar = "id")

dfL$cond <- ifelse(dfL$condition == "CS+", -0.25, 0.25)
PAV.means$cond <- ifelse(PAV.means$condition == "CS+", -0.25, 0.25)
PAV.means <- PAV.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))

# Liking
pp <- ggplot(PAV.means, aes(x = cond, y = liking, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = liking), alpha = .3, size = 0.5, color = 'gray' ) +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA)) +
  geom_point(aes(x = condjit, shape = group), alpha = .3) +
  geom_crossbar(data = dfL, aes(y = liking, ymin=liking-se, ymax=liking+se), width = 0.2 , alpha = 0.1)+
  ylab('Liking Ratings')+
  xlab('Conditioned stimulus')+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 25)), limits = c(-0.5,100.5)) +
  scale_x_continuous(labels=c("CS+", "CS-"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), guide = 'none') +
  scale_color_manual(values=c("CS+"= pal[2], "CS-"=  pal[1]), guide = 'none') +
  scale_shape_manual(name="Group", labels=c("Lean", "Obese"), values = c(1, 2)) +
  theme_bw()


ppp <- pp + averaged_theme 
ppp

pdf(file.path(figures_path,'Figure_PavlovianLiking.pdf'))
print(ppp)
dev.off()

# -------------------------------------------------------------------------------------------------
#                                             INSTRUMENTAL
# -------------------------------------------------------------------------------------------------

fac <- c("id", "trial", "gender", "group")
INST[fac] <- lapply(INST[fac], factor)

# -------------------------------------- PREPROC  --------------------------------------------------


# CREATE BINS OF 6
INST$trial        <- as.numeric(INST$trial)
INST  <- ddply(INST, "id", transform, bin = as.numeric(cut2(trial, g = 6)))
INST$trial      <- factor(INST$trial)


# get the averaged dataset
INST.means <- aggregate(INST$grips, by = list(INST$id, INST$trial, INST$group), FUN='mean') # extract means
colnames(INST.means) <- c('id','trial','group', 'grips')



# -------------------------------------- STAT -----------------------------------------------------


# --------------------------------------- all trials

# stat -  linear 
anova.Ins.all <- aov_car(grips ~ trial*group + Error (id/trial), data = INST.means, anova_table = list(correction = "GG", es = "pes")); anova.Ins.all
pes_Ins.all = pes_ci(grips ~ trial*group + Error (id/trial), INST.means); pes_Ins.all


# Bayes factors
inst.BF.all <- anovaBF(grips ~ trial*group  + id, data = INST.means, 
                       whichRandom = "id", iterations = 50000); inst.BF.all 

# stat -  different fit
INST.means$trial = as.numeric(INST.means$trial)
## LINEAR FIT  
linmod <- lmer(grips~trial*group + (1 |id),data=INST.means, REML = FALSE)
## POLYNOMIAL FIT  
quadmod <- lmer(grips~trial*group+I(trial^2) + (1 |id), data=INST.means, REML = FALSE)
cubmod <- lmer(grips~trial*group+I(trial^2)+I(trial^3) + (1 |id),data=INST.means, REML = FALSE)
## PIECEWISE REGRESSION WITH SPLINES
splinemod <- lmer(grips ~ lspline(trial, 5) *group + (1 |id), data = INST.means, REML = FALSE)
bayesfactor_models(linmod, quadmod, cubmod, splinemod, denominator = linmod) #splinemod is the best fit
summary(splinemod)


# -------------------------------------- PLOT  ---------------------------------------------------------

#over time
dfTRIAL <- summarySEwithin(INST.means,
                           measurevar = "grips",
                           withinvars = "trial", 
                           idvar = "id")

dfTRIAL$trial       <- as.numeric(dfTRIAL$trial)

dfTRIALg <- summarySEwithin(INST.means,
                           measurevar = "grips",
                           withinvars = "trial", 
                           betweenvars = "group",
                           idvar = "id")

dfTRIALg$trial       <- as.numeric(dfTRIALg$trial)

dfTRIAL$x = dfTRIAL$trial; dfTRIAL$y = dfTRIAL$grips
splinelm <- lm(y ~ lspline(x, 5), data=dfTRIAL)


pp <- ggplot(dfTRIAL, aes(x =trial, y = grips)) +
  geom_point(data = dfTRIALg, aes(shape = group), alpha = 0.3, color = 'black') +
  geom_point(data = dfTRIAL, alpha = 0.5, color = pal[4], shape = 18) +
  geom_line(color = pal[4]) +
  #geom_smooth(method="lm", formula=formula(splinelm), color="tomato",fill = NA, size=0.7) +
  geom_ribbon(aes(ymin=grips-se, ymax=grips+se), fill = pal[4], alpha = 0.3)+
  ylab('Number of Grips')+
  xlab('Trial') +
  scale_y_continuous(expand = c(0, 0),  limits = c(10.5,14.05),  breaks=c(seq.int(11,14, by = 1))) +
  scale_x_continuous(expand = c(0, 0),  limits = c(0,25),  breaks=c(seq.int(0,25, by = 5))) +
  scale_shape_manual(name="Group", labels=c("Lean", "Obese"), values = c(1, 2, 18)) +
  theme_bw()

ppp <- pp + averaged_theme
ppp

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
  geom_line(aes(x = trialjit, group = id, y = n_grips), alpha = .3, size = 0.5, color = 'gray') +
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

# define as.factors
fac <- c("id", "trial", "condition", "trialxcondition", "gender", "group")
PIT[fac] <- lapply(PIT[fac], factor)

#center covariates
numer <- c("piss", "thirsty", "hungry", "diff_piss", "diff_thirsty", "diff_hungry", "age")
PIT = PIT %>% group_by %>% mutate_at(numer, scale)

# Center level-1 predictor within cluster (CWC)
PIT$AUC = center(PIT$AUC, type = "CWC", group = PIT$id)

PIT.all = PIT
#--------------------------------------- PREPROC  -----------------------------------------------------

#subset phases
RIM <- subset (PIT.all,task == 'Reminder') 
PE <- subset (PIT.all,task == 'Partial_Extinction') 
PIT <- subset (PIT.all,task == 'PIT') 

# create bin for each mini block
PIT$trialxcondition        <- as.numeric(PIT$trialxcondition)
PIT  <- ddply(PIT, "id", transform, bin = as.numeric(cut2(trialxcondition, g = 5)))

# Center level-1 predictor within cluster (CWC)
PIT$AUC = center(PIT$AUC, type = "CWC", group = PIT$id) 


# -------------------------------------- STATS -----------------------------------------------
PIT.s <- subset (PIT, condition == 'CSplus'| condition == 'CSminus')
PIT.s$trialxcondition <- factor(PIT.s$trialxcondition)
PIT.means <- aggregate(PIT.s$AUC, by = list(PIT.s$id, PIT.s$condition, PIT.s$group), FUN='mean') # extract means
colnames(PIT.means) <- c('id','condition', 'group', 'AUC')

PIT.trial <- aggregate(PIT.s$AUC, by = list(PIT.s$id, PIT.s$trialxcondition), FUN='mean') # extract means
colnames(PIT.trial) <- c('id','trialxcondition','AUC')


# stat
PIT.stat <- aov_car(AUC ~ condition*group + Error (id/condition), data = PIT.means, anova_table = list(correction = "GG", es = "pes")); PIT.stat
pes_PIT.stat = pes_ci(AUC ~ condition*group*trialxcondition + Error (id/condition*trialxcondition), PIT.s)

model = mixed(AUC ~ condition*group + hungry + hungry:condition + thirsty + piss  + (condition|id) + (1|trialxcondition), data = PIT, method = "LRT",  REML = FALSE)
model

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
                       measurevar = "AUC",
                       withinvars = "condition", 
                       idvar = "id")

dfG$cond <- ifelse(dfG$condition == "CS+", -0.25, 0.25)
PIT.means$cond <- ifelse(PIT.means$condition == "CS+", -0.25, 0.25)
set.seed(666)
PIT.means <- PIT.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))


pp <- ggplot(PIT.means, aes(x = cond, y = n_grips, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = n_grips), alpha = .3, size = 0.5, color = 'gray') +
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
  geom_line(alpha = .5, size = 1, show.legend = F) +
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
  geom_line(aes(x = condjit, group = id, y = perceived_liking), alpha = .3, size = 0.5, color = 'gray') +
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


#save RData for cluster computing
save.image(file = "OBIWAN.RData", version = NULL, ascii = FALSE,
           compress = FALSE, safe = TRUE)