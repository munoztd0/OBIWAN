ggplot(subset(INST, trialcat %in% c("1-5")), aes(trial, id, fill= z)) + 
  geom_tile() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

factor(INST$trialcat,levels(INST$trialcat)[c(1,5,2,3,4)])

INST <- INST %>% group_by(id) %>% mutate(pissC = center(piss))

INST$z <- ave(INST$grips, INST$id, FUN=scale)
INST$trialcat <- c(1:length(INST$trial))
INST$trialcat[INST$trial<=25] <- "21-25"
INST$trialcat[INST$trial<=20] <- "16-20"
INST$trialcat[INST$trial<=15] <- "11-15"
INST$trialcat[INST$trial<=10] <- "6-10"
INST$trialcat[INST$trial<= 5] <- "1-5"