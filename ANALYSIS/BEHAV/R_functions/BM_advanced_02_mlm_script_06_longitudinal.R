library(lme4)
library(lmerTest)
library(lattice)
library(r2glmm)
library(boot)
source("https://drive.switch.ch/index.php/s/ZjAezR7ehy7xZhP/download")


## LOADING AND INSPECTING THE DATA
ponies <- read.table("https://drive.switch.ch/index.php/s/EhA63ePqbJrqUod/download",header=TRUE,sep=",")
ponies[1:10,]
dim(ponies)
str(ponies)


## REMOVE CASES WITH MISSING SALES DATA
ponies <- ponies[complete.cases(ponies),]


## VISUALIZING THE DATA (RUN ALL TOGETHER)
plot(Sales~Time,data=ponies,pch="+",col="plum4",ylim=c(0,50),ylab="Number of Robot Ponies sold",xlab="Days since tracking")
points(Sales~Time,data=ponies,subset=Store=="S20",pch=15,col="darkblue")
lines(aggregate(Sales~Time,data=ponies,FUN=mean),col="violetred3",lwd=3)
abline(v=30,lty=2)
legend("topleft",legend=c("Average sales per day","Start of campaign"),lwd=c(3,1),seg.len=2.5,col=c("violetred4","black"),lty=c(1,2),bty="n")
legend("topright",legend=c("All stores","Store 20"),pch=c(3,15),col=c("plum4","darkblue"),pt.cex=1.2,bty="n")


## QUADRATIC POLYNOMIAL REGRESSION
quadmod <- lmer(Sales~Time+I(Time^2)+(1+Time+I(Time^2)|Store),data=ponies)
summary(quadmod)


### SCALING OF TIME IS NECESSARY
ponies$Time.z <- scale(ponies$Time)
quadmod <- lmer(Sales~Time.z+I(Time.z^2)+(1+Time.z+I(Time.z^2)|Store),data=ponies)
summary(quadmod)
AIC(quadmod) ; BIC(quadmod)


## PIECEWISE REGRESSION WITH SPLINES
ponies$Time.s <- ifelse(ponies$Time.z<0.03, 0, ponies$Time.z-0.03)
splinemod <- lmer(Sales~Time.z+Time.s+(1+Time.z+Time.s||Store),data=ponies)
summary(splinemod)
AIC(splinemod) ; BIC(splinemod)
ranova(splinemod)

## COMPARISON OF POLYNOMIAL FIT VERSUS SPLINE FIT
par(mfrow=c(2,1))
plot(Sales~I(scale(Time)),data=ponies,pch="+",col="plum4",ylim=c(0,50),xlab="Standardized time",ylab="Number of Robot Ponies sold")
lines(aggregate(fitted(quadmod)~ponies$Time.z,FUN=mean),lwd=3,col="violetred4")
lines(fitted(quadmod)[ponies$Store=="S20"]~ponies$Time.z[ponies$Store=="S20"],lwd=2,col="darkblue")
lines(fitted(quadmod)[ponies$Store=="S27"]~ponies$Time.z[ponies$Store=="S27"],lwd=2,col="darkgoldenrod")
abline(v=0.03,lty=2)
legend("topleft",legend=c("Population trend","Store 20 trend","Store 27 trend","Start of campaign"),
 lwd=c(3,3,3,1),seg.len=2.5,col=c("violetred4","darkblue","darkgoldenrod","black"),lty=c(1,1,1,2),bty="n")
plot(Sales~I(scale(Time)),data=ponies,pch="+",col="plum4",ylim=c(0,50),xlab="Standardized time",ylab="Number of Robot Ponies sold")
lines(aggregate(fitted(splinemod)~ponies$Time.z,FUN=mean),lwd=3,col="violetred4")
lines(fitted(splinemod)[ponies$Store=="S20"]~ponies$Time.z[ponies$Store=="S20"],lwd=2,col="darkblue")
lines(fitted(splinemod)[ponies$Store=="S27"]~ponies$Time.z[ponies$Store=="S27"],lwd=2,col="darkgoldenrod")
abline(v=0.03,lty=2)
legend("topleft",legend=c("Population trend","Store 20 trend","Store 27 trend","Start of campaign"),
 lwd=c(3,3,3,1),seg.len=2.5,col=c("violetred4","darkblue","darkgoldenrod","black"),lty=c(1,1,1,2),bty="n")


## BOOTSTRAP TESTING
ponies <- read.table("https://drive.switch.ch/index.php/s/EhA63ePqbJrqUod/download",header=TRUE,sep=",")
set.seed(1502)
ponies$Sales[ponies$Store=="S11"][31:60] <- round(seq(14,2,length=30)+rnorm(30,0,2))
ponies$Time.z <- scale(ponies$Time)
ponies$Time.s <- ifelse(ponies$Time.z<0.03, 0, ponies$Time.z-0.03)

splinemod <- lmer(Sales~Time.z+Time.s+(1+Time.z+Time.s||Store),data=ponies)
summary(splinemod)
coef(splinemod)$Store

coef.out <- function(merMod) { coef(merMod)$Store[,3] }
set.seed(59)
system.time(boot.out <- bootMer(splinemod,FUN=coef.out,nsim=9999,use.u=TRUE,type="parametric"))
confint(boot.out,method="boot",boot.type="perc",level=0.999)

coef.out <- function(merMod) { coef(merMod)$Store[,2]+coef(merMod)$Store[,3] }
set.seed(59)
system.time(boot.out <- bootMer(splinemod,FUN=coef.out,nsim=9999,use.u=TRUE,type="parametric"))
confint(boot.out,method="boot",boot.type="perc",level=0.999)
