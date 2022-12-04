library(dplyr)
library(ggplot2)
library(caTools)
library(glmnet)

for (name in list("imputed", "non_imputed")){
  df <- as_tibble(read.csv(paste(name, ".csv", sep="")))
  df$ACCPT1ST <- (ifelse(df$ACCPT1ST == 2, 1, 0))
  df <- select(df, -c(CHOICE, ComparisonGroup3, Studentstatus, Normsstatus, OBEREGION, OBERegion, X))
  sample_split <- sample.split(Y = df$ACCPT1ST, SplitRatio = 0.7)
  train_set <- subset(x = df, sample_split == TRUE)
  test_set <- subset(x = df, sample_split == FALSE)
  source = test_set
  target = test_set$ACCPT1ST
  factored_target = as.factor(target)
  lasso_log <- glmnet(source, y=factored_target, alpha=1, family="binomial")
  ridge_log <- glmnet(source, y=factored_target, alpha=0, family="binomial")

}