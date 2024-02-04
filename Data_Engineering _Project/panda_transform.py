import pandas as pd


def remove_duplicates(df, subset=None):
    return df.drop_duplicates(subset=subset, keep='first')

def remove_nulls(df, columns=None):
    if columns:
        return df.dropna(subset=columns)
    else:
        return df.dropna()

