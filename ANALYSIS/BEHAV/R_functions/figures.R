library("ggpubr")
library("grid")
library("magick")
library("cowplot")




# behav figures -----------------------------------------------------------

PIT_grips = image_read_pdf('~/REWOD/DERIVATIVES/BEHAV/FIGURES/neat/PIT_n_grips.pdf')
HED_ratings = image_read_pdf('~/REWOD/DERIVATIVES/BEHAV/FIGURES/neat/HED_ratings.pdf')

PIT_trial = image_read_pdf('~/REWOD/DERIVATIVES/BEHAV/FIGURES/neat/PIT_trial.pdf')
HED_trial = image_read_pdf('~/REWOD/DERIVATIVES/BEHAV/FIGURES/neat/HED_trial.pdf')

A1 <-  rasterGrob(HED_trial, interpolate=TRUE)
A2 <-  rasterGrob(HED_ratings, interpolate=TRUE)


A3 <-  rasterGrob(PIT_trial, interpolate=TRUE)
A4 <-  rasterGrob(PIT_grips, interpolate=TRUE)


# arranging ---------------------------------------------------------------


# figure1 <- ggarrange(A1,A2,A3,A4,
#                      labels = c("   A", "   B", "   C", "   D"),
#                      ncol = 2, nrow = 2,
#                      vjust=3, hjust=0) 
# 
# figure1

lay <- rbind(c(1,2),c(3,4))

grid.arrange(A1,A2, A3, A4, layout_matrix=lay, widths = c(2, 1)) # Widths of the two columns)
