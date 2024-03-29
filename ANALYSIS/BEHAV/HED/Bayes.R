---
  title: "How to compute Bayes factors using lm, lmer, BayesFactor, brms, and JAGS/stan/pymc3"
output: 
  html_document:
  toc: true
---
  ```{r, include=FALSE}
library(brms)
library(ggplot2)
library(BayesFactor)
library(kableExtra)
library(knitr)
```


<!--
  TO DO:
  * Compare posteriors of the different packages.
-->
  **By Jonas Kristoffer Lindeløv.** 
  See [my blog](http://lindeloev.net) and [my academic profile](http://personprofil.aau.dk/117060). Created on Feb, 2018.

# About this tutorial
Here, I compare different ways of computing Bayes Factors in R. I start with a TL;DR section showing off the syntax for the simplest of all models: the intercept-only model. Then I go on to demonstrate Bayes Factors for mixed models using the same packages, including a more thorough discussion of pros and cons.

In each section, I start with the most limited methods and then progress towards the all-purpose solutions. As flexibility increases so do complexity, so find you own golden middle way.

This is just a demonstration of syntax which ignores some controversies surrounding Bayes Factors. Namely, [some researchers](http://andrewgelman.com/2017/07/21/bayes-factor-term-came-references-generally-hate/) go for parameter estimation rather than Bayes Factors because BFs are too relative: (1) Bayes factors just change credence between models without quantifying whether the better model is actually credible enough, and (2) they are relative to the prior, yet people often discuss Bayes Factors as if they are purely data-driven. A good first amelioration of these problems is to accompany your Bayes Factors with **posterior predictive checks** for absolute model fit and **[sensitivity analyses](https://en.wikipedia.org/wiki/Robust_Bayesian_analysis)** for robustness to theoretically unimortant changes in model structure and priors.

The full code for this notebook is [available on GitHub](https://github.com/lindeloev/r_notebooks).

# Intercept-only models
Here is some data:
  
  ```{r}
set.seed(14)  # Cherry-picked to reveal the difference between p and BF
intercept_data = data.frame(score=scale(rnorm(40), center=0.72))
```

Let's take a look at it:

```{r, echo=FALSE, fig.height=3, fig.width=7}
#round(intercept_data$score, 3)
plot(density(intercept_data$score), main='Density of score', xlab='score', xlim=c(-3, 4));
abline(v=0, col='red')  # null hypothesis
abline(v=mean(intercept_data$score), col='blue')  # alternative hypothesis around here
legend(0.6, 0.38, c('H0: intercept = 0', 'mean(intercept_data$score)'), lty=1, col=c('red', 'blue'))
```


A frequentist one-sample t-test shows that the results are HIGHLY SIGNIFICANT (p < 0.01) !!!!1!1!one:

```{r}
x = t.test(intercept_data$score)
x$p.value
```


... but let's compute som Bayes factors and see how this holds up. Put in Bayesian terms, we want to use this data to update our beliefs in whether it was generated either by a world in which $intercept = 0$ or by a world where $intercept != 0$. Bayes Factors will tell us how much the data *changes* our belief relative to our prior beliefs, so let's go ahead and compute some Bayes Factors:

### BIC
The Bayesian Information Criterion (BIC) is like the more popular AIC but with a slightly different penalization for the number of parameters which allow for a (more) Bayesian interpretation. [Wagenmakers (2007)](http://www.ejwagenmakers.com/2007/pValueProblems.pdf) popularized BIC-derived Bayes factors which can be computed in the comfort zone of base R.
```{r}
full_lm = lm(score ~ 1, intercept_data)  # One mean with gauss residual
null_lm = lm(score ~ 0, intercept_data)  # Fixed mean at score = 0
BF_BIC = exp((BIC(null_lm) - BIC(full_lm))/2)  # From BICs to Bayes factor
BF_BIC  # Show it
```
OK, so those whose belief state was "unit information" (whatever that is) before seeing the data, you should now believe `r round(BF_BIC, 2)` times more in H1 and, conversely, `r round(1/BF_BIC, 2)` times "more" in H0. Although the direction of evidence is the same, the magnitude gives a different impression than the p-value. The fact that p-values are poor indices of model evidence has been noted for a long time but has yet to hit mainstream stats education. (p-values are still practical if you just want to control long-run error rates)


###`BayesFactor` package
[The BayesFactor package](http://bayesfactorpcl.r-forge.r-project.org/) is dedicated to the computation of Bayes factors, so it's probably the solution requiring the least code. There is substantial academic literature to support it as cited in the previous link.
```{r}
library(BayesFactor)
BF = ttestBF(intercept_data$score)
exp(BF@bayesFactor$bf)  # Show just the (non-log) Bayes factor
```

Under the hood, this `ttestBF` is based on the JZS prior which is a $Cauchy(0, 0.707)$ prior on the standardized mean difference, standardized by a sigma with a [Jeffreys prior](https://en.wikipedia.org/wiki/Jeffreys_prior). The width of this prior can be changed using the `rscale` argument, e.g.  `ttestBF(intercept_data$score, rscale = 0.3)`.


###`brms::hypothesis`
`brms` can model almost all (non-)linear models, including structural equation modeling. It makes little sense to use such a huge package for a one-sample t-test, but let's go ahead to demonstrate it anyway using a cauchy prior (but not the Jeffreys prior for simplicity) to get some similarity to the JZS prior used above by `BayesFactor`:

```{r, cache = TRUE, results = 'hide', message = FALSE}
library(brms)
priors_intercept = c(set_prior('cauchy(0, 0.707)', class = 'Intercept'))  # JZS prior as the BayesFactor package, though without the Jeffreys prior on Sigma for simplicity.
full_brms = brm(score ~ 1, data = intercept_data, prior = priors_intercept, sample_prior = TRUE, iter = 10000)
BF_brms_savage = hypothesis(full_brms, hypothesis = 'Intercept = 0')
1 / BF_brms_savage$hypothesis$Evid.Ratio  # Inverse to make it in favor of the full model
```
```{r, echo=FALSE}
1 / BF_brms_savage$hypothesis$Evid.Ratio
```

`brms::hypothesis` fails here because it relies on the Savage-Dickey density ratio between the prior and the posterior. This fails for priors that are hard to sample (Cauchy amd others). Thanks to `brms` developer Paul Bürkner [for this insigt](https://twitter.com/paulbuerkner/status/963585470482604033). Luckily, there's a more general solution in `brms::bayesfactor`:
  
  ###`brms::bayes_factor`
  We finally arrived at my favorite: comparing `brm` models using `brms::bayes_factor`. This is a recent development, made possible by [the publication of the `bridgesampling` package in 2017](https://arxiv.org/abs/1703.05984).

Using the `priors_intercept` above, the syntax is very much like `lme4::lmer`. It mainly differs from `brms::hypothesis` in that you should fit the null model independently and change some arguments:
  
  ```{r, cache = TRUE, results = 'hide', message = FALSE, warning = FALSE}
full_brms = brm(score ~ 1, data = intercept_data, prior = priors_intercept, save_all_pars = TRUE, iter=10000)
null_brms = brm(score ~ 0, data = intercept_data, save_all_pars = TRUE, iter = 10000)
BF_brms_bridge = bayes_factor(full_brms, null_brms)
BF_brms_bridge$bf
```
```{r, echo = FALSE}
BF_brms_bridge$bf
```

I'm told that you need a lot of samples to get accurate Bayes factors using `brm`, so be sure to do multiple runs to ensure convergence.

### Summary of intercept-models
The computed Bayes factors against the $intercept = 0$ hypothesis were:

* BIC: `r round(BF_BIC, 1)`. 
* `BayesFactor`: `r round(exp(BF@bayesFactor$bf), 1)`
* `brms::hypothesis`: `r round(1 / BF_brms_savage$hypothesis$Evid.Ratio, 1)` (whoa!)
* `brms::bayes_factor`: `r round(BF_brms_bridge$bf, 1)`

Three of them are in the same ballpark. While their small differences are likely due to differences in priors. `bmrs::hypothesis` is erroneous in this case as explained in that section above. In general, though, Savage-Dickey works well for models with more well-defined priors (normal, etc.). The BICs unit information prior is very uninformative, leading to a higher change in credence, hence typically higher BF than priors which are more informative in the region of the maximum likelihood, such as the Cauchy prior we used above.

# Mixed models
To demonstrate the syntax for more complicated models, let's use data from an RCT which we published this spring. In brief, we include data from two treatment groups where brain-injured patients were treated using hypnotic suggestion and the effect on working memory was assessed on an index score, WMI (population mean=100, SD=15). A passive control group is excluded here because the treatment effects were very large and I want moderate Bayes factors for the present purpose.
```{r}
mixed_data = read.csv('https://osf.io/42avq/download', sep = '\t')
mixed_data = subset(mixed_data, group != 'control')  # Remove passive control group
```

```{r, echo = FALSE}
library(ggplot2)
ggplot(mixed_data, aes(x = session, y = WMI, group = id)) + 
  geom_line(col='gray') + 
  #geom_point(col='gray') + 
  stat_summary(aes(group = 1), fun.data = mean_cl_boot, lwd = 0.5, geom = 'pointrange') +
  facet_grid(~group) + 
  theme_bw() + 
  scale_y_continuous(breaks = seq(0, 200, 10)) + 
  ggtitle('Subjects and means from Lindeløv et al. (2017)')
```


We will be interested in seeing whether the two groups develop at a different rate as a function of time with time being modeled as a single slope rather than four offsets. This would be the session * group interaction term. <!-- I don't always do frequentist statistics, but when I do, I do likelihood-ratios:

```{r}
full = lme4::lmer(WMI ~ session * group + (1|id), mixed_data)  # With interaction
null = lme4::lmer(WMI ~ session + group + (1|id), mixed_data)  # Without interaction
anova(full, null)
```
-->
(For this particular research, this analysis does not reflect the hypotheses, but itøs data and we can compute Bayes factors. That's all that matters for the present purpose. (1) we expected ceiling effects in both groups, so the data is censored, and (2) we expected a greater gain in A between test 1-2, similar A and B between test 2-3 and greater gain in B between test 3-4. So our hypothesis is not unidirectional across all data. We expanded this on [page 10 of our supplementary information](https://osf.io/p5ybn/download).)


### BIC in `lme4::lmer`
BIC-based Bayes factors can also be computed for more complex `lme4::lmer` models in a similar way. Here we do a Bayes factor on the presence of the interaction term, i.e., whether the slope of `WMI` to `session` differs by group while using the random effect for `id` to discard between-subject offsets and provide a bit of shrinkage (good to ameliorate regression towards the mean, among other things).

```{r}
full_lmer = lme4::lmer(WMI ~ session * group + (1|id), mixed_data, REML = FALSE)
null_lmer = update(full_lmer, formula = ~ . -session:group)  # Without interaction term
#null_lmer = lme4::lmer(WMI ~ session + group + (1|id), mixed_data, REML=FALSE)  # Alternative specification
BF_BIC = exp((BIC(null_lmer) - BIC(full_lmer))/2)  # BICs to Bayes factor
BF_BIC
```

OK, so you would now favor the null model by a factor of `r round(1/BF_BIC, 1)` more than you did previously.

**Evaluation:** On the positive side, this method is very easy, very fast, and works for a lot of models. For mixed models, I used this approach to get a ballpark figure until I discovered `brms` a few weeks ago!
  
  There are many downsides. The BIC-derived Bayes factor uses a "unit information prior" which is a very uninformative prior that I haven't found a way to visualize. In other words, I don't really understand it. So BIC-based Bayes factors are far from the Bayesian ideal of updating credible beliefs. In BIC-world, you always start out knowing barely anything. Can people have an IQ of minus 100 or one million? Sure!
  
  
  ### `BayesFactor` package: many mixed effects models
  The test of the interaction term is quite similar to the `lme4::lmer` syntax:
  
  ```{r}
library(BayesFactor)
mixed_data$id = factor(mixed_data$id)  # BayesFactor wants the random to be a factor

full_BF = lmBF(WMI ~ session * group + id, data = mixed_data, whichRandom = 'id')
null_BF = lmBF(WMI ~ session + group + id, data = mixed_data, whichRandom = 'id')
full_BF / null_BF  # The Bayes factor in favor of the full model
```

This value is very similar to the BIC-lmer Bayes factor for the mixed model interaction term. 

**Evaluation:** `BayesFactor` is very easy to work with. The default priors in this package are the de facto default priors in research, for better or worse. Do remember to specify prior scales using `rScaleFixed` and `rScaleRandom`. Priors are specified on a normalized scale (standardized mean difference), so it does require some thought how to specify them for more intuitive untransformed effect sizes such as distance, time, weight, etc.

Although the information is hard to find, you can include multiple random intercepts like `lmBF(formula, data, whichRandom = c('id', 'other_var', 'third_var'))`.

`lmBF` works for GLM but not generalIZED models like logistic regression, log-linear regression, etc. It uses a few select priors (JZS and g-priors) which have to be centered at zero. This is much better than BIC but `brms` and BUGS-like implementations (see below) offers greater flexibility, though (naturally) at the "cost" of more coding.

Judging from it's [development on GitHub](https://github.com/richarddmorey/BayesFactor), the development of `BayesFactor` has slowed down since March 2017, but it is still developed and maintained.


### Savage-Dickey using `brms::hypothesis`
For the hypnosis study, we would set priors for each parameter individually.  To see the parameters of a model and their default priors, run

```{r, eval=FALSE}
get_prior(WMI ~ session * group + (1|id), data = mixed_data)
```
```{r, echo=FALSE}
prior_print = get_prior(WMI ~ session * group + (1|id), data = mixed_data)
kable(prior_print[, 1:4], "html") %>%  # Only first columns
  kable_styling()
```

These priors do not at all represent our knowledge about patients, treatments, and the design. There's a big literature on how to set priors, and I'm not too well acquainted with it. For a truly cumulative science, you would probably try to conduct meta-analyses on all published data and use those parameter estimates as your prior. This would be "maximally informative priors" (as opposed to "uninformative priors"). In practice, many set a prior using the results from one highly similar study or just make an even vaguer "expert judgment" to save time. Personally, to save time on smaller projects, I look at the 50% and 95% credible intervals and run it by a few colleagues to get a consensus summary of the current knowledge. So for the intercept of the patient population, I would fiddle around with this, until I found the values for `patient_mean` and `patient_sd` which best summarizes (my) current knowledge. I ended up with this:

```{r, fig.height=2.5, fig.width=6}
quantile_probs = c(0.05, 0.25, 0.75, 0.95)  # Quantiles for 95% and 50% intervals
patient_mean = 85  # minus one SD when population mean=100 and 1SD=15
patient_sd = 7

# Plot curve with ticks
curve(dnorm(x, patient_mean, patient_sd), from = 60, to = 110, n = 2000, xaxt = "n", yaxt = 'n', xlab = '', ylab = '', main = paste('Prior with SD = ', patient_sd))
  
# X-axis labels and vertical lines at quantiles
quantiles = qnorm(quantile_probs, patient_mean, patient_sd)
print(quantiles)
axis(1, at=round(quantiles, 1))
abline(v=quantiles, lty = c(3,1,1,3), lwd = c(1,3,3,1), col = 'red')
```

Let's set all priors using this kind of expert judgment (read: I'm just being lazy now) for the parameters of this model:
```{r}
priors_mixed = c(
  # -1SD Expected for patient group. 80% CI from 82 to 98 seems reasonable
  set_prior('normal(85, 7)', class = 'Intercept'),
  
  # none-to-moderate apriori difference between groups
  set_prior('normal(0, 8)', coef = 'groupgroupB'),
  
  # some gain expected due to retest and non-specific effects
  set_prior('normal(3, 2)', coef = 'session'),
  
  # a priori group A and B are expected to improve equally
  set_prior('normal(0, 2)', coef = 'session:groupgroupB'),
  
  # Between-subject SD at baseline around 15
  set_prior('gamma(30, 2)', class = 'sd', coef = 'Intercept', group = 'id')
)
```

Then run `brm` on the full model:
```{r, cache=TRUE, , results='hide', message=FALSE}
full_brms = brm(WMI ~ session * group + (1|id), data = mixed_data, prior = priors_mixed, sample_prior = TRUE, iter = 10000)
BF_brms_savage = hypothesis(full_brms, hypothesis = 'session:groupgroupB = 0')  # H0: No interaction
BF_brms_savage$hypothesis  # Show the results of this hypothesis test
```
```{r, echo=FALSE}
BF_brms_savage$hypothesis
```

Note that `Evid.Ratio` is the Bayes factor in favor of the null (!) since that is the hypothesis that we stated, so the BF in favor of H1 is `r 1/BF_brms_savage$hypothesis$Evid.Ratio`. In this case, it is less in favor of the null than when we used BIC or `BayesFactor`. The discrepancy is probably due to the change in priors: a more null-like prior means that we have to update our knowledge less.

`brms::hypothesis` computes an evidence ratio (a Bayes Factor) using the Savage-Dickey method which only requires the posterior of the parameter of interest. Thus, no null model needs to be fitted explicitly. As a side note, it is fairly straightforward to manually compute Bayes factors from Savage-Dickey density ratios on the output of `stan`, `JAGS`, and other samplers. I return to this in the section on the Product Space method.

**Evaluation:** `brms` provides a huge improvement over the other methods by allowing explicit specification of all priors, all link functions, meta-analysis, etc. With `hypothesis`, you don't need to explicitly state a null model.

However, Savage-Dickey can fail for even relatively simple models, e.g., categorical ones such as one-way ANOVAs ([Morey et al., 2011](http://pcl.missouri.edu/sites/default/files/Morey-etal-2011a.pdf)) and if we had modeled session with individual offsets in a change-model (as we did in our paper). I don't know of a simple rule about when it works and when it does not, and that makes me uncomfortable.


### `brms::bayes_factor`: almost all models
Again, this is very much like `brms::hypothesis` but with the null model fitted independently:
```{r, cache=TRUE, results='hide', message=FALSE}
full_brms = brm(WMI ~ session * group + (1|id), data = mixed_data, prior = priors_mixed, save_all_pars = TRUE, iter = 10000)
null_brms = update(full_brms, formula = ~ .-group:session)  # Same but without the interaction term
BF_brms_bridge = bayes_factor(full_brms, null_brms)
BF_brms_bridge
```
```{r, echo=FALSE}
BF_brms_bridge
```

**Evaluation:** Learn this tool, and you can do almost everything you'd ever need, including meta-analysis, Poisson models, mixed models with crossed random effects, SEM, etc. `brms` is a quite young package, bearing witness of incredible development speed. Expect many more features shortly. I'm personally looking forward to seeing full support for SEM in `brms` and automatic "imputation" of missing values, further setting `brms` apart from the other solutions.

On the negative side, `stan` compilation time is around 1 minute on my system which slows down testing of simpler models. Just building this notebook takes around 50 times longer because there are `brms` examples.


### Product space method in `JAGS`, `stan`, etc.: Truly all models!
If you want to do strange stuff like change point analysis or Number Needed to Treat (I do both), you would have to go for specialized R packages or the true all-purpose solution: the product space method. Here, you would code the models directly in a BUGS-like language like JAGS or stan.

For a conceptual and practical introduction, see [Ledowyckx et al., 2011](https://www.sciencedirect.com/science/article/pii/S0022249611000423) and then check out [this JAGS tutorial](https://michael-franke.github.io/statistics,/modeling/2017/07/07/BF_computation.html) on ways to set up BUGS models so that Bayes Factors can be computed from the MCMC samples. Despite these ressources, I am writing a section here to present the most minimal example for clarity, and adding solutions to a practical sampling problem. 

The product space method is very simple: you write up the two models and and let an indicator variable select one of them at the time (`which_model` below). The relative rate by which each model is sampled it's posterior odds. Multiply by the prior and BAM! You have your Bayes Factor!
  
  I like the product space method because of its conceptual simplicity whereas other Bayes factors tend to rely on clever math which is barely accessible to me. Also, the indicator variable reveals something fundamental about (Bayesian) hypothesis testing: in typical models, the mere presence of a certain parameter expresses the 100% prior belief that this parameter exists. The model switcher simply puts a less-than-100% prior on the parameter or configuration of parameters. In other words, the model itself is "just" a prior like those we put on parameters, and they do the same thing: specify which worlds (or "events" in philosophy) could have generated data.

Here is a JAGS model corresponding to a one-sample t-test where `score` is observed:
  
  ```{r, eval=FALSE}
model {
  which_model ~ dbern(0.5)  # Selecting between two models. dcat() for more.
  mu ~ dnorm(0, 10^-2)
  score ~ dnorm(mu * which_model, 0.707^-2)  # H0: mu*0 = 0. H1: mu * 1 = mu.
}
```

Since the sampling frequency represents the relative posterior probability of the two models, the Bayes factor for H1 is simply the proportion of samples where `which_model == 1` multiplied by the prior:
  
  ```{r, eval=FALSE}
rates = xtabs(~as.matrix(mcmc_samples$which_model))
BF_productspace = prior * (rates[2] / rates[1])
```

[Here's how to do the same thing in pymc3](https://github.com/pymc-devs/pymc3/issues/812). However, there are some major problems that you need to solve "manually": The autocorrelation on the `which_model` parameter is usually huge, leading to small effective sample size. Also, if one model is much more likely than another (say by a factor of > 1000), the less likely model will be sampled very rarely. It typically requires a lot of samples to arrive at an accurate Bayes factor. 

The latter problem can be solved by putting a prior in favor of the less likely model on `which_model` to counterweight the low likelihood, leading to more frequent sampling of it. But how much should the prior be in favor? The best solution I've found so far requires point-null hypotheses:
   
   1. Run the full model by setting `which_model ~ dbern(1)` so that the null model is never sampled.
 2. Calculate the Savage-Dickey Bayes factor for the parameter of interest.
 3. Use the inverse of this model probability as the prior when doing the proper product space method to counterweight the difference in likelihoods: `which_model ~ dbern(model_0_probability)`
 
 So if you use JAGS to get the posterior samples of the full model (`samples`) and the parameter posterior can be approximated as normal (using `dnorm`):
   
   ```{r, eval=FALSE}
 ps = as.matrix(samples['session'])  # posterior samples
 M0 = dnorm(0, 3, 3)  # height of prior at 0
 M1 = dnorm(0, mean(ps), sd(ps))  # approximation to height of posterior at 0.
 BF = M0 / M1  # BF in favor of H1 for this parameter
 ```
 
 If you test multiple parameters at once, a reasonable approximation is to multiply the Savage-Dickey Bayes factors for each of the parameters. Say you test two parameters at once:
   
   ```{r, eval=FALSE}
 param_names = c('session', 'age')  # Example parameter names
 param_prior_means = list(session = 3, age = 0)  # Priors for means
 param_prior_sds = list(session = 3, age = 0.4)  # Priors for SDs
 
 # Loop over parameters to test and update bayes factor
 BF = 1  # Start with equal model probabilities
 for(param_name in param_names) {
   ps = as.matrix(samples[param_name])  # posterior samples
   M1 = dnorm(0, mean(ps), sd(ps))  # approximation to height of posterior at 0.
   M0 = dnorm(0, param_prior_means[param_name], param_prior_sds[param_name])  # height of prior at 0
   BF_parameter = M0 / M1  # BF in favor of H1 for this parameter
   BF = BF * BF_parameter  # Update the estimate of the overall model evidence
 }
 ```
 
 I used this approach in Lindeløv et al. (2017), and [the code for that analysis can be found on OSF](https://osf.io/e63gd/). Another solution is doing an interactive process to home in on the prior probability that leads to equal sampling of model 0 and 1:
   
   1. Start with equal model probabilities: `which_model ~ dbern(0.5)`
 2. If the models are sampled very unevenly (i.e., by a factor of more than 20), run the sampling again using the inverse posterior probability as prior in the next iteration. So if model 1 was sampled 97% of the time, you set `which_model ~ dbern(1 - 0.97)`. If the 97% estimate was correct, model 1 should now be sampled 50% of the time relative to this prior meaning that its posterior probability is indeed 97%.
 3. Continue (2) until both models are sampled evenly.
 
 **Evaluation:** The product space method will work for everything. Test completely different models with all sorts of fancy switch points, non-linear effects, strange priors, non-standard covariance matrices, etc. Also, learning BUGS was the event that really made me understand linear models and how non-magic they are.
 
 However, this requires expert knowledge. It takes time to implement, change, and sample, so you feel less inclined to do model testing and sensitivity analyses, which you really should do! I only use product space in cases of emergency.
 
 ### Summary of mixed models
 ```{r, include=FALSE}
 BF_BF = full_BF / null_BF
 
 ```
 
 * `lme4` and BIC: `r round(BF_BIC, 3)`
 * `BayesFactor`: `r round(exp(BF_BF@bayesFactor$bf), 3)`
 * `brms::hypothesis`: `r round(1 / BF_brms_savage$hypothesis$Evid.Ratio, 3)`
 * `brms::bayes_factor`: `r round(BF_brms_bridge$bf, 3)`
 
 It is nice to see consistency between the two `brms` approaches, now that we have well-behaving priors. The more informative priors were only possible in the `brms` models and this is likely the source of the difference in the magnitude of the belief updating (the Bayes factor).
 
 # Honorable mentions
 ### JASP
 In the above, I focused exclusively on solutions in R. However, [there's also JASP](https://jasp-stats.org/). JASP is a super-sleek graphical user interface that makes Bayes factors accessible to a wider audience and [is a major improvement over SPSS](https://jasp-stats.org/2017/11/01/jasp-vs-spss/) even for frequentist statistics. JASP computes Bayes factors for most popular statistical models, including RM-ANOVA, regression, binomial, etc., and you can specify informative priors. JASP is a graphical interface to `R` and has hitherto relied on the `BayesFactor` package for analysis, though the JASP development team is currently working on a more comprehensive solution using BAS (see below).

### The BAS package
[BAS](https://github.com/merliseclyde/BAS) is a relatively new package which includes many "default priors" which can be specified using a single argument. This is very convenient. While it does GLM, it doesn't do intercept-only models and mixed models, so I haven't demoed it in this post. But the syntax for the equivalent of the intercept-only model would be something like:

```{r, eval=FALSE}
BAS::bas.lm(score ~ 1, data = intercept_data, prior = 'JZS', alpha = 0.707^2)
```

### Bayes Factors from parameter estimates
Many solutions have been proposed on how to compute Bayes Factors using posterior samples. I have covered the Savage-Dickey method above, which is somewhat fragile and constrained. The Bridge Sampling method of `brms::bayes_factor` seems like a general solution. 

Once in a while, a new paper claims to have found a similar general method. It is beyond my level of expertise to evaluate the merits of these approaches. I do want to raise a warning concerning one popular method, the Harmonic Mean estimate, [which has been shown to be highly unreliable](https://radfordneal.wordpress.com/2008/08/17/the-harmonic-mean-of-the-likelihood-worst-monte-carlo-method-ever/).