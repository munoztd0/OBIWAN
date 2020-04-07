pacman::p_load(ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, mosaic)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


participants <- read.delim("~/REWOD/participants.tsv")
mean(participants$age)
sd(participants$age)
count(participants$sex)
min(participants$age)
max(participants$age)
