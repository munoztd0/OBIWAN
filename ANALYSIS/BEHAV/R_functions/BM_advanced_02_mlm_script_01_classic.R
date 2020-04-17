library(car)

## LOADING THE DATA
darts <- read.table("https://drive.switch.ch/index.php/s/Tym4l1XhHG37UbT/download",header=TRUE,sep=",")


## INSPECTING THE DATA
head(darts)
dim(darts)
str(darts)
table(darts$Hero,darts$Throw)
aggregate(Points~Hero,data=darts,FUN=mean)


## LONG FORMAT TO WIDE FORMAT
darts.wide <- reshape(darts,direction="wide",v.names="Points",timevar="Throw",idvar=c("Observation","Hero"))
darts.wide
cor(darts.wide[,3:5])


## REPEATED MEASURES ANOVA
within.design <- data.frame(Throw=as.factor(c("T1","T2","T3")))

model <- lm(cbind(Points.T1,Points.T2,Points.T3)~1,data=darts.wide)
result <- Anova(model,type=2,test="Wilks",idesign=~Throw,idata=within.design)
result^
summary(result)


## HERO EFFECT?
model <- lm(Points~Hero,data=darts)
Anova(model,type=2)

