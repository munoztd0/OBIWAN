

# ------------------------------------ intensity ------------------------------

formula = 'perceived_intensity ~ condition*group + thirsty + thirsty:condition +  hungry + 
              (condition |id) + (1|trialxcondition)'
model = mixed(formula, data = HED, method = "LRT", control = control, REML = FALSE); model
#xxxx
### Linear Mixed Models  
# Mixed is just a wrapper for lmer to get p-values from parametric bootstrapping #but set to method "LRT" and remove "args_test" to quick check
# model = mixed(formula, data = HED.clean, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 500, cl=cl)); model 

ref_grid(model)  #triple check everything is centered at 0

### Extract LogLik to compute BF for condition
main = lmer(formula, data = HED, control = control, REML = F)
null = lmer(perceived_intensity ~ group + hungry + hungry:condition  + (condition|id) + (1|trialxcondition), data = HED, control = control, REML = F)
test = anova(main, null, test = 'Chisq')

#get BF from mixed models see Wagenmakers, 2007
BF_HED = exp((test[1,3] - test[2,3])/2); BF_HED


### Get posthoc contrasts pval and CI
mod <- lmer(formula, data = HED, control = control, REML = T) # recompute model with REML = T now for further analysis

p_cond = emmeans(mod, pairwise~ condition, side = ">"); p_cond #for condition (MilkShake > Empty right sided)
CI_cond = confint(emmeans(mod, pairwise~ condition),level = 0.95, method = c("boot"), nsim = 5000); CI_cond$contrasts #get CI condition

# inter = emmeans(mod, pairwise~ condition|group, adjust = "tukey"); inter$contrasts  #for group X condition (adjusted but still right sided)
# CI_inter = confint(emmeans(mod, pairwise~ condition|group),level = 0.95,method = c("boot"),nsim = 5000); CI_inter$contrasts ##get CI inter


# ------------------------------------ familiarity ------------------------------

formula = 'perceived_familiarity ~ condition*group + thirsty + thirsty:condition +  hungry + 
              (condition |id) + (1|trialxcondition)'
model = mixed(formula, data = HED, method = "LRT", control = control, REML = FALSE); model
#xxxx
### Linear Mixed Models  
# Mixed is just a wrapper for lmer to get p-values from parametric bootstrapping #but set to method "LRT" and remove "args_test" to quick check
# model = mixed(formula, data = HED.clean, method = "PB", control = control, REML = FALSE, args_test = list(nsim = 500, cl=cl)); model 

ref_grid(model)  #triple check everything is centered at 0

### Extract LogLik to compute BF for condition
main = lmer(formula, data = HED, control = control, REML = F)
null = lmer(perceived_familiarity ~ group + hungry + hungry:condition  + (condition|id) + (1|trialxcondition), data = HED, control = control, REML = F)
test = anova(main, null, test = 'Chisq')

#get BF from mixed models see Wagenmakers, 2007
BF_HED = exp((test[1,3] - test[2,3])/2); BF_HED


### Get posthoc contrasts pval and CI
mod <- lmer(formula, data = HED, control = control, REML = T) # recompute model with REML = T now for further analysis

p_cond = emmeans(mod, pairwise~ condition, side = ">"); p_cond #for condition (MilkShake > Empty right sided)
CI_cond = confint(emmeans(mod, pairwise~ condition),level = 0.95, method = c("boot"), nsim = 5000); CI_cond$contrasts #get CI condition

# inter = emmeans(mod, pairwise~ condition|group, adjust = "tukey"); inter$contrasts  #for group X condition (adjusted but still right sided)
# CI_inter = confint(emmeans(mod, pairwise~ condition|group),level = 0.95,method = c("boot"),nsim = 5000); CI_inter$contrasts ##get CI inter