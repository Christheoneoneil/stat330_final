"""
script that fits a bayesian lasso regression to binomial target data
"""
import pandas as pd


def read_data(file_name):
    return pd.read_csv(file_name, index_col="Unnamed: 0")


imputed_dat = read_data("final_frame_imputed.csv")
non_imputed_dat = read_data("final_frame_non_imputed.csv")
