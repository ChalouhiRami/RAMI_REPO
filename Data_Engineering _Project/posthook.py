from data_handler import read_sheet_as_dataframe
import lookups
import data_handler  
import database_handler
def truncate_tables():
    db_session = database_handler.create_connection('config.json')
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

    ]

    for sheet_info in sheets_info:
        sheet_name = sheet_info["sheet_name"]
        full_table_name = data_handler.get_full_table_name(sheet_name, 'stg', 'config.json') 
        query = f'TRUNCATE TABLE Pluto.{full_table_name}'
        database_handler(db_session, query)
    database_handler.close_connection()

