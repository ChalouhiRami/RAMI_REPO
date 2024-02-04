import database_handler

import glob 

def execute():
    db_session = database_handler.create_connection('config.json')
    sql_files = glob.glob("**/*.sql")

    for sql_file in sql_files:
         
        file_name = sql_file.split("\\")[-1]
            
        if "V3_hook"  in file_name:
            query = None
            print(file_name)   
            
            with open(sql_file, "r") as f:
                query = f.read()
            database_handler.execute_query(db_session, query)
            db_session.commit()
    db_session.close()