"""
Christopher O'Neil
Script that does preliminary data cleaning and analysis
"""

import sqlite3
import pandas as pd
import os
from functools import reduce


def read_data(query: str, database: str, csv_name) -> pd.DataFrame:

    list_dir = os.listdir()
    list_diff = list(set([csv_name])-set(list_dir))

    if list_diff == [csv_name]:
        conn = sqlite3.connect(database)
        df = pd.read_sql_query(query, conn)
        df.dropna(axis=1, how="all", inplace=True)

        df.to_csv(csv_name)
        return df

    df = pd.read_csv(csv_name)
    return df


def merge_data(df_list: list, id_var_dict)-> pd.DataFrame:
    merged_df = reduce(lambda x, y: pd.merge(x, y, left_on=id_var_dict[str(x)], right_on=id_var_dict[str(y)]), df_list)
    merged_df.drop(columns=["Unnamed: 0_x", "Unnamed: 0_y"] + list(id_var_dict.values())[1:], inplace=True)
    return merged_df


def explore_data(data: pd.DataFrame):
    data_copy = data.copy()
    na_vals = data_copy.isna().sum().sort_values(ascending=False) / len(data_copy) * 100
    print(na_vals)
    data_copy.dropna(axis=0, how="any", inplace=True)
    print(data_copy)


choice_data = read_data("SELECT * FROM CHOICE WHERE YEAR==2010", "TFS_CHOICE_2008_2010.db", "choice.csv")
demo_data = read_data("SELECT * FROM DEMOGRAPHICS WHERE Surveyyear == 2010", "DEMOGRAPHICS.db", "demo.csv")
merged_data = merge_data([choice_data, demo_data], id_var_dict={str(choice_data):"SUBJID", str(demo_data):"SubjectI.D."})
explore_data(merged_data)

