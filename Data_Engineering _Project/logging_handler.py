import logging

# error handling same as logging handler , unify both
def configure_logger(log_file):
    logging.basicConfig(filename=log_file, level=logging.ERROR, format='%(asctime)s - %(levelname)s - %(message)s')
    
def log_error(error_message):
    logging.error(error_message)