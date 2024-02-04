import pandas as pd
import lookups
from error_handler import log_error, print_error_console
import lookups
import data_handler
import database_handler
import json
from datetime import datetime
import numpy as np 


def read_data_as_dataframe(file_type, file_config, db_session = None):
    try:
        if file_type == lookups.FileType.CSV:
            return pd.read_csv(file_config,low_memory=False)
        elif file_type == lookups.FileType.EXCEL:
            return pd.read_excel(file_config)
        elif file_type == lookups.FileType.SQL:
            return pd.read_sql(file_config, db_session)
    except Exception as error:
        prefix = lookups.ErrorHandling.DB_CONNECTION_ERROR.value
        suffix = str(error)
        print_error_console(suffix,prefix)
        log_error(f'An error occurred: {str(error)}')
        return None

def read_sheet_as_dataframe(sheet_info):
    file_type = sheet_info["type"]
    file_config_parameter = sheet_info["config"]
    sheet_name = sheet_info["sheet_name"]

    df = data_handler.read_data_as_dataframe(file_type, file_config_parameter)
    return df, sheet_name



import json

def return_create_statement_from_df(dataframe, schema_name, table_name, table_type, config_path='config.json'):
    with open(config_path) as config_file:
        config_data = json.load(config_file)

    type_mapping = {
        'int64': 'BIGINT',  # Change to BIGINT for int64 columns
        'float64': 'FLOAT',
        'object': 'TEXT',
        'datetime64[ns]': 'TIMESTAMP'
    }
    
    fields = []
    for column, dtype in dataframe.dtypes.items():
        if str(dtype) == 'int64':
            sql_type = 'BIGINT'
        else:
            sql_type = type_mapping.get(str(dtype), 'TEXT')
        fields.append(f"{column} {sql_type}")
    
    table_source = config_data.get(table_name, '')
    full_table_name = f"{table_type}_{table_name}_{table_source}"
    
    create_table_statement = f"CREATE TABLE IF NOT EXISTS {schema_name}.{full_table_name} ( \n"
    create_table_statement += "ID SERIAL PRIMARY KEY,\n"  # Assuming an ID column
    create_table_statement += ',\n'.join(fields)
    create_table_statement += ");"
    
    return full_table_name, create_table_statement

import pandas as pd
import datetime

def return_insert_statement_from_df(dataframe, schema_name, full_table_name, db_session):
    columns = ', '.join(dataframe.columns)
    insert_statements = []

    try:
        with db_session.cursor() as cursor:
            for index, row in dataframe.iterrows():
                values_list = []
                for val in row.values:
                    if pd.isnull(val):
                        values_list.append("NULL")
                    elif isinstance(val, (int, float)):
                        values_list.append(str(val))
                    elif isinstance(val, str):
                        
                        try:
                            date_obj = datetime.datetime.strptime(val, "%m/%d/%Y")
                            formatted_val = date_obj.strftime("%Y-%m-%d")
                            values_list.append(f"'{formatted_val}'")
                        except ValueError:
                             
                            values_list.append(f"'{val}'")
                    else:
                        
                        values_list.append(f"'{str(val)}'")

                values = ', '.join(values_list)
                insert_statement = f"INSERT INTO {schema_name}.{full_table_name} ({columns}) VALUES ({values});"
                insert_statements.append(insert_statement)
    except Exception as error:
        db_session.rollback()   
        print(f"An error occurred: {str(error)}")

    return insert_statements

def read_config(config_path='config.json'):
    with open(config_path, 'r') as config_file:
        return json.load(config_file)

def get_timestamp_column(config, table_name):
    return config['staging_tables'][table_name]['timestamp_column']

def get_last_update_timestamp(db_session, schema_name, watermark_table_name, full_table_name):
    query = f"""
        SELECT last_update_timestamp FROM {schema_name}.{watermark_table_name}
        WHERE table_name = '{full_table_name}';
    """
    result = database_handler.execute_query_and_fetch(db_session, query)
    return result[0][0] if result else None

def insert_records(db_session, statements):
    for statement in statements:
        database_handler.execute_query(db_session, statement)

def update_watermark(db_session, schema_name, watermark_table_name, full_table_name):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    query = f"""
        INSERT INTO {schema_name}.{watermark_table_name} (last_update_timestamp, table_name)
        VALUES ('{timestamp}', '{full_table_name}')
        ON CONFLICT (table_name)
        DO UPDATE SET last_update_timestamp = EXCLUDED.last_update_timestamp;
    """
    database_handler.execute_query(db_session, query)

def update_watermark_if_data_exist(db_session, schema_name, watermark_table_name, full_table_name, timestamp):
     
    timestamp_as_timestamp = pd.to_datetime(f'{int(timestamp)}-01-01')

    query = f"""
        INSERT INTO {schema_name}.{watermark_table_name} (last_update_timestamp, table_name)
        VALUES ('{timestamp_as_timestamp}', '{full_table_name}')
        ON CONFLICT (table_name)
        DO UPDATE SET last_update_timestamp = EXCLUDED.last_update_timestamp;
    """
    database_handler.execute_query(db_session, query)

 

  

def create_staging_tables(db_session, df, schema_name, table_name):
    config = read_config()
    timestamp_column_name = get_timestamp_column(config, table_name)
    full_table_name, create_statement = data_handler.return_create_statement_from_df(df, schema_name, table_name, "stg")

    database_handler.execute_query(db_session, create_statement)

    timestamp_object = get_last_update_timestamp(db_session, schema_name, "etl_watermark", full_table_name)
    new_or_updated_records = pd.DataFrame()

    if timestamp_object is not None:
         
        timestamp_object = pd.to_datetime(timestamp_object)

        if df[timestamp_column_name].dtype == 'int64':
          new_or_updated_records = df[df[timestamp_column_name] > timestamp_object.year]
        else:
          new_or_updated_records = df[pd.to_datetime(df[timestamp_column_name]) > timestamp_object]


        if not new_or_updated_records.empty:
            print("table name:", full_table_name, " ", new_or_updated_records.empty)
            insert_statements = data_handler.return_insert_statement_from_df(new_or_updated_records, schema_name, full_table_name, db_session)
            insert_records(db_session, insert_statements)
            timestamp_value = new_or_updated_records[timestamp_column_name].max()
            update_watermark_if_data_exist(db_session, schema_name, "etl_watermark", full_table_name, timestamp_value)
        else:
            print("No new or updated records found.")
    else:
        print("none", timestamp_object)
        print("table name:", full_table_name, " ", new_or_updated_records.empty)
        insert_statements = data_handler.return_insert_statement_from_df(df, schema_name, full_table_name, db_session)
        insert_records(db_session, insert_statements)
        update_watermark(db_session, schema_name, "etl_watermark", full_table_name)

 
