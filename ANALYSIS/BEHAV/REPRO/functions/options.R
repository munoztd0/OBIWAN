# -------------------------------------- Miscellaneous  ----------------------------------------------------------

options(contrasts=c("contr.sum","contr.poly")) #set contrasts to sum !
set.seed(666) #set random seed
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb')) #set "better" lmer optimizer #nolimit # yoloptimizer
emm_options(pbkrtest.limit = 5000) #increase repetitions limit
options(mc.cores = parallel::detectCores()); cl <- parallel::detectCores() #to mulithread
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/pes_ci.R', echo=F) #useful PES function from Yoann
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

scale2 <- function(x, na.rm = TRUE) (x - mean(x, na.rm = na.rm)) / sd(x, na.rm) # global functions
