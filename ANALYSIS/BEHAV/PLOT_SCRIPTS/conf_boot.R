looking at coeficients
coef.out <- function(merMod) { coef(merMod)$id[,2] } #change column number here
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=99,use.u=TRUE))
confint(boot.out,method="boot",boot.type="perc",level=0.95)

#looking at sum of coeficients
coef.out <- function(merMod) { 
  coef(merMod)$id[,2] + coef(merMod)$id[,3]}
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=99,use.u=TRUE))
confint(boot.out,method="boot",boot.type="perc",level=0.95)


#### The rest on plot_INST_T0 - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------

# Random variation in store sales after advertising is supported by AIC/BIC, showing lower values for the model with a random spline effect (AIC=6827) than one without (AIC=7406). As well, the LRT is significant.
# Summary output indicates that there is a significant fixed spline effect. In other words, the linear trend of sales changes significantly after the start of the advertising campaign, -4.87 versus -4.87+12.95=8.08
# -> hich indicate all regression coefficients are significantly different from 0.