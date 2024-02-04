import psycopg2
import lookups
import file_handler
from error_handler import log_error, print_error_console


def create_connection(config_file):
    db_session = None
    try:
        config_data = file_handler.read_config(config_file)

        if config_data is not None:
            db_host = config_data.get("db_host")
            db_name = config_data.get("db_name")
            db_user = config_data.get("db_user")
            db_pass = config_data.get("db_pass")
            db_port = config_data.get("port_id")

            if db_host and db_name and db_user and db_pass:
                db_session = psycopg2.connect(
                    host=db_host,
                    database=db_name,
                    user=db_user,
                    password=db_pass,
                    port=db_port
                )
            else:
                print("Missing database connection parameters in the config file.")
        else:
            print("Failed to read the configuration file.")
    except Exception as error:
        prefix = lookups.ErrorHandling.DB_CONNECTION_ERROR.value
        suffix = str(error)
        print_error_console(suffix, prefix)
        log_error(f'An error occurred: {str(error)}')

    finally:
        return db_session


def close_connection(db_session):
    db_session.close()


def execute_query(db_session, sql_query, parameters=None):
    if db_session is not None:
        cursor = db_session.cursor()
        try:
            if parameters is not None:
                cursor.execute(sql_query, parameters)
            else:
                cursor.execute(sql_query)
            db_session.commit()
        except Exception as error:
            prefix = lookups.ErrorHandling.DB_CONNECTION_ERROR.value
            suffix = str(error)
            print_error_console(suffix, prefix)
            log_error(f'An error occurred: {str(error)}')
        finally:
            cursor.close()
    else:
        print("Error, cannot execute query.")

def execute_query_and_fetch(db_session, sql_query):
    if db_session is not None:
        cursor = db_session.cursor()
        try:
            cursor.execute(sql_query)
            result = cursor.fetchall()
        except Exception as error:
            prefix = lookups.ErrorHandling.DB_CONNECTION_ERROR.value
            suffix = str(error)
            print_error_console(suffix, prefix)
            log_error(f'An error occurred: {str(error)}')
         
    else:
        print("Error, cannot execute query.")
    return result