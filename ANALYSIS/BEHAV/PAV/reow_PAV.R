df <- summarySE(PAV, measurevar="RT_TC", groupvars=c("id", "condition"))
bcRT_TC <- summarySEwithin(df,
                        measurevar = "RT_TC",
                        withinvars = "condition", 
                        idvar = "id")

#need Rmisc


# get liking  means by participant (with baseline)

df <- summarySE(PAV, measurevar="likC", groupvars=c("id", "condition"))
bcLIK <- summarySEwithin(df,
                         measurevar = "likC",
                         withinvars = "condition", 
                         idvar = "id")

###################### do the plot ###########################
add.alpha <- function(col, alpha=1){
  apply(sapply(col, col2rgb)/255, 2, 
        function(x) 
          rgb(x[1], x[2], x[3], alpha=alpha))}


Alpha <- add.alpha('black', alpha=0.4)




###################### start the plot ###########################

#par(mar = c(5, 1.8, 2, 2))
par(mar = c(5, 5,5,5))
#
#rownames(bcLIK) <- 1:nrow(bcLIK)

#bcLIK$condition = factor(bcLIK$condition,levels(bcLIK$condition)[c(2,1,3)])

ggplot() + 
  geom_bar(bcLIK, mapping = aes(x = condition, y = likC), stat = "identity", fill = "white") +
  geom_point(bcRT_TC, mapping = aes(x = condition, y = RT_TC)) +
  geom_errorbar(bcRT_TC, mapping = aes(x = condition, y = RT_TC, ymin=bcRT_TC$RT_TC-bcRT_TC$se, ymax=bcRT_TC$RT_TC+bcRT_TC$se), width=.1, color = 'black')+
  geom_line(bcRT_TC, mapping = aes(x = condition, y = RT_TC, group =1), color = 'black', lty = 4) + 
  theme(plot.margin = margin(2, 2, 2, 2, "cm")) +
  ylim(-0.5, 0.5) + 
  theme_void()

par(new = TRUE)

bcLIK <- bcLIK[order(-bcLIK$likC),]

foo <- barplot(bcLIK$likC,names.arg=bcLIK$condition,xlab="Pavlovian Stimulus",ylab="Liking Ratings",col=Alpha, space = 1, ylim
               = c(-0.5,0.5), border=NA)



for (i in 1:length(bcLIK)){
  arrows(x0=foo[i],y0=bcLIK$likC[i]-bcLIK$se[i],y1=bcLIK$likC[i]+bcLIK$se[i],angle=90,code=3,length=0.05)
}
##

par(new = TRUE)
x = c(1:1000)
y = c(1:1000)
plot(x, y, ylim = c(0,500), axis(4, lty=4), col.axis = "black", lwd = 0.5, cex.axis = 0.5)
legend("topright", inset=.05, legend=c("Pleasantness Ratings", "Latency"),
       col=c(Alpha, "black"), lty=c(1,4), lwd=c(8,2), cex=0.8, box.lty=0)

