# stat330_final

Project looking to explore the relationship between a large breadth of features (race, geography, sat scores, etc.) and acceptance into a given college. This will be explored through Bayesian workflow, and specifically Bayesian regressions. 

analyze_model.R analyzes the rstanarm horseshoe prior logistic model on all of the features and a subset of the observations.

data_munging.py reads in the data cleans merges and prepares data for logistic regression. 

horseshoe.R builds and fits a rstanarm model that implements a horseshoe pior logistic regression to the cleaned and subsetted data. 