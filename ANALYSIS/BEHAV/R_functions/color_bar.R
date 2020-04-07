# Function to plot color bar
color.bar <- function(lut,  max, min=3, nticks=6, ticks=seq(min, max, len=nticks), title='') {
  scale = (length(lut)-1)/(max-min)
  
  #dev.new(width=1, height=5)
  plot(c(0,10O), c(0,5), type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='', main=title)
  axis(2, ticks, las=1)
  for (i in 1:(length(lut)-1)) {
    y = (i-1)/scale + min
    rect(0,y,10,y+1/scale, col=lut[i], border=NA)
  }
}

A5 <- color.bar(colorRampPalette(c("red", "yellow"))(100), 5)