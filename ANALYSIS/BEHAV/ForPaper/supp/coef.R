#looking at coeficients time 0 # takes a while
coef.out <- function(merMod) { coef(merMod)$id[,2] } #column 2 is coeficient for CS+ (diff from 0 to CS-)
set.seed(666)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=1000,use.u=TRUE,type="parametric"))
coef.conf = confint(boot.out,method="boot",boot.type="perc",level=0.95)
coef.conf2= as_tibble(cbind(ID, coef.conf)); coef.conf2$group = ifelse(coef.conf2$ID > 199, "obese", "lean")
coef.conf2$preval = ifelse(coef.conf2$`2.5 %` > 0, 0, 1)
#This paints a slightly more interesting picture. We have 28 person 
#with no significant decreases  (95%) in grips for the CS- stimulus,
#In other words, the proportion of people showing a PIT effect is 
#estimated to be 45% (23/51)!. -