library(rstanarm)
library(see)

data = output$allIndPars

model <- stan_glm(aplha_pos ~ group, data = data,
                  prior = normal(0, 3, autoscale = FALSE))

#test interval between -1 and 1
BF <- bayesfactor_parameters(model, null = c(-1, 1))
BF


plot(BF)

#test against 0
BF2 <- bayesfactor_parameters(model, null = 0)
BF2
plot(BF2)

#directional
test_group2_right <- bayesfactor_parameters(model, direction = ">")
test_group2_right
plot(test_group2_right)


#so now we ask what parameters are supported by the data (at at least 1 BF) -> SI= suported interval
my_first_si <- si(model, BF = 1)
my_first_si
plot(my_first_si)

#“The interpretation of such intervals would be analogous to how a frequentist confidence interval contains all the parameter values that would not have been rejected if tested at level α. For instance, a BF = 1/3 support interval encloses all values of theta for which the updating factor is not stronger than 3 against.” (Wagenmakers et al., 2018)
