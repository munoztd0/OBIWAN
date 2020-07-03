contgroup = emmeans(mod, pairwise~ condition|bmiZ, at = list(bmiZ = c(-1.36,0.17,0.92)), adjust = "mvt")
#get pval

cont = emmeans(mod, pairwise~ condition|bmiZ, at = list(bmiZ = c(-2,-1,0, 1, 2)), adjust = "mvt")

df = confint(cont)

df.PIT = as.data.frame(df$contrasts)

df.PIT %>%
  ggplot(aes(bmiZ, estimate)) +
  geom_line() +
  geom_ribbon(aes(ymin=lower.CL, ymax=upper.CL), alpha = .1) +
  geom_point(data = df.observed, size = 0.5, alpha = 0.4, color = 'royalblue', position = position_jitter(width = 0.2)) +
  ylab("Delta effort (z)")





#pwpp(cont$emmeans)
plot(cont, comparisons = TRUE, horizontal = FALSE) #no overlapping red arrow-> signif
df.PIT = as.data.frame(cont$contrasts) 
df.PIT$bmiZ <- as.character(df.PIT$bmiZ)

eff_size(em$emmeans,  sigma = sigma(mod), edf = inf)
eff_size(pairs(em$emmeans,), sigma = sigma(mod), edf = 86, method = "identity")
         
em = emmeans(mod, pairwise~ condition|bmiZ, at = list(bmiZ = c(-1.36,0.17,0.92)), adjust = "mvt")
m.emm = as.data.frame(em$emmeans) 
CSPlus <- subset(m.emm, condition =="1" )
CSMinus <- subset(m.emm, condition =="-1" )
diff = CSPlus - CSMinus
diff$bmiZ = c(-1.36,0.17,0.92)
m.emm = ddply(m.emm, (.condition), )
df = ddply(m.emm, .(bmiZ), summarise, emmean = mean(emmean), SE = mean(SE), df = mean(df), lower.CL = mean(lower.CL), upper.CL = mean(upper.CL))
df$emmean = diff$emmean  
diff %>%
  ggplot(aes(bmiZ, emmean)) +
  geom_line() +
  geom_ribbon(aes(ymin=lower.CL, ymax=upper.CL), alpha = .1) +
  ylab("Delta effort (z)")

mylist <- list(bmiZ = c(-1.36,0.17,0.92), condition=c("1","-1"))
emmip(mod, condition ~bmiZ, at=mylist,CIs=FALSE)
         
mydf <-  ggeffects::ggpredict(mod, terms = c("bmiZ", "condition"),
                  ci.lvl = 0.95,
                  type = "fe")

ggplot(mydf, aes(x, predicted, color= group)) +
  geom_line() +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = .1)

df.predicted <- ggeffects::ggpredict(
  model = mod,
  terms = c("condition", "bmiZ"),
  ci.lvl = 0.95,
  type = "fe")
df.predicted <- tibble(df.predicted)

df.observed = ddply(PIT, .(id, condition, bmiZ), summarise, predicted = mean(gripZ, na.rm = TRUE)) 

#change value of groups to plot
PIT$group2 = c(1:length(PIT$group))
PIT$group2[PIT$BMI_t1 < 30 ] <- '-1.36' # control BMI = 22.25636 -> -1.36,
PIT$group2[PIT$BMI_t1 >= 30 & PIT$BMI_t1 < 35] <- '0.17' # Class I obesity: BMI = 30 to 35. -> 0.17
PIT$group2[PIT$BMI_t1 >= 35] <- '0.92' # Class II obesity: BMI = 35 to 40. -> 0.92)
#PIT$group2[PIT$BMI_t1 > 40] <- '3' # Class III obesity: BMI 40 or higher -> 1.89

N_group2 = ddply(PIT, .(id, group2), summarise, group2=mean(as.numeric(group2)))  %>%
  group_by(group2) %>% tally()

BMI_group = ddply(PIT, .(group2), summarise, bmi=mean(bmiZ)) 

full.obs = ddply(PIT, .(id, bmiZ, condition), summarise, predicted = mean(gripZ)) 
plus = subset(full.obs, condition == '1')
minus = subset(full.obs, condition == '-1')
df.observed = minus
df.observed$predicted = plus$predicted - minus$predicted
#df.observed$bmiZ = df.observed$group2

labels <- c("-1.36" = "Lean", "0.17" = "Class I" , "0.92" = "II-III")

# pl <-  ggplot(df.PIT, aes(x = bmiZ, y = estimate)) +
#   #geom_bar(stat="identity", alpha=0.6, width=0.3, ) +
#   geom_errorbar(aes(ymax = estimate + SE, ymin = estimate - SE), width=0.05,  alpha=1)+
#   geom_point(size = 0.5, color = 'blue') + 
#   geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) + 
#   geom_point(data = df.observed, size = 0.1, alpha = 0.4, color = 'royalblue',  position = position_jitter(width = 0.1))

pl <-  ggplot(df.PIT, aes(x = bmiZ, y = predicted)) +
  geom_point(data = df.observed, size = 0.1, alpha = 0.4, color = 'royalblue', position = position_jitter(width = 0.2)) +
  geom_bar(data =df.PIT, stat="identity", alpha=0.6, width=0.3) +
  geom_errorbar(data =df.PIT,  aes(ymax = estimate + SE, ymin = estimate - SE), color = 'black', width=0.05,  alpha=0.7)+
  geom_point(size = 0.7, color = 'black') + 
  geom_hline(yintercept=0, linetype="dashed", size=0.4, alpha=0.7) 
