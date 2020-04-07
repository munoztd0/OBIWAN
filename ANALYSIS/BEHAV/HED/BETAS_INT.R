## R code for FOR REWOD GENERAL
# last modified on August 2019 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(robust, permuco, MASS, ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, mosaic, psychometric)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


#SETUP
taskHED = 'hedonic'
taskPIT = 'PIT'
con_name = 'AMY'
con_name2 = 'Od_NoOd'
con1 = 'CSp-CSm'
con2 = 'Odor-NoOdor'
mod1 = 'eff'
mod2 = 'int'
mod3 = 'lik'


k = 2
n = 24




## R code for FOR REWOD_HED
# Set working directory -------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS') 
setwd(analysis_path)

# open dataset 
BETAS_O_N <- read.delim(file.path(analysis_path, taskHED, 'ROI', paste('extracted_betas_',con_name2,'.txt',sep="")), header = T, sep ='\t') # read in dataset

INT_O_N <- read.delim(file.path(analysis_path, taskHED, 'GLM-04', 'group_covariates', paste(con2,'_', mod2, '_meancent.txt',sep="")), header = T, sep ='\t')  # read in dataset

LIK_O_N <- read.delim(file.path(analysis_path, taskHED, 'GLM-04', 'group_covariates', paste(con2,'_', mod3, '_meancent.txt',sep="")), header = T, sep ='\t')  # read in dataset



O_N_df = merge(BETAS_O_N, INT_O_N, by.x = "ID", by.y = "subj", all.x = TRUE)
O_N_df = merge(O_N_df, LIK_O_N, by.x = "ID", by.y = "subj", all.x = TRUE)

# define factors
O_N_df$ID <- factor(O_N_df$ID)




# # open dataset 
# BETAS_CSp_CSm <- read.delim(file.path(analysis_path, taskPIT, 'ROI', paste('extracted_betas_',con_name,'.txt',sep="")), header = T, sep ='\t') # read in dataset
# 
# EFF <- read.delim(file.path(analysis_path, taskPIT, 'GLM-04', 'group_covariates', paste(con1,'_', mod1, '_rank.txt',sep="")), header = T, sep ='\t') # read in dataset
# 
# 
# # merge
# CSp_CSm_df = merge(BETAS_CSp_CSm, EFF, by.x = "ID", by.y = "subj", all.x = TRUE)
# 
# 
# # define factors
# CSp_CSm_df$ID <- factor(CSp_CSm_df$ID)
# 
# # zscore
# CSp_CSm_df$eff = zscore(CSp_CSm_df$eff)

O_N_df$int = zscore(O_N_df$int )
O_N_df$lik = zscore(O_N_df$lik )




# signif ------------------------------------------------------------------


# INTEN ________________ NOW --------------------------------------------------------------
int = O_N_df$int
int = zscore(int)
O_N_df$int = zscore(int)


# STATS cm_OFC int--------------------------------------------------------------

par = summary(lm(O_N_df$AMY_AAA_betas~O_N_df$int))
p_par = par$coefficients[8]

rob = rlm(O_N_df$AMY_AAA_betas~O_N_df$int)
rsq = summary(lmRob(O_N_df$AMY_AAA_betas~O_N_df$int))$r.squared
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

O_N_df$AMY_weights = weights
O_N_df$AMY_weights = I(O_N_df$AMY_weights)

# PLOT INT RLM

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

A1 <- ggplot(O_N_df, aes(int, AMY_AAA_betas)) + #A2
  geom_point(aes(alpha=O_N_df$AMY_weights)) +
  geom_smooth(method = "rlm", col = "orange", fullrange = F) +
  #labs(subtitle = paste("Adj R2 = ",signif(summary(lm(O_N_df$AMY_AAA_betas~O_N_df$int))$adj.r.squared, 3),   "  &  P =", round(p, 4)))+
  #"Intercept =",signif(fit$coef[[1]],5 ),
  #" Slope =",signif(fit$coef[[2]], 5),
  scale_x_continuous(name="Intensity Index", expand = c(0, 0), limits=c(-2, 3.0), breaks=c(seq.int(-2,3, by = 1))) +
  scale_y_continuous(expression(paste(beta, "  Odor > No Odor")), expand = c(0, 0), limits=c(-1, 2), breaks=c(seq.int(-1,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)+
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

A1


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_1 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))


# plot INT LM


#  _R2_ 
rsq =summary(lm(O_N_df$AMY_AAA_betas~int))$r.squared

grob0 <- grobTree(textGrob("LS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

A2 <- ggplot(O_N_df, aes(int, AMY_AAA_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm", col = "orange", fullrange = F) +
  #labs(subtitle = paste("Adj R2 = ",signif(summary(lm(O_N_df$AMY_AAA_betas~O_N_df$int))$adj.r.squared, 3),   "  &  P =", round(p, 4)))+
  #"Intercept =",signif(fit$coef[[1]],5 ),
  #" Slope =",signif(fit$coef[[2]], 5),
  scale_x_continuous(name="Intensity Index", expand = c(0, 0), limits=c(-2, 3.0), breaks=c(seq.int(-2,3, by = 1))) +
  scale_y_continuous(expression(paste(beta, "  Odor > No Odor")), expand = c(0, 0), limits=c(-1, 2), breaks=c(seq.int(-1,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)+
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

A2


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_2 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))




# LIKING ________________ NOW --------------------------------------------------------------
lik = O_N_df$lik
lik = zscore(lik)
O_N_df$lik = zscore(lik)


# STATS cm_OFC lik--------------------------------------------------------------

par = summary(lm(O_N_df$AMY_AAA_betas~O_N_df$lik))
p_par = par$coefficients[8]

rob = rlm(O_N_df$AMY_AAA_betas~O_N_df$lik)
rsq = summary(lmRob(O_N_df$AMY_AAA_betas~O_N_df$lik))$r.squared
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

O_N_df$AMY2_weights = weights
O_N_df$AMY2_weights = I(O_N_df$AMY_weights)

# PLOT lik RLM

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

A3 <- ggplot(O_N_df, aes(lik, AMY_AAA_betas)) + #A2
  geom_point(aes(alpha=O_N_df$AMY2_weights)) +
  geom_smooth(method = "rlm", col = "blue", fullrange = F) +
  #labs(subtitle = paste("Adj R2 = ",signif(summary(lm(O_N_df$AMY_AAA_betas~O_N_df$lik))$adj.r.squared, 3),   "  &  P =", round(p, 4)))+
  #"likercept =",signif(fit$coef[[1]],5 ),
  #" Slope =",signif(fit$coef[[2]], 5),
  scale_x_continuous(name="Plesantness Index", expand = c(0, 0), limits=c(-2.4, 3.0), breaks=c(seq.int(-2,3, by = 1))) +
  scale_y_continuous(expression(paste(beta, "  Odor > No Odor")), expand = c(0, 0), limits=c(-1, 2), breaks=c(seq.int(-1,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)+
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

A3


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_3 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))


# plot lik LM


#  _R2_ 
rsq =summary(lm(O_N_df$AMY_AAA_betas~lik))$r.squared

grob0 <- grobTree(textGrob("LS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

A4 <- ggplot(O_N_df, aes(lik, AMY_AAA_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm", col = "blue", fullrange = F) +
  #labs(subtitle = paste("Adj R2 = ",signif(summary(lm(O_N_df$AMY_AAA_betas~O_N_df$lik))$adj.r.squared, 3),   "  &  P =", round(p, 4)))+
  #"likercept =",signif(fit$coef[[1]],5 ),
  #" Slope =",signif(fit$coef[[2]], 5),
  scale_x_continuous(name="Plesantness Index", expand = c(0, 0), limits=c(-2.4, 3.0), breaks=c(seq.int(-2,3, by = 1))) +
  scale_y_continuous(expression(paste(beta, "  Odor > No Odor")), expand = c(0, 0), limits=c(-1, 2), breaks=c(seq.int(-1,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)+
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

A4

CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_4 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))



###########################


stat_1
stat_2
stat_3
stat_4


figure5 <- ggarrange(A1,A2,A3,A4,
                     labels = c( " A",   " B"   ,  " C", " D"  ),
                     ncol = 2, nrow = 2,
                     vjust=2, hjust=0) 

figure5 # pirif
