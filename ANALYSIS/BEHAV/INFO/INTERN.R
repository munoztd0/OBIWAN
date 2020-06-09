pacman::p_load( ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc, data.table, ggpubr, gridExtra, plotrix)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


#SETUP
task = 'INTERNAL'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

# open dataset
INTERN <- read.delim(file.path(analysis_path,'OBIWAN_INTERNAL.txt'), header = T, sep ='') # read in dataset


`%notin%` <- Negate(`%in%`)
INTERN = INTERN %>% filter(id %notin% c(101, 103))

INTERN  <- subset(INTERN, session == 'second')
INTERN_thi  <- subset(INTERN, session == 'third')


# summarySE provides the standard deviation, standard error of the mean, and a (default 95%) confidence interval
bs = ddply(INTERN, .(id), summarise, urinate = mean(piss, na.rm = TRUE), thirst = mean(thirsty, na.rm = TRUE), hunger = mean(hungry, na.rm = TRUE))
BS = ddply(INTERN, .(id, phase), summarise, urinate = mean(piss, na.rm = TRUE), thirst = mean(thirsty, na.rm = TRUE), hunger = mean(hungry, na.rm = TRUE))

BS = ddply(INTERN, .(id, phase), summarise, urinate = mean(piss, na.rm = TRUE), thirst = mean(thirsty, na.rm = TRUE), hunger = mean(hungry, na.rm = TRUE))
data_long <- gather(BS, condition, measurement, urinate:hunger, factor_key=TRUE)
long = ddply(data_long, .(phase, condition), summarise, measurement = mean(measurement, na.rm = TRUE), sd = sd(measurement, na.rm = TRUE))

bs_long = ddply(data_long, .(id, phase, condition), summarise, measurement = mean(measurement, na.rm = TRUE))


BS_BL = ddply(BS, .(id), summarise, freqA=mean(urinate, na.rm = TRUE), sdA=sd(urinate,  na.rm = TRUE)) 
BS = merge(BS, BS_BL, by = "id")
BS$urinateZ = (BS$urinate - BS$freqA) / BS$sdA

BS_BL = ddply(BS, .(id), summarise, freqB=mean(thirst, na.rm = TRUE), sdB=sd(thirst,  na.rm = TRUE)) 
BS = merge(BS, BS_BL, by = "id")
BS$thirstZ = (BS$thirst - BS$freqB) / BS$sdB

BS_BL = ddply(BS, .(id), summarise, freqC=mean(hunger, na.rm = TRUE), sdC=sd(hunger,  na.rm = TRUE)) 
BS = merge(BS, BS_BL, by = "id")
BS$hungerZ = (BS$hunger - BS$freqC) / BS$sdC

df1 <- summarySE(INTERN, measurevar="piss", na.rm = TRUE, groupvars=c("phase"))
df2 <- summarySE(INTERN, measurevar="thirsty", na.rm = TRUE, groupvars=c("phase"))
df3 <- summarySE(INTERN, measurevar="hungry", na.rm = TRUE, groupvars=c("phase"))

df = data.frame(rbindlist(list(df1,df2,df3), use.names=FALSE))
cat = c(0,0,0,0,0,1,1,1,1,1,2,2,2,2,2)
df = cbind(df, cat)

# 
# dfPIT2 <- summarySEwithin(df,
#                           measurevar = "piss",
#                           withinvars = c("Condition"), 
#                           idvar = "id")
labels <- c( "0" = "Urinate" , "1" = "Thirst", "2" = "Hunger" )


plt <- ggplot(long, aes(x = phase, y = measurement)) +
  geom_point(data = bs_long, color = 'royalblue', alpha = .4) +
  geom_line(data = bs_long, aes(group = id), color = 'royalblue', alpha = .1) +
  geom_line(data= long, alpha = .7, size = 1) +
  geom_point() +
  #geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_ribbon(aes(ymax = measurement + sd, ymin = measurement -sd), alpha=0.3, linetype = 0 ) +
  facet_wrap(~ condition)

plt1 = plt +  
  scale_y_continuous(expand = c(0, 0),
                     breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  
  scale_x_continuous(breaks = c(seq.int(1,5, by = 1))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_line(size=.2, color="lightgrey"),
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        #axis.text.x =  element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16), 
        strip.background = element_rect(fill="white")) + 
  labs(y =  "Internal state evaluation", x = "Phase")

plot(plt1)



plt <- ggplot(BS, aes(x = phase, y = urinate)) +
  geom_line(alpha = .7, size = 1, color = 'royalblue') +
  geom_point(color = 'royalblue') +
  geom_line(color = 'royalblue') +
  #geom_ribbon(aes(ymax = piss +se, ymin = piss -se), fill = 'blue', alpha=0.2, linetype = 0 ) +
  facet_zoom(~ id)

plt1 = plt +  
  scale_y_continuous(expand = c(0, 0),
                     breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  
  scale_x_continuous(breaks = c(seq.int(1,5, by = 1))) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_line(size=.2, color="lightgrey"),
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        #axis.text.x =  element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16), 
        strip.background = element_rect(fill="white")) + 
  labs(y =  "Internal state evaluation", x = "Phase")

plot(plt1)


library(tidyverse)

f_plot <- function(idk) {
    filter(BS, id == idk) %>%
    ggplot(aes(x = phase, y = hungerZ)) +
    geom_line(alpha = .7, size = 1, color = 'royalblue') +
    geom_point(color = 'royalblue') +
    geom_line(color = 'royalblue') +
    scale_y_continuous(expand = c(0, 0),
                       breaks = c(seq.int(-3,3, by = 1)), limits = c(-3,3)) +
    labs(title = as.character(idk))
}

map(bs$id[1:94], f_plot)

BS$phase <- as.factor(BS$phase)

ur.lm = lm(urinate ~ phase , BS)
summary(ur.lm)


im <- influence(ur.lm,by='id')
influenceIndexPlot(ur.lm,vars=c("cookd"))

ols_plot_cooksd_bar(ur.lm)

thi.lm = lm(thirst ~ phase, BS)
summary(thi.lm)

hun.lm = lm(hunger ~ phase, BS)
summary(hun.lm)


