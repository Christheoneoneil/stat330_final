"""
Christopher O'Neil
Script that does preliminary data cleaning and analysis
"""

import sqlite3
import pandas as pd
import os
from functools import reduce
import zipcodes


def read_data(query: str, database: str, csv_name) -> pd.DataFrame:
    """
    read data takes supplied sql queries and uses that to create
    pandas data frames
    :param query: string sql query
    :param database: provided data base to query
    :param csv_name: name of desired output csv
    :return: pandas data frame
    """
    list_dir = os.listdir()
    list_diff = list(set([csv_name])-set(list_dir))

    if list_diff == [csv_name]:
        conn = sqlite3.connect(database)
        df = pd.read_sql_query(query, conn)
        df.dropna(axis=1, how="all", inplace=True)

        df.to_csv(csv_name, index=False)
        return df

    df = pd.read_csv(csv_name)
    return df


def merge_data(df_list: list, merge_var) -> pd.DataFrame:
    """
    merge data merges the given data frames into one to
    prepare for data engineering.
    :param df_list: list of data frames
    :param id_var_dict: dictionary to keep track of columns to merge
    :return: merged pandas data frame
    """
    merged_df = reduce(lambda x, y: pd.merge(x, y, on=merge_var, how='outer'), df_list)

    return merged_df


def data_engineering(data: pd.DataFrame, desired_stats: list, unwanted_cols: list) -> None:
    """
    data engineering explores and engineers data for fitting a
    bayesian GLM
    :param unwanted_cols: columns that were found to be unwanted
    through data analysis
    :param data: pandas data frame containing given survey data
    :param desired_stats: stats desired for data analysis
    :return: None
    """

    from sklearn.preprocessing import LabelEncoder
    data_copy = data.copy()
    print(list(data_copy.columns))
    na_vals = data_copy.isna().sum().sort_values(ascending=False) / len(data_copy) * 100
    print(na_vals)

    data_copy.dropna(axis=0, how="any", inplace=True)

    desc_df = data_copy.describe()
    for stat in desired_stats:
        print(desc_df.iloc[list(desc_df.index).index(stat)])

    str_cols = list(data_copy.select_dtypes(include=object).columns)
    data_copy[str_cols] = data_copy[str_cols].apply(LabelEncoder().fit_transform)
    data_copy["is_real_zip"] = [zipcodes.is_real(str(int(zip_code))) for zip_code in data_copy["Studentshomezip"]]
    print(data_copy[data_copy["is_real_zip"] == False])
    data_copy.drop(unwanted_cols, axis=1, inplace=True)
    data_copy.to_csv("final_frame.csv")


merging_var = "SubjectI.D."
choice_data = read_data("SELECT * FROM CHOICE WHERE YEAR==2010", "TFS_CHOICE_2008_2010.db", "choice.csv")
choice_data.rename(columns={"SUBJID": merging_var}, inplace=True)
demo_data = read_data("SELECT * FROM DEMOGRAPHICS WHERE Surveyyear == 2010", "DEMOGRAPHICS.db", "demo.csv")
high_data = read_data("SELECT [SubjectI.D.], SATVerbal, SATMath, SATWriting ACTComposite FROM 'HIGH SCHOOL' WHERE Surveyyear == 2010",
                      "HIGH SCHOOL.db", "high_school.csv")

merged_data = merge_data([choice_data, demo_data, high_data], merging_var)
print(merged_data)
unneeded_cols = ["NORMSTAT", "STUDSTAT", "YEAR", "Surveyyear", "Studentshomezip", "AmericanIndian/AlaskaNative",
                 "NativeHawaiian/PacificIslander", "AfricanAmerican/Black", "MexicanAmerican/Chicano/o/x", "PuertoRican",
                  "OtherLatino/o/x", "White/Caucasian", "Other", "Asian", "RecodedCollegeI.D.", "is_real_zip",
                  "SurveyType", "Areyouenrolled(orenrolling)asa:", "Seximputed", "InstitutionControl", "InstitutionType"]

data_engineering(merged_data, ["min", "max", "std"], unneeded_cols)
