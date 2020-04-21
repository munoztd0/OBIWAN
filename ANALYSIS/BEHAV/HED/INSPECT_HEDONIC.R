## R code for inspection of data FOR OBIWAN_HED
# last modified on March 2020 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(rmcorr,corrplot, ggplot2, dplyr, sm, plyr, tidyr, reshape)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 

# open dataset
OBIWAN_HED <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset

# define factors
OBIWAN_HED$id         <- factor(OBIWAN_HED$id)
OBIWAN_HED$session          <- factor(OBIWAN_HED$session)
OBIWAN_HED$condition        <- factor(OBIWAN_HED$condition)
OBIWAN_HED$group            <- factor(OBIWAN_HED$group)

OBIWAN_HED$Condition[OBIWAN_HED$condition== 'MilkShake']     <- 'Reward'
OBIWAN_HED$Condition[OBIWAN_HED$condition== 'Empty']     <- 'Control'


OBIWAN_HED$Condition        <- factor(OBIWAN_HED$Condition)
OBIWAN_HED$trialxcondition        <- factor(OBIWAN_HED$trialxcondition)
#OBIWAN_HED$Condition2        <- factor(OBIWAN_HED$Condition2)

## remove sub only group contorl for now
OBIWAN_HED <- filter(OBIWAN_HED,  group == "control")
#OBIWAN_HED <- filter(OBIWAN_HED,  id != "8")

# PLOTS
# pdf(file.path(figures_path,'XXX.pdf'))
# plot cc
# dev.off()


# liking boxplot by condition
boxplot(OBIWAN_HED$perceived_liking ~ OBIWAN_HED$condition, las = 1)
sm.density.compare(OBIWAN_HED$perceived_liking, OBIWAN_HED$Condition, col=c("black","blue"),lty=c(4,6), xlab="Pleasantness ratings by condition")
legend("topright", levels(OBIWAN_HED$Condition), fill=c("black","blue"))

# liking boxplot by time
#boxplot(OBIWAN_HED$perceived_liking ~ OBIWAN_HED$trialxcondition, las = 1)
sm.density.compare(OBIWAN_HED$perceived_liking, OBIWAN_HED$trialxcondition, xlab="Pleasantness ratings by trialXcondition")
colfill<-c(2:(2+length(levels(OBIWAN_HED$trialxcondition))))
legend("topright", levels(OBIWAN_HED$trialxcondition), fill=colfill)


# intensity boxplot by condition
boxplot(OBIWAN_HED$perceived_intensity ~ OBIWAN_HED$condition, las = 1)
sm.density.compare(OBIWAN_HED$perceived_intensity, OBIWAN_HED$Condition, col=c("black","blue"),lty=c(4,6), xlab="Intensity ratings by condition")
legend("topright", levels(OBIWAN_HED$Condition), fill=c("black","blue"))

# intensity boxplot by time
#boxplot(OBIWAN_HED$perceived_intensity ~ OBIWAN_HED$trialxcondition, las = 1)
sm.density.compare(OBIWAN_HED$perceived_intensity, OBIWAN_HED$trialxcondition, xlab="Intensity ratings by trialXcondition")
colfill<-c(2:(2+length(levels(OBIWAN_HED$trialxcondition))))
legend("topright", levels(OBIWAN_HED$trialxcondition), fill=colfill)


# familiarity boxplot by condition
#pdf(file.path(figures_path,paste(task, 'cor.pdf',  sep = "_")))
boxplot(OBIWAN_HED$perceived_familiarity ~ OBIWAN_HED$condition, las = 1)
#dev.off()

sm.density.compare(OBIWAN_HED$perceived_familiarity, OBIWAN_HED$Condition, col=c("black","blue"),lty=c(4,6), xlab="Familiarity ratings by condition")
legend("topright", levels(OBIWAN_HED$Condition), fill=c("black","blue"))

# familiarity boxplot by time
#boxplot(OBIWAN_HED$perceived_familiarity ~ OBIWAN_HED$trialxcondition, las = 1)
sm.density.compare(OBIWAN_HED$perceived_familiarity, OBIWAN_HED$trialxcondition, xlab="Familiarity ratings by trialXcondition")
colfill<-c(2:(2+length(levels(OBIWAN_HED$trialxcondition))))
legend("topright", levels(OBIWAN_HED$trialxcondition), fill=colfill)


# get means by condition 
bt = ddply(OBIWAN_HED, .(trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) 
# get means by condition and trialxcondition
btc = ddply(OBIWAN_HED, .(Condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) #, EMG = mean(EMG, na.rm = TRUE)) 

# get means by participant 
bsT = ddply(OBIWAN_HED, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) #, EMG = mean(EMG, na.rm = TRUE)) 
bsC= ddply(OBIWAN_HED, .(id, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
bsTC = ddply(OBIWAN_HED, .(id, trialxcondition, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))


#univariate corr

## correlation Liking and intensity

rmcorr(id, perceived_liking, perceived_intensity, OBIWAN_HED, CIs = c("analytic",
                                                    "bootstrap"), nreps = 100, bstrap.out = F)

## correlation Liking and familiarity

rmcorr(id, perceived_liking, perceived_familiarity, OBIWAN_HED, CIs = c("analytic",
                                                                      "bootstrap"), nreps = 100, bstrap.out = F)

## correlation intensity and familiarity

rmcorr(id, perceived_intensity, perceived_familiarity, OBIWAN_HED, CIs = c("analytic",
                                                                        "bootstrap"), nreps = 100, bstrap.out = F)

#plot
keep <- c("perceived_intensity","perceived_familiarity", "perceived_liking")
corDATA = OBIWAN_HED[ , (names(OBIWAN_HED) %in% keep)]

M <- cor(corDATA)
corrplot(M, method = "circle")


# # plot liking by time by condition 

dfLIK <- summarySEwithin(bsTC,
                         measurevar = "perceived_liking",
                         withinvars = c("Condition", "trialxcondition"), 
                         idvar = "id")

dfLIK$Condition = as.factor(dfLIK$Condition)
dfLIK$Condition = factor(dfLIK$Condition,levels(dfLIK$Condition)[c(2,1)])
dfLIK$trialxcondition =as.numeric(dfLIK$trialxcondition)


ggplot(dfLIK, aes(x = trialxcondition, y = perceived_liking, color=Condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_errorbar(aes(ymax = perceived_liking +se, ymin = perceived_liking -se), width=0.25, alpha=0.7, size=0.4)+
  scale_colour_manual(values = c("Reward"="blue",  "Control"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(40,75),  breaks=c(seq.int(40,80, by = 5))) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  scale_x_continuous(expand = c(0, 0), limits = c(0,20.25), breaks=c(seq.int(1,20, by = 1)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Pleasantness Ratings")



#### same for INTENSITY

dfINT <- summarySEwithin(bsTC,
                         measurevar = "perceived_intensity",
                         withinvars = c("Condition", "trialxcondition"), 
                         idvar = "id")

dfINT$Condition = as.factor(dfINT$Condition)
dfINT$Condition = factor(dfINT$Condition,levels(dfINT$Condition)[c(3,2,1)])
dfINT$trialxcondition =as.numeric(dfINT$trialxcondition)


ggplot(dfINT, aes(x = trialxcondition, y = perceived_intensity, color=Condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_errorbar(aes(ymax = perceived_intensity +se, ymin = perceived_intensity -se), width=0.25, alpha=0.7, size=0.4)+
  scale_colour_manual(values = c("Reward"="blue", "Control"="black")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(30,75),  breaks=c(seq.int(30,75, by = 5))) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  scale_x_continuous(expand = c(0, 0), limits = c(0,20.25), breaks=c(seq.int(1,20, by = 1)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Intensity Ratings")




# functions ---------------------------------------------------------------


ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Rˆ2* = ",signif(summary(fit)$adj.r.squared, 5),
                       " P =",signif(summary(fit)$coef[2,4], 5)))
}


