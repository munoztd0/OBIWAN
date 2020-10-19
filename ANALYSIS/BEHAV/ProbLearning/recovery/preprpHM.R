#' @noRd
#' @keywords internal


pst_preprocess_func <- function(raw_data, general_info) {
  # Currently class(raw_data) == "data.table"
  
  # Use general_info of raw_data
  subjs   <- general_info$subjs
  n_subj  <- general_info$n_subj
  t_subjs <- general_info$t_subjs
  t_max   <- general_info$t_max
  
  # Initialize (model-specific) data arrays
  option1 <- array(-1, c(n_subj, t_max))
  option2 <- array(-1, c(n_subj, t_max))
  choice  <- array(-1, c(n_subj, t_max))
  reward  <- array(-1, c(n_subj, t_max))
  
  # Write from raw_data to the data arrays
  for (i in 1:n_subj) {
    subj <- subjs[i]
    t <- t_subjs[i]
    DT_subj <- raw_data[raw_data$subjid == subj]
    
    option1[i, 1:t] <- DT_subj$type %/% 10
    option2[i, 1:t] <- DT_subj$type %% 10
    choice[i, 1:t]  <- DT_subj$choice
    reward[i, 1:t]  <- DT_subj$reward
  }
  
  # Wrap into a list for Stan
  data_list <- list(
    N       = n_subj,
    T       = t_max,
    Tsubj   = t_subjs,
    option1 = option1,
    option2 = option2,
    choice  = choice,
    reward  = reward
  )
  
  # Returned data_list will directly be passed to Stan
  return(data_list)
}

