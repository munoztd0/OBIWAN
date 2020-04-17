library(lme4)
library(lmerTest)
library(lattice)
library(visreg)
source("https://drive.switch.ch/index.php/s/ZjAezR7ehy7xZhP/download")

## LOADING AND INSPECTING THE DATA
priming <- read.table("https://drive.switch.ch/index.php/s/BZCVZC1142BAiJs/download",header=TRUE,sep=",")
priming[priming$Subject=="ID7",][1:10,]
dim(priming)
str(priming)

## VISUALIZING THE PRIMING EFFECT
mysettings <- list(
  superpose.polygon=list(col=c("maroon","lightgoldenrod"), border="transparent"),
  strip.background=list(col=c("lightsteelblue")),
  strip.border=list(col="black")
)
barchart(RT~Prime,groups=Target,data=aggregate(RT~Prime+Target,data=priming,FUN=mean),
 col=c("maroon","lightgoldenrod"),par.settings=mysettings,ylab="Average RT",
 auto.key=list(columns=2,space="top",points=FALSE,rectangles=TRUE,title="Target",cex.title=1),xlab="Prime",ylim=c(500,600))


## CROSSED RANDOM EFFECTS
model <- lmer(RT~Prime*Target+(1|Subject)+(1|Pword)+(1|Tword),data=priming)
summary(model)

AIC(lmer(RT~Prime*Target+(1|Subject)+(1|Pword)+(1|Tword),data=priming))
AIC(lmer(RT~Prime*Target+(1|Subject)+(1|Tword),data=priming))
AIC(lmer(RT~Prime*Target+(1|Subject)+(1|Pword),data=priming))
AIC(lmer(RT~Prime*Target+(1|Subject),data=priming))

system.time(model2 <- lmer(RT~Prime*Target+(1+Prime+Target|Subject)+(1|Pword)+(1|Tword),data=priming))
system.time(model3 <- lmer(RT~Prime*Target+(1+Prime*Target|Subject)+(1|Pword)+(1|Tword),data=priming))
system.time(model4 <- lmer(RT~Prime*Target+(1+Prime*Target||Subject)+(1|Pword)+(1|Tword),data=priming))
system.time(model5 <- lmer(RT~Prime*Target+(1+Prime*Target|Subject)+(1|Pword)+(1+Prime*Target|Tword),data=priming))
AIC(model2) ; AIC(model3) ; AIC(model4) ; AIC(model5)

summary(model3)
ranef(model3)
coef(model3)$Subject[1:20,]

## ANOVA OUTPUT
contrasts(priming$Prime) <- contr.sum(2)
contrasts(priming$Target) <- contr.sum(2)
anova(model3,type=2)
difflsmeans(model3)
ls_means(model3)
r2beta(model3,method="nsj")

visreg(model3,xvar="Prime",by="Target",overlay=TRUE,points.par=list(col=adjustcolor(c("maroon","lightgoldenrod"),alpha=0.1)),line.par=list(lwd=6,col=c("maroon","darkgoldenrod")),
 fill.par=list(col=c("grey80")),ylab="Reaction time (ms)")