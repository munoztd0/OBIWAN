##########################################################################
#                                                                        #
#              FUNCTION FOR COMPUTING COHEN'S d & HEDGES' g              #
#                  ALONG WITH THEIR CONFIDENCE INTERVAL                  #
#             FOR INDEPENDENT, ONE-SAMPLE, OR PAIRED T TESTS             #
#                                                                        #
##########################################################################

# LAST UPDATED ON: 18.09.19 by YS

# Based on:
# Lakens, D. (2013). Calculating and reporting effect sizes to facilitate cumulative science: A practical primer for t-tests and ANOVAs. Frontiers in Psychology, 4, 863. https://doi.org/10.3389/fpsyg.2013.00863
# Lakens, D. (2015). The perfect t-test. Retrieved from https://Neutralthub.com/Lakens/perfect-t-test. https://doi.org/10.5281/zenodo.17603

#---------------------------------------------------------------------------------------------------------------------------#
# INPUTS:
# x           = data vector in wide format for the first condition
# y           = data vector in wide format for the second condition [if missing -> one-sample t test]
# mu          = (for one-sample t tests) reference mean [default -> 0]
# paired      = TRUE -> paired t test, FALSE -> indepedent-sample t test
# var.equal   = TRUE -> two variances treated as equal, FALSE [default] -> two variances treated as unequal (Welch's t test)
# conf.level  = level of the confidence interval between 0 to 1 [default -> .95]
#---------------------------------------------------------------------------------------------------------------------------#

cohen_d_ci <- function(x, y, mu, paired, var.equal, conf.level)
{
  #----INPUTS
  # y input
  ifelse(missing(y), y <- NA, y <- y)
  
  # mu input
  ifelse(missing(mu), mu <- 0, mu <- mu)
  
  # paired input
  ifelse(missing(paired), ifelse(length(x) != length(y), paired <- F, paired <- paired), paired <- paired)
  
  # var.equal input
  ifelse(missing(var.equal), var.equal <- F, var.equal <- var.equal)
  
  # conf.level input
  ifelse(missing(conf.level), conf.level <- .95, conf.level <- conf.level)
  
  #---------------------------------------------------------------------------------------------------------#
  #----INDEPENDENT-SAMPLE T TEST
  if (is.na(y) == F && paired == F) {
    
    # output from t test
    ttest.output <- t.test(x = x, y = y, paired = F, var.equal = var.equal, conf.level = conf.level)
    
    # effect size (Cohen's d_s)
    m.x   <- mean(x)
    m.y   <- mean(y)
    sd.x  <- sd(x)
    sd.y  <- sd(y)
    n.x   <- length(x)
    n.y   <- length(y)
    
    tvalue <- ttest.output$statistic
    
    d_s    <- (m.x - m.y)/(sqrt(((n.x - 1) * sd.x^2 + (n.y - 1) * sd.y^2)/(n.x + n.y - 2)))
    g_s    <- d_s * (1 - 3/(4 * (n.x + n.y - 2) - 1))
    
    require(MBESS)
    ci_lower_d_s <- ci.smd(ncp = tvalue,
                           n.1 = n.x,
                           n.2 = n.y,
                           conf.level = conf.level)$Lower.Conf.Limit.smd
    
    ci_upper_d_s <- ci.smd(ncp = tvalue,
                           n.1 = n.x,
                           n.2 = n.y,
                           conf.level = conf.level)$Upper.Conf.Limit.smd
    
    # SUMMARY TABLE
    table.effectsize           <- matrix(c(d_s, g_s, ci_lower_d_s, ci_upper_d_s),
                                         ncol = 4, byrow = F)
    colnames(table.effectsize) <- c("Cohen's d_s", "Hedges' g_s",
                                    paste(conf.level*100, "% CI lower bound"),
                                    paste(conf.level*100, "% CI upper bound"))
    rownames(table.effectsize) <- "Effect size"
    print(table.effectsize)
    
    # OUTPUT
    output <- list(d_s = d_s, g_s = g_s, ci_lower_d_s = ci_lower_d_s, ci_upper_d_s = ci_upper_d_s)
    return(invisible(output))
  }
  
  
  #---------------------------------------------------------------------------------------------------------#
  #----PAIRED-SAMPLE T TEST
  if (is.na(y) == F && paired == T) {
    
    # output from t test
    ttest.output <- t.test(x = x, y = y, paired = T, conf.level = conf.level)
    
    # effect size
    diff    <- x - y
    m_diff  <- mean(diff)
    sd_diff <- sd(diff)
    sd.x    <- sd(x)
    sd.y    <- sd(y)
    N       <- length(x)
    r       <- cor(x, y)
    
    tvalue  <- ttest.output$statistic
    
    # Cohen's d_z
    d_z     <- tvalue/sqrt(N)
    g_z     <- d_z * (1 - 3/(4 * (N - 1) - 1))
    
    require(MBESS)
    nct_limits    <- conf.limits.nct(t.value = tvalue, df = N - 1, conf.level = conf.level)
    ci_lower_d_z  <- nct_limits$Lower.Limit/sqrt(N)
    ci_upper_d_z  <- nct_limits$Upper.Limit/sqrt(N)
    
    # Cohen's d_rm
    s_rm    <- sqrt(sd.x^2 + sd.y^2 - 2 * r * sd.x * sd.y) / sqrt(2 * (1 - r))
    
    d_rm    <- m_diff/s_rm
    g_rm    <- d_rm * (1 - 3/(4 * (N - 1) - 1))
    
    ci_lower_d_rm <- nct_limits$Lower.Limit * sqrt((2 * (sd.x^2 + sd.y^2 - 2 * (r * sd.x * sd.y)))/(N * (sd.x^2 + sd.y^2)))
    ci_upper_d_rm <- nct_limits$Upper.Limit * sqrt((2 * (sd.x^2 + sd.y^2 - 2 * (r * sd.x * sd.y)))/(N * (sd.x^2 + sd.y^2)))
    
    # Cohen's d_av
    s_av    <- sqrt((sd.x^2 + sd.y^2)/2)
    
    d_av    <- m_diff/s_av
    g_av    <- d_av * (1 - (3 / (4 * (N - 1) - 1)))
    
    ci_lower_d_av <- nct_limits$Lower.Limit * sd_diff/(s_av * sqrt(N))
    ci_upper_d_av <- nct_limits$Upper.Limit * sd_diff/(s_av * sqrt(N))
    
    # SUMMARY TABLE
    table.effectsize           <- matrix(c(d_z, g_z, ci_lower_d_z, ci_upper_d_z,
                                           d_rm, g_rm, ci_lower_d_rm, ci_upper_d_rm,
                                           d_av, g_av, ci_lower_d_av, ci_upper_d_av),
                                         ncol = 4, byrow = T)
    colnames(table.effectsize) <- c("Cohen's d", "Hedges' g", 
                                    paste(conf.level*100, "% CI lower bound"),
                                    paste(conf.level*100, "% CI upper bound"))
    rownames(table.effectsize) <- c("d_z", "d_rm", "d_av")
    print(table.effectsize)
    
    # OUTPUT
    output <- list(d_z = d_z, g_z = g_z, ci_lower_d_z = ci_lower_d_z, ci_upper_d_z = ci_upper_d_z,
                   d_rm = d_rm, g_rm = g_rm, ci_lower_d_rm = ci_lower_d_rm, ci_upper_d_rm = ci_upper_d_rm,
                   d_av = d_av, g_av = g_av, ci_lower_d_av = ci_lower_d_av, ci_upper_d_av = ci_upper_d_av)
    return(invisible(output))
  }
  
  
  #---------------------------------------------------------------------------------------------------------#
  #----ONE-SAMPLE T TEST
  if (is.na(y) == T) {
    
    # output from t test
    ttest.output <- t.test(x = x, mu = mu, conf.level = conf.level)
    
    # effect size
    diff    <- x - mu
    m_diff  <- mean(diff)
    sd_diff <- sd(diff)
    sd.x    <- sd(x)
    N       <- length(x)
    
    tvalue  <- ttest.output$statistic
    
    # Cohen's d_z
    d_z     <- tvalue/sqrt(N)
    g_z     <- d_z * (1 - 3/(4 * (N - 1) - 1))
    
    require(MBESS)
    nct_limits    <- conf.limits.nct(t.value = tvalue, df = N - 1, conf.level = conf.level)
    ci_lower_d_z  <- nct_limits$Lower.Limit/sqrt(N)
    ci_upper_d_z  <- nct_limits$Upper.Limit/sqrt(N)
    
    # # ALTERNATIVE METHOD (gives the exact same results)
    # d_z    <- m_diff/sd.x
    # g_z    <- d_z * (1 - (3 / (4 * (N - 1) - 1)))
    # 
    # ci_lower_d_z <- nct_limits$Lower.Limit * sd_diff/(sd.x * sqrt(N))
    # ci_upper_d_z <- nct_limits$Upper.Limit * sd_diff/(sd.x * sqrt(N))
    
    # SUMMARY TABLE
    table.effectsize           <- matrix(c(d_z, g_z, ci_lower_d_z, ci_upper_d_z),
                                         ncol = 4, byrow = T)
    colnames(table.effectsize) <- c("Cohen's d", "Hedges' g", 
                                    paste(conf.level*100, "% CI lower bound"),
                                    paste(conf.level*100, "% CI upper bound"))
    rownames(table.effectsize) <- c("d_z")
    print(table.effectsize)
    
    # OUTPUT
    output <- list(d_z = d_z, g_z = g_z, ci_lower_d_z = ci_lower_d_z, ci_upper_d_z = ci_upper_d_z)
    return(invisible(output))
  }
}