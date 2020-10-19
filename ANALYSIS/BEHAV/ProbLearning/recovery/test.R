update_RW <- function(value, alpha=.3, beta=.3, lambda=1) {
  value_compound <- sum(value)                    # value of the compound 
  prediction_error <- lambda - value_compound     # prediction error
  value_change <- alpha * beta * prediction_error # change in strength
  value <- value + value_change                   # update value
  return(value)
}

n_trials <- 30

strength <- numeric(n_trials)

for(trial in 2:n_trials) {
  strength[trial] <- update_RW( strength[trial-1] )
}

print(strength)