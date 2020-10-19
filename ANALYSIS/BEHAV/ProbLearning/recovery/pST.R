
#' Frank, M. J., Moustafa, A. A., Haughey, H. M., Curran, T., & Hutchison, K. E. (2007). Genetic triple dissociation reveals multiple roles for dopamine in reinforcement learning. Proceedings of the National Academy of Sciences, 104(41), 16311-16316.
#'

pst_gainloss_Q <- hBayesDM_model(
  task_name       = "pst",
  model_name      = "gainloss_Q",
  model_type      = "",
  data_columns    = c("subjID", "type", "choice", "reward"),
  parameters      = list(
    "alpha_pos" = c(0, 0.5, 1),
    "alpha_neg" = c(0, 0.5, 1),
    "beta" = c(0, 1, 10)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred"),
  preprocess_func = pst_preprocess_func)

pst_gain_Q <- hBayesDM_model(
  task_name       = "pst",
  model_name      = "gainloss_Q",
  model_type      = "",
  data_columns    = c("subjID", "type", "choice", "reward"),
  parameters      = list(
    "alpha_pos" = c(0, 0.5, 1),
    "beta" = c(0, 1, 10)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred"),
  preprocess_func = pst_preprocess_func)
