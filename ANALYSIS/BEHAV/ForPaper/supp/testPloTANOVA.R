
if(!require(pacman)) {
  install.packages("pacman")
  install.packages("devtools")
  library(pacman)
}

pacman::p_load(tidyverse, dplyr, plyr, Rmisc, sjPlot)

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

HED  <- read.delim(file.path(data_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') #
HED = subset(HED, session = 'third'); HED = filter(HED, id %in% subj)
# HED  <- read.delim(file.path(data_path,'HED_covariateT1_Ratings.tsv'), header = T, sep ='');  HED$session = 'third'; HED = filter(HED, id %in% subj)
# HED2  <- read.delim(file.path(data_path,'HED_covariateT0_Ratings.tsv'), header = T, sep ='') ; HED2$session = 'second'; HED2 = filter(HED2, id %in% subj)
# bs = as_tibble(rbind(HED,HED2))

bs = ddply(HED, .(id, condition), summarise, lik = mean(perceived_liking, na.rm = TRUE), int = mean(perceived_intensity, na.rm = TRUE), fam = mean(perceived_familiarity, na.rm = TRUE)) #session
bs$id = as.factor(bs$id)

data <- read.delim("~/OBIWAN/DERIVATIVES/GLM/SPM/hedonicreactivity/RM_LIRA_lik/RawData_6_27_-24.txt", header=FALSE)
data$V5 = subj
colnames(data) <- c('Milk_pre', 'Milk_post', 'Tasteless_pre', 'Tasteless_post', 'id')

df1 <- gather(data, session, MilkShake, c(Milk_pre,Milk_post), factor_key=TRUE)
df1$session = as.factor(revalue(df1$session, c(Milk_pre="second", Milk_post="third"))); df1 = select(df1, c(id, session, MilkShake))

df2 <- gather(data, session, Empty, c(Tasteless_pre,Tasteless_post), factor_key=TRUE)
df2$session = as.factor(revalue(df2$session, c(Tasteless_pre="second", Tasteless_post="third"))); df2 = select(df2, c(id, session, Empty))

diff = df2; diff$score =  df1$MilkShake -df2$Empty

df = merge(df1, df2 , by=c('id', 'session')); df <- gather(df, condition, beta_coef, c(MilkShake,Empty), factor_key=TRUE) #, 

df = merge(df, bs , by= c('id', 'condition'));
#df = merge(diff, bs , by= c('id', 'session'));  'session',


info <- read.delim(file.path(data_path,'info_expe.txt'), header = T, sep ='') # 

df = merge(df, info , by= 'id');
df$intervention = as.factor(revalue(as.factor(df$intervention), c('0'="placebo", '1'="treatment")));


mod = lmer(beta_coef ~ session*condition*intervention*lik + (session+condition|id), data=df, REML=FALSE)
anova(mod)  
#quickplot
# pp =plot_model(mod, type = "int", terms = c("session", "condition", "intervention", "lik"), mdrt.values = "meansd")
pp =plot_model(mod, type = "pred", terms = c("lik","intervention", "session"))

# -------------------------------------- themes for plots --------------------------------------------------------

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


pal = viridis::inferno(n=5) # specialy conceived for colorblindness

# AVERAGED EFFECT
dfH <- summarySE(df, measurevar = "score",
                 groupvars = c("session","intervention"))

dfH$cond <- ifelse(dfH$intervention == "treatment", -0.25, 0.25)
df$cond <- ifelse(df$intervention == "treatment", -0.25, 0.25)
set.seed(666)
df <- df %>% mutate(condjit = jitter(as.numeric(cond), 0.3),
                    grouping = interaction(id, cond))


pp <- ggplot(df, aes(x = cond, y = score, 
                     fill = intervention, color = intervention)) +
  geom_point(data = dfH, alpha = 0.5) +
  # geom_line(aes(x = condjit, group = id, y = beta_coef), alpha = .3, size = 0.5, color = 'gray') +
  #geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, aes(fill = intervention, color = NA))+
  #geom_point(aes(x = condjit), alpha = .3,) +
  geom_crossbar(data = dfH, aes(y = score, ymin=score-se, ymax=score+se), width = 0.2 , alpha = 0.1)+
  ylab('Beta Coeficcient') +
  xlab('Milkshake-Tastless (modulated by liking ratings)') +
  #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(-0.5,100.5)) +
  #scale_x_continuous(labels=c("Pleasant", "Neutral"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  scale_fill_manual(values=c("treatment"= pal[3], "placebo"=pal[1]), guide = 'none') +
  scale_color_manual(values=c("treatment"=pal[3], "placebo"=pal[1])) +
  theme_bw() + facet_wrap(~session)

ppp <- pp + averaged_theme
ppp

cairo_pdf(file.path(figures_path,'Figure_HEDONIC.pdf'))
print(ppp)
dev.off()


