# read dataset
df = mtcars

# create multiple linear model
lm_fit <- lm(mpg ~ cyl + hp, data=df)
summary(lm_fit)

# save predictions of the model in the new data frame 
# together with variable you want to plot against
predicted_df <- data.frame(mpg_pred = predict(lm_fit, df), hp=df$hp)

# this is the predicted line of multiple linear regression
ggplot(data = df, aes(x = mpg, y = hp)) + 
  geom_point(color='blue') +
  geom_line(color='red',data = predicted_df, aes(x=mpg_pred, y=hp))