##################################################################################################
# Created  by D.M.T. on AUGUST 2020                                                             
##################################################################################################
#                                      PRELIMINARY STUFF ----------------------------------------

#load libraries

if(!require(pacman)) {
  install.packages("pacman")
  install.packages("devtools")
  library(pacman)
}

pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, 
               reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, parallel,
               lsmeans, BayesFactor, effectsize, devtools, misty, bayestestR, lspline)


# get tool
devtools::source_gist("2a1bb0133ff568cbe28d", 
                      filename = "geom_flat_violin.R")

# -------------------------------------------------------------------------
# *************************************** SETUP **************************************
# -------------------------------------------------------------------------




# Set path
home_path       <- '~/OBIWAN'

# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/BEHAV/ForPaper')
figures_path  <- file.path(home_path, 'DERIVATIVES/FIGURES/BEHAV/T0') 
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

#exclude participants (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123 and 124 have imcomplete data
`%notin%` <- Negate(`%in%`)
dflist <- lapply(mget(tables),function(x)filter(x, id %notin% c(242, 256, 114, 228, 123, 124)))
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


# -------------------------------------- themes for plots --------------------------------------------------------

averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position=c(.9,.9),
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


pal = viridis::inferno(n=5) # specialy conceived for colorblindness
pal[6] = "#21908CFF" # add one


# -------------------------------------- Miscellaneous  ----------------------------------------------------------

options(contrasts=c("contr.sum","contr.poly")) #set contrasts to sum !
set.seed(666) #set random seed
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb')) #set "better" lmer optimizer #nolimit # yoloptimizer
emm_options(pbkrtest.limit = 5000) #increase repetitions limit
options(mc.cores = parallel::detectCores()); cl <- parallel::detectCores() #to mulithread
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/pes_ci.R', echo=F) #useful PES function from Yoann
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

scale2 <- function(x, na.rm = TRUE) (x - mean(x, na.rm = na.rm)) / sd(x, na.rm) # global functions


# Check Demo
PAV$group = as.numeric(as.factor(PAV$group))
AGE = ddply(PAV,~group,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PAV,~group,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PAV, .(id, group), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, group) %>%
  tally() #1 = women

N_group = ddply(PAV, .(id, group), summarise, group=mean(as.numeric(group)))  %>%
  group_by(group) %>% tally()

# -------------------------------------------------------------------------
# *************************************** PAVLOVIAN *********************************************
# -------------------------------------- PREPROC ----------------------------------------

# define as.factors
fac <- c("id", "trial", "condition", "group" ,"trialxcondition", "gender")
PAV[fac] <- lapply(PAV[fac], factor)

#revalue all catego
PAV$group = as.factor(revalue(PAV$group, c(control="-1", obese="1"))) #change value of group
PAV$condition = as.factor(revalue(PAV$condition, c(CSminus="-1", CSplus="1"))); PAV$condition <- factor(PAV$condition, levels = c("1", "-1"))#change value of condition

#center covariates
numer <- c("piss", "thirsty", "hungry", "diff_piss", "diff_thirsty", "diff_hungry", "age")
PAV = PAV %>% group_by %>% mutate_at(numer, scale)

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

densityPlot(PAV.clean$RT) #RT are skewed 

#log transform function
t_log_scale <- function(x){
  if(x==0){y <- 1}
  else {y <- (sign(x)) * (log(abs(x)))}
  y }

PAV.clean$RT_T <- sapply(PAV.clean$RT,FUN=t_log_scale)
densityPlot(PAV.clean$RT_T) # much better 

# -------------------------------------- STATS -----------------------------------------------

#FOR MODEL SELECTION we followed Barr et al. (2013) approach to contruct random structure and covariates SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PAV_T0.R

# -------------------------------------- RT
formula = 'RT_T ~ condition*group + (condition|id) + (1|trialxcondition)'
model = mixed(formula, data = PAV.clean, method = "LRT", control = control, REML = FALSE); model

### Linear Mixed Models 
# Mixed is just a wrapper for lmer to get p-values from parametric bootstrapping #but set to method "LRT" and remove "args_test" to quick check
# model = mixed(formula, data = PAV.clean, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 500, cl=cl)); model

ref_grid(model)  #triple check everything is centered at 0

### Extract LogLik to compute BF
main = lmer(formula, data = PAV.clean, control = control, REML = F)
null = lmer(RT_T ~ group + (condition|id) + (1|trialxcondition), data = PAV.clean, control = control, REML = F)
test = anova(main, null, test = 'Chisq')

#get BF from mixed models see Wagenmakers, 2007
BF_RT = exp((test[1,2] - test[2,2])/2); BF_RT 

### Get posthoc contrasts pval and CI
mod <- lmer(formula, data = PAV.clean, control = control, REML = T) # recompute model with REML = T now for further analysis

p_cond = emmeans(mod, pairwise~ condition, side = "<"); p_cond #for condition (CS+ < CS- left sided!)
CI_cond = confint(emmeans(mod, pairwise~ condition),level = 0.95, method = c("boot"), nsim = 5000); CI_cond$contrasts #get CI condition

# inter = emmeans(mod, pairwise~ condition|group, adjust = "tukey", side = "<"); inter$contrasts  #for group X condition (adjusted but still left sided)
# CI_inter = confint(emmeans(mod, pairwise~ condition|group),level = 0.95,method = c("boot"),nsim = 5000); CI_inter$contrasts ##get CI inter


# -------------------------------------- Liking
# stat regular anova because no repeated measures

PAV.means <- aggregate(PAV.clean$RT, by = list(PAV.clean$id, PAV.clean$condition, PAV.clean$liking, PAV.clean$group), FUN='mean') # extract means
colnames(PAV.means) <- c('id','condition','liking','group', 'RT')

anova.liking <- aov_car(formula = liking ~ condition*group + Error (id/condition), data = PAV.means, anova_table = list(correction = "GG", es = "pes")); anova.liking
pes_lik = pes_ci(liking ~ condition*group + Error (id/condition), PAV.means); pes_lik


# Bayes factors
liking.BF <- anovaBF(liking ~ condition*group + id, data = PAV.means, 
                     whichRandom = "id", iterations = 50000); liking.BF
#plot(liking.BF)

# -------------------------------------- PLOT -----------------------------------------------


# RT
dfR <- summarySEwithin(PAV.means,
                       measurevar = "RT",
                       withinvars = "condition", 
                       idvar = "id")

dfR$cond <- ifelse(dfR$condition == "1", -0.25, 0.25)
PAV.means$cond <- ifelse(PAV.means$condition == "1", -0.25, 0.25)
PAV.means <- PAV.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))

pp <- ggplot(PAV.means, aes(x = cond, y = RT, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = RT), alpha = .3, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA))+
  geom_point(aes(x = condjit, shape = group), alpha = .3,) +
  geom_crossbar(data = dfR, aes(y = RT, ymin=RT-se, ymax=RT+se), width = 0.2 , alpha = 0.1)+
  ylab('Reaction Times (ms)')+
  xlab('Conditioned stimulus')+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(200,800, by = 200)), limits = c(180,875)) +
  scale_x_continuous(labels=c("CS+", "CS-"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("1"= pal[2], "-1"=  pal[1]), guide = 'none') +
  scale_color_manual(values=c("1"= pal[2], "-1"=  pal[1]), guide = 'none') +
  scale_shape_manual(name="Group", labels=c("Lean", "Obese"), values = c(1, 2)) +
  theme_bw()


ppp <- pp + averaged_theme 
ppp

cairo_pdf(file.path(figures_path,'Figure_PavlovianRT.pdf'))
print(ppp)
dev.off()


dfL <- summarySEwithin(PAV.means,
                       measurevar = "liking",
                       withinvars = "condition", 
                       idvar = "id")

dfL$cond <- ifelse(dfL$condition == "1", -0.25, 0.25)


# Liking
pp <- ggplot(PAV.means, aes(x = cond, y = liking, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = liking), alpha = .3, size = 0.5, color = 'gray' ) +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA)) +
  geom_point(aes(x = condjit, shape = group), alpha = .3) +
  geom_crossbar(data = dfL, aes(y = liking, ymin=liking-se, ymax=liking+se), width = 0.2 , alpha = 0.1)+
  ylab('Liking Ratings')+
  xlab('Conditioned stimulus')+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 25)), limits = c(-0.05,100.5)) +
  scale_x_continuous(labels=c("CS+", "CS-"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("1"= pal[2], "-1"=  pal[1]), guide = 'none') +
  scale_color_manual(values=c("1"= pal[2], "-1"=  pal[1]), guide = 'none') +
  scale_shape_manual(name="Group", labels=c("Lean", "Obese"), values = c(1, 2)) +
  theme_bw()


ppp <- pp + averaged_theme 
ppp

cairo_pdf(file.path(figures_path,'Figure_PavlovianLiking.pdf'))
print(ppp)
dev.off()


# -------------------------------------------------------------------------
# *************************************** INSTRUMENTAL ******************************************
# -------------------------------------- PREPROC  --------------------------------------------------

#defne factors
fac <- c("id", "trial", "gender", "group")
INST[fac] <- lapply(INST[fac], factor)

#revalue all catego
INST$group = as.factor(revalue(INST$group, c(control="-1", obese="1"))) #change value of group

#center covariates
numer <- c("piss", "thirsty", "hungry", "diff_piss", "diff_thirsty", "diff_hungry", "age")
INST = INST %>% group_by %>% mutate_at(numer, scale)


INST$trial        <- as.numeric(INST$trial)

# -------------------------------------- STATS -----------------------------------------------------
#FOR MODEL SELECTION we followed Barr et al. (2013) approach to contruct random structure and covariates SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_INST_T0.R


# ---------- all trials
# stat -  different fit
formu = '*group + thirsty +hungry + piss + (1 |id)'
## LINEAR FIT  
linmod <- lmer(paste('grips~trial', formu),data=INST, control = control, REML = FALSE)
## POLYNOMIAL FIT  
quadmod <- lmer(paste('grips~trial+I(trial^2)', formu), data=INST, control = control, REML = FALSE)
cubmod <- lmer(paste('grips~trial+I(trial^2)+I(trial^3)', formu),data=INST, control = control, REML = FALSE)
## PIECEWISE REGRESSION WITH SPLINES
splinemod <- lmer(paste('grips ~ lspline(trial, 5)', formu),  data = INST, control = control, REML = FALSE)
bayesfactor_models(linmod, quadmod, cubmod, splinemod, denominator = linmod) #splinemod is the best fit

anova(splinemod)

### Extract LogLik to compute BF
main = lmer(paste('grips ~ lspline(trial, 5)', formu), data = INST, control = control, REML = F)
null = lmer(paste('grips ~ trial', formu), data = INST, control = control, REML = F)
test = anova(main, null, test = 'Chisq')

#get BF from mixed models see Wagenmakers, 2007
BF_gr = exp((test[1,3] - test[2,3])/2); BF_gr 



# -------------------------------------- PLOT  ---------------------------------------------------------

# get the averaged dataset
INST.means <- aggregate(INST$grips, by = list(INST$id, INST$trial, INST$group), FUN='mean') # extract means
colnames(INST.means) <- c('id','trial','group', 'grips')

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
  geom_smooth(method="lm", formula=formula(splinelm), color="tomato",fill = NA, size=0.7) +
  geom_ribbon(aes(ymin=grips-se, ymax=grips+se), fill = pal[4], alpha = 0.3)+
  ylab('Number of Grips')+
  xlab('Trial') +
  scale_y_continuous(expand = c(0, 0),  limits = c(10.5,14.05),  breaks=c(seq.int(11,14, by = 1))) +
  scale_x_continuous(expand = c(0, 0),  limits = c(0,15),  breaks=c(seq.int(1,15, by = 1))) +
  scale_shape_manual(name="Group", labels=c("Lean", "Obese"), values = c(1, 2, 18)) +
  theme_bw()

ppp <- pp + averaged_theme + theme(legend.position=c(.9,.88), axis.text.x = element_text(size = 16))
ppp


cairo_pdf(file.path(figures_path,'Figure_Instrumental_trial.pdf'))
print(ppp)
dev.off()

#xxx



# -------------------------------------------------------------------------
# **************************************   PIT **************************************************
# --------------------------------------- PREPROC  ----------------------

 
# define as factors
fac <- c("id", "trial", "condition", "trialxcondition", "gender", "group")
PIT[fac] <- lapply(PIT[fac], factor)

#remove the baseline
PIT.clean =  subset(PIT, condition != 'BL') 

#revalue all catego
PIT.clean$group = as.factor(revalue(PIT.clean$group, c(control="-1", obese="1"))) #change value of group
PIT.clean$condition = as.factor(revalue(PIT.clean$condition, c(CSminus="-1", CSplus="1"))); PIT.clean$condition <- factor(PIT.clean$condition, levels = c("1", "-1"))#change value of condition


#center covariates
numer <- c("piss", "thirsty", "hungry", "diff_piss", "diff_thirsty", "diff_hungry", "age")
PIT.clean = PIT.clean %>% group_by %>% mutate_at(numer, scale)  


# -------------------------------------- STATS -----------------------------------------------

#FOR MODEL SELECTION we followed Barr et al. (2013) approach to contruct random structure and covariates SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_PIT_T0.R

formula = 'AUC ~ condition*group + hungry + hungry:condition  + (condition|id) + (1|trialxcondition)'
model = mixed(formula, data = PIT.clean, method = "LRT", control = control, REML = FALSE); model
### Linear Mixed Models 
# Mixed is just a wrapper for lmer to get p-values from parametric bootstrapping #but set to method "LRT" and remove "args_test" to quick check
# model = mixed(formula, data = PIT.clean, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 500, cl=cl)); model 

ref_grid(model)  #triple check everything is centered at 0

### Extract LogLik to compute BF for interaction
main = lmer(formula, data = PIT.clean, control = control, REML = F)
null = lmer(AUC ~ condition+ group + hungry + hungry:condition  + (condition|id) + (1|trialxcondition), data = PIT.clean, control = control, REML = F)
test = anova(main, null, test = 'Chisq')

#get BF from mixed models see Wagenmakers, 2007
BF_PIT = exp((test[1,2] - test[2,2])/2); BF_PIT


### Get posthoc contrasts pval and CI
mod <- lmer(formula, data = PIT.clean, control = control, REML = T) # recompute model with REML = T now for further analysis

p_cond = emmeans(mod, pairwise~ condition, side = ">"); p_cond #for condition (CS+ > CS- right sided)
CI_cond = confint(emmeans(mod, pairwise~ condition),level = 0.95, method = c("boot"), nsim = 5000); CI_cond$contrasts #get CI condition

inter = emmeans(mod, pairwise~ condition|group, adjust = "tukey", side = ">"); inter$contrasts  #for group X condition (adjusted but still right sided)
CI_inter = confint(emmeans(mod, pairwise~ condition|group),level = 0.95,method = c("boot"),nsim = 5000); CI_inter$contrasts ##get CI inter



ID <- as.numeric(as.character(rownames(coef(mod)$id))) #get ID names



# -------------------------------------- PLOTS -----------------------------------------------

# create bin for each mini block
PIT.clean$trialxcondition        <- as.numeric(PIT.clean$trialxcondition)
PIT.clean  <- ddply(PIT.clean, "id", transform, bin = as.numeric(cut2(trialxcondition, g = 5)))

PIT.s <- subset (PIT.clean, condition == '1'| condition == '-1')
PIT.s$trialxcondition <- factor(PIT.s$trialxcondition)
PIT.means <- aggregate(PIT.s$AUC, by = list(PIT.s$id, PIT.s$condition, PIT.s$group), FUN='mean') # extract means
colnames(PIT.means) <- c('id','condition', 'group', 'force')

PIT.trial <- aggregate(PIT.s$AUC, by = list(PIT.s$id, PIT.s$trialxcondition), FUN='mean') # extract means
colnames(PIT.trial) <- c('id','trialxcondition','force')



# AVERAGED EFFECT
dfG <- summarySEwithin(PIT.means,
                       measurevar = "force",
                       withinvars = "condition", 
                       betweenvars = "group",
                       idvar = "id")

dfG$cond <- ifelse(dfG$condition == "1", -0.25, 0.25)
PIT.means$cond <- ifelse(PIT.means$condition == "1", -0.25, 0.25)
set.seed(666)
PIT.means <- PIT.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))

labels <- c("-1" = "Lean", "1" = "Obese")

pp <- ggplot(PIT.means, aes(x = cond, y = force, 
                            fill = condition, color = condition)) +
  geom_line(aes(x = condjit, group = id, y = force), alpha = .3, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA))+
  geom_point(aes(x = condjit), alpha = .3,) +
  geom_crossbar(data = dfG, aes(y = force, ymin=force-se, ymax=force+se), width = 0.2 , alpha = 0.1)+
  ylab('Mobilized effort (AUC)')+
  xlab('Conditioned stimulus')+
  scale_fill_manual(values=c("1" = pal[2],"-1"=pal[1]), guide = 'none') +
  scale_color_manual(values=c("1" = pal[2],"-1"=pal[1]), guide = 'none')  +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,600, by = 100)), limits = c(-10,600.5)) +
  scale_x_continuous(labels=c("CS+", "CS-"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  theme_bw() + 
  facet_wrap(~group, labeller=labeller(group = labels))


ppp <- pp + averaged_theme + theme(strip.background = element_rect(fill="white"))
ppp

cairo_pdf(file.path(figures_path,'Figure_PIT_wrap.pdf'))
print(ppp)
dev.off()


### Plot between contrasts

df_est = emmeans(mod, pairwise~ condition|group) # estimate contrasts means by group from the model 
dfP = data.frame(df_est$contrasts); dfP$force = dfP$estimate #create a dataframe
CSp = subset(PIT.means, condition == '1'); CSm = subset(PIT.means, condition == '-1'); cont.means = CSp
cont.means$force = CSp$force - CSm$force; 

dfP$groupi <- ifelse(dfP$group == "1", -0.25, 0.25)
cont.means$groupi <- ifelse(cont.means$group == "1", -0.25, 0.25)
set.seed(666)
cont.means <- cont.means %>% mutate(groupjit = jitter(as.numeric(groupi), 0.25),
                                          grouping = interaction(id, groupi))


pp <- ggplot(cont.means, aes(x = groupi, y = force, 
                            fill = group, color = group)) +
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.8) +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = group, color = NA))+
  geom_point(aes(x = groupjit), alpha = .3,) +
  geom_crossbar(data = dfP, aes(y = force, ymin=force-SE, ymax=force+SE), width = 0.2 , alpha = 0.1)+
  #geom_errorbar(data = dfP,aes(group = group, ymin=force-SE, ymax=force+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  ylab('\u0394 Mobilized effort (CS+ > CS-)')+
  xlab('')+
  scale_fill_manual(values=c("1" = pal[6],"-1"=pal[1]), guide = 'none') +
  scale_color_manual(values=c("1" = pal[6],"-1"=pal[1]), guide = 'none')  +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-200,200, by = 50)), limits = c(-200.5,200.5)) +
  scale_x_continuous(labels=c("Obese", "Lean"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  theme_bw() 


ppp <- pp + averaged_theme 
ppp

cairo_pdf(file.path(figures_path,'Figure_PIT_contrast.pdf'))
print(ppp)
dev.off()


# -------------------------------------------------------------------------

# PLOT OVERTIME
PIT.p <- summarySEwithin(PIT.clean,
                         measurevar = "AUC",
                         withinvars = c("trialxcondition","condition"),
                         betweenvars = "group",
                         idvar = "id")

PIT.p$trial <- as.numeric(PIT.p$trialxcondition)
PIT.p = select(PIT.p, c('trial', 'N' , 'AUC', 'sd', 'se', 'ci', 'condition', 'group'))


# plot 
pp <- ggplot(PIT.p, aes(x = as.numeric(trial), y = AUC,
                     color = condition, 
                     fill  = condition))+
  geom_line(alpha = .5, size = 1, show.legend = F) +
  geom_ribbon(aes(ymax = AUC + se, ymin = AUC - se),  alpha=0.4) + 
  geom_point() +
  ylab('Mobilized effort (AUC)')+
  xlab('Trial')+
  scale_color_manual(labels = c('-1'= 'CS-', "1" = 'CS+'), name="", 
                     values = c("1"= pal[2], '-1'= pal[1])) +
  scale_fill_manual(labels = c('-1'= 'CS-', "1" = 'CS+'), name="", 
                    values = c("1"= pal[2], '-1'= pal[1])) +
  scale_y_continuous(expand = c(0, 0),  limits = c(50,200),  breaks=c(seq.int(50,200, by = 50))) +
  scale_x_continuous(expand = c(0, 0),  limits = c(0,15),  breaks=c(seq.int(1,15, by = 2))) +
  theme_bw() +
  facet_wrap(~group, labeller=labeller(group = labels))


ppp <- pp + averaged_theme + theme(strip.background = element_rect(fill="white"), legend.key.size = unit(0.8, "cm"), axis.text.x = element_text(size = 16))
ppp

cairo_pdf(file.path(figures_path,'Figure_PIT_time.pdf'))
print(ppp)
dev.off()





# ------------------------------------------------------------------------------------------------
# **************************************  HEDONIC **************************************
# ------------------------------------- PREPROC  ----------------------------------------------------------------

# define as.factors
fac <- c("id", "trial", "condition", "trialxcondition", "gender", "group")
HED[fac] <- lapply(HED[fac], factor)

#revalue all catego
HED$condition = as.factor(revalue(HED$condition, c(MilkShake="1", Empty="-1"))) #change value of condition
HED$condition <- relevel(HED$condition, "1") # Make MilkShake first
HED$group = as.factor(revalue(HED$group, c(obese="1", control="-1"))) #change value of group

# create Intensity and Familiarity diff
bs = ddply(HED, .(id, condition), summarise, int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) 
Empty = subset(bs, condition == "-1"); Milkshake = subset(bs, condition == "1"); diff = Empty;
diff$int = Milkshake$int - Empty$int; diff$fam = Milkshake$fam - Empty$fam;
HED = merge(x = HED, y = diff[ , c("int", "fam", 'id')], by = "id", all.x=TRUE)

#center covariates
numer <- c("piss", "thirsty", "hungry", "diff_piss", "diff_thirsty", "diff_hungry", "age", "fam", "int")
HED = HED %>% group_by %>% mutate_at(numer, scale)


# -------------------------------------- STATS -----------------------------------------------

#------------------------------------ pleasantness ----------------------------------------------------------------

#FOR MODEL SELECTION we followed Barr et al. (2013) approach to contruct random structure and covariates SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/MS_HED_T0.R

formula = 'perceived_liking ~ condition*group + thirsty + hungry + hungry:condition  + 
          + fam + int + int:condition + (condition |id) + (1|trialxcondition)'
model = mixed(formula, data = HED, method = "LRT", control = control, REML = FALSE); model

### Linear Mixed Models  
# Mixed is just a wrapper for lmer to get p-values from parametric bootstrapping #but set to method "LRT" and remove "args_test" to quick check
# model = mixed(formula, data = HED.clean, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 500, cl=cl)); model 

ref_grid(model)  #triple check everything is centered at 0

### Extract LogLik to compute BF for condition
main = lmer(formula, data = HED, control = control, REML = F)
null = lmer(perceived_liking ~ group + thirsty + hungry + hungry:condition  + 
              + fam + int + int:condition + (condition |id) + (1|trialxcondition), data = HED, control = control, REML = F)
test = anova(main, null, test = 'Chisq')

#get BF from mixed models see Wagenmakers, 2007
BF_HED = exp((test[1,3] - test[2,3])/2); BF_HED


### Get posthoc contrasts pval and CI
mod <- lmer(formula, data = HED, control = control, REML = T) # recompute model with REML = T now for further analysis

p_cond = emmeans(mod, pairwise~ condition, side = ">"); p_cond #for condition (MilkShake > Empty right sided)
CI_cond = confint(emmeans(mod, pairwise~ condition),level = 0.95, method = c("boot"), nsim = 5000); CI_cond$contrasts #get CI condition

# inter = emmeans(mod, pairwise~ condition|group, adjust = "tukey"); inter$contrasts  #for group X condition (adjusted but still right sided)
# CI_inter = confint(emmeans(mod, pairwise~ condition|group),level = 0.95,method = c("boot"),nsim = 5000); CI_inter$contrasts ##get CI inter



# -------------------------------------- PLOTS -----------------------------------------------
HED.means <- aggregate(HED$perceived_liking, by = list(HED$id, HED$condition, HED$group), FUN='mean') # extract means
colnames(HED.means) <- c('id','condition','group', 'perceived_liking')


# AVERAGED EFFECT
dfH <- summarySEwithin(HED.means,
                       measurevar = "perceived_liking",
                       withinvars = "condition", 
                       idvar = "id")

dfH$cond <- ifelse(dfH$condition == "1", -0.25, 0.25)
HED.means$cond <- ifelse(HED.means$condition == "1", -0.25, 0.25)
set.seed(666)
HED.means <- HED.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))


pp <- ggplot(HED.means, aes(x = cond, y = perceived_liking, 
                            fill = condition, color = condition)) +
  geom_point(data = dfH, alpha = 0.5) +
  geom_line(aes(x = condjit, group = id, y = perceived_liking), alpha = .3, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA))+
  geom_point(aes(x = condjit, shape = group), alpha = .3,) +
  geom_crossbar(data = dfH, aes(y = perceived_liking, ymin=perceived_liking-se, ymax=perceived_liking+se), width = 0.2 , alpha = 0.1)+
  ylab('Perceived liking') +
  xlab('Odorant') +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(-0.5,100.5)) +
  scale_x_continuous(labels=c("Pleasant", "Neutral"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("1"= pal[3], "-1"=pal[1]), guide = 'none') +
  scale_color_manual(values=c("1"=pal[3], "-1"=pal[1]), guide = 'none') +
  scale_shape_manual(name="Group", labels=c("Lean", "Obese"), values = c(1, 2)) +
  theme_bw()

ppp <- pp + averaged_theme
ppp

cairo_pdf(file.path(figures_path,'Figure_HEDONIC.pdf'))
print(ppp)
dev.off()


# OVERTIME
HED.t <- summarySEwithin(HED,
                         measurevar = "perceived_liking",
                         withinvars = c("trialxcondition","condition"),
                         idvar = "id")

HED.tg <- summarySEwithin(HED,
                         measurevar = "perceived_liking",
                         withinvars = c("trialxcondition","condition"),
                         betweenvars = 'group',
                         idvar = "id")


# plot xxx
pp <- ggplot(HED.t, aes(x = as.numeric(trialxcondition), y = perceived_liking,
                     color =condition, fill = condition)) +
  geom_point(data = HED.tg, aes(shape=group), color = "black", alpha = 0.5) +
  geom_point(data = HED.t) +
  geom_line(alpha = .7, size = 1) +
  geom_ribbon(aes(ymax = perceived_liking + se, ymin = perceived_liking - se),  alpha=0.4) + 
  ylab('Perceived liking')+
  xlab('Trial') +
  scale_shape_manual(name="Group", labels=c("Lean", "Obese"), values = c(1, 2)) +
  scale_color_manual(labels = c('Pleasant', 'Neutral'), name = "",
                     values = c( "1" =pal[3], '-1' =pal[1])) +
  scale_fill_manual(labels = c('Pleasant', 'Neutral'), name = "",
                    values = c( "1" =pal[3], '-1'=pal[1])) +
  scale_y_continuous(expand = c(0, 0),  limits = c(40,100),  breaks=c(seq.int(50,100, by = 10))) +
  scale_x_continuous(expand = c(0, 0),  limits = c(-0.09,20.09),  breaks=c(seq.int(0,20, by = 2))) +
  guides(color=guide_legend(override.aes=list(fill=c(pal[3], pal[1]))))+
  theme_bw()


ppp <- pp + averaged_theme + guides(shape = guide_legend(order = 1)) + theme(legend.margin=margin(0,0,0,0), legend.box = "horizontal", legend.key.size = unit(0.4, "cm"), axis.text.x = element_text(size = 16), legend.position = c(0.8, 0.915)) 
ppp

cairo_pdf(file.path(figures_path,'Figure_Hedonic_time.pdf'))
print(ppp)
dev.off()


