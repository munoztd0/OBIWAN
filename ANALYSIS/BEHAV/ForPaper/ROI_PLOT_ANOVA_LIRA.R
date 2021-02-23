  
  if(!require(pacman)) {
    install.packages("pacman")
    install.packages("devtools")
    library(pacman)
  }
  
  pacman::p_load(tidyverse, dplyr, plyr, Rmisc, sjPlot, afex)
  
  # get tool
  devtools::source_gist("2a1bb0133ff568cbe28d", 
                        filename = "geom_flat_violin.R")
  # Set path
  home_path       <- '~/OBIWAN'
  
  # Set working directory
  analysis_path <- file.path(home_path, 'CODE/ANALYSIS/BEHAV/ForPaper')
  figures_path  <- file.path(home_path, 'DERIVATIVES/FIGURES/BEHAV/') 
  setwd(analysis_path)
  
  subj = c(202, 203, 204, 209, 213, 217, 220, 224, 225, 235, 236, 237, 238, 239, 241, 246, 250, 259, 264, 265, 266, 269, 270, 205, 206, 207, 211, 215, 218, 221, 227, 229, 230, 231, 232, 244, 248, 251, 252, 253, 254, 262, 268)
  
  #datasets dictory
  data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 
  
  cov  <- read.delim(file.path(data_path,'covariate_LIRA.txt'), header = T, sep ='') #
  

# hpp ---------------------------------------------------------------------

  
  PREplaceboREW <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/reward/parraHPP_roi_0_placebo_betas.csv", header=T); PREplaceboREW$session = '0'
  PREplaceboNEU <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/neutral/parraHPP_roi_0_placebo_betas.csv", header=T); PREplaceboNEU$session = '0'
  POSTplaceboREW <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/reward/parraHPP_roi_1_placebo_betas.csv", header=T); POSTplaceboREW$session = '1'
  POSTplaceboNEU <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/neutral/parraHPP_roi_1_placebo_betas.csv", header=T); POSTplaceboNEU$session = '1'
  
  PREtreatmentREW <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/reward/parraHPP_roi_0_treatment_betas.csv", header=T); PREtreatmentREW$session = '0'
  PREtreatmentNEU <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/neutral/parraHPP_roi_0_treatment_betas.csv", header=T); PREtreatmentNEU$session = '0'
  POSTtreatmentREW <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/reward/parraHPP_roi_1_treatment_betas.csv", header=T); POSTtreatmentREW$session = '1'
  POSTtreatmentNEU <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/neutral/parraHPP_roi_1_treatment_betas.csv", header=T); POSTtreatmentNEU$session = '1'
  
  PRE_REW = rbind(PREplaceboREW, PREtreatmentREW)
  POST_REW = rbind(POSTplaceboREW, POSTtreatmentREW)
  
  PRE_NEU = rbind(PREplaceboNEU, PREtreatmentNEU)
  POST_NEU = rbind(POSTplaceboNEU, POSTtreatmentNEU)
  
  
  diffPRE = PRE_REW; diffPRE$score =  PRE_REW$betas - PRE_NEU$betas; diffPRE$id =subj;  diffPRE$session = 'pre'
  diffPOST = POST_REW; diffPOST$score =  POST_REW$betas - POST_NEU$betas; diffPOST$id =subj; diffPOST$session = 'post'
  
  diff = rbind(diffPRE, diffPOST)
  
  df = merge(diff, cov , by= 'id'); df$intervention = as.factor(df$intervention)
  
  #interscore
  diffPRE = subset(diff, session == 'pre') ; diffPOST = subset(diff, session == 'post')
  diffSES = diffPRE; diffSES$inter =  diffPOST$score - diffPRE$score
  
  dft = merge(diffSES, cov , by= 'id'); 
  
  mod = lm(data = dft, inter ~ intervention*GLP1 + intervention*Fast_glu + intervention*bmi + intervention*gender + intervention*age + intervention*piss + intervention*thirsty + intervention*hungry + intervention*insulin + intervention*AEA + intervention*PEA + intervention*OEA )
  
  anova(mod)
  
  # PLOT --------------------------------------------------------------------
  # df$session =as.factor(df$session)
  # neworder <- c("pre","post")
  # df <- arrange(transform(df,
  #                         session=factor(session,levels=neworder)),session)
  
  
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
  
  pal = viridis::inferno(n=5); pal[6] = "#21908CFF" # add one # specialy conceived for colorblindness
  
  
  
  dft$intervention = as.factor(dft$intervention)
  # AVERAGED EFFECT
  dfH <- summarySE(dft,  measurevar = "inter",
                   groupvars = "intervention")
  
  dfH$cond <- ifelse(dfH$intervention == "0", -0.25, 0.25)
  dft$cond <- ifelse(dft$intervention == "0", -0.25, 0.25)
  set.seed(666)
  dft <- dft %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                        grouping = interaction(id, cond))
  
  
  pp <- ggplot(dft, aes(x = cond, y = inter, 
                        fill = intervention, color = intervention)) +
    geom_hline(yintercept = 0) + 
    geom_point(data = dfH, alpha = 0.5) +
    geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = intervention, color = NA))+
    geom_point(aes(x = condjit), alpha = .3,) +
    geom_crossbar(data = dfH, aes(y = inter, ymin=inter-se, ymax=inter+se), width = 0.2 , alpha = 0.1)+
    ylab('Beta estimates (a.u.)') +
    xlab('parahippocamp') +
    #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(-0.5,100.5)) +
    scale_x_continuous(labels=c("Placebo", "Liraglutide"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
    scale_fill_manual(values=c("0"= pal[1], "1"=pal[6]), guide = 'none') +
    scale_color_manual(values=c("0"=pal[1], "1"=pal[6]), guide = 'none') +
    theme_bw()
  
  ppp <- pp + averaged_theme
  ppp
  
  cairo_pdf(file.path(figures_path,'Figure_HEDONIC_fMRI.pdf'))
  print(ppp)
  dev.off()
  
  bf = ttestBF(formula = inter ~ intervention, data = dft); bf
  t = t.test(formula = inter ~ intervention, data = dft); t
  
  

# mOFC --------------------------------------------------------------------

  
  PREplaceboREW <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/reward/cmOFC_roi_0_placebo_betas.csv", header=T); PREplaceboREW$session = '0'
  PREplaceboNEU <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/neutral/cmOFC_roi_0_placebo_betas.csv", header=T); PREplaceboNEU$session = '0'
  POSTplaceboREW <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/reward/cmOFC_roi_1_placebo_betas.csv", header=T); POSTplaceboREW$session = '1'
  POSTplaceboNEU <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/neutral/cmOFC_roi_1_placebo_betas.csv", header=T); POSTplaceboNEU$session = '1'
  
  PREtreatmentREW <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/reward/cmOFC_roi_0_treatment_betas.csv", header=T); PREtreatmentREW$session = '0'
  PREtreatmentNEU <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/neutral/cmOFC_roi_0_treatment_betas.csv", header=T); PREtreatmentNEU$session = '0'
  POSTtreatmentREW <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/reward/cmOFC_roi_1_treatment_betas.csv", header=T); POSTtreatmentREW$session = '1'
  POSTtreatmentNEU <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/ROI/neutral/cmOFC_roi_1_treatment_betas.csv", header=T); POSTtreatmentNEU$session = '1'
  
  PRE_REW = rbind(PREplaceboREW, PREtreatmentREW)
  POST_REW = rbind(POSTplaceboREW, POSTtreatmentREW)
  
  PRE_NEU = rbind(PREplaceboNEU, PREtreatmentNEU)
  POST_NEU = rbind(POSTplaceboNEU, POSTtreatmentNEU)
  
  
  diffPRE = PRE_REW; diffPRE$score =  PRE_REW$betas - PRE_NEU$betas; diffPRE$id =subj;  diffPRE$session = 'pre'
  diffPOST = POST_REW; diffPOST$score =  POST_REW$betas - POST_NEU$betas; diffPOST$id =subj; diffPOST$session = 'post'
  
  diff = rbind(diffPRE, diffPOST)
  
  df = merge(diff, cov , by= 'id'); df$intervention = as.factor(df$intervention)
  
  #interscore
  diffPRE = subset(diff, session == 'pre') ; diffPOST = subset(diff, session == 'post')
  diffSES = diffPRE; diffSES$inter =  diffPOST$score - diffPRE$score
  
  dft = merge(diffSES, cov , by= 'id'); 
  
  mod = lm(data = dft, inter ~ intervention*GLP1 + intervention*Fast_glu + intervention*bmi + intervention*gender + intervention*age + intervention*piss + intervention*thirsty + intervention*hungry + intervention*insulin + intervention*AEA + intervention*PEA + intervention*OEA )
  
  anova(mod)
  
  # PLOT --------------------------------------------------------------------
  # df$session =as.factor(df$session)
  # neworder <- c("pre","post")
  # df <- arrange(transform(df,
  #                         session=factor(session,levels=neworder)),session)
  

  
  
  
  dft$intervention = as.factor(dft$intervention)
  # AVERAGED EFFECT
  dfH <- summarySE(dft,  measurevar = "inter",
                   groupvars = "intervention")
  
  dfH$cond <- ifelse(dfH$intervention == "0", -0.25, 0.25)
  dft$cond <- ifelse(dft$intervention == "0", -0.25, 0.25)
  set.seed(666)
  dft <- dft %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                        grouping = interaction(id, cond))
  
  
  pp <- ggplot(dft, aes(x = cond, y = inter, 
                        fill = intervention, color = intervention)) +
    geom_hline(yintercept = 0) + 
    geom_point(data = dfH, alpha = 0.5) +
    geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = intervention, color = NA))+
    geom_point(aes(x = condjit), alpha = .3,) +
    geom_crossbar(data = dfH, aes(y = inter, ymin=inter-se, ymax=inter+se), width = 0.2 , alpha = 0.1)+
    ylab('Beta estimates (a.u.)') +
    xlab('mOFC') +
    #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(-0.5,100.5)) +
    scale_x_continuous(labels=c("Placebo", "Liraglutide"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
    scale_fill_manual(values=c("0"= pal[1], "1"=pal[6]), guide = 'none') +
    scale_color_manual(values=c("0"=pal[1], "1"=pal[6]), guide = 'none') +
    theme_bw()
  
  ppp <- pp + averaged_theme
  ppp
  
  cairo_pdf(file.path(figures_path,'Figure_HEDONIC_fMRI.pdf'))
  print(ppp)
  dev.off()
  
  bf = ttestBF(formula = inter ~ intervention, data = dft); bf
  t = t.test(formula = inter ~ intervention, data = dft); t  
  