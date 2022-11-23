library("tidyverse")
library("brms")
remove.packages(c("StanHeaders", "rstan", "cmdstanr"))
install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
               
for (name in list("imputed", "non_imputed")){
  df <- as_tibble(read.csv(paste(name, ".csv", sep="")))
  df$CHOICE <- (ifelse(df$CHOICE ==1, 1, 0))
  df <- sample_frac(df, 0.3)
  y <- pull(df, CHOICE)
  x <- select(df, -c(CHOICE, ComparisonGroup3, Studentstatus, Normsstatus, X))
  D <- ncol(x)
  n <- nrow (x)
  p0 <- 20 # prior guess for the number of relevant variables
  sigma <- 1 / sqrt (mean(y)*(1 - mean (y))) # pseudo sigma
  tau0 <- p0 /(D -p0) * sigma / sqrt(n)
  set_prior(horseshoe(scale_global = tau0))
  # fit the model
  fit <- brm(CHOICE ~ ., family = bernoulli(link="logit") , data=data.frame(df), 
             chains = 2, cores = 7, iter=4000)
  saveRDS(fit, file=paste(name, ".rds", sep=""))
  stanplot(fit, 
           type = "trace")
  stanplot(Bayes_Model_Binary, 
           type = "acf_bar")
  stanplot(Bayes_Model_Binary, 
           type = "areas",
           prob = 0.95,
           transformations = "exp") +
    geom_vline(xintercept = 1, color = "grey")
  print(summary(fit))
}

