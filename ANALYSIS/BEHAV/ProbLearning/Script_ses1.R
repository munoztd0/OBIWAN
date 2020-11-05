## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman", "devtools")
  library(devtools)
  library(pacman)
}

if(!require(tidyBF)) {
  install_version("tidyBF", version = "0.3.0")
  library(tidyBF)
}

pacman::p_load(tidyverse, plyr,dplyr,readr, car, BayesFactor, sjmisc, parallel, effectsize, tidyBF) #whatchout to have tidyBF 0.2.0
pacman::p_load_gh("munoztd0/hBayesDM") # your need to install this modfied version of hBayesDM where I implement an alternate model of the PST task 


options(mc.cores = parallel::detectCores()) #to mulithread

# SETUP ------------------------------------------------------------------

task = 'PBlearning'


# Set working directory #change here if the switchdrive is not on your home folder
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV/T0') 

setwd(analysis_path)

# open dataset 
full <- read_csv("~/OBIWAN/DERIVATIVES/BEHAV/PBLearning.csv")


#load("~/OBIWAN/DERIVATIVES/BEHAV/PBL_OBIWAN_T0.RData") # if you dont want ot recompute and go directly to stats


# Preprocess --------------------------------------------------------------

data  <- subset(full, Session == 1) #subset #only session one 
data  <- subset(data, Phase == 'proc1') #only learning phase

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
  if((data$side[i] == 'L')&(data$img[i] == 'A' || data$img[i] == 'C' || data$img[i] == 'E')) {
    data$choice[i] = 1
  } else if ((data$side[1] == 'R')&(data$imd[i] == 'A' || data$imd[i] == 'C' || data$imd[i] == 'E')) {
    data$choice[i] = 1}
  else {
  data$choice[i] = 0}
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

dataclean <- select(data, c(subjID, type, choice, reward, Group))

#check that nobody has more than 200 trial
count_trial = dataclean %>% group_by(subjID) %>%tally()



# Estimate model's parameters and compare model's fit ----------------------------------------------------------
#run Probabilistic Learning Task -- Q-learning (following Frank et al. (2007))
#type ?pst_gain_Q for more info

# 10'000 per model ... x 4 chains.. so 40'000 itertaions  X 4 model, where 1 chain ~ 7min on my dedicated GPU cores and ~25 min on my normal CPU cores.. so prepare your expectations ..

### Group Lean
Lean_data  <- subset(dataclean, Group == 'C')
#Q-learning via Rescorla-Wagner update rule with one learning speed: αlpha.
Lean_output1 <- pst_gain_Q(data = Lean_data, niter = 50000, nwarmup = 500, nchain = 4, ncore = 8, nthin = 1, inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

#Q-learning via Rescorla-Wagner update rule with two different learning speeds: α-Gain referring to player’s sensitivity to rewards and α-Loose referring to player’s sensitivity to punishments.
Lean_output2 <- pst_gainloss_Q(data = Lean_data, niter = 50000, nwarmup = 500, nchain = 4, ncore = 8, nthin = 1, inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

#BIC; k*ln(n) - 2*logLik
BIC11 = 2*log(length(Lean_output1$allIndPars$subjID)) - 2*mean(Lean_output1$parVals$log_lik); BIC11
BIC21 = 3*log(length(Lean_output2$allIndPars$subjID)) - 2*mean(Lean_output2$parVals$log_lik); BIC21

mod = Lean_output1
extract_ic(mod) #check the LOOIC in more details


## Visualize
plot(mod, type = 'trace', inc_warmup=T) #The trace plots indicate that MCMC samples are indeed well mixed and converged, which is consistent with their R^ values #grey area is the burn in samples

#Visualize individual parameters
# plotInd(mod, "beta_pos")  
# plotInd(mod, "beta")  

# Check Rhat values (all Rhat values should be less than or equal to 1.1)
#rhat(mod)

# Plot the posterior distributions of the hyper-parameters (distributions should be unimodal)
#densityPlot(mod$parVals$mu_beta_pos)
#densityPlot(mod$parVals$mu_beta)


### Group Obese
Obese_data  <- subset(dataclean, Group == 'O')
#Q-learning via Rescorla-Wagner update rule with one learning speed: αlpha.
Obese_output1 <- pst_gain_Q(data = Obese_data, niter = 50000, nwarmup = 500,nchain = 4, ncore = 8,nthin = 1,inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

#Q-learning via Rescorla-Wagner update rule with two different learning speeds: α-Gain referring to player’s sensitivity to rewards and α-Loose referring to player’s sensitivity to punishments.
Obese_output2 <- pst_gainloss_Q(data = Obese_data, niter = 50000, nwarmup = 500, nchain = 4, ncore = 8,nthin = 1,inits = "random", indPars = "mean", modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE, adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

#BIC approx ; k*ln(n) - 2*logLik
BIC12 = 2*log(length(Obese_output1$allIndPars$subjID)) - 2*mean(Obese_output1$parVals$log_lik); BIC12
BIC22 = 3*log(length(Obese_output2$allIndPars$subjID)) - 2*mean(Obese_output2$parVals$log_lik); BIC22

mod = Obese_output1
extract_ic(mod) #check the LOOIC in more details

## Visualize
plot(mod, type = 'trace', inc_warmup=T) #The trace plots indicate that MCMC samples are indeed well mixed and converged, which is consistent with their R^ values #grey area is the burn in smaples

#Visualize individual parameters
# plotInd(mod, "beta_pos")  
# plotInd(mod, "beta")  

# Check Rhat values (all Rhat values should be less than or equal to 1.1)
#rhat(mod)

# Plot the posterior distributions of the hyper-parameters (distributions should be unimodal)
#densityPlot(mod$parVals$mu_beta_pos)
#densityPlot(mod$parVals$mu_beta)



# Compare groups ----------------------------------------------------------

group1 = Lean_output1$allIndPars
group2 = Obese_output1$allIndPars
df = rbind(group1, group2)
df$group = ifelse(df$subjID > 199, "obese", "lean")
df$group = as.factor(df$group); df$group  <- relevel(df$group , "obese")

save(df, file = "PBL_OBIWAN_T0.RData")

#### For alpha

# unpaired Bayesian t-test
BF_alpha = tidyBF::bf_ttest(df, group, alpha_pos, output = "dataframe", paired = F, iterations = 50000); BF_alpha$log_e_bf10; BF_alpha$estimate; BF_alpha$conf.low; BF_alpha$conf.high


#Frequentist
# classical.test = t.test(df$alpha_pos[df$group=='lean'], df$alpha_pos[df$group=='obese'], paired=F, var.eq = F); classical.test
# 
# hedges_g(alpha_pos ~ group, data = df, paired = F, correction = T)



#### For beta

# unpaired Bayesian t-test
BF_beta = tidyBF::bf_ttest(df, group, beta, output = "dataframe", paired = F, iterations = 50000); BF_beta$log_e_bf10; BF_beta$estimate; BF_beta$conf.low; BF_beta$conf.high


#Frequentist
# classical.test = t.test(df$beta[df$group=='lean'], df$beta[df$group=='obese'], paired=F, var.eq = F); classical.test
# 
# hedges_g(beta ~ group, data = df, paired = F, correction = T)


# Plot --------------------------------------------------------------------


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

pp <- ggplot(df, aes(x = group, y = alpha_pos, 
                            fill = group, color = group)) +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA)+
  geom_point(aes(x = group), alpha = .3, position = position_jitter(width = 0.05)) +
  geom_boxplot(width = 0.05 , alpha = 0.1)+
  ylab('\u03B1 (Learning Rate)')+ xlab('')+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0.08,0.16, by = 0.02)), limits = c(0.07,0.17)) +
  scale_x_discrete(labels=c("Obese", "Lean")) +
  scale_fill_manual(values=c("lean"= pal[1], "obese"=  pal[6]), guide = 'none') +
  scale_color_manual(values=c("lean"= pal[1], "obese"=  pal[6]), guide = 'none') +
  theme_bw()


ppp <- pp + averaged_theme 
ppp

cairo_pdf(file.path(figures_path,'Figure_alpha.pdf'))
print(ppp)
dev.off()


pp <- ggplot(df, aes(x = group, y = beta, 
                     fill = group, color = group)) +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA)+
  geom_point(aes(x = group), alpha = .3, position = position_jitter(width = 0.05)) +
  geom_boxplot(width = 0.05 , alpha = 0.1)+
  ylab('\u03B2 (Choice Consistency)')+ xlab('')+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(4,8, by = 1)), limits = c(3.8,8)) +
  scale_x_discrete(labels=c("Obese", "Lean")) +
  scale_fill_manual(values=c("lean"= pal[1], "obese"=  pal[6]), guide = 'none') +
  scale_color_manual(values=c("lean"= pal[1], "obese"=  pal[6]), guide = 'none') +
  theme_bw()


ppp <- pp + averaged_theme 
ppp

cairo_pdf(file.path(figures_path,'Figure_beta.pdf'))
print(ppp)
dev.off()




# THE END -----------------------------------------------------------------
