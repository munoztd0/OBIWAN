#----clean----
#subset only pretest
tables <- c("PAV","INST","PIT","HED", "intern")
dflist <- lapply(mget(tables),function(x)subset(x, session == 'second'))
list2env(dflist, envir=.GlobalEnv)

#exclude participants (242 really outlier everywhere, 256 can't do the task, 114 & 228 REALLY hated the solution and thus didn't "do" the conditioning) & 123 and 124 have imcomplete data
`%notin%` <- Negate(`%in%`)
dflist <- lapply(mget(tables),function(x)filter(x, id %notin% c(242, 256, 114, 228, 123, 124)))
list2env(dflist, envir=.GlobalEnv)

#merge with info
tables = tables[-length(tables)] # remove intern
dflist <- lapply(mget(tables),function(x)merge(x, info, by = "id"))
list2env(dflist, envir=.GlobalEnv)

# creates internal states variables for each data
listA = 2:5
def = function(data, number){
  baseINTERN = subset(intern, phase == number)
  data = merge(x = get(data), y = baseINTERN[ , c("piss", "thirsty", 'hungry', 'id')], by = "id", all.x=TRUE)
  diffINTERN = subset(intern, phase == number | phase == number+1) #before and after 
  before = subset(diffINTERN, phase == number); after = subset(diffINTERN, phase == number+1); diff = after
  diff$diff_piss = diff$piss - before$piss
  diff$diff_thirsty = diff$thirsty - before$thirsty
  diff$diff_hungry = diff$hungry - before$hungry
  data= merge(data, y = diff[ , c("diff_piss", "diff_thirsty", 'diff_hungry', 'id')], by = "id", all.x=TRUE)
  return(data)
}
dflist = mapply(def,tables,listA)
list2env(dflist, envir=.GlobalEnv)


# PAV PREPROC -------------------------------------------------------------

# -------------------------------------- PREPROC ----------------------------------------

# define as.factors
fac <- c("id", "trial", "condition", "group" ,"trialxcondition", "gender")
PAV[fac] <- lapply(PAV[fac], factor)

#revalue all catego
PAV$group = as.factor(revalue(PAV$group, c(control="-1", obese="1"))) #change value of group
PAV$condition = as.factor(revalue(PAV$condition, c(CSminus="-1", CSplus="1"))); PAV$condition <- factor(PAV$condition, levels = c("1", "-1"))#change value of condition

#center covariates
numer <- c("piss", "thirsty", "hungry", "diff_piss", "diff_thirsty", "diff_hungry", "age")
PAV = PAV %>% group_by %>% mutate_at(numer, scale)

# get times in milliseconds 
PAV$RT               <- PAV$RT * 1000

#Preprocessing
PAV$condition <- droplevels(PAV$condition, exclude = "Baseline")
acc_bef = mean(PAV$ACC, na.rm = TRUE) #0.93
full = length(PAV$RT)

##shorter than 100ms and longer than 3sd+mean
PAV.clean <- filter(PAV, RT >= 100) # min RT is 
PAV.clean <- ddply(PAV.clean, .(id), transform, RTm = mean(RT))
PAV.clean <- ddply(PAV.clean, .(id), transform, RTsd = sd(RT))
PAV.clean <- filter(PAV.clean, RT <= RTm+3*RTsd) 

# calculate the dropped data in the preprocessing
clean = length(PAV.clean$RT)
dropped = full-clean
(dropped*100)/full

densityPlot(PAV.clean$RT) #RT are skewed 

#log transform function
t_log_scale <- function(x){
  if(x==0){y <- 1}
  else {y <- (sign(x)) * (log(abs(x)))}
  y }

PAV.clean$RT_T <- sapply(PAV.clean$RT,FUN=t_log_scale)
densityPlot(PAV.clean$RT_T) # much better 



