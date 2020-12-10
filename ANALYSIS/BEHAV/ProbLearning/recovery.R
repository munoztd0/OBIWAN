## R code for FOR PROBA LEARNING TASK OBIWAN
# last modified on April 2020 by David MUNOZ TORD


# PRELIMINARY STUFF ----------------------------------------
#if there is any bug please run this line below once ant then rerun the script
#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))

#load packages
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(tidyverse, plyr,dplyr,readr,rlist, parallel, effectsize, ggpubr, pracma)


options(mc.cores = parallel::detectCores()) #to mulithread

# SETUP ------------------------------------------------------------------

task = 'PBlearning'


# Set working directory #change here if the switchdrive is not on your home folder
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV/T0') 

setwd(analysis_path)




# simulate behavior -------------------------------------------------------
set.seed(666)
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/ProbLearning/simulatePST.R', echo=TRUE)

# create data structure ----------------------------------------------

load("~/OBIWAN/DERIVATIVES/BEHAV/PBL_OBIWAN_T0.RData")
s = length(unique(df$ID))
simDATA = c(); 

for (i in 1:s) {
  alphaG = df$alpha_gain[i]
  alphaL = df$alpha_loss[i]
  beta = df$beta[i]
  ID = as.numeric(as.character(rep(df$ID[i], 300)))
  type = sample(rep(c(12, 34, 56), each=100))
  data = cbind(ID, type); data = as_tibble(data)
  print(paste('simulate sub', ID[i]))
  d = simulatePST(alphaG, alphaL, beta, data)
  simDATA = rbind(simDATA, d)
}


# Re-estimate model's parameters  ----------------------------------------------------------
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/ProbLearning/PST_Q_learning.R', echo=TRUE)
set.seed(666); Nrep = 100; k = 3 # number of free parameteres
subj = unique(simDATA$ID)
alphaG = c(); alphaL = c(); beta = c(); nll= c(); ID = c(); group = c(); trials = c()
LB = c(0, 0, 0); UB = c(1, 1, 10) # parameters lower and upper bounds
for (s in subj) {
  data = subset(simDATA, ID == s)
  param_rep = c(); nll_rep = c()
  for (i in  1:Nrep) {
    x0 = c(rand(), rand(), 10*rand()); #different parameter initial values to avoid local minima
    f = fmincon(x0=x0,fn=PST_q_dual, data = data, lb = LB, ub = UB) #optimize
    param_rep = rbind(param_rep, f$par); nll_rep = rbind(nll_rep, f$value)
  }
  pos = which.min(nll_rep)
  alphaG = rbind(alphaG,param_rep[pos,1]); alphaL = rbind(alphaL,param_rep[pos,2]); beta = rbind(beta,param_rep[pos,3]); nll = rbind(nll,nll_rep[pos]); ID = rbind(ID,s); group = rbind(group, ifelse(s > 200, 'obese', 'lean')); trials = rbind(trials,length(data$ID))
  print(paste('done subj', s))
}

dfsim = cbind(ID, alphaG, alphaL, beta, nll, group, trials)
colnames(dfsim) = c('ID', 'alpha_gain', 'alpha_loss','beta', 'nll', 'group', 'trials'); 
dfsim = as_tibble(dfsim); dfsim$group =as.factor(dfsim$group); dfsim$ID =as.factor(dfsim$ID)
dfsim[] <- lapply(dfsim, function(x) {if(is.character(x)) as.numeric(as.character(x)) else x})  



# check correlation between true participant's parameters and their  --------


dfsim$alphaGO = df$alpha_gain
dfsim$alphaLO = df$alpha_loss
dfsim$betaO = df$beta

p1 = ggscatter(dfsim, x = "alphaGO", y = "alpha_gain", 
          add = "reg.line", conf.int = T,
          add.params = list(color = "black", fill = "grey", size = 0.75), xlab = "true", ylab = "recovered", title = 'Alpha Gain', show.legend.text = FALSE ) + 
  stat_cor(aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~")), label.y = 1.2); p1

p2 = ggscatter(dfsim, x = "alphaLO", y = "alpha_loss", 
          add = "reg.line", conf.int = T,
          add.params = list(color = "black", fill = "grey", size = 0.75), xlab = "true", ylab = "recovered", title = 'Alpha Loss', show.legend.text = FALSE ) + 
  stat_cor(aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~")), label.y = 0.8); p2


p3 = ggscatter(dfsim, x = "betaO", y = "beta", 
          add = "reg.line", conf.int = T,
          add.params = list(color = "black", fill = "grey", size = 0.75), xlab = "true", ylab = "recovered", title = 'Beta', show.legend.text = FALSE ) + 
  stat_cor(aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~")), label.y = 10); p3

dfsim$group = ifelse(as.numeric(as.character(dfsim$ID)) > 199, "obese", "lean")

ggscatter(dfsim, x = "alphaGO", y = "alpha_gain",
          color = "group",
          palette = c("#00AFBB", "#E7B800"),
          ellipse = TRUE, mean.point = TRUE,
          star.plot = TRUE,   show.legend.text = FALSE,  xlab = "true", ylab = "recovered", title = '') + 
  stat_cor(aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~")), label.y = 1, label.x = -0.4)


cairo_pdf(file.path(figures_path,'Figure_alphaG_SIM.pdf'))
print(p1)
dev.off()

cairo_pdf(file.path(figures_path,'Figure_alphaL)SIM.pdf'))
print(p2)
dev.off()

cairo_pdf(file.path(figures_path,'Figure_betaSIM.pdf'))
print(p3)
dev.off()



# checks ------------------------------------------------------------------


#checking expected value
# d$trial = 1:length(d$ID)
# data_long <- gather(d, option, ev, ev1:ev6, factor_key=TRUE)
# data_long$option <- factor(data_long$option, levels = c("ev1", "ev3", "ev5", "ev2", "ev4", "ev6"))
# data_long %>%
#   ggplot(aes(x = trial, y = ev)) +
#   geom_line(size=0.5) +
#   #geom_line(aes(y=pe), color ='red',size=0.5) +
#   ylim(0,1) +
#   facet_wrap("option")