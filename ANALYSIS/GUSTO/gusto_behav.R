##################################################################################################
# Created  by D.M.T. on AUGUST 2021                                                           
##################################################################################################
#                                      PRELIMINARY STUFF ----------------------------------------

#load libraries

if(!require(pacman)) {
  install.packages("pacman")
  install.packages("devtools")
  library(pacman)
}

pacman::p_load(tidyverse, dplyr, plyr, Rmisc) 
#                reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, parallel,
#                lsmeans, BayesFactor, effectsize, devtools, misty, bayestestR, lspline)
# get tool
devtools::source_gist("2a1bb0133ff568cbe28d", 
                      filename = "geom_flat_violin.R")


# -------------------------------------------------------------------------
# *************************************** SETUP **************************************
# -------------------------------------------------------------------------




# Set path
home_path       <- '~/OBIWAN'

# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/GUSTO')
figures_path  <- file.path(home_path, 'CODE/ANALYSIS/GUSTO/FIGURES') 
setwd(analysis_path)

#datasets dictory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 

# open datasets
HED  <- read.delim(file.path(data_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # 
info <- read.delim(file.path(data_path,'info_expe.txt'), header = T, sep ='') # 

#subset only pretest
HED = subset(HED, session == 'second')

#exclude participants (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123, 124 and 226 have imcomplete data
`%notin%` <- Negate(`%in%`)
HED = filter(HED, id %notin% c(242, 256, 114, 228, 123, 124, 226))

#merge with info
HED = merge(HED, info, by = "id")


# -------------------------------------- themes for plots --------------------------------------------------------
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


# Check Demo
AGE = ddply(HED,.(), summarise,mean=mean(age),sd=sd(age), min = min(age), max = max(age)); AGE
GENDER = ddply(HED, .(id), summarise, gender=mean(as.numeric(gender)))  %>%
  group_by(gender) %>%
  tally() ; GENDER #1 = women

cov = ddply(HED, .(id),  summarize, age = mean(age, na.rm = TRUE), gender = mean(as.numeric(gender), na.rm = TRUE)) ; cov$age = scale(cov$age)

write.table(cov, (file.path(analysis_path, "covariate.txt")), row.names = F, sep="\t")



# -------------------------------------- PLOTS -----------------------------------------------
HED.means <- aggregate(HED$perceived_liking, by = list(HED$id, HED$condition), FUN='mean') # extract means
colnames(HED.means) <- c('id','condition','perceived_liking')


# AVERAGED EFFECT
dfH <- summarySEwithin(HED.means,
                       measurevar = "perceived_liking",
                       withinvars = "condition", 
                       idvar = "id")

dfH$cond <- ifelse(dfH$condition == "MilkShake", -0.25, 0.25)
HED.means$cond <- ifelse(HED.means$condition == "MilkShake", -0.25, 0.25)
set.seed(666)
HED.means <- HED.means %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                                  grouping = interaction(id, cond))


pp <- ggplot(HED.means, aes(x = cond, y = perceived_liking, 
                            fill = condition, color = condition)) +
  geom_point(data = dfH, alpha = 0.5) +
  geom_line(aes(x = condjit, group = id, y = perceived_liking), alpha = .3, size = 0.5, color = 'gray') +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = condition, color = NA))+
  geom_point(aes(x = condjit), alpha = .3,) +
  geom_crossbar(data = dfH, aes(y = perceived_liking, ymin=perceived_liking-se, ymax=perceived_liking+se), width = 0.2 , alpha = 0.1)+
  ylab('Perceived liking') +
  xlab('Odorant') +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(-0.5,100.5)) +
  scale_x_continuous(labels=c("Pleasant", "Neutral"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("MilkShake"= pal[3], "Empty"=pal[1]), guide = 'none') +
  scale_color_manual(values=c("MilkShake"=pal[3], "Empty"=pal[1]), guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme
ppp

cairo_pdf(file.path(figures_path,'Figure_HEDONIC.pdf'))
print(ppp)
dev.off()
