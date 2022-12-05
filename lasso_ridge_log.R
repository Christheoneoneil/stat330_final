library(dplyr)
library(ggplot2)
library(caTools)
library(glmnet)

varImp <- function(object, lambda = NULL, ...) {
  beta <- predict(object, s = lambda, type = "coef")
  if(is.list(beta)) {
    out <- do.call("cbind", lapply(beta, function(x) x[,1]))
    out <- as.data.frame(out, stringsAsFactors = TRUE)
  } else out <- data.frame(Overall = beta[,1])
  out <- abs(out[rownames(out) != "(Intercept)",,drop = FALSE])
  out
}

for (name in list("imputed")){
  df <- as_tibble(read.csv(paste(name, ".csv", sep="")))
  
  df$ACCPT1ST <- (ifelse(df$ACCPT1ST == 2, 1, 0))
  
  df <- select(df, -c(CHOICE,
                      ComparisonGroup3,
                      Studentstatus,
                      Normsstatus,
                      OBEREGION,
                      OBERegion,
                      X))
  
  sample_split <- sample.split(Y = df$ACCPT1ST, SplitRatio = 0.7)
  
  train_set <- subset(x = df, sample_split == TRUE)
  test_set <- subset(x = df, sample_split == FALSE)
  
  train_x = as.matrix(select(train_set, -ACCPT1ST))
  train_y = as.matrix(train_set$ACCPT1ST)
  
  lasso_log <- glmnet(train_x,
                      y=train_y,
                      alpha=1,
                      family="binomial")
  
  ridge_log <- glmnet(train_x,
                      y=train_y,
                      alpha=0,
                      family="binomial")
  
  test_x = as.matrix(select(test_set, -ACCPT1ST))
  test_y = as.matrix(test_set$ACCPT1ST)
  
  pred_lasso <- predict(lasso_log, newx = test_x)
  pred_ridge <- predict(ridge_log, newx = test_x)
  
  assess_lasso <- assess.glmnet(pred_lasso,
                                newy = test_y,
                                alpha = 1,
                                family = "binomial")
  
  assess_ridge <- assess.glmnet(pred_ridge,
                                newy = test_y,
                                alpha = 0,
                                family = "binomial")
  
  cfit_lasso <- cv.glmnet(as.matrix(select(df, -ACCPT1ST)),
                          as.matrix(df$ACCPT1ST),
                          alpha = 1,
                          family = "binomial",
                          type.measure = "auc",
                          keep = TRUE)
  
  cfit_ridge <- cv.glmnet(as.matrix(select(df, -ACCPT1ST)),
                          as.matrix(df$ACCPT1ST),
                          alpha = 0,
                          family = "binomial",
                          type.measure = "auc", 
                          keep = TRUE)
  
  sds <- apply(as.matrix(select(df, -ACCPT1ST)), 2, sd)
  
  lasso_imp <- varImp(cfit_lasso, lambda = cfit_lasso$lambda.min)
  lasso_coef <- as.matrix(coef(cfit_lasso, s='lambda.min'))
  lasso_imp <- lasso_coef[-1, 1] * sds
  
  ridge_imp <- varImp(cfit_ridge, lambda = cfit_ridge$lambda.min)
  ridge_coef <- as.matrix(coef(cfit_ridge, s="lambda.min"))
  ridge_imp <- ridge_coef[-1, 1] * sds
  
  rocs_lasso <- roc.glmnet(cfit_lasso$fit.preval, newy = factor(df$ACCPT1ST))
  lass_best <- cfit_lasso$index["min",]
  plot(rocs_lasso[[lass_best]], type = "l")
  invisible(sapply(rocs_lasso, lines, col="grey"))
  lines(rocs_lasso[[lass_best]], lwd = 2,col = "red")
  title('Logistic LASSO Regression True versus False Positive Rates\n(Imputed)')
  
  rocs_ridge <- roc.glmnet(cfit_ridge$fit.preval, newy = factor(df$ACCPT1ST))
  ridge_best <- cfit_ridge$index["min",]
  plot(rocs_ridge[[ridge_best]], type = "l")
  invisible(sapply(rocs_ridge, lines, col="grey"))
  lines(rocs_ridge[[ridge_best]], lwd = 2,col = "red")
  title('Logistic Ridge Regression True versus False Positive Rates\n(Imputed)')
  
  lidf <- data.frame(lasso_imp)
  sorted_lidf_vals <- lidf[order(lidf$lasso_imp, decreasing = TRUE),]
  sorted_lidf_name <- data.frame(rownames(lidf))[order(lidf$lasso_imp, decreasing = TRUE),]
  sorted_lidf <- data.frame(sorted_lidf_name, sorted_lidf_vals)
  
  ridf <- data.frame(ridge_imp)
  sorted_ridf_vals <- ridf[order(ridf$ridge_imp, decreasing = TRUE),]
  sorted_ridf_name <- data.frame(rownames(ridf))[order(ridf$ridge_imp, decreasing = TRUE),]
  sorted_ridf <- data.frame(sorted_ridf_name, sorted_ridf_vals)
  
  remove(df, cfit_ridge, cfit_lasso, 
         pred_lasso, pred_ridge, test_x, 
         test_y, train_x, train_y)
}

for (name in list("non_imputed")){
  df <- as_tibble(read.csv(paste(name, ".csv", sep="")))
  
  df$ACCPT1ST <- (ifelse(df$ACCPT1ST == 2, 1, 0))
  
  df <- select(df, -c(CHOICE,
                      ComparisonGroup3,
                      Studentstatus,
                      Normsstatus,
                      OBEREGION,
                      OBERegion,
                      X))
  
  sample_split <- sample.split(Y = df$ACCPT1ST, SplitRatio = 0.7)
  
  train_set <- subset(x = df, sample_split == TRUE)
  test_set <- subset(x = df, sample_split == FALSE)
  
  train_x = as.matrix(select(train_set, -ACCPT1ST))
  train_y = as.matrix(train_set$ACCPT1ST)
  
  lasso_log <- glmnet(train_x,
                      y=train_y,
                      alpha=1,
                      family="binomial")
  
  ridge_log <- glmnet(train_x,
                      y=train_y,
                      alpha=0,
                      family="binomial")
  
  test_x = as.matrix(select(test_set, -ACCPT1ST))
  test_y = as.matrix(test_set$ACCPT1ST)
  
  pred_lasso <- predict(lasso_log, newx = test_x)
  pred_ridge <- predict(ridge_log, newx = test_x)
  
  assess_lasso <- assess.glmnet(pred_lasso,
                                newy = test_y,
                                alpha = 1,
                                family = "binomial")
  
  assess_ridge <- assess.glmnet(pred_ridge,
                                newy = test_y,
                                alpha = 0,
                                family = "binomial")
  
  cfit_lasso <- cv.glmnet(as.matrix(select(df, -ACCPT1ST)),
                          as.matrix(df$ACCPT1ST),
                          alpha = 1,
                          family = "binomial",
                          type.measure = "auc",
                          keep = TRUE)
  
  cfit_ridge <- cv.glmnet(as.matrix(select(df, -ACCPT1ST)),
                          as.matrix(df$ACCPT1ST),
                          alpha = 0,
                          family = "binomial",
                          type.measure = "auc", 
                          keep = TRUE)
  
  sds <- apply(as.matrix(select(df, -ACCPT1ST)), 2, sd)
  
  lasso_imp <- varImp(cfit_lasso, lambda = cfit_lasso$lambda.min)
  lasso_coef <- as.matrix(coef(cfit_lasso, s='lambda.min'))
  lasso_imp <- lasso_coef[-1, 1] * sds
  
  ridge_imp <- varImp(cfit_ridge, lambda = cfit_ridge$lambda.min)
  ridge_coef <- as.matrix(coef(cfit_ridge, s="lambda.min"))
  ridge_imp <- ridge_coef[-1, 1] * sds
  
  rocs_lasso <- roc.glmnet(cfit_lasso$fit.preval, newy = factor(df$ACCPT1ST))
  lass_best <- cfit_lasso$index["min",]
  plot(rocs_lasso[[lass_best]], type = "l")
  invisible(sapply(rocs_lasso, lines, col="grey"))
  lines(rocs_lasso[[lass_best]], lwd = 2,col = "red")
  title('Logistic LASSO Regression True versus False Positive Rates\n(Non-Imputed)')
  
  rocs_ridge <- roc.glmnet(cfit_ridge$fit.preval, newy = factor(df$ACCPT1ST))
  ridge_best <- cfit_ridge$index["min",]
  plot(rocs_ridge[[ridge_best]], type = "l")
  invisible(sapply(rocs_ridge, lines, col="grey"))
  lines(rocs_ridge[[ridge_best]], lwd = 2,col = "red")
  title('Logistic Ridge Regression True versus False Positive Rates\n(Non-Imputed)')
  
  lndf <- data.frame(lasso_imp)
  sorted_lidf_vals <- lidf[order(lidf$lasso_imp, decreasing = TRUE),]
  sorted_lidf_name <- data.frame(rownames(lidf))[order(lidf$lasso_imp, decreasing = TRUE),]
  sorted_lidf <- data.frame(sorted_lidf_name, sorted_lidf_vals)
  
  rndf <- data.frame(ridge_imp)
  sorted_ridf_vals <- ridf[order(ridf$ridge_imp, decreasing = TRUE),]
  sorted_ridf_name <- data.frame(rownames(ridf))[order(ridf$ridge_imp, decreasing = TRUE),]
  sorted_ridf <- data.frame(sorted_ridf_name, sorted_ridf_vals)
  
  remove(df, cfit_ridge, cfit_lasso, 
         pred_lasso, pred_ridge, test_x, 
         test_y, train_x, train_y)
}