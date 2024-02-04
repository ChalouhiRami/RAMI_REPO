import database_handler
import data_handler
import lookups
import os 
import glob 
from datetime import datetime
# def create_etl_watermark( ):
    
#     try:
#         db_session = database_handler.create_connection('config.json')
#         execute(db_session)
#         data_handler.read_dataset_create_tables_and_insert_data
        
 
#         current_timestamp = datetime.now()
#         initial_timestamp = current_timestamp.strftime("%Y-%m-%d %H:%M:%S")
    
#         schema_name = "dwreporting"
#         table_name = "etl_watermark"
    
#         query = f"INSERT INTO {schema_name}.{table_name} (etl_last_execution_time) VALUES ('{initial_timestamp}');"
#         database_handler.execute_query(db_session, query)
        
       
     
#         db_session.commit()

#     except Exception as error:
        
#         print(f'An error occurred during ETL: {str(error)}')
    
    
 
def execute(db_session):
    sql_files = glob.glob("**/*.sql")

    for sql_file in sql_files:
         
        file_name = sql_file.split("\\")[-1]
         
        if "_prehook" in file_name:
            query = None
            print(file_name)   
            
            with open(sql_file, "r") as f:
                query = f.read()
            database_handler.execute_query(db_session, query)
            db_session.commit()
def create_staging_tables():
    db_session = database_handler.create_connection('config.json')
    execute(db_session)
   
    
    sheets_info = [
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=countries', "sheet_name": "countries"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=avg_temperature', "sheet_name": "avg_temperature"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=prevalence_of_undernourishment', "sheet_name": "prevalence_of_undernourishment"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=disaster_types', "sheet_name": "disaster_types"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=gdp', "sheet_name": "gdp"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=world_population', "sheet_name": "world_population"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=natural_disasters', "sheet_name": "natural_disasters"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=disaster_magnitude', "sheet_name": "disaster_magnitude"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=worldcities', "sheet_name": "worldcities"},
        {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=share_without_improved_water', "sheet_name": "share_without_improved_water"},
         {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=valuable_country_data', "sheet_name": "valuable_country_data"},
                  {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=continents', "sheet_name": "continents"},
                  {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=magnitude_scale', "sheet_name": "magnitude_scale"},
                  {"type": lookups.FileType.CSV, "config": 'https://docs.google.com/spreadsheets/d/18GUCOh6BzZ6eLeM1fbLGrnPpW2DeUUal-jqci93w6R8/gviz/tq?tqx=out:csv&sheet=subregions', "sheet_name": "subregions"},

 
    ]

    for sheet_info in sheets_info:
        df, sheet_name = data_handler.read_sheet_as_dataframe(sheet_info)
        data_handler.create_staging_tables(db_session, df, 'dwreporting',sheet_name)
    db_session.commit()