library(lme4)
library(lmerTest)
source("https://drive.switch.ch/index.php/s/ZjAezR7ehy7xZhP/download")


## LOADING AND INSPECTING THE DATA
sleep2 <- read.table("https://drive.switch.ch/index.php/s/23DhWwECFnCFH4M/download",header=TRUE,sep=",")
sleep2[1:10,]
dim(sleep2)
str(sleep2)


## STANDARDIZE CONTINUOUS VARIABLES AND RECODE FACTORS
sleep2$Age <- hscale(sleep2$Age,sleep2$Subject)
sleep2$Deprivation <- scale(sleep2$Deprivation)
sleep2$Bodytemp <- scale(sleep2$Bodytemp)

contrasts(sleep2$Gender) <- contr.sum(2)
contrasts(sleep2$Gender)


## BASIC RANDOM INTERCEPT MODEL
rint <- lmer(Attention ~ 1 + Gender + Age + Bodytemp + Deprivation + (1|Subject), data=sleep2)
summary(rint)


## COMPARING RANDOM EFFECTS MODELS
mod1 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1|Subject),data=sleep2)
mod2 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1+Deprivation|Subject),data=sleep2)
mod3 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1+Bodytemp|Subject),data=sleep2)
mod4 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1+Deprivation+Bodytemp|Subject),data=sleep2)

AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)


## BEST RANDOM SLOPE MODEL
rslope <- lmer(Attention ~ 1 + Gender + Age + Bodytemp + Deprivation + (1+Deprivation|Subject), data=sleep2)
summary(rslope)
ranova(rslope)

## REML VERSUS ML
mod1 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1+Deprivation|Subject),data=sleep2,REML=FALSE)
mod2 <- lmer(Attention~Gender+Age+Deprivation+(1+Deprivation|Subject),data=sleep2,REML=FALSE)
AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)


## TESTING THE RANDOM INTERCEPT
mod1 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1|Subject),data=sleep2,REML=FALSE)
mod2 <- lm(Attention~Gender+Age+Bodytemp+Deprivation,data=sleep2)

AIC(mod1) ; BIC(mod1)
AIC(mod2) ; BIC(mod2)


## R-SQUARED IN MULTILEVEL MODELS
library(r2glmm)
library(MuMIn)

r2beta(rslope,method="nsj")

mod1 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1+Deprivation|Subject),data=sleep2,REML=FALSE)
mod2 <- lmer(Attention~Gender+Age+Bodytemp+(1+Deprivation|Subject),data=sleep2,REML=FALSE)
r.squaredGLMM(mod1)
r.squaredGLMM(mod2)

mod1 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1|Subject),data=sleep2,REML=FALSE)
mod2 <- lmer(Attention~Gender+Age+Bodytemp+(1|Subject),data=sleep2,REML=FALSE)
r.squaredGLMM(mod1)
r.squaredGLMM(mod2)


## PLOTTING
library(visreg)
mod1 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+(1+Deprivation|Subject),data=sleep2,REML=FALSE)
visreg(mod1,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

model <- lmer(Attention~Age*Deprivation+(1+Deprivation|Subject),data=sleep2)
visreg(model,xvar="Deprivation",by="Age",gg=TRUE,type="contrast",ylab="Attention (z)",breaks=c(-2,0,2),xlab="Deprivation (z)")


## PROBLEMS AND RESIDUAL DIAGNOSTICS
sleep2 <- read.table("https://drive.switch.ch/index.php/s/23DhWwECFnCFH4M/download",header=TRUE,sep=",")
model <- lmer(Attention~Gender+Bodytemp+Deprivation*Age+(1+Deprivation+Bodytemp|Subject),data=sleep2)
summary(model)

library(car)
vif(model)
sleep2$Age <- hscale(sleep2$Age,sleep2$Subject)
sleep2$Deprivation <- scale(sleep2$Deprivation)
sleep2$Bodytemp <- scale(sleep2$Bodytemp)

model <- lmer(Attention~Gender+Bodytemp+Deprivation*Age+(1+Deprivation+Bodytemp|Subject),data=sleep2)
vif(model)

boxplot(scale(ranef(model)$Subject),ylab="Standardized estimate of deviation")

set.seed(1816)
im <- influence(model,maxfun=100)
influenceIndexPlot(im,col="steelblue",vars=c("cookd"))
influenceIndexPlot(im,col="steelblue",vars=c("dfbetas"))
dfbetas(im)

par(mfrow=c(2,2))
hist(residuals(model),breaks=100,main="Untransformed",freq=FALSE,col="slategray",border="white")
lines(density(residuals(model)),lwd=3,col="firebrick")
hist(tdiagnostic(model)$tres,breaks=100,main="Transformed",freq=FALSE,col="slategray",border="white")
lines(density(tdiagnostic(model)$tres),lwd=3,col="firebrick")
qqnorm(residuals(model),pch=4,col="bisque3") ; qqline(residuals(model),col="darkblue",lwd=2)
qqnorm(tdiagnostic(model)$tres,pch=4,col="bisque3") ; qqline(tdiagnostic(model)$tres,col="darkblue",lwd=2)

par(mfrow=c(1,2))
plot(fitted(model),residuals(model),pch=4,col="slategray",ylab="Untransformed residuals",xlab="Untransformed fitted values",ylim=c(-3,3))
abline(h=0,lty=2,lwd=2)
plot(tdiagnostic(model)$tfit,tdiagnostic(model)$tres,pch=4,col="slategray",ylab="Transformed residuals",xlab="Transformed fitted values",ylim=c(-3,3))
abline(h=0,lty=2,lwd=2)
