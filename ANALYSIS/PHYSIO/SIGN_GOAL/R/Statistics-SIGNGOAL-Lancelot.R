## R Code for intermediary analysis
## Last modified by Eva on FEBRUARY 2020


# to do:
  # substituing the missing value with mean
  # try to think about other sign-tracking indexes (e.g., pupil dilation?)

#----------------------------------------------------------------------------------------------------
#                                      PRELIMINARY STUFF 
#----------------------------------------------------------------------------------------------------

# load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(car, lme4, lmerTest, pbkrtest, ggplot2, dplyr, plyr, tidyr, multcomp, mvoutlier, HH, doBy, psych, pastecs, reshape, reshape2, 
               jtools, effects, compute.es, DescTools, MBESS, afex, ez, metafor, influence.ME, longpower,pwr,sjstats,flexmix,GPArotation)

require(lattice)

# Set path
home_path    <- '/Users/lance/switchdrive/SIGNGOAL/ANALYSIS/R/' # this will need to be made non-specific at the end (source the)
home_path    <- '/Users/lance/switchdrive/SIGNGOAL/ANALYSIS/R/' # this will need to be made non-specific at the end (source the)

figures_path <- file.path(home_path,'figures')
utilities    <- file.path(home_path,'utilites')
setwd (home_path)

# source my utilites
source (file.path(utilities, 'SG_timeplot.R')) # source all functions

# open dataset
SIGNGOAL      <- read.delim(file.path(home_path,'Database-SIGNGOAL.txt'), header = T, sep ='') # read in dataset
QUESTIONNAIRE <- read.delim(file.path(home_path,'Questionnaires-SIGNGOAL-imputed.txt'), header = T, sep ='') # read in dataset

SIGNGOAL$ID             <- factor(SIGNGOAL$ID)
SIGNGOAL$trial          <- factor(SIGNGOAL$trial)
SIGNGOAL$item_condition <- factor(SIGNGOAL$item_condition)        
SIGNGOAL$run            <- factor(SIGNGOAL$run)
SIGNGOAL$bin            <- factor(SIGNGOAL$bin)
SIGNGOAL$congr          <- factor(SIGNGOAL$congr)
SIGNGOAL$CS             <- factor(SIGNGOAL$CS)


# simple value contrast
SIGNGOAL$CS.value[SIGNGOAL$CS== 'CSpL'] <- .5
SIGNGOAL$CS.value[SIGNGOAL$CS== 'CSpR'] <- .5
SIGNGOAL$CS.value[SIGNGOAL$CS== 'CSmi'] <- -1

# sensory left CS+
SIGNGOAL$CSp.left[SIGNGOAL$CS== 'CSmi']   <- -.5
SIGNGOAL$CSp.left[SIGNGOAL$CS== 'CSpR']   <- -.5
SIGNGOAL$CSp.left[SIGNGOAL$CS== 'CSpL']   <- 1

# sensory right CS+
SIGNGOAL$CSp.right[SIGNGOAL$CS== 'CSmi']   <- -.5
SIGNGOAL$CSp.right[SIGNGOAL$CS== 'CSpR']   <- 1
SIGNGOAL$CSp.right[SIGNGOAL$CS== 'CSpL']   <- -.5


# join
ALL = join(QUESTIONNAIRE, SIGNGOAL, type = 'full')

# remove participants that have missing data
ALL = subset(ALL, !ID == "sub-15" & !ID == "sub-62" & !ID == "sub-73" & !ID == "sub-79" & !ID == "sub-40") 

QUESTIONNAIRE = subset(QUESTIONNAIRE, !ID == "sub-15" & !ID == "sub-62" & !ID == "sub-73" & !ID == "sub-79" & !ID == "sub-40") 

# ----------------------------------------------------------------------------------------------------
#                                 DESCRIPTIVE ANALYSIS
# ----------------------------------------------------------------------------------------------------

# --------------------------------- MEAN AND SD ---------------------------------------------------------------

# count participants
count(ALL, c("ID"))

# average and std dev of age
# proportion of male female
# average and std dev of snack liking and hunger
# average and std dev of the questionnaires subscales

# stress and anxiety (it would be good to compare to normative data when these are available)
aggregate(STAI_T_total~ 1, data = QUESTIONNAIRE, mean)
aggregate(STAI_T_total~ 1, data = QUESTIONNAIRE, sd)

aggregate(PSS_total~ 1, data = QUESTIONNAIRE, mean)
aggregate(PSS_total~ 1, data = QUESTIONNAIRE, sd)

# impulsivity and complusivity # lancelot can you add the subscales ?
aggregate(BIS_total~ 1, data = QUESTIONNAIRE, mean)
aggregate(BIS_total~ 1, data = QUESTIONNAIRE, sd)

aggregate(BISBAS_total~ 1, data = QUESTIONNAIRE, mean)
aggregate(BISBAS_total~ 1, data = QUESTIONNAIRE, sd)

aggregate(OCIR_total~ 1, data = QUESTIONNAIRE, mean)
aggregate(OCIR_total ~ 1, data = QUESTIONNAIRE, sd)

# addiction
aggregate(CAST_total~ 1, data = QUESTIONNAIRE, mean)
aggregate(CAST_total~ 1, data = QUESTIONNAIRE, sd)

aggregate(AUDIT_total~ 1, data = QUESTIONNAIRE, mean)
aggregate(AUDIT_total~ 1, data = QUESTIONNAIRE, sd)

aggregate(CDS_12_total ~ 1, data = QUESTIONNAIRE, mean)
aggregate(CDS_12_total ~ 1, data = QUESTIONNAIRE, sd)

# --------------------------------- PLOT ---------------------------------------------------------------
# let's plot all the distributions of the questionnaires to visualize the data and the potential problems

# let's put together the database with only the variables of interest
db             <- data.frame(QUESTIONNAIRE$STAI_T_total)
db$PSS         <- QUESTIONNAIRE$PSS_total
db$BIS         <- QUESTIONNAIRE$BIS_total
db$BISBAS      <- QUESTIONNAIRE$BISBAS_total
db$OCIR        <- QUESTIONNAIRE$OCIR_total
db$CAST        <- QUESTIONNAIRE$CAST_total
db$AUDIT       <- QUESTIONNAIRE$AUDIT_total
db$CDS_12      <- QUESTIONNAIRE$CDS_12_total

# now we need to have that in a long format because it's easy for the plots
db_long <- gather(db,questionnaire,score, QUESTIONNAIRE.STAI_T_total:CDS_12, factor_key=TRUE)

# let's plot the data
pp = ggplot(data = db_long, aes (x=questionnaire, y = score, fill = questionnaire)) +
  facet_wrap(~questionnaire, scales = "free" ) +
  geom_point(aes(color = questionnaire),position = position_jitterdodge(jitter.width = .2, jitter.height = 0))+
  geom_violin(aes(color = questionnaire, fill = questionnaire),alpha = .3, size = .5)+ 
  theme_bw()+
  labs(
    title = '',
    x = 'Questionnaires',
    y = "Scores"
  ) 
# let's make the plot nice looking
ppp <-  pp + theme_linedraw(base_size = 10, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 10, face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x  = element_blank(),
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"))  

# let's print the plot in a pdf document
pdf(file.path(figures_path,'Questionnaires_distribution.pdf'))
print(ppp)
dev.off()


# correlations between the questionnaires
db = na.omit(db)
cor.plot(db, number = T, pval= T)

scatterplot.matrix(~QUESTIONNAIRE.STAI_T_total+PSS+OCIR+BIS+BISBAS+CAST+CDS_12+AUDIT,data=db,
      main="Simple Scatterplot Matrix")



# ----------------------------------------------------------------------------------------------------
#                                 MANIPULATION CHECK
# ----------------------------------------------------------------------------------------------------

#MC.mean

# select only variable of interest (pupil, dw lwft ant, dw right ant, dw left cs, dw right cs, STAI, RT ,liking )

# example to see how to select the varibale of interest (not on the right database)
QUESTLEARN_t <- QUESTIONNAIRE[,c("ID","BIS_total","BISBAS_total","OCIR_total","PSS_total","STAI_T_total", "CAST_total","AUDIT_total","CDS_12_total")]



PUPIL.mean <- aggregate(SIGNGOAL$CS_pupil, by= list (SIGNGOAL$ID, SIGNGOAL$CS.value, SIGNGOAL$run), FUN='mean')
colnames(PUPIL.mean) <- c('ID','CS.value','run','CS_pupil')
# add the anxiety value
PUPIL_Q.mean <- join (PUPIL.mean,QUESTIONNAIRE)


car.aov  <- aov_car(CS_pupil ~ CS.value*run+ Error(ID/CS.value*run), data = PUPIL.mean, factorize = F, anova_table = list(es = "pes"))
car.aov  <- aov_car(CS_pupil ~ CS.value*run*STAI_T_total+ Error(ID/CS.value*run), data = PUPIL_Q.mean, factorize = F, anova_table = list(es = "pes"))

#DW left ant: 
DWLeftAnt.mean <- aggregate(SIGNGOAL$ANT_DW_L, by= list (SIGNGOAL$ID, SIGNGOAL$CS.value, SIGNGOAL$run), FUN='mean')
colnames(DWLeftAnt.mean) <- c('ID','CS.value','run','ANT_DW_L')

DWLant.aov <- aov_car(ANT_DW_L ~ CS.value*run+ Error(ID/CS.value*run), data = DWLeftAnt.mean, factorize = F, anova_table = list(es = "pes"))

#DW right ant: 
DWRightAnt.mean <- aggregate(SIGNGOAL$ANT_DW_R, by= list (SIGNGOAL$ID, SIGNGOAL$CS.value, SIGNGOAL$run), FUN='mean')
colnames(DWRightAnt.mean) <- c('ID','CS.value','run','ANT_DW_R')

DWRant.aov <- aov_car(ANT_DW_R ~ CS.value*run+ Error(ID/CS.value*run), data = DWRightAnt.mean, factorize = F, anova_table = list(es = "pes"))


#DW left: 
DWLeft.mean <- aggregate(SIGNGOAL$CS_DW_L, by= list (SIGNGOAL$ID, SIGNGOAL$CS.value, SIGNGOAL$run), FUN='mean')
colnames(DWLeft.mean) <- c('ID','CS.value','run','CS_DW_L')

DWL.aov <- aov_car(CS_DW_L ~ CS.value*run+ Error(ID/CS.value*run), data = DWLeft.mean, factorize = F, anova_table = list(es = "pes"))

#DW Right: 
DWRight.mean <- aggregate(SIGNGOAL$CS_DW_R, by= list (SIGNGOAL$ID, SIGNGOAL$CS.value, SIGNGOAL$run), FUN='mean')
colnames(DWRight.mean) <- c('ID','CS.value','run','CS_DW_R')

DWR.aov <- aov_car(CS_DW_R ~ CS.value*run+ Error(ID/CS.value*run), data = DWRight.mean, factorize = F, anova_table = list(es = "pes"))

#liking: 
liking.mean <- aggregate(SIGNGOAL$CS_liking, by= list (SIGNGOAL$ID, SIGNGOAL$CS.value, SIGNGOAL$run), FUN='mean')
colnames(liking.mean) <- c('ID','CS.value','run','CS_liking')

liking.aov <- aov_car(CS_liking ~ CS.value*run+ Error(ID/CS.value*run), data = liking.mean, factorize = F, anova_table = list(es = "pes"))

#Reaction time: 
RT.mean <- aggregate(SIGNGOAL$US_RT, by= list (SIGNGOAL$ID, SIGNGOAL$CS.value, SIGNGOAL$run), FUN='mean')
colnames(RT.mean) <- c('ID','CS.value','run','US_RT')

RT.aov <- aov_car(US_RT ~ CS.value*run+ Error(ID/CS.value*run), data = RT.mean, factorize = F, anova_table = list(es = "pes"))

#STAI: 
STAI.mean <- aggregate(QUESTIONNAIRE$STAI_T_total, by= list (SIGNGOAL$ID, SIGNGOAL$CS.value, SIGNGOAL$run), FUN='mean')
colnames(STAI.mean) <- c('ID','CS.value','run','STAI_T_total')

STAI.aov <- aov_car(STAI_t_total ~ CS.value*run+ Error(ID/CS.value*run), data = STAI.mean, factorize = F, anova_table = list(es = "pes"))
#

# control parameters to use in all models
control_params = lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000))
learn.pupil = lmer(CS_pupil~ CS.value*run+(CS.value*run|ID), data = SIGNGOAL, REML=FALSE, control = control_params)
anova(learn.pupil)



#------------------------ Pupil dilation during the CS -----------------------------------
learn.pupil = lmer(CS_pupil~ CS.value+(CS.value|ID), data = SIGNGOAL, REML=FALSE, control = control_params)
anova(learn.pupil)
fit <- (aov(CS_pupil ~ CS.value + Error(ID/CS.value),data= SIGNGOAL))
anova_stats(fit$`ID:CS.value`)

# ok it might be because of learning and beh
learn.pupil = lmer(CS_pupil ~ CS.value*run*STAI_T_total+(CS.value*run|ID), data = ALL, REML=FALSE,control = control_params)
anova(learn.pupil)

# let's check run by run
learn1.pupil = lmer(CS_pupil ~ CS.value*STAI_T_total+(CS.value|ID), data = subset(ALL, run == 1), REML=FALSE,control = control_params)
anova(learn1.pupil)

fit <- (aov(CS_pupil ~ CS.value*STAI_T_total + Error(ID/CS.value), data = subset(ALL, run == 1)))
anova_stats(fit$`ID:CS.value`)

learn2.pupil = lmer(CS_pupil ~ CS.value*STAI_T_total+(CS.value|ID), data = subset(ALL, run == 2), REML=FALSE,control = control_params)
anova(learn2.pupil)

fit <- (aov(CS_pupil ~ CS.value*STAI_T_total + Error(ID/CS.value), data = subset(ALL, run == 2)))
anova_stats(fit$`ID:CS.value`)

learn3.pupil = lmer(CS_pupil ~ CS.value*STAI_T_total+(CS.value|ID), data = subset(ALL, run == 3), REML=FALSE,control = control_params)
anova(learn3.pupil)

fit <- (aov(CS_pupil ~ CS.value*STAI_T_total + Error(ID/CS.value), data = subset(ALL, run == 3)))
anova_stats(fit$`ID:CS.value`)

#------------------------ Dwell time during the CS -----------------------------------------

# dwell time in the left ROI CS+
learn.dwleft = lmer(CS_DW_L ~ CSp.left + (CSp.left|ID), data = SIGNGOAL, REML=FALSE)
anova(learn.dwleft)

fit <- (aov(CS_DW_L ~ CSp.left + Error(ID/CSp.left), data= SIGNGOAL))
anova_stats(fit$`ID:CSp.left`)

# dwell time in the right ROI CS+
learn.dwright = lmer(CS_DW_R ~ CSp.right + (CSp.right|ID), data = SIGNGOAL, REML=FALSE)
anova(learn.dwright)

fit <- (aov(CS_DW_R ~ CSp.right + Error(ID/CSp.right), data= SIGNGOAL))
anova_stats(fit$`ID:CSp.right`)


#------------------------ Dwell time during the ANTICIPATION -----------------------------------------

# dwell time in the left ROI CS+
learn.dwleft = lmer(ANT_DW_L ~ CSp.left + (CSp.left|ID), data = SIGNGOAL, REML=FALSE)
anova(learn.dwleft)

fit <- (aov(ANT_DW_L ~ CSp.left + Error(ID/CSp.left), data= SIGNGOAL))
anova_stats(fit$`ID:CSp.left`)

# dwell time in the right ROI CS+
learn.dwright = lmer(ANT_DW_R ~ CSp.right + (CSp.right|ID), data = SIGNGOAL, REML=FALSE)
anova(learn.dwright)

fit <- (aov(ANT_DW_R ~ CSp.right + Error(ID/CSp.right), data= SIGNGOAL))
anova_stats(fit$`ID:CSp.right`)



#------------------------ Reaction time to detect the US -----------------------------------
learn.RT = lmer(US_RT ~ congr + (congr|ID), data = SIGNGOAL, REML=FALSE)
anova(learn.RT)

fit <- (aov(US_RT ~ congr + Error(ID/congr),data= SIGNGOAL))
anova_stats(fit$`ID:congr`)


#------------------------ CS liking ratings at the end of the run -----------------------------------
learn.liking = lmer(CS_liking ~ CS.value+ (CS.value|ID) + (CS.value|run), data = SIGNGOAL, REML=FALSE )
anova(learn.liking)

fit <- (aov(CS_liking ~ CS.value + Error(ID/CS.value),data= SIGNGOAL))
anova_stats(fit$`ID:CS.value`)



# ----------------------------------------------------------------------------------------------------
#                                 INTER-INDIVIDUAL DIFFERENCES 
# ----------------------------------------------------------------------------------------------------


#---------------------- Create groups based on differences during the CS -----------------------------

# first we create the index
CSplus <- subset (SIGNGOAL, CS == 'CSpR' | CS == 'CSpL') # create the index for that we don not want the CS-
CSplus <- ddply(CSplus, .(ID), transform, index_CS = (mean(CS_DW_cue, na.rm = T) - mean (CS_DW_congr, na.rm = T)) / (mean(CS_DW_cue,  na.rm = T) + mean(CS_DW_congr, na.rm = T)))
CSplus.mean <- ddply(CSplus, .(ID), summarise, index_CS = mean(index_CS, na.rm = T)) 

# then we classify participants based on the index

# what is the number of clusters that better explains the data
n_clusters <- stepFlexmix(index_CS ~ 1, data = CSplus.mean, control = list(verbose = 0), k = 1:5, nrep = 5)
getModel(n_clusters, "BIC")

# the we do the analysis specifying the number of cluster we found with step flex
mixlm <- flexmix(index_CS ~ 1, data = CSplus.mean, k = 2)
print(table(clusters(mixlm)))
CSplus.mean$flx_CS_cluster = factor(clusters(mixlm)) # create a variable based on the clustering


# ------------------------ PLOT
pp <- ggplot(CSplus.mean, aes(index_CS, fill = flx_CS_cluster)) +
  geom_histogram(aes(y=..density..),alpha=0.5,binwidth=0.05)+
  geom_density(alpha = 0.3)+
  theme_bw()+
  labs(
    title = '',
    x = "Dwell Time[cue - goal / cue + goal]",
    y = "Density"
  )

ppp <- pp + theme_linedraw(base_size = 18, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 14, face = "bold"),
        plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        legend.position="none",
        axis.title.y = element_text(size = 24)) 

pdf(file.path(figures_path,'Figure_clusters_CS.pdf'))
print(ppp)
dev.off()

#---------------------- Create groups based on differences during the ANT -----------------------------

CSplus <- subset (SIGNGOAL, CS == 'CSpR' | CS == 'CSpL') # create the index for that we don not want the CS-
ANTplus <- ddply(CSplus, .(ID), transform, index_ANT = (mean(ANT_DW_cue, na.rm = T) - mean (ANT_DW_congr, na.rm = T)) / (mean(ANT_DW_cue,  na.rm = T) + mean(ANT_DW_congr, na.rm = T)))
ANTplus.mean <- ddply(ANTplus, .(ID), summarise, index_ANT = mean(index_ANT, na.rm = T))

# then we need to see what is the number of clusters that better explains the data
n_clusters <- stepFlexmix(index_ANT ~ 1, data = ANTplus.mean, control = list(verbose = 0), k = 1:5, nrep = 5)
getModel(n_clusters, "BIC")

# the we do the analysis specifying the number of cluster we found with step flex
mixlm <- flexmix(index_ANT ~ 1, data = ANTplus.mean, k = 2)
print(table(clusters(mixlm)))
ANTplus.mean$flx_ANT_cluster = factor(clusters(mixlm)) # create a variable based on the clustering

pp <- ggplot(ANTplus.mean, aes(index_ANT, fill = flx_ANT_cluster)) +
  geom_histogram(aes(y=..density..),alpha=0.5,binwidth=0.05)+
  geom_density(alpha = 0.3)+
  theme_bw()+
  labs(
    title = '',
    x = "Dwell Time[cue - goal / cue + goal]",
    y = "Density"
    )

ppp <- pp + theme_linedraw(base_size = 18, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 14, face = "bold"),
        plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        legend.position="none",
        axis.title.y = element_text(size = 24)) 

pdf(file.path(figures_path,'Figure_clusters_ANT.pdf'))
print(ppp)
dev.off()





# ----------------------------------------------------------------------------------------------------
#                                 Look at differences during pavlovian learning 
# ----------------------------------------------------------------------------------------------------

TIME1   = join(CSplus.mean, SIGNGOAL, type = 'right')
TIME    = join(TIME1, ANTplus.mean, type = 'right')

# ------------------------------ Differences in the gaze behavior -------------------------

# CSp - CSm on the CS
TIME    <- ddply(TIME, .(ID,bin), transform, delta_CS_cue = mean(CS_DW_cue[CS == "CSpL" | CS == "CSpR"], na.rm = T) - mean(CS_DW_cue[CS == "CSmi"],na.rm = T)) # for the cue
TIME    <- ddply(TIME, .(ID,bin), transform, delta_CS_goal = mean(CS_DW_congr[CS == "CSpL" | CS == "CSpR"], na.rm = T) - mean(CS_DW_congr[CS == "CSmi"],na.rm = T)) # for the goal

# CSp only on the CS
TIME <- ddply(TIME, .(ID,bin), transform, CSp_cue = mean(CS_DW_cue[CS == "CSpL" | CS == "CSpR"], na.rm = T) ) # for the cue
TIME <- ddply(TIME, .(ID,bin), transform, CSp_goal = mean(CS_DW_congr[CS == "CSpL" | CS == "CSpR"], na.rm = T)) # for the goal

DW_CS.mean <- ddply(TIME, .(ID), summarise, DW_CS_index = mean(CSp_goal, na.rm = T)) # this will be used for the correlations later on


# CSp - CSm on the ANT
TIME    <- ddply(TIME, .(ID,bin), transform, delta_ANT_cue = mean(ANT_DW_cue[CS == "CSpL" | CS == "CSpR"], na.rm = T) - mean(ANT_DW_cue[CS == "CSmi"],na.rm = T)) # for the cue
TIME    <- ddply(TIME, .(ID,bin), transform, delta_ANT_goal = mean(ANT_DW_congr[CS == "CSpL" | CS == "CSpR"], na.rm = T) - mean(ANT_DW_congr[CS == "CSmi"],na.rm = T)) # for the goal

# CSp only on the ANT
TIME <- ddply(TIME, .(ID,bin), transform, ANTp_cue = mean(ANT_DW_cue[CS == "CSpL" | CS == "CSpR"], na.rm = T) ) # for the cue
TIME <- ddply(TIME, .(ID,bin), transform, ANTp_goal = mean(ANT_DW_congr[CS == "CSpL" | CS == "CSpR"], na.rm = T)) # for the goal

DW_ANT.mean <- ddply(TIME, .(ID), summarise, DW_ANT_index = mean(ANTp_goal, na.rm = T)) # this will be used for the correlations later on


# ---- plot cue
SG_timeplot(TIME, CSp_cue, flx_CS_cluster, bin, "dwell in the cue location during CS", "by CS cluster")
SG_timeplot(TIME, delta_CS_cue, flx_CS_cluster, bin, "dwell in the cue location during CS [CS- corrected]", "by CS cluster")  

SG_timeplot(TIME, ANTp_cue, flx_ANT_cluster, bin, "dwell in the cue location during ANT", "by ANT cluster")
SG_timeplot(TIME, delta_ANT_cue, flx_ANT_cluster, bin, "dwell in the cue location during ANT [CS- corrected]", "by ANT cluster")  

# ---- plot goal
SG_timeplot(TIME, CSp_goal, flx_CS_cluster, bin, "dwell in the goal location during CS", "by CS cluster")
SG_timeplot(TIME, delta_CS_goal, flx_CS_cluster, bin, "dwell in the goal location during CS [CS- corrected]", "by CS cluster")  

SG_timeplot(TIME, ANTp_goal, flx_ANT_cluster, bin, "dwell in the goal location during ANT", "by ANT cluster")
SG_timeplot(TIME, delta_ANT_goal, flx_ANT_cluster, bin, "dwell in the goal location during ANT [CS- corrected]", "by ANT cluster")  



# ------------------------------ Differences in the pupil behavior -------------------------

# CSp - CSm on the CS
TIME    <- ddply(TIME, .(ID,bin), transform, delta_pupil_index = mean(CS_pupil[CS == "CSpL" | CS == "CSpR"], na.rm = T) - mean(CS_pupil[CS == "CSmi"],na.rm = T)) # for the cue
TIME    <- ddply(TIME, .(ID,bin), transform, pupil_index = mean(CS_pupil[CS == "CSpL" | CS == "CSpR"], na.rm = T)) # for the cue
PUPIL.mean <- ddply(TIME, .(ID), summarise, delta_pupil_index = mean(delta_pupil_index, na.rm = T)) # this will be used for the correlations later on


# ---- plot CS
SG_timeplot(TIME, pupil_index, flx_CS_cluster, bin, "pupil during CS", "by CS cluster")
SG_timeplot(TIME, pupil_index, flx_ANT_cluster, bin, "pupil during CS", "by ANT cluster")

# ---- plot CS CS- corrected
SG_timeplot(TIME, delta_pupil_index, flx_CS_cluster, bin, "pupil during CS (CS-corrected)", "by CS cluster")
SG_timeplot(TIME, delta_pupil_index, flx_ANT_cluster, bin, "pupil during CS (CS-corrected)", "by ANT cluster")


# ------------------------------ Differences in RT -------------------------

# US_RT incongr - incongr
TIME    <- ddply(TIME, .(ID,bin), transform, US_RT_index = mean(US_RT[congr == "incongr" ], na.rm = T) - mean(US_RT[congr == "congr"],na.rm = T)) # for the cue
RT.mean <- ddply(TIME, .(ID), summarise, US_RT_index = mean(US_RT_index, na.rm = T)) # this will be used for the correlations later on

# ---- plot CS
SG_timeplot(TIME, US_RT_index, flx_CS_cluster, bin, "Reaction time on the US", "by CS cluster")
SG_timeplot(TIME, US_RT_index, flx_ANT_cluster, bin, "Reaction time on the US", "by ANT cluster")


# ------------------------------ Differences in CS liking -------------------------

TIME    <- ddply(TIME, .(ID,bin), transform, delta_liking_index = mean(CS_liking[CS == "CSpL" | CS == "CSpR"], na.rm = T) - mean(CS_liking[CS == "CSmi"],na.rm = T)) # for the cue
TIME    <- ddply(TIME, .(ID,bin), transform, liking_index = mean(CS_liking[CS == "CSpL" | CS == "CSpR"], na.rm = T)) # for the cue
LIKING.mean <- ddply(TIME, .(ID), summarise, delta_liking_index = mean(delta_liking_index, na.rm = T)) # this will be used for the correlations later on


# ---- plot CS
SG_timeplot(TIME, liking_index, flx_CS_cluster, run, "CS liking", "by CS cluster")
SG_timeplot(TIME, liking_index, flx_ANT_cluster, run, "CS liking", "by ANT cluster")

# ---- plot CS CS- corrected - 
SG_timeplot(TIME, delta_liking_index, flx_CS_cluster, run, "CS liking (CS-corrected)", "by CS cluster")
SG_timeplot(TIME, delta_liking_index, flx_ANT_cluster, run, "CS liking (CS-corrected)", "by ANT cluster") # this is sign and interesting






# ----------------------------------------------------------------------------------------------------
#                         CORRELATION PAVLEARNING-QUESTIONNARIES (WITHOUT ACP)
# ----------------------------------------------------------------------------------------------------

# create database with the subscales of questionnaires and the indexes of learning

QUESTLEARN_t <- QUESTIONNAIRE[,c("ID","BIS_total","BISBAS_total","OCIR_total","PSS_total","STAI_T_total",
                               "CAST_total","AUDIT_total","CDS_12_total")]

QUESTLEARN_s <- QUESTIONNAIRE[,c("ID","BIS_motor","BIS_attentional","BIS_nonplanning",
                                 "BIS","BAS_drive","BAS_Fun_seeking","BAS_reward_responsivness",
                                 "OCIR_total","STAI_T_total","CAST_total","AUDIT_total","CDS_12_total")]

# create a database for all the pav learning indexes
t1 <- join (CSplus.mean, ANTplus.mean)
t2 <- join (t1, PUPIL.mean)
t3 <- join (t2, LIKING.mean)
t4 <- join (t3, DW_ANT.mean)
t5 <- join (t4, DW_CS.mean)
PAVINDEX <- join (t5, RT.mean)

# join questionnaires database and learning indexes
QUESTLEARN_t <- join(QUESTLEARN_t,PAVINDEX)
QUESTLEARN_s <- join(QUESTLEARN_s,PAVINDEX)

#------------------------------------------  run the correlations ------------------------------------------
cor.plot(na.omit(subset(QUESTLEARN_t, select = -c(ID, flx_ANT_cluster, flx_CS_cluster ))),number = T, pval= T)
cor(na.omit(subset(QUESTLEARN_t, select = -c(ID, flx_ANT_cluster, flx_CS_cluster ))))

cor.plot(na.omit(subset(QUESTLEARN_s, select = -c(ID, flx_ANT_cluster, flx_CS_cluster ))),number = T, pval= T)
cor(na.omit(subset(QUESTLEARN_s, select = -c(ID, flx_ANT_cluster, flx_CS_cluster ))))

# just plot the intersting ones

# pupil and anxiety [lose sign when we use all data]
scatterplot(QUESTLEARN_t$STAI_T_total, QUESTLEARN_t$delta_pupil_index)
cor.test(QUESTLEARN_t$STAI_T_total, QUESTLEARN_t$delta_pupil_index)

# sign tracking and OCD [solid]
scatterplot(QUESTLEARN_t$OCIR_total, QUESTLEARN_t$index_ANT)
cor.test(QUESTLEARN_t$OCIR_total, QUESTLEARN_t$index_ANT)

scatterplot(QUESTLEARN_t$OCIR_total, QUESTLEARN_t$DW_ANT_index)
cor.test(QUESTLEARN_t$OCIR_total, QUESTLEARN_t$DW_ANT_index)

# goal tracking and AUDIT [distribution problem]
scatterplot(QUESTLEARN_t$AUDIT_total, QUESTLEARN_t$index_ANT)
cor.test(QUESTLEARN_t$AUDIT_total, QUESTLEARN_t$index_ANT, method = "kendall")

scatterplot(QUESTLEARN_t$AUDIT_total, QUESTLEARN_t$DW_ANT_index)
cor.test(QUESTLEARN_t$AUDIT_total, QUESTLEARN_t$DW_ANT_index, method = "kendall")

# goal tracking and CDS_12 & dwell in the congruent location [distribution problem]
scatterplot(QUESTLEARN_t$CDS_12_total, QUESTLEARN_t$DW_CS_index)
cor.test(QUESTLEARN_t$CDS_12_total, QUESTLEARN_t$DW_CS_index)

# goal tracking and BIS [distribution problem]
scatterplot(QUESTLEARN_t$BIS_total, QUESTLEARN_t$DW_CS_index)
cor.test(QUESTLEARN_t$BIS_total, QUESTLEARN_t$DW_CS_index)


# ----------------------------------------------------------------------------------------------------
#                                 ACP ANALYSIS ON THE QUESTIONNARIES 
# ----------------------------------------------------------------------------------------------------

# here we have too many items and too little participants. Actually that is not a problem for PCA

# we need the a dabase with the individual items only 

ITEMS <- na.omit(subset(QUESTIONNAIRE, select = -c(BIS_motor,BIS_attentional,BIS_nonplanning, BIS_total,
                                         BAS_drive, BAS_Fun_seeking,BAS_reward_responsivness,BIS, BISBAS_total,
                                         OCIR_total, STAI_T_total,PSS_total, CAST_total, AUDIT_total, CDS_12_total, ID)))



cor.plot(ITEMS,numbers=TRUE,main="correlation matrix")


# apply PCA
options(max.print=100000)
describe (ITEMS)
ITEMS <- subset(ITEMS, select = -c(CAST4, CAST5 ))# we need to remove CAST5  and CAST4  since there is no variance


# determine the number of factors
fa.parallel(ITEMS,fa="pc") 

# apply PCA with varimax rotation
quest.1.pca <- psych::principal(ITEMS, rotate="none", nfactors=8, scores=TRUE) # "none", "varimax" (Default), "quatimax", "promax", "oblimin", "simplimax", and "cluster"
print(quest.1.pca$loadings,cutoff = 0.4)




































                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    