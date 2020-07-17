#do a double axis plot with grip force and n grips

df <- summarySE(INST, measurevar="grips", groupvars=c("id", "trial"))
dfTRIAL <- summarySEwithin(df,
                           measurevar = "grips",
                           withinvars = "trial", 
                           idvar = "id")

df <- summarySE(INST, measurevar="auc", groupvars=c("id", "trial"))
dfTRIAL <- summarySEwithin(df,
                           measurevar = "auc",
                           withinvars = "trial", 
                           idvar = "id")



dfTRIAL$trial        <- as.numeric(dfTRIAL$trial)
##plot grips to see the trajectory of learning (overall average by trials)


ggplot(dfTRIAL, aes(x = trial, y = auc)) +
  geom_point() + geom_line(group=1) +
  geom_errorbar(aes(ymin=auc-se, ymax=auc+se), color='grey', width=.3,
                position=position_dodge(0.05), linetype = "dashed") +
  theme_classic() +
  #scale_y_continuous(expand = c(0, 0), limits = c(10,14)) + #, breaks = c(9.50, seq.int(10,15, by = 1)), ) +
  scale_x_continuous(expand = c(0, 0), limits = c(0,25), breaks=c(0, seq.int(1,25, by = 3))) + #,breaks=c(seq.int(1,24, by = 2), 24), limits = c(0,24)) + 
  labs(x = "Trial
          ",
       y = "Number of Squeezes",title= "   
       ") +
  theme(text = element_text(size=rel(4)), plot.margin = unit(c(1, 1,0, 1), units = "cm"), axis.title.x = element_text(size=16), axis.title.y = element_text(size=16))
