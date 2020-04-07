## R code for FOR REWOD GENERAL
# last modified on August 2019 by David




# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(robust, permuco, MASS, ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, mosaic, psychometric, mosaic, grid)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

#SETUP
task = 'PIT'
con_name1 = 'CSp_CSm'
con_name2 = 'R_NoR'

con1 = 'CSp-CSm'
con2 = 'Reward_NoReward'

mod1 = 'eff'
mod2 = 'lik'

k = 2
n = 24


#

## R code for FOR REWOD_HED
# Set working directory -------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS', task) 
setwd(analysis_path)

# open dataset 
BETAS_CSp <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name1,'.txt',sep="")), header = T, sep ='\t') # read in dataset


EFF_CSp <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste(con1,'_', mod1, '_rank.txt',sep="")), header = T, sep ='\t') # read in dataset


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS/hedonic') 

BETAS_R_NoR <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name2, '_via_', con_name1, '.txt',sep="")), header = T, sep ='\t') # read in dataset
LIK_CSp    <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste(con2,'_', mod2, '_rank.txt',sep="")), header = T, sep ='\t') # read in dataset


# merge
R_NoR_df = merge(BETAS_R_NoR, LIK_CSp, by.x = "ID", by.y = "subj", all.x = TRUE)
#CSp_CSp = merge(CSp_CSp, INT_CSp, by.x = "ID", by.y = "subj", all.x = TRUE)

CSp_df = merge(BETAS_CSp, EFF_CSp, by.x = "ID", by.y = "subj", all.x = TRUE)



# define factors
CSp_df$ID <- factor(CSp_df$ID)
R_NoR_df$ID <- factor(R_NoR_df$ID)
#CSp_CSp$ID <- factor(CSp_CSp$ID)



# PLOT FUNCTIONS --------------------------------------------------------------------


ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "blue") +
    labs(title = paste(" R2 = ",signif(summary(fit)$r.squared, 5),
                       #"Intercept =",signif(fit$coef[[1]],5 ),
                       #" Slope =",signif(fit$coef[[2]], 5),
                       "  &  P =",signif(summary(fit)$coef[2,4], 5)))+
    theme(plot.title = element_text(size = 10, hjust =1))
  
}




#  Plot for CSp  ----------------------------------------------------------
#CSp_df <- filter(CSp_df, ID != "6")  ## outlier
# For effort

eff = CSp_df$eff
eff = zscore(eff)
CSp_df$eff = zscore(eff)
A1 <- ggplotRegression(lm(CSp_df[[2]]~eff)) + rremove("x.title")
A2 <- ggplotRegression(lm(CSp_df[[3]]~eff)) + rremove("x.title")
A3 <- ggplotRegression(lm(CSp_df[[5]]~eff)) + rremove("x.title")
A4 <- ggplotRegression(lm(CSp_df[[6]]~eff)) + rremove("x.title")
A5 <- ggplotRegression(lm(R_NoR_df[[3]]~R_NoR_df$lik)) + rremove("x.title")
A6 <- ggplotRegression(lm(R_NoR_df[[4]]~R_NoR_df$lik)) + rremove("x.title")
A7 <- ggplotRegression(lm(R_NoR_df[[5]]~R_NoR_df$lik)) + rremove("x.title")
A8 <- ggplotRegression(lm(R_NoR_df[[6]]~R_NoR_df$lik)) + rremove("x.title")


figure1 <- ggarrange(A1,A2,A3,A4,
                     labels = c( "LEFT_BLVP_betas",   "cluster_BLVP_L_betas"   ,  "cluster_core_right_betas", "pcore_RIGHT_betas"  ),
                     ncol = 2, nrow = 2,
                     vjust=3, hjust=0) 

figure2 <- ggarrange(A5,A6, A7, A8, 
                     labels = c( "LEFT_BLVP_LIK"    ,      "cluster_BLVP_L_LIK"   ,  "cluster_core_right_LIK", "pcore_RIGHT_LIK"  ),
                     ncol = 2, nrow = 2,
                     vjust=3, hjust=0) 

figure <- annotate_figure(figure1,
                           top = text_grob("Coeficient of determination: CSp for EFFORT", color = "black", face = "bold", size = 14),
                           bottom = "Figure 1", fig.lab.face = "bold")
#figure




# STATS BLVP ---------------------------------------------------------------
perm = summary(lmperm(CSp_df$LEFT_BLVP_betas~CSp_df$eff))
p_par = perm$`parametric Pr(>|t|)`[2]
p_per = perm$`permutation Pr(>|t|)`[2]
rob = rlm(CSp_df$LEFT_BLVP_betas~CSp_df$eff)
rsq = signif(summary(lmRob(CSp_df$LEFT_BLVP_betas~CSp_df$eff))$r.squared,2)

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par
p_per
p_rob


CSp_df$BLVP_weights = weights^3
CSp_df$BLVP_weights = I(CSp_df$BLVP_weights)



# check = lmRob(CSp_df$LEFT_BLVP_betas~CSp_df$eff)
# summary(check)  #this one is not conservator at all it just leaves out the points



# PLOT BLVP rlm---------------------------------------------------------------
grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P1 <- ggplot(CSp_df, aes(eff, LEFT_BLVP_betas)) + #A2
  geom_point(aes(alpha=CSp_df$BLVP_weights)) +
  geom_smooth(method = "rlm",  col = "green") +
  #geom_smooth(lm(CSp_df$LEFT_BLVP_betas~CSp_df$eff, w = 1/CSp_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Pavlovian-Instrumental index", expand = c(0, 0), limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1)))  +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.3, 0.4), breaks=c(seq.int(-0.5,0.4, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)





P1




CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_1 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", signif(p_rob, 5))



#  PLOT norlm lm BLVP----------------------------------------------------------------

# _R2_ 
rsq =summary(lm(CSp_df$LEFT_BLVP_betas~eff))$r.squared

grob0 <- grobTree(textGrob("LS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P2 <- ggplot(CSp_df, aes(eff, LEFT_BLVP_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "green") +
  #geom_smooth(lm(CSp_df$LEFT_BLVP_betas~CSp_df$eff, w = 1/CSp_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Pavlovian-Instrumental Index", expand = c(0, 0), limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1)))  +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.3, 0.4), breaks=c(seq.int(-0.5,0.4, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left pcore ~ effort



P2



CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_2 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", signif(p_par, 5))






# STATS pCORE -------------------------------------------------------------

perm = summary(lmperm(CSp_df$pcore_RIGHT_betas~CSp_df$eff))
p_par = perm$`parametric Pr(>|t|)`[2]
p_per = perm$`permutation Pr(>|t|)`[2]
rob = rlm(CSp_df$pcore_RIGHT_betas~CSp_df$eff)
rsq = summary(lmRob(CSp_df$pcore_RIGHT_betas~CSp_df$eff))$r.squared

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))

#robuste changes everyhting
p_par
p_per
p_rob


CSp_df$pcore_weights = weights^2
CSp_df$pcore_weights = I(CSp_df$pcore_weights)

# check = lmRob(CSp_df$pcore_RIGHT_betas~CSp_df$eff)
# summary(check)  #this one is not conservator at all it just leaves out the points BAAD robustness


# PLOT Pcore RLM ----------------------------------------------------------

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))


#RLM
P3 <- ggplot(CSp_df, aes(eff, pcore_RIGHT_betas)) + #A2
  geom_point(aes(alpha = CSp_df$pcore_weights)) +
  geom_smooth(method = "rlm",  col = "green") +
  scale_x_continuous(name="Pavlovian-Instrumental Index", expand = c(0, 0),limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1)))  +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.3, 0.4), breaks=c(seq.int(-0.5,0.4, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)



#anatomicaly defined left pcore ~ effort

P3



CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_3 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", signif(p_rob, 5))




# PLOT norm pcore --------


# _R2_ 
rsq =summary(lm(CSp_df$pcore_RIGHT_betas~eff))$r.squared

grob0 <- grobTree(textGrob("LS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))


P4 <- ggplot(CSp_df, aes(eff, pcore_RIGHT_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "green") +
  scale_x_continuous(name="Pavlovian-Instrumental Index", expand = c(0, 0), limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1)))  +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.3, 0.4), breaks=c(seq.int(-0.5,0.4, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)
#anatomicaly defined left pcore ~ effort


P4



CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_4 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", signif(p_par, 5))



# LIKING ________________ NOW --------------------------------------------------------------
lik = R_NoR_df$lik
lik = zscore(lik)
R_NoR_df$lik = zscore(lik)


# STATS BLVP LIK--------------------------------------------------------------

par = summary(lm(R_NoR_df$LEFT_BLVP_betas~R_NoR_df$lik))
p_par = par$coefficients[8]
rob = rlm(R_NoR_df$LEFT_BLVP_betas~R_NoR_df$lik)
rsq = summary(lmRob(R_NoR_df$LEFT_BLVP_betas~R_NoR_df$lik))$r.squared

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*pt(t, df)
# kind of similar 
p_par

p_rob

#weights

R_NoR_df$BLVP_weights = weights
R_NoR_df$BLVP_weights = I(R_NoR_df$BLVP_weights)


# check = lmRob(R_NoR_df$LEFT_BLVP_betas~R_NoR_df$lik)
# summary(check)  #this one is not conservator at all it just leaves out the points



# PLOT BLVP LIK RLM -----------------------------------------------------------

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P5 <- ggplot(R_NoR_df, aes(lik, LEFT_BLVP_betas)) + #A2
  geom_point(aes(alpha=R_NoR_df$BLVP_weights)) +
  geom_smooth(method = "rlm",  col = "blue") +
  #geom_smooth(lm(R_NoR_df$LEFT_BLVP_betas~R_NoR_df$lik, w = 1/R_NoR_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Pleasantness Index", expand = c(0, 0),limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1)))  +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-1.5, 1.5), breaks=c(seq.int(-1.5,1.5, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left BLVP ~ likort

P5




CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_5 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", signif(p_rob, 5))

# PLOT BLVP LIK norm -----------------------------------------------------------


#_R2_ 
rsq =summary(lm(R_NoR_df$LEFT_BLVP_betas~lik))$r.squared

grob0 <- grobTree(textGrob("LS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P6 <- ggplot(R_NoR_df, aes(lik, LEFT_BLVP_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "blue") +
  #geom_smooth(lm(R_NoR_df$LEFT_BLVP_betas~R_NoR_df$lik, w = 1/R_NoR_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Pleasantness Index", expand = c(0, 0),limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1)))  +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-1.5, 1.5), breaks=c(seq.int(-1.5,1.5, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)


#anatomicaly defined left BLVP ~ likort

P6


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_6 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", signif(p_par, 5))


# STATS pcor LIK--------------------------------------------------------------

par = summary(lm(R_NoR_df$pcore_RIGHT_betas~R_NoR_df$lik))
p_par = par$coefficients[8]


rob = rlm(R_NoR_df$pcore_RIGHT_betas~R_NoR_df$lik)
rsq = summary(lmRob(R_NoR_df$pcore_RIGHT_betas~R_NoR_df$lik))$r.squared

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par

p_rob

#weights


R_NoR_df$pcore_weights = weights
R_NoR_df$pcore_weights = I(R_NoR_df$pcore_weights)
# check = lmRob(R_NoR_df$pcore_RIGHT_betas~R_NoR_df$lik)
# summary(check)  #this one is not conservator at all it just leaves out the points

# PLOT pCore LIK -----------------------------------------------------------

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))


P7 <- ggplot(R_NoR_df, aes(lik, pcore_RIGHT_betas)) + #A2
  geom_point(aes(alpha=R_NoR_df$pcore_weights)) +
  geom_smooth(method = "rlm",  col = "blue") +
  #geom_smooth(lm(R_NoR_df$pcore_RIGHT_betas~R_NoR_df$lik, w = 1/R_NoR_df$pcore_RIGHT_betas^2)
  scale_x_continuous(name="Pleasantness Index", expand = c(0, 0), limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1)))  +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-1.5, 2), breaks=c(seq.int(-1.5,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left pcore ~ likort


P7


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_7 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", signif(p_rob, 5))


# PLOT pCore LIK REG -----------------------------------------------------------


# _R2_ 
rsq =summary(lm(R_NoR_df$pcore_RIGHT_betas~lik))$r.squared

CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_8 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", signif(p_par, 2))

# Create a text
grob0 <- grobTree(textGrob("LS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P8 <- ggplot(R_NoR_df, aes(lik, pcore_RIGHT_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "blue") +
  #geom_smooth(lm(R_NoR_df$pcore_RIGHT_betas~R_NoR_df$lik, w = 1/R_NoR_df$pcore_RIGHT_betas^2)
  scale_x_continuous(name="Pleasantness Index", expand = c(0, 0), limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1)))  +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-1.5, 2), breaks=c(seq.int(-1.5,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

P8
#anatomicaly defined left pcore ~ lik




# FINAL FIGURES -----------------------------------------------------------



stat_1   #blvp eff- rob
stat_2    #blvp eff
stat_5   #blvp lik _ rob
stat_6   #blvp lik


stat_3    #pcore - eff _ rob
stat_4    #pcore -eff
stat_7   #pcore_lik _rob
stat_8  #pcore



figure9 <- ggarrange(P1,P2,P5,P6,
                     labels = c( " A",   " B"   ,  " C", " D"  ),
                     ncol = 2, nrow = 2,
                     vjust=2, hjust=0) 

figure9 # BLVP


figure10 <- ggarrange(P3,P4,P7,P8,
                     labels = c( " A",   " B"   ,  " C", " D"  ),
                     ncol = 2, nrow = 2,
                     vjust=2, hjust=0) 

figure10 # pcore






