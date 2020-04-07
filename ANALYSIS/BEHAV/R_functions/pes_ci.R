##########################################################################
#                                                                        #
#               FUNCTION FOR COMPUTING PARTIAL ETA-SQUARED               #
#                  ALONG WITH THEIR CONFIDENCE INTERVAL                  #
#                   FOR ANALYSES OF VARIANCE (ANOVAs)                    #
#                                                                        #
##########################################################################


# LAST UPDATED ON: 27.09.19 by YS

# Based on:
# Lakens, D. (2013). Calculating and reporting effect sizes to facilitate cumulative science: A practical primer for t-tests and ANOVAs. 
#                    Frontiers in Psychology, 4, 863. https://doi.org/10.3389/fpsyg.2013.00863
# http://daniellakens.blogspot.com/2014/06/calculating-confidence-intervals-for.html


#------------------------------------------------------------------------------------------------------------------------#
# ARGUMENTS:
# formula    = formula specifying the model using the aov format (e.g., DV ~ IVb * IVw1 * IVw2 + Error(id/(IVw1 * IVw2)))
# data       = a data frame in which the variables specified in the formula will be found
# conf.level = level of the confidence interval between 0 to 1 [default -> .90]
# epsilon    = epsilon correction used to adjust the lack of sphericity for factors involving repeated measures among 
#              list("default", "none, "GG", "HF")
#              - default: use Greenhouse-Geisser (GG) correction when epsilon GG < .75, Huynh-Feldt (HF) correction 
#                         when epsilon GG = [.75, .90], and no correction when epsilon GG >= .90 [default]
#              - none: use no sphericity correction
#              - GG: use Greenhouse-Geisser (GG) correction for all factors (>2 levels) involving repeated measures
#              - HF: use Huynh-Feldt (HF) correction for all factors (>2 levels) involving repeated measures
# anova.type = type of sum of squares used in list("II", "III", 2, 3)
#              - "II" or 2: use type II sum of squares (hierarchical or partially sequential)
#              - "III" or 3: use type III sum of squares (marginal or orthogonal) [default] 
#------------------------------------------------------------------------------------------------------------------------#

pes_ci <- function(formula, data, conf.level, epsilon, anova.type)
{
  
  #----------------------------------------------------------------------------------------------#
  #----ARGUMENTS
  # conf.level
  ifelse(missing(conf.level), conf.level <- .90, conf.level <- conf.level)
  
  # epsilon
  ifelse(missing(epsilon), epsilon <- "default", epsilon <- epsilon)
  
  iscorrectionok <- epsilon == list("default", "none", "GG", "HF")
  if(all(iscorrectionok == F)) stop('Unknown correction for sphericity used. Please use (i) the default option ("default"; i.e., no correction applied when epsilon GG >= .90, 
                                    GG correction applied when GG epsilon < .75, and HF correction applied when GG epsilon = [.75, .90]),
                                    (ii) no correction ("none"), (iii) Greenhous-Geisser ("GG") correction, or (iv) Huyhn-Feldt ("HF") correction.')
  
  # anova.type
  ifelse(missing(anova.type), anova.type <- "III", anova.type <- anova.type)
  
  
  #----------------------------------------------------------------------------------------------#
  #----COMPUTE ETA-SQUARED EFFECT SIZE ESTIMATES
  
  # afex package for computing eta-squared estimates
  require(afex)
  
  # compute anova with partial (pes) eta-squared estimates
  aov     <- aov_car(formula = formula, 
                     data = data, 
                     anova_table = list(es = "pes"),
                     type = anova.type)
  aov.sum <- summary(aov)
  
  
  #----CREATE MATRIX TO STORE RESULTS
  matrix.es <- matrix(nrow = length(rownames(aov$anova_table)), ncol = 3)
  
  
  #----------------------------------------------------------------------------------------------#
  #----COMPUTE CONFIDENCE INTERVAL FOR EACH FACTOR
  
  # MBESS package for computing confidence intervals
  require(MBESS)
  
  for (i in 1:length(rownames(aov$anova_table))) {
    
    # CHECK
    if (length(aov.sum$pval.adjustments) != 0) {
      
      #--------------------------------------------------------------------------------------------#
      # DEFAULT OPTION 
      # (no correction if GG epsilon >= .90, GG correction if GG epsilon < .75, or HF correction if GG epsilon = [.75, .90])
      if (epsilon == "default") {
        
        # Search for factors with more than 2 levels
        for (j in 1:length(rownames(aov.sum$pval.adjustments))) {
          
          if (rownames(aov.sum$pval.adjustments)[j] == rownames(aov$anova_table)[i]) {
            
            # Apply GG correction if GG epsilon < .75
            if (is.na(aov.sum$pval.adjustments[j, "GG eps"]) == F && aov.sum$pval.adjustments[j, "GG eps"] < .75) {
              
              aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                             conf.level = conf.level,
                                             df.1 <- aov.sum$univariate.tests[i + 1, "num Df"] * aov.sum$pval.adjustments[j, "GG eps"],
                                             df.2 <- aov.sum$univariate.tests[i + 1, "den Df"] * aov.sum$pval.adjustments[j, "GG eps"])
              break
            }
            
            # Apply HF correction if GG epsilon = [.75, .90]
            else if (is.na(aov.sum$pval.adjustments[j, "GG eps"]) == F && aov.sum$pval.adjustments[j, "GG eps"] >= .75 && aov.sum$pval.adjustments[j, "GG eps"] < .90) {
              
              aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                             conf.level = conf.level,
                                             df.1 <- aov.sum$univariate.tests[i + 1, "num Df"] * aov.sum$pval.adjustments[j, "HF eps"],
                                             df.2 <- aov.sum$univariate.tests[i + 1, "den Df"] * aov.sum$pval.adjustments[j, "HF eps"])
              break
            }
            
            # Apply no correction if GG epsilon >= .90
            else if (is.na(aov.sum$pval.adjustments[j, "GG eps"]) == F && aov.sum$pval.adjustments[j, "GG eps"] >= .90) {
              
              aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                             conf.level = conf.level,
                                             df.1 <- aov.sum$univariate.tests[i + 1, "num Df"],
                                             df.2 <- aov.sum$univariate.tests[i + 1, "den Df"])
              break
            }
          } else {
            
            aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                           conf.level = conf.level,
                                           df.1 <- aov.sum$univariate.tests[i + 1, "num Df"],
                                           df.2 <- aov.sum$univariate.tests[i + 1, "den Df"])
          }
        }
      }
      
      #--------------------------------------------------------------------------------------------#
      # SPHERICITY ASSUMED
      if (epsilon == "none") {
        
        aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                       conf.level = conf.level,
                                       df.1 <- aov.sum$univariate.tests[i + 1, "num Df"],
                                       df.2 <- aov.sum$univariate.tests[i + 1, "den Df"])
      }
      
      #--------------------------------------------------------------------------------------------#
      # GREENHOUSE-GEISSER (GG) CORRECTION
      else if (epsilon == "GG") {
        
        # Search for factors with more than 2 levels
        for (j in 1:length(rownames(aov.sum$pval.adjustments))) {
          
          if (is.na(aov.sum$pval.adjustments[j, "GG eps"]) == F && rownames(aov.sum$pval.adjustments)[j] == rownames(aov$anova_table)[i]) {
            
            # Apply GG correction
            aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                           conf.level = conf.level,
                                           df.1 <- aov.sum$univariate.tests[i + 1, "num Df"] * aov.sum$pval.adjustments[j, "GG eps"],
                                           df.2 <- aov.sum$univariate.tests[i + 1, "den Df"] * aov.sum$pval.adjustments[j, "GG eps"])
            break
          } else {
            
            aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                           conf.level = conf.level,
                                           df.1 <- aov.sum$univariate.tests[i + 1, "num Df"],
                                           df.2 <- aov.sum$univariate.tests[i + 1, "den Df"])
          }
        }
      }
      
      #--------------------------------------------------------------------------------------------#
      # HUYNH-FELDT (HF) CORRECTION
      else if (epsilon == "HF") {
        
        # Search for factors with more than 2 levels
        for (j in 1:length(rownames(aov.sum$pval.adjustments))) {
          
          if (is.na(aov.sum$pval.adjustments[j, "GG eps"]) == F && rownames(aov.sum$pval.adjustments)[j] == rownames(aov$anova_table)[i]) {
            
            # Apply HF correction
            aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                           conf.level = conf.level,
                                           df.1 <- aov.sum$univariate.tests[i + 1, "num Df"] * aov.sum$pval.adjustments[j, "HF eps"],
                                           df.2 <- aov.sum$univariate.tests[i + 1, "den Df"] * aov.sum$pval.adjustments[j, "HF eps"])
            break
          } else {
            
            aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$univariate.tests[i + 1, "F value"], 
                                           conf.level = conf.level,
                                           df.1 <- aov.sum$univariate.tests[i + 1, "num Df"],
                                           df.2 <- aov.sum$univariate.tests[i + 1, "den Df"])
          }
        }
      }
    } else {
      aov.sum.lim <- conf.limits.ncf(F.value = aov.sum$F[i], conf.level = .90, 
                                     df.1 <- aov.sum$"num Df"[i], 
                                     df.2 <- aov.sum$"den Df"[i])
    }
    
    #--------------------------------------------------------------------------------------------#
    # LOWER LIMIT
    aov.sum.lower_lim <- ifelse(is.na(aov.sum.lim$Lower.Limit/(aov.sum.lim$Lower.Limit + df.1 + df.2 + 1)),
                                0,
                                aov.sum.lim$Lower.Limit/(aov.sum.lim$Lower.Limit + df.1 + df.2 + 1))
    
    # UPPER LIMIT
    aov.sum.upper_lim <- aov.sum.lim$Upper.Limit/(aov.sum.lim$Upper.Limit + df.1 + df.2 + 1)
    
    
    #--------------------------------------------------------------------------------------------#
    #----STORE RESULTS IN THE MATRIX
    matrix.es[i,]         <- matrix(c(aov$anova_table$pes[i],
                                      aov.sum.lower_lim,
                                      aov.sum.upper_lim),
                                    ncol = 3)
    
  }
  
  
  #----------------------------------------------------------------------------------------------#
  #----OUTPUT MATRIX WITH PARTIAL ETA-SQUARED EFFECT SIZE ESTIMATES AND THEIR CONFIDENCE INTERVAL
  
  # Rename rows and columns
  rownames(matrix.es) <- rownames(aov$anova_table)
  colnames(matrix.es) <- c("Partial eta-squared", 
                           paste(conf.level * 100, "% CI lower limit"), 
                           paste(conf.level * 100, "% CI upper limit"))
  
  # Output
  return(matrix.es)
}