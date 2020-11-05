#-------------------------------------------------------------------------%
#   SIMULATION OF THE PST TASK    %
# David Munoz Tord
#-------------------------------------------------------------------------%
# PARAMETERS
# lr      = learning rate for CS1 (range = [0, 1])
# b       = choice consistency for US1 (range = [0, 1])


simulatePST <- function(lr, b, data){
  
  #tidy up
  N       <- length(data$type)
  #litle trick to get the types of trials from 12 34 56
  option1 <- data$type %/% 10  #modulo 12 = 1, 34 = 3, 56 = 5
  option2 <- data$type %% 10  #numerical division 12 = 2, 34 = 4, 56 = 6
  choice  <- rep(0, N)
  reward  <- rep(0, N)
  

  ev = rep(0, 6) # initialization

  #loop through trials
  for (t in  1:N) {
    
    p =  exp(beta*ev[option1[t]])/(exp(beta*ev[option1[t]]) + (exp(beta*ev[option2[t]]))) #compute probaility of chosing option 1
    
    if (sample(1:2, 1) > 1) {
      choice[t] = ifelse(p >= 0.5, 1, 0) #more and equal to?
    } else  {
      choice[t] = ifelse(p > 0.5, 1, 0) #more and equal to?
    }
    
    if (choice[t] == 1) {
      co = option1[t]
    } else  {
      co = option2[t]
    }
    
    if (co == 1) {
      reward[t] = ifelse(sample(1:10, 1) <= 8, 1, 0)
    } else if (co == 2) {
      reward[t] = ifelse(sample(1:10, 1) <= 2, 1, 0)
    } else if (co == 3) {
      reward[t] = ifelse(sample(1:10, 1) <= 7, 1, 0)
    } else if (co == 4) {
      reward[t] = ifelse(sample(1:10, 1) <= 3, 1, 0)
    } else if (co == 5) {
      reward[t] = ifelse(sample(1:10, 1) <= 6, 1, 0)
    } else if (co == 6) {
      reward[t] = ifelse(sample(1:10, 1) <= 4, 1, 0)
    }
    
    pe = reward[t] - ev[co]  #prediction error
    ev[co] = ev[co] + alpha * pe  #Q or expected value update
  }
  
  return(invisible(choice))
}