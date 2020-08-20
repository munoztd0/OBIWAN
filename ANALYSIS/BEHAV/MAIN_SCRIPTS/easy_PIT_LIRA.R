## R code for FOR PIT OBIWAN LIRA
# last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, misty, interactions)

# SETUP ------------------------------------------------------------------


task = 'PIT'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)


# open dataset or load('PIT_Lira.RData')
PIT_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset
intern <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset

#subset #only group obese 
PIT  <- subset(PIT_full, group == 'obese')
HED  <- subset(HED_full, group == 'obese') 
intern  <- subset(intern, group == 'obese') 

#merge with info
PIT = merge(PIT, info, by = "id")

#take out incomplete data ##218 only have the third ? influence -> 238 & 234 & 232 & 254
`%notin%` <- Negate(`%in%`)
PIT = PIT %>% filter(id %notin% c(242,245, 256, 266)) #& 266??
HED = HED %>% filter(id %notin% c(242, 245, 256, 266)) #& 266??
#, 201, 218, 219, 221, 225, 230, 241,  244, 246, 247 check
#242 245 bc MRI & behav 256 task

# INTERNAL STATES
baseINTERN = subset(intern, phase == 3)
PIT = merge(x = PIT, y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
diffINTERN = subset(intern, phase == 3 | phase == 4) #before and after PIT
before = subset(diffINTERN, phase == 3)
after = subset(diffINTERN, phase == 4)
diff = after
diff$diff_piss = diff$piss - before$piss
diff$diff_thirsty = diff$thirsty - before$thirsty
diff$diff_hungry = diff$hungry - before$hungry

PIT = merge(x = PIT, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)


# define as.factors
fac <- c("id", "trial", "condition", "session", "trialxcondition", "gender", "intervention")
PIT[fac] <- lapply(PIT[fac], factor)


#check demo
n_tot = length(unique(PIT$id))
bs = ddply(PIT, .(id, session, condition),summarise,mean=mean(AUC))

#remove the baseline from other trials and then scale  by id  
PIT =  subset(PIT, condition != 'BL')
PIT <- PIT[!(PIT$id == "248" & PIT$session == "third" ),] 

# Center level-1 predictor within cluster (CWC)
PIT$gripC = center(PIT$AUC, type = "CWC", group = PIT$id) #nested within session?
PIT <- PIT %>% group_by(id) %>% mutate(gripZ = center(AUC))
PIT_agg = ddply(PIT, .(id, session, condition, intervention), summarise, grip= mean(gripZ, na.rm = TRUE)) 

t0 = subset(PIT_agg, session == 'second')
t1 = subset(PIT_agg, session == 'third')

CSp0 = subset(t0, condition == 'CSplus')
CSm0 = subset(t0, condition == 'CSminus')
CSp1 = subset(t1, condition == 'CSplus')
CSm1 = subset(t1, condition == 'CSminus')

df = CSp0
df$scoreT0 =  CSp0$grip - CSm0$grip

CSp1$scoreT1 =  CSp1$grip - CSm1$grip 

df = merge(x = df, y = CSp1[ , c("id", "scoreT1")], by = "id", all.x=TRUE)

mod <- aov_car(scoreT1 ~ intervention*scoreT0 + Error(id/1), data = df, anova_table = list(es = "pes"), factorize = FALSE)
model = lm(scoreT1 ~ intervention*scoreT0, data = df)
summary(mod)

# Anova Table (Type 3 tests)
# 
# Response: scoreT1
# num Df den Df  MSE       F     pes    Pr(>F)    
# intervention              1     41 4276  0.0294 0.00072   0.86472    
# scoreT0                   1     41 4276 24.8764 0.37762 1.167e-05 ***
# intervention:scoreT0      1     41 4276  6.3349 0.13383   0.01584 *  
#the people with lira have an higher positive correlation between sessions

p_grip = as_tibble(emmeans(mod, ~ intervention)) 

interact_plot(model, pred = scoreT0 , modx = intervention) #dafuk
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
  geom_errorbar(data = p_grip, aes(group = intervention, ymin=emmean-SE, ymax=emmean+SE),position=position_nudge(x=0.15), size=0.5, width=0.1,  color = "black") + 
  geom_point(data = p_grip, size = 2, shape=23,position=position_nudge(x=0.15)) 

plt = plt0 + 
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
  labs(title = "Effect of Treatment on PIT", 
       y =  "Mobilized Effort (AUC) \u2013 \u0394 CS", x = "") # ,caption = "Error bars represent SEM for the model emmeand mean constrasts\n")
#Main effect of condition, p = 0.022, \u0394 AIC = 4.42, Controling for Plesantness, Age & Gender")

plot(plt)

cairo_pdf(file.path(figures_path,paste(task,'LIRA_treat.pdf',  sep = "_")),
          width = 5.5,
          height = 6)

plot(plt)
dev.off()


#create table
#apa.aov.table(x, filename = "Table7_APA.doc", table.number = 7)
