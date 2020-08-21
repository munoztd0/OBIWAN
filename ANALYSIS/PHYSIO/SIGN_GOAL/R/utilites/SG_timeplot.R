SG_timeplot <- function (database, DV, cluster, timeunit, titley, groupx)
{ # this  function does the time plot in function of the group
  # for now it does not save (to be added)

  
# enter variables
database$timeunit <- eval(substitute(timeunit), database)
database$DV <- eval(substitute(DV), database) 
database$cluster <- eval(substitute(cluster), database) 


BS = ddply(database, .(ID,timeunit,cluster), summarise, DV = mean(DV , na.rm = T)) 
BC = ddply(database, .(timeunit,cluster), summarise, DV  = mean(DV , na.rm = T)) 
ggplot(BS, aes(x = timeunit, y = DV , group = cluster, fill = cluster, color = cluster)) +
  geom_point(data = BS, stat = 'identity', alpha = .3,position = position_jitterdodge(jitter.width = .2, jitter.height = 0)) +
  geom_line(data = BC, stat = 'identity') +
  geom_point(data = BC, stat = "identity", size = 4) +
  theme_classic() +
  theme(plot.title = element_text(face = "bold"), axis.text = element_text(colour = "black")) +
  labs(
    title = paste(titley ,"over time", groupx), 
    x = "BINS (9 trials)",
    y = titley
  ) + 
  theme_linedraw(base_size = 10, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 10, face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x  = element_blank(),
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"))  


}

