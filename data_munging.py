"""
Christopher O'Neil
Script that does preliminary data cleaning and analysis
"""

import sqlite3
import pandas as pd
import matplotlib.pyplot as plt


def read_data(query: str, database: str) -> pd.DataFrame:
    conn = sqlite3.connect(database)
    df = pd.read_sql_query(query, conn)
    return df


choice_data = read_data("SELECT * FROM CHOICE WHERE YEAR==2010", "TFS_CHOICE_2008_2010.db")
demo_data = read_data("SELECT * FROM DEMOGRAPHICS WHERE Surveyyear == 2010", "DEMOGRAPHICS.db")
