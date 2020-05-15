packageurl <- "https://cran.r-project.org/src/contrib/Archive/pbkrtest/pbkrtest_0.4-4.tar.gz"
install.packages(packageurl, repos=NULL, type="source")
pacman::p_load(lme4, car, afex, optimx)

load('~/OBIWAN/DERIVATIVES/BEHAV/HED.RData')