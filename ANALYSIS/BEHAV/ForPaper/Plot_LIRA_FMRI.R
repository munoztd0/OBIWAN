
if(!require(pacman)) {
  install.packages("pacman")
  install.packages("devtools")
  library(pacman)
}

pacman::p_load(tidyverse, dplyr, plyr, Rmisc, sjPlot, afex)

# get tool
devtools::source_gist("2a1bb0133ff568cbe28d", 
                      filename = "geom_flat_violin.R")
# Set path
home_path       <- '~/OBIWAN'

# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/BEHAV/ForPaper')
figures_path  <- file.path(home_path, 'DERIVATIVES/FIGURES/BEHAV/') 
setwd(analysis_path)

subj = c(202, 203, 204, 209, 213, 217, 220, 224, 225, 235, 236, 237, 238, 239, 241, 246, 250, 259, 264, 265, 266, 269, 270, 205, 206, 207, 211, 215, 218, 221, 227, 229, 230, 231, 232, 244, 248, 251, 252, 253, 254, 262, 268)

#datasets dictory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 

cov  <- read.delim(file.path(data_path,'covariate_LIRA.txt'), header = T, sep ='') #

data <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/RM_LIRA_new/RawData_6_27_-24.txt", header=FALSE)
data$V5 = subj
colnames(data) <- c('Milk_pre', 'Milk_post', 'Tasteless_pre', 'Tasteless_post', 'id')

df1 <- gather(data, session, MilkShake, c(Milk_pre,Milk_post), factor_key=TRUE)
df1$session = as.factor(revalue(df1$session, c(Milk_pre="second", Milk_post="third"))); df1 = select(df1, c(id, session, MilkShake))

df2 <- gather(data, session, Empty, c(Tasteless_pre,Tasteless_post), factor_key=TRUE)
df2$session = as.factor(revalue(df2$session, c(Tasteless_pre="second", Tasteless_post="third"))); df2 = select(df2, c(id, session, Empty))

diff = df2; diff$score =  df1$MilkShake -df2$Empty

#2x2
# df = merge(df1, df2 , by=c('id', 'session')); df <- gather(df, condition, beta_coef, c(MilkShake,Empty), factor_key=TRUE) #, 
df = merge(diff, cov , by= 'id'); df$intervention = as.factor(df$intervention)

#interscore
diffPRE = subset(diff, session == 'second') ; diffPOST = subset(diff, session == 'third')
diffSES = diffPRE; diffSES$inter =  diffPOST$score - diffPRE$score

dft = merge(diffSES, cov , by= 'id'); 

mod = lm(data = dft, inter ~ intervention*GLP1 + intervention*Fast_glu + intervention*bmi + intervention*gender + intervention*age + intervention*piss + intervention*thirsty + intervention*hungry + intervention*insulin + intervention*AEA + intervention*PEA + intervention*OEA )

anova(mod)

# PLOT --------------------------------------------------------------------

averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position=c(.9,.9),
        legend.title  = element_text(size = 12),
        legend.text  = element_text(size = 10),
        legend.key.size = unit(0.2, "cm"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"),
        panel.grid.major.x = element_blank() ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size =  30),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())

pal = viridis::inferno(n=5); pal[6] = "#21908CFF" # add one # specialy conceived for colorblindness


# AVERAGED EFFECT
dfH <- summarySEwithin(df,  measurevar = "score",
                       withinvars =  'session',
                       betweenvars = "intervention", 
                       idvar = "id")

dfH$cond <- ifelse(dfH$intervention == "0", -0.25, 0.25)
df$cond <- ifelse(df$intervention == "0", -0.25, 0.25)
set.seed(666)
df <- df %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                    grouping = interaction(id, cond))


pp <- ggplot(df, aes(x = cond, y = score, 
                     fill = intervention, color = intervention)) +
  geom_hline(yintercept = 0) + 
  geom_point(data = dfH, alpha = 0.5) +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = intervention, color = NA))+
  geom_point(aes(x = condjit), alpha = .3,) +
  geom_crossbar(data = dfH, aes(y = score, ymin=score-ci, ymax=score+ci), width = 0.2 , alpha = 0.1)+
  ylab('Beta estimates (a.u.)') +
  xlab('mOFC') +
  #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(-0.5,100.5)) +
  scale_x_continuous(labels=c("Placebo", "Liraglutide"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("0"= pal[1], "1"=pal[6]), guide = 'none') +
  scale_color_manual(values=c("0"=pal[1], "1"=pal[6]), guide = 'none') +
  theme_bw() + facet_wrap(~session)

ppp <- pp + averaged_theme
ppp

cairo_pdf(file.path(figures_path,'Figure_HEDONIC_fMRI.pdf'))
print(ppp)
dev.off()

bf = ttestBF(formula = betas ~ condition, data = df); bf
t = t.test(formula = betas ~ condition, data = df); t