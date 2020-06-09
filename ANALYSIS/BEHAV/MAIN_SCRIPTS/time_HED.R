
#**********************************  PLOT 2 main effect by trial # # plot liking by time by condition  
#rmisc
bsCT = ddply(HED, .(id, condition, trialxcondition), summarise, lik = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bT = ddply(HED, .(trialxcondition, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

bT <- summarySEwithin(bsCT,
                         measurevar = "lik",
                         withinvars = c("condition", "trialxcondition"), 
                         idvar = "id")

dfLIK$condition <- factor(dfLIK$condition, levels = rev(levels(dfLIK$condition)))

dfLIK$trialxcondition = as.numeric(dfLIK$trialxcondition)

plt2 <- ggplot(bsCT, aes(x = trialxcondition, y = lik, fill = id, color=condition)) +
  geom_line(alpha = .7, size = 1) +
  geom_point() +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  #geom_ribbon(aes(ymax = lik +se, ymin = lik -se), alpha=0.2, linetype = 0 ) +
  #geom_ribbon(aes(ymax = lik +se, ymin = lik -se), alpha=0.2, linetype = 0 ) +
  #scale_fill_manual(values = c("MilkShake"="blue",  "Empty"="black")) +
  #scale_color_manual(values = c("MilkShake"="purple",  "Empty"="black")) +
  #scale_y_continuous(expand = c(0, 0),  limits = c(-10,30),  breaks=c(seq.int(-10,30, by = 5))) +
  #scale_x_continuous(expand = c(0, 0), limits = c(0,21), breaks=c(seq.int(1,21, by = 2)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), 
        axis.text.y = element_text(size=12,  colour = "black"),
        axis.text.x = element_text(size=11,  colour = "black"),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), 
        legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trial",
       y = "Pleasantness Rating",
       caption = "Second session: nControl = 27, nObese = 63 \n Error bars represent SEM for within-subject design using method from Morey (2008)")



empty = subset(bsCT, condition == 'Empty')
MS = subset(bsCT, condition == 'MilkShake')
data = MS

data$diff = MS$lik - empty$lik
dataT <- summarySEwithin(data,
                      measurevar = "diff",
                      withinvars = c("condition", "trialxcondition"), 
                      idvar = "id")

dataID = ddply(data, .(id), summarise, diff = mean(diff, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

empty2 = subset(HED, condition == 'Empty')
MS2 = subset(HED, condition == 'MilkShake')
data2 = MS2
data2$diff = MS2$perceived_liking - empty2$perceived_liking
groupmean = ddply(data2, .(group), summarise, diff = mean(diff, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 



idplus = subset(dataID, diff >= 0)
idminus = subset(dataID, diff <= 0)

ggplot(data, aes(x = trialxcondition, y = diff)) +
  geom_point(data = data, size = 0.5, color = 'royalblue', alpha = .4) +
  geom_line(data = data, aes(group = id), color = 'royalblue', alpha = .2) +
  geom_line(data= dataT, alpha = .9, group=1) +
  geom_point(data= dataT, alpha = .9, size = 0.5) +
  geom_abline(slope= 0, intercept=0, linetype = "dashed", color = "black") + 
  geom_ribbon(data= dataT, aes(x = 1:length(trialxcondition), ymax = diff + sd, ymin = diff -sd), alpha = 0.5) 


