# Downsample pupil data
#
# This function will combine gaze samples into time bins
# @param dataframe dataframe
# @param bin.length Length of time bins
# @param timevar time column
# @param aggvars vector of variable names to group by for aggregation
downsample_pupil <- function(dataframe, bin.length = NULL, timevar=time, aggvars=c("subject", "script","timebins")){
  downsample <- dataframe %>%
    mutate(timebins = round(timevar/bin.length)*bin.length)
  # if there are aggregation variables, then aggregate
  if(length(aggvars > 0)){ 
    downsample <- downsample %>%
      dplyr::group_by_(.dots = aggvars) %>%
      dplyr::summarize(aggbaseline=mean(baselinecorrectedp)) %>%
      dplyr::ungroup()
  }
  return(downsample)
}
