from datetime import datetime
import logging

def configure_logger(log_file):
    logging.basicConfig(filename=log_file, level=logging.ERROR, format='%(asctime)s - %(levelname)s - %(message)s')
    
def log_error(error_message):
    logging.error(error_message)
 
def print_error_console(suffix,prefix):
    print(f"{datetime.now()} - {prefix} ##### {suffix}")