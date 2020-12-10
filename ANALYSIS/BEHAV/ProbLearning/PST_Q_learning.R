# PARAMETERS PST_q
# lr      = learning rate [0 - 1]
# b       = softmax inverse temperature [0 - 10]


PST_q <- function(x, data){
  alpha = x[1]
  beta  = x[2]
  #tidy up
  N       <- length(data$type)
  #litle trick to get the types of trials from 12 34 56
  option1 <- data$type %/% 10  #modulo 12 = 1, 34 = 3, 56 = 5
  option2 <- data$type %% 10  #numerical division 12 = 2, 34 = 4, 56 = 6
  choice  <- data$choice
  reward  <- data$reward
  
  ev = rep(0, 6) #initialization
  lik = c()
  #loop through trials
  for (t in  1:N) {
    
    co = ifelse(choice[t] > 0, option1[t], option2[t])
    
    pe = reward[t] - ev[co]  #prediction error
    ev[co] = ev[co] + alpha * pe  #Q or expected value update
    
    dQ = ev[option1[t]] - ev[option2[t]];
    phi = 1/(1+exp(-beta *dQ))
    
    #find the log likelihood for the choice made in each trial
    log_likelihood <- (choice[t] * log(phi)) + ((1-choice[t]) * log(1-phi))
    lik =  rbind(lik, log_likelihood)
  }
  NeglogLik <- -sum(lik)
  return(invisible(NeglogLik))
}


# PARAMETERS PST_q_dual
# lrG      = learning rate for gain [0 - 1]
# lrL     = learning rate for loss [0 - 1]
# b       = softmax inverse temperature [0 - 10]


PST_q_dual <- function(x, data){
  alphaG = x[1]
  alphaL = x[2]
  beta  = x[3]
  #tidy up
  N       <- length(data$type)
  #litle trick to get the types of trials from 12 34 56
  option1 <- data$type %/% 10  #modulo 12 = 1, 34 = 3, 56 = 5
  option2 <- data$type %% 10  #numerical division 12 = 2, 34 = 4, 56 = 6
  choice  <- data$choice
  reward  <- data$reward
  
  ev = rep(0, 6) #initialization
  lik = c()
  #loop through trials
  for (t in  1:N) {
    
    co = ifelse(choice[t] > 0, option1[t], option2[t])
    
    pe = reward[t] - ev[co]  #prediction error
    alpha = ifelse(reward[t] > 0, alphaG, alphaL) # differential lr for loss and gain
    ev[co] = ev[co] + alpha * pe  #Q or expected value update
    
    dQ = ev[option1[t]] - ev[option2[t]];
    phi = 1/(1+exp(-beta *dQ))
    
    #find the log likelihood for the choice made in each trial
    log_likelihood <- (choice[t] * log(phi)) + ((1-choice[t]) * log(1-phi))
    lik =  rbind(lik, log_likelihood)
  }
  NeglogLik <- -sum(lik)
  return(invisible(NeglogLik))
}


#' FE_null Calculate free energy for H0 (equal model frequencies in the population)
#'
#' THis function derives the free energy of the 'null' (H0: equal model frequencies). This routine has been copied from the VBA_groupBMC function of the VBA toolbox http://code.google.com/p/mbb-vb-toolbox/ which was written by Lionel Rigoux and J. Daunizeau. See Equation A.17 in Rigoux et al.
#' @param m N by K (N subjects by K models) matrix of log-model evidence.
#' @return Free energy.
#' @export
FE_null <- function(m){
  n <- dim(m)[1]  # number of subjects
  K <- dim(m)[2]  # number of models
  F0m <- 0
  for(i in 1:n){
    tmp <- m[i,] - max(m[i,])
    g <- exp(tmp)/sum(exp(tmp))
    for(k in 1:K){
      F0m = F0m + g[k] * (m[i,k]-log(K)-log(g[k]+.Machine$double.eps))
    }
  }
  return(unname(F0m))
}