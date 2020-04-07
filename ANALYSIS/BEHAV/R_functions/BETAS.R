## R code for FOR REWOD GENERAL
# last modified on August 2019 by David

# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, mosaic)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

#SETUP
task = 'hedonic'
con_name2 = 'R_N'
con2 = 'reward-neutral'
mod1 = 'lik'
mod2 = 'int'

conEFF = 'CSp_CSm'


## R code for FOR REWOD_HED
# Set working directory -------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS', task) 
setwd(analysis_path)

# open dataset 
BETAS_R_N <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name2,'.txt',sep="")), header = T, sep ='\t') # read in dataset
BETAS_R_N_CSp <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name2, '_via_', conEFF, '.txt',sep="")), header = T, sep ='\t') # read in dataset


LIK_R_N <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste(con2,'_', mod1, '_meancent.txt',sep="")), header = T, sep ='\t') # read in dataset

INT_R_N <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste(con2,'_', mod2, '_meancent.txt',sep="")), header = T, sep ='\t')  # read in dataset


# merge
R_N_CSp = merge(BETAS_R_N_CSp, LIK_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)
R_N_CSp = merge(R_N_CSp, INT_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)

R_N_df = merge(BETAS_R_N, LIK_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)
R_N_df = merge(R_N_df, INT_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)


# define factors
R_N_df$ID <- factor(R_N_df$ID)
R_N_CSp$ID <- factor(R_N_CSp$ID)



# PLOT FUNCTIONS --------------------------------------------------------------------


ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                       #"Intercept =",signif(fit$coef[[1]],5 ),
                       #" Slope =",signif(fit$coef[[2]], 5),
                       "  &  P =",signif(summary(fit)$coef[2,4], 5)))+
    theme(plot.title = element_text(size = 10, hjust =1))
  
}




#  Plot for R_N  ----------------------------------------------------------

# For liking

lik = R_N_df$lik
lik = zscore(lik)
A1 <- ggplotRegression(lm(R_N_df[[2]]~lik)) + rremove("x.title")
B1 <- ggplotRegression(lm(R_N_df[[3]]~lik)) + rremove("x.title")
C1 <- ggplotRegression(lm(R_N_df[[4]]~lik)) + rremove("x.title")
D1 <- ggplotRegression(lm(R_N_df[[5]]~lik)) + rremove("x.title")


figure1 <- ggarrange(A1,B1,C1,D1,
                     labels = c("A: AMY_BLA_L", "B: AMY_full_L", "C: CAUD_VENTR_L", "D: PUT_L"),
                     ncol = 2, nrow = 2,
                     vjust=3, hjust=0) 

figure1 <- annotate_figure(figure1,
                           top = text_grob("Coeficient of determination: REWARD-NEUTRAL for LIKING", color = "black", face = "bold", size = 14),
                           bottom = "Figure 1", fig.lab.face = "bold")

pdf('~/REWOD/DERIVATIVES/BEHAV/HED/R_N_lik_coeff.pdf')
plot(figure1)
dev.off()



# For intensity

int = R_N_df$int
int = zscore(int)
A2 <- ggplotRegression(lm(R_N_df[[2]]~int)) + rremove("x.title")
B2 <- ggplotRegression(lm(R_N_df[[3]]~int)) + rremove("x.title")
C2 <- ggplotRegression(lm(R_N_df[[4]]~int)) + rremove("x.title")
D2 <- ggplotRegression(lm(R_N_df[[5]]~int)) + rremove("x.title")


figure2 <- ggarrange(A2,B2,C2,D2,
                     labels = c("A: AMY_BLA_L", "B: AMY_full_L", "C: CAUD_VENTR_L", "D: PUT_L"),
                     vjust=3, hjust=0,
                     ncol = 2, nrow = 2)

figure2 <- annotate_figure(figure2,
                           top = text_grob("Coeficient of determination: REWARD-NEUTRAL for INTENSITY", color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")

pdf('~/REWOD/DERIVATIVES/BEHAV/HED/R_N_int_coeff.pdf')
plot(figure2)
dev.off()


#  Plot for R_N_CSp  ----------------------------------------------------------

# For liking

lik = R_N_CSp$lik
lik = zscore(lik)
A3 <- ggplotRegression(lm(R_N_CSp[[2]]~lik)) + rremove("x.title")
B3 <- ggplotRegression(lm(R_N_CSp[[3]]~lik)) + rremove("x.title")
C3 <- ggplotRegression(lm(R_N_CSp[[4]]~lik)) + rremove("x.title")
D3 <- ggplotRegression(lm(R_N_CSp[[5]]~lik)) + rremove("x.title")
E3 <- ggplotRegression(lm(R_N_CSp[[6]]~lik)) + rremove("x.title")
F3 <- ggplotRegression(lm(R_N_CSp[[8]]~lik)) + rremove("x.title")


figure3 <- ggarrange(A3,B3,C3,D3,E3,F3,
                     labels = c("A: AMY_BM_L", "B: AMY_full_L","C: CAUD_ANT_R", "D: CAUD_VENTR_L", "E: CAUD_VENTR_R", "F: NACC_R"),
                     ncol = 2, nrow = 3,
                     vjust=3, hjust=0) 

figure3 <- annotate_figure(figure3,
                           top = text_grob("Coeficient of determination: REWARD-NEUTRAL from CSp-CSm ROIs for LIKING", color = "black", face = "bold", size = 14),
                           bottom = "Figure 1", fig.lab.face = "bold")

pdf('~/REWOD/DERIVATIVES/BEHAV/HED/R_N_CSpROIs_lik_coeff.pdf')
plot(figure3)
dev.off()



# For intensity

int = R_N_CSp$int
int = zscore(int)
A4 <- ggplotRegression(lm(R_N_CSp[[2]]~int)) + rremove("x.title")
B4 <- ggplotRegression(lm(R_N_CSp[[3]]~int)) + rremove("x.title")
C4 <- ggplotRegression(lm(R_N_CSp[[4]]~int)) + rremove("x.title")
D4 <- ggplotRegression(lm(R_N_CSp[[5]]~int)) + rremove("x.title")
E4 <- ggplotRegression(lm(R_N_CSp[[6]]~int)) + rremove("x.title")
F4 <- ggplotRegression(lm(R_N_CSp[[8]]~int)) + rremove("x.title")


figure4 <- ggarrange(A4,B4,C4,D4,E4,F4,
                     labels = c("A: AMY_BM_L", "B: AMY_full_L","C: CAUD_ANT_R", "D: CAUD_VENTR_L", "E: CAUD_VENTR_R", "F: NACC_R"),
                     ncol = 2, nrow = 3,
                     vjust=3, hjust=0) 

figure4 <- annotate_figure(figure4,
                           top = text_grob("Coeficient of determination: REWARD-NEUTRAL from CSp-CSm ROIs for INTENSITY", color = "black", face = "bold", size = 14),
                           bottom = "Figure 1", fig.lab.face = "bold")

pdf('~/REWOD/DERIVATIVES/BEHAV/HED/R_N_CSpROIs_int_coeff.pdf')
plot(figure4)
dev.off()





# CORRELATIONS R_N ------------------------------------------------------

corr_R_N.rcorr = rcorr(as.matrix(R_N_df))
corr_R_N.coeff = corr_R_N.rcorr$r[2:5,8:10]
corr_R_N.p = corr_R_N.rcorr$P[2:5,8:10]

col3 <- colorRampPalette(c("blue", "white", "red")) 
# PLOT CORR

pdf('~/REWOD/DERIVATIVES/BEHAV/HED/R_N_corrplot.pdf')
corrplot(corr_R_N.coeff , method = "circle",tl.col = "black", tl.srt = 45, col = col3(20))
dev.off()

# CORRELATIONS R_N ------------------------------------------------------

# corr_R_N.rcorr = rcorr(as.matrix(R_N_CSp))
# corr_R_N.coeff = corr_R_N.rcorr$r[2:5,8:10]
# corr_R_N.p = corr_R_N.rcorr$P[2:5,8:10]
# 
# col3 <- colorRampPalette(c("blue", "white", "red")) 
# # PLOT CORR
# 
# pdf('~/REWOD/DERIVATIVES/BEHAV/HED/R_N_corrplot.pdf')
# corrplot(corr_R_N.coeff , method = "circle",tl.col = "black", tl.srt = 45, col = col3(20))
# dev.off()



# PIT ---------------------------------------------------------------------

#clean start
#remove(list = ls())
## R code for FOR REWOD_PIT


#SETUP
task = 'PIT'
con_name1 = 'CSp_CSm'

con1 = 'CSp-CSm'

mod1 = 'eff'

conHED = 'R_N'




# Set working directory ---------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS', task) 
setwd(analysis_path)

# open dataset 
BETAS_CSp_CSm <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name1,'.txt',sep="")), header = T, sep ='\t') # read in dataset
BETAS_CSp_CSm_RN <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name1,'_via_', conHED,'.txt',sep="")), header = T, sep ='\t') # read in dataset

EFF <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste(con1,'_', mod1, '_rank.txt',sep="")), header = T, sep ='\t') # read in dataset


# merge
CSp_CSm_RN = merge(BETAS_CSp_CSm_RN, EFF, by.x = "ID", by.y = "subj", all.x = TRUE)
CSp_CSm_RN = merge(CSp_CSm_RN, LIK_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)
CSp_CSm_RN = merge(CSp_CSm_RN, INT_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)

# merge
CSp_CSm_df = merge(BETAS_CSp_CSm, EFF, by.x = "ID", by.y = "subj", all.x = TRUE)
CSp_CSm_df = merge(CSp_CSm_df, LIK_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)
CSp_CSm_df = merge(CSp_CSm_df, INT_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)

# define factors
CSp_CSm_RN$ID <- factor(CSp_CSm_RN$ID)
CSp_CSm_df$ID <- factor(CSp_CSm_df$ID)


# Plot CSp_CSm  -----------------------------------------------------------

# For effort

eff = CSp_CSm_df$eff
eff = zscore(eff)
A5  <- ggplotRegression(lm(CSp_CSm_df[[2]]~eff)) + rremove("x.title")
B5  <- ggplotRegression(lm(CSp_CSm_df[[3]]~eff)) + rremove("x.title")
C5  <- ggplotRegression(lm(CSp_CSm_df[[4]]~eff)) + rremove("x.title")
D5  <- ggplotRegression(lm(CSp_CSm_df[[5]]~eff)) + rremove("x.title")
E5  <- ggplotRegression(lm(CSp_CSm_df[[6]]~eff)) + rremove("x.title")
F5  <- ggplotRegression(lm(CSp_CSm_df[[8]]~eff)) + rremove("x.title")


figure5 <- ggarrange(A5,B5,C5,D5,E5,F5,
                     labels = c("A: AMY_BM_L", "B: AMY_full_L","C: CAUD_ANT_R", "D: CAUD_VENTR_L", "E: CAUD_VENTR_R", "F: NACC_R"),
                     ncol = 2, nrow = 3,
                     vjust=3, hjust=0) 

figure5 <- annotate_figure(figure5,
                           top = text_grob("Coeficient of determination: CSp - CSm for EFFORT", color = "black", face = "bold", size = 14),
                           bottom = "Figure 5", fig.lab.face = "bold")

pdf('~/REWOD/DERIVATIVES/BEHAV/PIT/CSp_CSm_eff_coeff.pdf')
plot(figure5)
dev.off()


# Plot CSp_CSm_RN  -----------------------------------------------------------

# For effort

eff = CSp_CSm_RN$eff
eff = zscore(eff)
A6  <- ggplotRegression(lm(CSp_CSm_RN[[2]]~eff)) + rremove("x.title")
B6  <- ggplotRegression(lm(CSp_CSm_RN[[3]]~eff)) + rremove("x.title")
C6  <- ggplotRegression(lm(CSp_CSm_RN[[4]]~eff)) + rremove("x.title")
D6  <- ggplotRegression(lm(CSp_CSm_RN[[5]]~eff)) + rremove("x.title")



figure6 <- ggarrange(A6,B6,C6,D6,
                     labels = c("A: AMY_BLA_L", "B: AMY_full_L", "C: CAUD_VENTR_L", "D: PUT_L"),
                     ncol = 2, nrow = 2,
                     vjust=3, hjust=0) 

figure6 <- annotate_figure(figure6,
                           top = text_grob("Coeficient of determination: CSp - CSm from R-N ROIs for EFFORT", color = "black", face = "bold", size = 14),
                           bottom = "Figure 6", fig.lab.face = "bold")

pdf('~/REWOD/DERIVATIVES/BEHAV/PIT/CSp_CSm_RNROIs_eff_coeff.pdf')
plot(figure6)
dev.off()





# CORRELATIONS ------------------------------------------------------------


# corr_CSp_CSm.rcorr = rcorr(as.matrix(CSp_CSm_df))
# corr_CSp_CSm.coeff = corr_CSp_CSm.rcorr$r[c(2:6,8),12:14]
# corr_CSp_CSm.p = corr_CSp_CSm.rcorr$P[c(2:6,8),12:14]
# 
# col3 <- colorRampPalette(c("blue", "white", "red")) 
# 
# # PLOT CORR
# pdf('~/REWOD/DERIVATIVES/BEHAV/PIT/CSp_CSm_corrplot.pdf')
# corrplot(corr_CSp_CSm.coeff, method = "circle", tl.col = "black", tl.srt = 45, col = col3(20))
# dev.off()




# FINAL PLOTS ---------------------------------------------------------------

figure7 <- ggarrange(A1,A2,A6,
                     labels = c("A: reward-neutral liking", "B: reward-neutral intensity", "C: CSp-CSm effort"),
                     ncol = 2, nrow = 2,
                     vjust=3, hjust=0) 

figure7 <- annotate_figure(figure7,
                           top = text_grob("Coeficient of determination for AMY_BLA", color = "black", face = "bold", size = 14),
                           bottom = "Figure 4", fig.lab.face = "bold")

pdf('~/REWOD/DERIVATIVES/BEHAV/AMY_BLA_coeff.pdf')
plot(figure7)
dev.off()

figure8 <- ggarrange(A3,A4,A5,
                     labels = c("A: reward-neutral liking", "B: reward-neutral intensity", "C: CSp-CSm effort"),
                     ncol = 2, nrow = 2,
                     vjust=3, hjust=0) 

figure8 <- annotate_figure(figure8,
                           top = text_grob("Coeficient of determination for AMY_BM", color = "black", face = "bold", size = 14),
                           bottom = "Figure 4", fig.lab.face = "bold")

pdf('~/REWOD/DERIVATIVES/BEHAV/AMY_BM_coeff.pdf')
plot(figure8)
dev.off()


# ggplot(lm(CSp_CSm_RN[[2]]~eff), aes_string(x = names(eff), y = names(CSp_CSm_RN[[2]]),  xlim=(-2:2), ylim=(-0.6:0.4)) + 
#     geom_point() +
#     stat_smooth(method = "lm", col = "red") +
#     labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
#                        #"Intercept =",signif(fit$coef[[1]],5 ),
#                        #" Slope =",signif(fit$coef[[2]], 5),
#                        "  &  P =",signif(summary(fit)$coef[2,4], 5)))+
#     theme(plot.title = element_text(size = 10, hjust =1))

A1 <- ggplot(R_N_df, aes(lik, R_N_df$AMY_BLA_LEFT_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  labs(title = paste("Adj R2 = ",signif(summary(lm(R_N_df$AMY_BLA_LEFT_betas~lik))$adj.r.squared, 3),
                     #"Intercept =",signif(fit$coef[[1]],5 ),
                     #" Slope =",signif(fit$coef[[2]], 5),
                     "  &  P =",signif(summary(lm(R_N_df$AMY_BLA_LEFT_betas~lik))$coef[2,4], 3)))+
  scale_x_continuous(name="Mobilized effort", limits=c(-2, 2)) +
  scale_y_continuous(name="CSp > CSm  Beta", limits=c(-0.6, 0.6)) +
  theme(plot.title = element_text(size = 10, hjust =1))

A2 <- ggplot(CSp_CSm_RN, aes(eff, AMY_BLA_LEFT_betas)) + #A2
        geom_point() +
        geom_smooth(method = "lm", col = "red") +
        labs(title = paste("Adj R2 = ",signif(summary(lm(CSp_CSm_RN$AMY_BLA_LEFT_betas~eff))$adj.r.squared, 3),
                           #"Intercept =",signif(fit$coef[[1]],5 ),
                           #" Slope =",signif(fit$coef[[2]], 5),
                           "  &  P =",signif(summary(lm(CSp_CSm_RN$AMY_BLA_LEFT_betas~eff))$coef[2,4], 3)))+
        scale_x_continuous(name="Mobilized effort", limits=c(-2, 2)) +
        scale_y_continuous(name="CSp > CSm  Beta", limits=c(-0.6, 0.6)) +
        theme(plot.title = element_text(size = 10, hjust =1))
    

