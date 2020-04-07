## R code for FOR REWOD_PAV
# last modified on Nov 2018 by David


#-----------------------  PRELIMINARY STUFF ----------------------------------------
#load libraries
pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, lsmeans, BayesFactor)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


task = 'PAVCOND'

#SETUP

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
setwd(analysis_path)

# open dataset
REWOD_PAV <- read.delim(file.path(analysis_path,'REWOD_PAVCOND_ses_first.txt'), header = T, sep ='') # read in dataset

# define factors
REWOD_PAV$id               <- factor(REWOD_PAV$id)
REWOD_PAV$trial            <- factor(REWOD_PAV$trial)
REWOD_PAV$session          <- factor(REWOD_PAV$session)
REWOD_PAV$condition        <- factor(REWOD_PAV$condition)

# get times in milliseconds 
REWOD_PAV$RT       <- REWOD_PAV$RT * 1000

# remove sub 8 (bc we dont have scans)
REWOD_PAV <- subset (REWOD_PAV,!id == '8') 

#Cleaning
##only first round
REWOD_PAV.clean <- filter(REWOD_PAV, rounds == 1)
REWOD_PAV.clean$condition <- droplevels(REWOD_PAV.clean$condition, exclude = "Baseline")
full = length(REWOD_PAV.clean$RT)

##shorter than 100ms and longer than 3sd+mean
REWOD_PAV.clean <- filter(REWOD_PAV.clean, RT >= 100) # min RT is 106ms
mean <- mean(REWOD_PAV.clean$RT)
sd <- sd(REWOD_PAV.clean$RT)
REWOD_PAV.clean <- filter(REWOD_PAV.clean, RT <= mean +3*sd) #which is 854.4ms
#now accuracy is to a 100%
clean= length(REWOD_PAV.clean$RT)

dropped = full-clean
(dropped*100)/full
#PLOTS 


##acc
mean(REWOD_PAV$accuracy, na.rm = TRUE)

# create one with baslein for liking
baseline = filter(REWOD_PAV, condition == 'Baseline')
ratings = rbind(REWOD_PAV.clean, baseline)

##plot (non-averaged per participant) 

# reaction time by conditions #(baseline non included)
boxplot(REWOD_PAV.clean$RT ~ REWOD_PAV.clean$condition, las = 1)

# get acc means by condition (without baseline)
ba = ddply(REWOD_PAV.clean, .(condition), summarise,  accuracy = mean(accuracy, na.rm = TRUE))

# get acc means by participant (without baseline)
bsacc = ddply(REWOD_PAV.clean, .(id), summarise, accuracy = mean(accuracy, na.rm = TRUE))

#get subject means
bsRT = ddply(REWOD_PAV.clean, .(id,condition), summarise, RT = mean(RT, na.rm = TRUE))
bsLIK = ddply(ratings, .(id,condition), summarise, liking_ratings = mean( liking_ratings, na.rm = TRUE))

## plot overall effect RT##


# get RT  means by participant 
RT_CS = ddply(bsRT, .(id), group_by)


# #show distrib
RT_plus= RT_CS  %>% filter(condition == 'CSplus')
densityplot(RT_plus$RT)
RT_minus= RT_CS  %>% filter(condition == 'CSminus')
densityplot(RT_minus$RT)




# RTs ---------------------------------------------------------------------


#do paired t-test (unilateral?)
cond.ttest = t.test(RT_minus$RT, RT_plus$RT,  paired = TRUE, alternative = "greater")
cond.ttest



# LMER --------------------------------------------------------------------


main.model.pav = lmer(RT ~ condition + trialxcondition  + (1+condition|id), data = REWOD_PAV.clean, REML=FALSE)
summary(main.model.pav)

null.model.pav = lmer(RT ~ trialxcondition  + (1+condition|id), data = REWOD_PAV.clean, REML=FALSE)

test = anova(main.model.pav, null.model.pav, test = 'Chisq')
test

ems = emmeans(main.model.pav, list(pairwise ~ condition))
ems

#----EFFECT SIZE see yoann's script

source('~/REWOD/CODE/ANALYSIS/BEHAV/my_tools/cohen_d_ci.R')
cohen_d_ci(RT_minus$RT, RT_plus$RT, paired  = TRUE)

# BAYES FACTOR
cond.N             <- length(RT_minus$RT)
cond.tvalue        <- cond.ttest$statistic
cond.BF            <- ttest.tstat(t = cond.tvalue, n1 = cond.N, nullInterval = c(0, Inf), rscale = 0.5, simple = T)
cond.BF


# RATINGS LIKING ----------------------------------------------------------

# get RT  means by participant 
LIK_CS = ddply(bsLIK, .(id), group_by)


#show distrib
LIK_plus= LIK_CS  %>% filter(condition == 'CSplus')
densityplot(LIK_plus$liking_ratings)
LIK_minus= LIK_CS  %>% filter(condition == 'CSminus') 
densityplot(LIK_minus$liking_ratings)
LIK_base= LIK_CS  %>% filter(condition == 'Baseline') 
densityplot(LIK_base$liking_ratings)



# ANOVA RATINGS -------------------------------------------------------------------


anova_model = ezANOVA(data = ratings,
                      dv = liking_ratings,
                      wid = id,
                      within = condition,
                      detailed = TRUE,
                      type = 3)

cond.aov <- aov_car(liking_ratings ~ condition + Error(id/condition), data = ratings, anova_table = list(es = "pes"))
cond.aov
cond.aov_sum <- summary(cond.aov)
cond.aov_sum



source('~/REWOD/CODE/ANALYSIS/BEHAV/my_tools/pes_ci.R')

pes_ci(liking_ratings ~ condition + Error(id/condition), ratings, 0.90, "III")



#contrast pairvise corrected to get pvalues
ems = emmeans(cond.aov, list(pairwise ~ condition), adjust = "tukey")
ems


# PAIRED CONTRASTS TO GET EFFECT SIZES--------------------------------------------------------

# CS+ vs CSminus ----------------------------to get effect sizes------------------------------

lik.ttest = t.test(LIK_plus$liking_ratings, LIK_minus$liking_ratings,  paired = TRUE, alternative = "greater")

#----EFFECT SIZE see yoann's script
cohen_d_ci(LIK_plus$liking_ratings, LIK_minus$liking_ratings, paired  = TRUE)

# BAYES FACTOR
lik.N             <- length(LIK_plus$liking_ratings)
lik.tvalue        <- lik.ttest$statistic
lik.BF            <- ttest.tstat(t = lik.tvalue, n1 = cond.N, nullInterval = c(0, Inf), rscale = 0.5, simple = T)
lik.BF


# CS+ vs Baseline ---------------------------------to get effect sizes------------------------

lik.ttest1 = t.test(LIK_plus$liking_ratings, LIK_base$liking_ratings,  paired = TRUE, alternative = "greater")
lik.ttest1

#----EFFECT SIZE see yoann's script
cohen_d_ci(LIK_plus$liking_ratings, LIK_base$liking_ratings, paired  = TRUE)

# BAYES FACTOR
lik.N             <- length(LIK_plus$liking_ratings)
lik.tvalue        <- lik.ttest1$statistic
lik.BF            <- ttest.tstat(t = lik.tvalue, n1 = cond.N, nullInterval = c(0, Inf), rscale = 0.5, simple = T)
lik.BF

# CS- vs Baseline ---------------------------------to get effect sizes------------------------

lik.ttest = t.test(LIK_minus$liking_ratings, LIK_base$liking_ratings,  paired = TRUE, alternative = "greater")
lik.ttest

#----EFFECT SIZE see yoann's script
cohen_d_ci(LIK_minus$liking_ratings, LIK_base$liking_ratings, paired  = TRUE)

# BAYES FACTOR
lik.N             <- length(LIK_minus$liking_ratings)
lik.tvalue        <- lik.ttest$statistic
lik.BF            <- ttest.tstat(t = lik.tvalue, n1 = cond.N, nullInterval = c(0, Inf), rscale = 0.5, simple = T)
lik.BF





#  PLOT -------------------------------------------------------------------

#data manip
# get RT and Liking means by condition (with baseline)

df <- summarySE(REWOD_PAV.clean, measurevar="RT", groupvars=c("id", "condition"))
bcRT <- summarySEwithin(df,
                                measurevar = "RT",
                                withinvars = "condition", 
                                idvar = "id")




# get liking  means by participant (with baseline)

df <- summarySE(ratings, measurevar="liking_ratings", groupvars=c("id", "condition"))
bcLIK <- summarySEwithin(df,
                        measurevar = "liking_ratings",
                        withinvars = "condition", 
                        idvar = "id")


###################### do the plot ###########################
add.alpha <- function(col, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2, 
        function(x) 
          rgb(x[1], x[2], x[3], alpha=alpha))  
}


Alpha <- add.alpha('black', alpha=0.4)




###################### start the plot ###########################

par(mar = c(5, 1.8, 2, 2))
#
#rownames(bcLIK) <- 1:nrow(bcLIK)

bcLIK$condition = factor(bcLIK$condition,levels(bcLIK$condition)[c(2,1,3)])

ggplot() + 
  geom_bar(bcLIK, mapping = aes(x = condition, y = liking_ratings), stat = "identity", fill = "white") +
  geom_point(bcRT, mapping = aes(x = condition, y = RT)) +
  geom_errorbar(bcRT, mapping = aes(x = condition, y = RT, ymin=bcRT$RT-bcRT$se, ymax=bcRT$RT+bcRT$se), width=.1, color = 'black')+
  geom_line(bcRT, mapping = aes(x = condition, y = RT, group =1), color = 'black', lty = 4) + 
  theme(plot.margin = margin(2, 2, 2, 2, "cm")) +
  ylim(0, 490) + 
  theme_void()

par(new = TRUE)

bcLIK <- bcLIK[order(-bcLIK$liking_ratings),]

foo <- barplot(bcLIK$liking_ratings,names.arg=bcLIK$condition,xlab="Pavlovian Stimulus",ylab="Liking Ratings",col=Alpha, space = 1, ylim
               = c(0,100), border=NA)



for (i in 1:length(bcLIK)){
  arrows(x0=foo[i],y0=bcLIK$liking_ratings[i]-bcLIK$se[i],y1=bcLIK$liking_ratings[i]+bcLIK$se[i],angle=90,code=3,length=0.05)
}
  ##

par(new = TRUE)
x = c(1:1000)
y = c(1:1000)
plot(x, y, ylim = c(0,500), axis(4, lty=4), col.axis = "black", lwd = 0.5, cex.axis = 0.5)
legend("topright", inset=.05, legend=c("Pleasantness Ratings", "Latency"),
       col=c(Alpha, "black"), lty=c(1,4), lwd=c(8,2), cex=0.8, box.lty=0)







