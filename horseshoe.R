library("tidyverse")
library("brms")
remove.packages(c("StanHeaders", "rstan", "cmdstanr"))
install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
                 
imputed_dat <- as_tibble(read.csv("imputed.csv"))
non_imputed_dat <- as_tibble(read.csv("non_imputed.csv"))
for (df in list(imputed_dat, non_imputed_dat)){
  df <- sample_frac(df, 0.2)
  y <- pull(df, CHOICE)
  x <- select(df, -c(CHOICE, ComparisonGroup3, Studentstatus, Normsstatus))
  D <- ncol(x)
  n <- nrow (x)
  p0 <- 5 # prior guess for the number of relevant variables
  sigma <- 1 / sqrt (mean(y)*abs(1 - mean (y))) # pseudo sigma
  tau0 <- p0 /(D -p0) * sigma / sqrt(n)
  set_prior(horseshoe(scale_global = tau0))
  # fit the model
  fit <- brm(CHOICE ~ ., family = categorical() , data=data.frame(df), 
             chains = 2, cores = 7)
  print(summary(fit))
}
