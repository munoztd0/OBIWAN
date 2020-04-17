library(lme4)
library(lattice)

## LOADING AND INSPECTING THE DATA
sleep <- read.table("https://drive.switch.ch/index.php/s/9JfbAPQl5YzJyHb/download",header=TRUE,sep=",")

sleep[1:10,]
dim(sleep)
str(sleep)
edit(sleep)


## SIMPLE PLOTS
plot(Attention~Deprivation,data=sleep,col="grey50",pch="+")
xyplot(Attention~Deprivation,groups=Subject,data=sleep,pch="+",cex=1.5)


## RANDOM INTERCEPT MODEL
rint <- lmer(Attention ~ 1 + Deprivation + (1|Subject),data=sleep)
summary(rint)


## INFERENTIAL TESTS WITH LMERTEST
library(lmerTest)
rint <- lmer(Attention ~ 1 + Deprivation + (1|Subject),data=sleep)
summary(rint)


## VISUALIZING SUBJECT 6 VERSUS POPULATION
plot(Attention~Deprivation,data=sleep,ylab="Standardized attention",xlab="Hours of sleep deprivation",
 pch="+",col="grey60",xlim=c(0,10),ylim=c(-2.5,2.5))
abline(a=1.42218,b=-0.28006,lwd=2,col="black")
points(Attention~Deprivation,data=sleep,subset=Subject=="ID6",pch="+",col="blue")
abline(a=1.42218-1.30205651,b=-0.28006,lwd=1.2,col="blue")
legend("topright",legend=c("Population","ID6"),col=c("black","blue"),title="Slope",lwd=3,seg.len=2,bty="n")


## RANDOM SLOPE MODEL
rslope <- lmer(Attention~1+Deprivation+(1+Deprivation|Subject),data=sleep)
summary(rslope)

## COMPARING RANDOM EFFECTS BY INFORMATION CRITERIA
AIC(rint) ; BIC(rint)
AIC(rslope) ; BIC(rslope)