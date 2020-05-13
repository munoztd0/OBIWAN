#Marginal and conditional r-squared values for mixed models are calculated based on Nakagawa et al. 2017. 
#The marginal r-squared considers only the variance of the fixed effects, while the conditional r-squared 
#takes both the fixed and random effects into account. The random effect variances are actually the mean random effect variances, thus the r-squared value is also appropriate for mixed models with random slopes or nested random effects (see Johnson 2014)


#P- values “are based on calculating the probability of observing test statistics that are as extreme or more extreme than the test
#statistic actually observed, whereas Bayes factors represent the relative probability assigned to the observed data under
#each of the competing hypotheses // the p-value is always the probability that sampling error alone could have produced the result.

#”. The key thing to remember is that under the hood, the main effect of X always really means the effect ofX when Y=0.

#If X is a n-level factor and Y is numeric, then X:Y introduces a linear effect
#of Y with a different slope for each level of X (hence n slopes).
#X*Y is always expanded out to 1 + X + Y + X:Y

# We tested for a main effect of X by converting Y to a sum-coding numeric
# representation and conducting a likelihood-ratio test between mixed-effects
# models differing only in the presence or absence of a fixed main effect of
# X. Both models included in their fixed effects an intercept, a main effect
# of Y, and an interaction between X and Y. Both models also had maximal
# random effects structure, namely random intercepts plus random slopes for
# X, Y, and their interaction for both subjects and items. The likelihood-ratio
# test showed no evidence for a main effect of X (p = 1, 1 d.f.).


#if cor  -1.0  -> lmer is telling you is essentially that you
# really don't have enough data to fit two separate random effects
# ((intercept):trial and condition:trial), so the fit is collapsing
# onto a linear combination of the two.  bc no much variance in empty

#K-R Kenward and Roger (2009) is probably the most reliable option Stroup (2013) for REML

#AIC (which is looking for the best *predictive* model) very
#slightly favors the model with correlation, although it's almost awash
#BIC (which is looking for the "true" model, i.e. identifying the
     #correct dimensionality) favors the simpler (no-correlation) model.

# Bates et al. 2015 seems to be that one starts with the maximal model a la Barr et al. 2013 
# and then decreases the complexity until the covariance matrix is full rank. 
# (Moreover, they would often recommend to reduce the complexity even further, 
# in order to increase the power.) Update: In contrast, Barr et al. recommend to reduce complexity 
# ONLY if the model did not converge; they are willing to tolerate singular covariance matrices.


#The random slope allows the effect of condition to vary between subjects. . So we can think of an overall slope (i.e. liking goes up over the Milkshake), 
#from which individuals deviate by some amount (e.g. a resiliant person will have a negative deviation or residual from the overall slope).
#Adding the random slope doesn’t change the pvalue generally

#But we can use the lmerTest::ranova() function to show that there is statistically significant 
#variation in slopes between individuals, using the likelihood ratio test lmerTest::ranova(random.slope.model)

#However we can explicitly check this correlation (between individuals’ intercept and slope residuals) using the VarCorr() function:
#want to try fitting a model without this correlation

#For Generalised Linear Models (GLMs) with non-Gaussian error structure the F-test is no longer valid, 
#and the LRT is approximate (the latter is in fact asymptotically chi-squared, which means that the approximation gets better 
#for larger sample sizes, but can be misleading in small samples). An alternative is to use something like Akaike’s Information Criterion (AIC), 
#which does not assess statistical significance and does not require the models to be nested (it is in essence a measure of predictive accuracy).

#If I do perform model simplification or variable selection, even then I would present the final model results in terms of effect sizes 
#and confidence intervals where possible (or via predictive plots), since although CIs suffer with some of the same problems as p-values, 
#at least they focus on the magnitude of the effects. If I have large enough sample sizes and not too many variables, then it may well be fine 
#just to fit one model and perform inference from that.

#here we have a balanced design (i.e. the same number of measurements in each combination of explanatory variables). 
#for balanced, nested designs we can usually derive suitable tests based on REML fits 

#The ‘intercept’ of the lmer model is the mean growth rate in media1 for an average cabinet

#compute parameteric bootstrapped CIs  the terms correspond to the difference in liking for XX levels 2, 3 and 4, relative to level 1
#to say . Each of these effects are statistically significantly different to the baseline media at the 3% level

#BOOOTSTAPING /  Parametric Bootstrap Methods for Tests in Linear Mixed Models #PBmodcomp the bootstrapped p-values is in the PBtest line, 
#the LRT line report the standard p-value assuming a chi-square distribution for the LRT value
#Approximate null–distribution by a kernel density estimate. The p–value is then calculated from the kernel density estimate. Ben Bolker 


## prediction function to use in bootstrap routine
predFun <- function(mod) {
  predict(mod, newdata = newdata, re.form = NA)
}

## produce 1000 bootstrapped samples
boot1 <- bootMer(split_lmer, predFun, nsim = 1000, type = "parametric", re.form = NA)

## function to produce percentile based CIs
sumBoot <- function(merBoot) {
  data.frame(
    yield = apply(merBoot$t, 2, function(x){
      mean(x, na.rm = T)
    }),
    lci = apply(merBoot$t, 2, function(x){
      quantile(x, probs = 0.025, na.rm = T)
    }),
    uci = apply(merBoot$t, 2, function(x){
      quantile(x, probs = 0.975, na.rm = T)
    })
  )
}

## bind CIs to newdata
split_pred <- cbind(newdata, sumBoot(boot1))

