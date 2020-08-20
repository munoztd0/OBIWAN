## R code for FOR PAV OBIWAN LIRA
# last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, misty)

# SETUP ------------------------------------------------------------------

task = 'PAV'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


# open dataset or load('PAV_LIRA.RData')
PAV_full <- read.delim(file.path(analysis_path,'OBIWAN_PAV.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PAV  <- subset(PAV_full, group == 'obese') 
intern  <- subset(intern, group == 'obese') 

#merge with info
PAV = merge(PAV, info, by = "id")

#take out incomplete data ## look out for  122 & 110 & 254 outliers!
#exclude 242 really outlier everywhere, 256 can't do the task, 228 also
`%notin%` <- Negate(`%in%`)
PAV = PAV %>% filter(id %notin% c(242, 256, 228, 230)) #check 224 254 227
intern = intern %>% filter(id %notin%  c(242, 256, 228, 230))

# INTERNAL STATES
baseINTERN = subset(intern, phase == 2)
PAV = merge(x = PAV, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
diffINTERN = subset(intern, phase == 2 | phase == 3) #before and after PAV
before = subset(diffINTERN, phase == 2)
after = subset(diffINTERN, phase == 3)
diff = after
diff$diff_piss = diff$piss - before$piss
diff$diff_thirsty = diff$thirsty - before$thirsty
diff$diff_hungry = diff$hungry - before$hungry

PAV = merge(x = PAV, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)

# define as.factors
fac <- c("id", "trial", "condition", "session", "trialxcondition", "gender", "intervention")
PAV[fac] <- lapply(PAV[fac], factor)

PAV$RT <- as.numeric(PAV$RT)*1000 # transform in millisecond

#check demo

AGE = ddply(PAV,~session,summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age))
BMI = ddply(PAV,~session,summarise,mean=mean(BMI_t1),sd=sd(BMI_t1), min = min(BMI_t1), max = max(BMI_t1))
GENDER = ddply(PAV, .(id, session), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender, session) %>%
  tally() #2 = female

PAV$idXsession = as.numeric(PAV$id) * as.numeric(PAV$session)

# Cleaning Up -------------------------------------------------------------
#shorter than 100ms and longer than 3sd+mean

densityPlot(PAV$RT) # bad 

acc_bef = mean(PAV$ACC, na.rm = TRUE) #0.93

full = length(PAV$RT)
PAV.clean <- PAV %>% filter(RT <= mean(RT, na.rm = TRUE) + 3*sd(RT, na.rm = TRUE) &  RT >= 200) 

clean= length(PAV.clean$RT)

dropped = full-clean
(dropped*100)/full  #dropped 6%

densityPlot(PAV.clean$RT) #skewed bwaaa

PAV = PAV.clean 

#log transform function
t_log_scale <- function(x){
  if(x==0){y <- 1} 
  else {y <- (sign(x)) * (log(abs(x)))}
  y }

PAV$RT_T <- sapply(PAV$RT,FUN=t_log_scale)
densityPlot(PAV$RT_T) # ahh this is much better !

#accuracy is to 99 (was 93 before cleaning)
acc_clean = mean(PAV$ACC, na.rm = TRUE)

n_tot = length(unique(PAV$id))
bsRT = ddply(PAV, .(id, session, condition), summarise, RT = mean(RT, na.rm = TRUE)) 

# 224 and 225  third have a mean of 999.99 taking them out
PAVRT <- PAV[!(PAV$id == "224" & PAV$session == "third" ),] 
PAVRT <- PAVRT[!(PAVRT$id == "225" & PAVRT$session == "third" ),] 

PAV_agg = ddply(PAVRT, .(id, session, condition, intervention), summarise, RT = mean(RT, na.rm = TRUE)) 

t0 = subset(PAV_agg, session == 'second')
t1 = subset(PAV_agg, session == 'third')

CSp0 = subset(t0, condition == 'CSplus')
CSm0 = subset(t0, condition == 'CSminus')
CSp1 = subset(t1, condition == 'CSplus')
CSm1 = subset(t1, condition == 'CSminus')

df = CSp0
df$scoreT0 =  CSm0$RT -CSp0$RT

CSp1$scoreT1 =  CSm1$RT -CSp1$RT

df = merge(x = df, y = CSp1[ , c("id", "scoreT1")], by = "id", all.x=TRUE)

mod <- aov_car(scoreT1 ~ intervention*scoreT0 + Error(id/1), data = df, anova_table = list(es = "pes"), factorize = FALSE)
summary(mod)

# Anova Table (Type 3 tests)
# 
# Response: scoreT1
# num Df den Df  MSE      F       pes Pr(>F)
# intervention              1     40 4615 0.8186 0.0200554 0.3710
# scoreT0                   1     40 4615 0.0524 0.0013077 0.8201
# intervention:scoreT0      1     40 4615 0.7871 0.0192986 0.3803

p_RT = as_tibble(emmeans(mod, ~ intervention))

# LIKING ------------------------------------------------------------------

bsLIK = ddply(PAV, .(id, session, condition), summarise, liking = mean(liking, na.rm = TRUE)) 

PAV_lik = ddply(PAV, .(id, session, condition, intervention), summarise, liking = mean(liking, na.rm = TRUE)) 

t0_lik = subset(PAV_lik, session == 'second')
t1_lik = subset(PAV_lik, session == 'third')

CSp0_lik = subset(t0_lik, condition == 'CSplus')
CSm0_lik = subset(t0_lik, condition == 'CSminus')
CSp1_lik = subset(t1_lik, condition == 'CSplus')
CSm1_lik = subset(t1_lik, condition == 'CSminus')

df_lik = CSp0_lik
df_lik$scoreT0 = CSp0_lik$liking - CSm0_lik$liking

CSp1_lik$scoreT1 = CSp1_lik$liking - CSm1_lik$liking

df_lik = merge(x = df_lik, y = CSp1_lik[ , c("id", "scoreT1")], by = "id", all.x=TRUE)

mod_lik <- aov_car(scoreT1 ~ intervention*scoreT0 + Error(id/1), data = df_lik, anova_table = list(es = "pes"), factorize = FALSE)
summary(mod_lik)
#x = lm(scoreT1 ~ intervention*scoreT0, data = df_lik)

# Anova Table (Type 3 tests)
# 
# Response: scoreT1
# num Df den Df    MSE       F     pes    Pr(>F)    
# intervention              1     42 390.59  0.3176 0.00751    0.5760    
# scoreT0                   1     42 390.59 20.4547 0.32751 4.933e-05 ***
#   intervention:scoreT0      1     42 390.59  0.3803 0.00897    0.5408  

p_liking = as_tibble(emmeans(mod_lik, ~ intervention))


# PLOT --------------------------------------------------------------------
#labelsSES <- c("0" = "\u2800 \u2800 \u2800 Pre-Test", "1" = "\u2800 \u2800 \u2800 Post-Test")
labelsTRE <- c( "0" = "\u2800 \u2800 Placebo" , "1" = "\u2800 \u2800 Liraglutide")
#labelsCON <- c( "-1" = "CS-" , "1" = "CS+")

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R') #helpful plot functions

df$emmean = df$scoreT1
plt0 <- ggplot(df, aes(x = intervention, y = emmean, fill = intervention)) + 
  #geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.5) +
  geom_point(size=2,shape=20, alpha=.5, position=position_jitter(width=0.05, seed = 59)) +
  geom_flat_violin(position=position_nudge(x=0.15),adjust=1.5,trim=FALSE,alpha=.5,colour=NA) +
  geom_boxplot(position=position_dodge(width =0.15),fatten = NULL, outlier.shape=NA, alpha=.5,width=.1,colour="black") +
  geom_errorbar(data = p_RT, aes(group = intervention, ymin=emmean-SE, ymax=emmean+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  geom_point(data = p_RT, size = 2, shape=23,position=position_nudge(x=0.15)) 

plt = plt0 + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-100,300, by = 100)), limits = c(-200,400)) +
  scale_x_discrete(labels=labelsTRE) +
  scale_fill_manual(labels=labelsTRE, values=c('seagreen3','royalblue')) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5, size=20),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=16,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=20), 
        legend.title = element_blank(),
        legend.text = element_text(size=16), 
        legend.position = "none", #c(0.5, 0.5),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"),
        strip.text = element_text(size=16),
        legend.key.size = unit(2,"line"))+ 
  labs(title = "Effect of Treatment on Pavlovian Conditioning", 
       y =  "Latency (ms) \u2013 \u0394 CS", x = "") # ,caption = "Error bars represent SEM for the model emmeand mean constrasts\n")
#Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")

plot(plt)

cairo_pdf(file.path(figures_path,paste(task,'LIRA_cond&RT.pdf',  sep = "_")),
          width = 5.5,
          height = 6)

plot(plt)
dev.off()



# ---------------------------------
  
df_lik$emmean = df_lik$scoreT1
plt_lik <- ggplot(df_lik, aes(x = intervention, y = emmean, fill = intervention)) + 
  #geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.5) +
  geom_point(size=2,shape=20, alpha=.5, position=position_jitter(width=0.05, seed = 59)) +
  geom_flat_violin(position=position_nudge(x=0.15),adjust=1.5,trim=FALSE,alpha=.5,colour=NA) +
  geom_boxplot(position=position_dodge(width =0.15),fatten = NULL, outlier.shape=NA, alpha=.5,width=.1,colour="black") +
  geom_errorbar(data = p_liking, aes(group = intervention, ymin=emmean-SE, ymax=emmean+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  geom_point(data = p_liking, size = 2, shape=23,position=position_nudge(x=0.15)) 

plt = plt_lik + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(-50,100, by = 25)), limits = c(-50,100)) +
  scale_x_discrete(labels=labelsTRE) +
  scale_fill_manual(labels=labelsTRE, values=c('seagreen3','royalblue')) +
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5, size=20),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x = element_text(size=16,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=20), 
        legend.title = element_blank(),
        legend.text = element_text(size=16), 
        legend.position = "none", #c(0.5, 0.5),
        axis.ticks.x = element_blank(), 
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"),
        strip.text = element_text(size=16),
        legend.key.size = unit(2,"line"))+ 
  labs(title = "Effect of Treatment on CS ratings", 
       y =  "Pleasantness Ratings \u2013 \u0394 CS", x = "") # ,caption = "Error bars represent SEM for the model emmeand mean constrasts\n")
#the only effect is the score baseline if they liked at point 0 they like at point 1

plot(plt)

cairo_pdf_lik(file.path(figures_path,paste(task,'LIRA_cond&pleas.pdf_lik',  sep = "_")),
          width = 5.5,
          height = 6)

plot(plt)
dev.off()
#create table
#apa.aov.table(x, filename = "Table7_APA.doc", table.number = 7)
