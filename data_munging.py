"""
Christopher O'Neil
Script that does preliminary data cleaning and analysis
"""

import sqlite3
import pandas as pd
import os


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


def engineer_data(data: pd.DataFrame):
    data_copy = data.copy()


choice_data = read_data("SELECT * FROM CHOICE WHERE YEAR==2010", "TFS_CHOICE_2008_2010.db", "choice.csv")
demo_data = read_data("SELECT * FROM DEMOGRAPHICS WHERE Surveyyear == 2010", "DEMOGRAPHICS.db", "demo.csv")
