## R code for FOR OBIWAN GENERAL
# last modified on August 2019 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(robust, permuco, MASS, ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, grid, mosaic, psychometric, RNOmni)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

#SETUP

k = 2
n = 24

## R code for FOR REWOD_HED

# open dataset 
OBIWAN_HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
OBIWAN_INST_full <- read.delim(file.path(analysis_path,'OBIWAN_PIT.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

OBIWAN_HED  <- subset(OBIWAN_HED_full, intervention == '0' & group == 'obese' & session == 'second') #only group obese 
OBIWAN_PIT  <- subset(OBIWAN_PIT_full, intervention == '0', session = 'second') #only group obese 

bsPIT = ddply(OBIWAN_PIT, .(id, condition), summarise, gripFreq = mean(gripFreq, na.rm = TRUE))
bsHED = ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

#PIT idx
CSp = subset(bsPIT, condition == 'CSplus')
CSm = subset(bsPIT, condition == 'CSminus')
PIT = CSp

PIT$idxPIT = CSp$gripFreq #- CSm$gripFreq

#LIK idx
EMp = subset(bsHED, condition == 'Empty')
MLs = subset(bsHED, condition == 'MilkShake')
HED = MLs

HED$idxLIK = MLs$perceived_liking #- EMp$perceived_liking

source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

dataset = merge(PIT, HED, by = "id", all.x = TRUE)
dataset  <- subset(dataset, id != 242 & id != 256 & id != 234) #234 only have third session
info$id      <- as.factor(info$id)
dataset$id      <- as.factor(dataset$id)

dataset = full_join(dataset, info, by = "id")

dataset <-dataset %>% drop_na("condition.x")

#dataset  <- subset(dataset, intervention =='1') 

#scale everything
dataset$gripsZ = scale(dataset$idxPIT)
dataset$likZ= scale(dataset$idxLIK)
#HED$famZ = scale(bsHED$perceived_familiarity)
#HED$likZZ = scale(bsHED$perceived_likZensity)

plot(density(dataset$gripsZ))
plot(density(dataset$likZ))

library(moments)
skewness(dataset$gripsZ, na.rm = TRUE)

plot(density(dataset$idxPIT))

t_log_scale <- function(x){
  if(x==0){
    y <- 1
  } else {
    y <- (sign(x)) * (log(abs(x)))
  }
  y 
}

plot(density(sapply(dataset$idxPIT,FUN=t_log_scale)))


dataset$gripsT <- sapply(dataset$idxPIT,FUN=t_log_scale)
skewness(dataset$gripsT, na.rm = TRUE)
skewness(dataset$likZ, na.rm = TRUE)


# STATS --------------------------------------------------------------

par = summary(lm(dataset$gripsT~dataset$likZ))
p_par = par$coefficients[8]

rob = rlm(dataset$gripsT~dataset$likZ)
rsq = summary(lmRob(dataset$gripsT~dataset$likZ))$r.squared
# .rsq <- 1 - (1 - rsq) * ((n - 1)/(n-k-1))

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par

p_rob

#weights

dataset$weights = weights
dataset$weights = I(dataset$weights)

# PLOT likZ RLM

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

A1 <- ggplot(dataset, aes(likZ, gripsT)) + #A2
  geom_point(aes(alpha=dataset$weights)) +
  geom_smooth(method = "rlm", col = "orange", fullrange = F) +
  #labs(subtitle = paste("Adj R2 = ",signif(summary(lm(dataset$gripsZ~dataset$likZ))$adj.r.squared, 3),   "  &  P =", round(p, 4)))+
  #"likZercept =",signif(fit$coef[[1]],5 ),
  #" Slope =",signif(fit$coef[[2]], 5),
  scale_x_continuous(name="liking Index", expand = c(0, 0), limits=c(-2, 3.0), breaks=c(seq.int(-2,3, by = 1))) +
  scale_y_continuous(expression(paste("PIT index")), expand = c(0, 0), limits=c(-1, 2), breaks=c(seq.int(-1,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)+
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

A1


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_1 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))



figure5 <- ggarrange(A1,A2,A3,A4,
                     labels = c( " A",   " B"   ,  " C", " D"  ),
                     ncol = 2, nrow = 2,
                     vjust=2, hjust=0) 

figure5 # pirif
