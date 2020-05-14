#ANOVA test 
#2: Missing values for following ID(s):
#c(201, 208, 210, 214, 216, 219, 222, 223, 233, 240, 245, 247, 249, 258, 263, 267)
HED_test <-  HED[!HED$id %in% c("201", "208", "210", "214", "216", "219", "222", "223", "233", "240", "245", "247", "249", "258", "263", "267"), ] #, 208, "210", "214", "216", "219", "222", "223", "233", "240", "245", "247", "249", "258", "263", "267")) #all  that didnt have Post test

HED_test$perceived_familiarity = ddply(HED, .(id, con), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 

#scale everything
HED_test$likZ= scale(HED_test$perceived_liking)
HED_test$famZ = scale(HED_test$perceived_familiarity)
HED_test$intZ = scale(HED_test$perceived_intensity)
HED_test$ageZ = hscale(HED_test$age, HED_test$id) #agragate by subj and then scale 

#create BMI diff #double check
HED_test$diff_Z = hscale(HED_test$BMI_t1 - HED_test$BMI_t2, HED_test$id)
HED_test$bmi_T0 = hscale(HED_test$BMI_t1, HED_test$id)

# MANOVA ANALYSIS
mglm.stat <- with(HED_test,manova(cbind(likZ, famZ, intZ) ~ condition*time*intervention + Error(id/condition*time)))
summary(mglm.stat)


##MEDIATION ANALYSIS
library(mediation)
library(lme4)
mglm.stat <- with(HED_test,manova(cbind(likZ, intZ) ~ condition*time*intervention + Error(id/condition*time)))

med.fit <- lmer(famZ ~ condition*time*intervention + (1|id), data = HED_test)
out.fit <- lmer(likZ ~ famZ*condition*time*intervention + (famZ|id), data = HED_test)

med.out <- mediate(med.fit, out.fit, treat = "condition", mediator = "famZ",sims = 100)
summary(med.out)