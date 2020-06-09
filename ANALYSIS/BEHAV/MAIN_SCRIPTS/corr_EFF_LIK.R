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
HED_full <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset
INST_full <- read.delim(file.path(analysis_path,'OBIWAN_INST.txt'), header = T, sep ='') # read in dataset
info <- read.delim(file.path(analysis_path,'info_expe.txt'), header = T, sep ='') # read in dataset

#merge with info
HED = merge(HED_full, info, by = "id")
INST = merge(INST_full, info, by = "id")

HED  <- subset(HED, group == 'obese' & condition == 'MilkShake') #only group obese 
INST  <- subset(INST, group == 'obese') #only group obese 

HED$time = revalue(HED$session, c(second="0", third="1"))
INST$time = revalue(INST$session, c(second="0", third="1"))

bsINST = ddply(INST, .(id,intervention, time), summarise, grips = mean(grips, na.rm = TRUE))
bsHED = ddply(HED, .(id,intervention, time), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 


source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/LMER_misc_tools.R') #useful functions from Ben Meulman

dataset = merge(bsINST, bsHED, by = c("id", "time", "intervention"), all.x = FALSE)
dataset  <- subset(dataset, id != 242 & id != 256 & id != 234) #234 only have third session
dataset$id      <- as.factor(dataset$id)

dataset  <- subset(dataset, time =='0') 

#scale everything
dataset$gripsZ = scale(dataset$grips)
dataset$likZ= scale(dataset$perceived_liking)
#HED$famZ = scale(bsHED$perceived_familiarity)
#HED$likZZ = scale(bsHED$perceived_likZensity)

plot(density(dataset$gripsZ))
plot(density(dataset$likZ))


#quick stats

cor.test(dataset$grips, dataset$likZ, method="pearson")


# 
# library(moments)
# skewness(dataset$gripsZ, na.rm = TRUE)
# 
# plot(density(dataset$idxINST))
# 
# t_log_scale <- function(x){
#   if(x==0){
#     y <- 1
#   } else {
#     y <- (sign(x)) * (log(abs(x)))
#   }
#   y 
# }
# 
# plot(density(sapply(dataset$idxINST,FUN=t_log_scale)))
# dataset$gripsZ <- sapply(dataset$idxINST,FUN=t_log_scale)
# skewness(dataset$gripsZ, na.rm = TRUE)
# skewness(dataset$likZ, na.rm = TRUE)


# STATS --------------------------------------------------------------

par = summary(lm(dataset$gripsZ~dataset$likZ))
p_par = par$coefficients[8]

rob = rlm(dataset$gripsZ~dataset$likZ)
rsq = summary(lmRob(dataset$gripsZ~dataset$likZ))$r.squared
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

A1 <- ggplot(dataset, aes(likZ, gripsZ)) + #A2
  geom_point(aes(alpha=dataset$weights)) +
  geom_smooth(method = "rlm", col = "orange", fullrange = F) +
  #labs(subtitle = paste("Adj R2 = ",signif(summary(lm(dataset$gripsZ~dataset$likZ))$adj.r.squared, 3),   "  &  P =", round(p, 4)))+
  #"likZercept =",signif(fit$coef[[1]],5 ),
  #" Slope =",signif(fit$coef[[2]], 5),
  scale_x_continuous(name="liking Index", expand = c(0, 0), limits=c(-2, 3.0), breaks=c(seq.int(-2,3, by = 1))) +
  scale_y_continuous(expression(paste("INST index")), expand = c(0, 0), limits=c(-1, 2), breaks=c(seq.int(-1,2, by = 0.5))) +
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
