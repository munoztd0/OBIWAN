library(lme4)
library(lmerTest)
library(lattice)
library(r2glmm)
library(MuMIn)
library(car)
source("https://drive.switch.ch/index.php/s/ZjAezR7ehy7xZhP/download")


## LOADING AND INSPECTING THE DATA
resto <- read.table("https://drive.switch.ch/index.php/s/L9DmmfqSGhoYKJI/download",header=TRUE)
resto[sample(1:600,6),]
dim(resto)
str(resto)


## VISUALIZING DIFFERENCES IN STAR CLASSES
resto.star.means <- aggregate(Quality~Stars+Criterion,data=resto,FUN=mean)
barchart(Quality~I(as.factor(Stars)),groups=Criterion,data=resto.star.means)


## CREATE CATEGORICAL STARS VARIABLE & RECODE FACTORS
resto$Starcat <- as.factor(resto$Stars)
contrasts(resto$Starcat) <- contr.sum(3)
contrasts(resto$Criterion) <- contr.sum(4)


## THREE-LEVEL HIERARCHICAL MODEL
mod1 <- lmer(Quality~Starcat*Criterion+(1|Region)+(1|Restaurant)+(1|Critic),data=resto)
summary(mod1)


## INFORMATION CRITERIA SELECTION OF RANDOM EFFECTS MODELS
mod2 <- lmer(Quality~Starcat*Criterion+(1|Region),data=resto)
mod3 <- lmer(Quality~Starcat*Criterion+(1|Restaurant),data=resto)
mod4 <- lmer(Quality~Starcat*Criterion+(1|Critic),data=resto)
mod5 <- lmer(Quality~Starcat*Criterion+(1|Region)+(1|Restaurant),data=resto)
mod6 <- lmer(Quality~Starcat*Criterion+(1|Region)+(1|Critic),data=resto)
mod7 <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto)

AIC(mod2) ; BIC(mod2)
AIC(mod3) ; BIC(mod3)
AIC(mod4) ; BIC(mod4)
AIC(mod5) ; BIC(mod5)
AIC(mod6) ; BIC(mod6)
AIC(mod7) ; BIC(mod7)
AIC(mod1) ; BIC(mod1)

ranova(mod1)
ranef(mod1)

## RANDOM EFFECTS ESTIMATES
mod2 <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto)
ranef(mod2)
par(mfrow=c(1,3))
Boxplot(ranef(mod2)$Critic,main="Critics")
Boxplot(ranef(mod2)$Restaurant,main="Restaurants")
Boxplot(ranef(mod2)$Region,main="Regions")


## FIXED EFFECTS SELECTION
mod3 <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
summary(mod3)
anova(mod3,type=2)

par(mfrow=c(1,3),cex.axis=1.5,cex.lab=1.5,mar=c(5,5,3,0.5),cex.main=1.5)
visreg(mod3,xvar="Criterion",cond=list(Starcat=0),points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=5),ylab="Rating",ylim=c(50,100),
 main="0 stars",fill.par=list(col=adjustcolor("slategray3",0.5)))
visreg(mod3,xvar="Criterion",cond=list(Starcat=1),points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=5),ylab="Rating",ylim=c(50,100),
 main="1 stars",fill.par=list(col=adjustcolor("slategray3",0.5)))
visreg(mod3,xvar="Criterion",cond=list(Starcat=2),points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=5),ylab="Rating",ylim=c(50,100),
 main="2 stars",fill.par=list(col=adjustcolor("slategray3",0.5)))


## POST-HOC FOLLOW-UPS
difflsmeans(mod3)
ls_means(mod3)

library(emmeans)
joint_tests(mod3,by="Starcat")


## R-SQUARED BREAKDOWN
r2beta(lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE),method="nsj")

r.squaredGLMM(lmer(Quality~1+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE))
r.squaredGLMM(lmer(Quality~Starcat+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE))
r.squaredGLMM(lmer(Quality~Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE))
r.squaredGLMM(lmer(Quality~Starcat+Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE))
r.squaredGLMM(lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE))


## FIXED VERSUS RANDOM EFFECT
mod4 <-  lmer(Quality~Starcat*Criterion+Region+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
anova(mod4,type=2)


## RANDOM SLOPES WITH MULTIPLE HIERARCHIES
model <- lmer(Quality~Starcat*Criterion+Service+Gender+Opensince+Location+(1|Restaurant)+(1|Critic),data=resto,REML=TRUE)
anova(model,type=2)
summary(model)

model <- lmer(Quality~Starcat*Criterion+Service+Gender+Opensince+Location+(1+Opensince+Gender+Service|Region) + (1+Gender+Service|Restaurant) + (1|Critic),data=resto,REML=TRUE)
ranef(model)
boxplot(ranef(model)$Restaurant$ServiceLunch)

AIC(lmer(Quality~Starcat*Criterion+Service+Gender+Opensince+Location+(1+Opensince+Gender+Service|Region) + (1+Gender+Service|Restaurant) + (1|Critic),data=resto,REML=TRUE))
summary(lmer(Quality~Starcat*Criterion+Service+Gender+Opensince+Location+(1+Opensince+Gender+Service|Region) + (1+Gender+Service|Restaurant) + (1|Critic),data=resto,REML=TRUE))

AIC(lmer(Quality~Starcat*Criterion+Service+Gender+Opensince+Location+(1+Gender+Service|Region) + (1+Gender+Service|Restaurant) + (1|Critic),data=resto,REML=TRUE))
summary(lmer(Quality~Starcat*Criterion+Service+Gender+Opensince+Location+(1+Gender+Service|Region) + (1+Gender+Service|Restaurant) + (1|Critic),data=resto,REML=TRUE))

AIC(lmer(Quality~Starcat*Criterion+Service+Gender+Opensince+Location+ (1|Restaurant) + (1|Critic),data=resto,REML=TRUE))
summary(lmer(Quality~Starcat*Criterion+Service+Gender+Opensince+Location+ (1|Restaurant) + (1|Critic),data=resto,REML=TRUE))
