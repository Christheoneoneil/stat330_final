library("tidyverse")
library("brms")
library("rstanarm")
remove.packages(c("StanHeaders", "rstan", "cmdstanr"))
install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
               
for (name in list("imputed", "non_imputed")){
  df <- as_tibble(read.csv(paste(name, ".csv", sep="")))
  df$CHOICE <- (ifelse(df$CHOICE ==1, 1, 0))
  df <- sample_frac(df, 0.3)
  y <- pull(df, CHOICE)
  x <- select(df, -c(CHOICE, ComparisonGroup3, Studentstatus, Normsstatus, X))
  x <- as.matrix(x)
  D <- ncol (x)
  n <- nrow (x)
  p0 <- 1 # prior guess for the number of relevant variables
  sigma <- 1 / sqrt(mean(y)*(1-mean(y))) # pseudo sigma
  tau0 <- p0 /( D - p0 ) * sigma / sqrt ( n )
  prior_coeff <- hs ( df =1 , global_df =1 , global_scale = tau0 )
  # fit the model
  fit <- stan_glm ( y ~ x , family = binomial () , data = data.frame (I(x),y) ,
                    prior = prior_coeff, chains = 2, iter=4000, cores=7)
  saveRDS(fit, file=paste(name, ".rds", sep=""))
}
