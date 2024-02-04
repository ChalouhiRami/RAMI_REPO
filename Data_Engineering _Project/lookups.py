from enum import Enum

class FileType(Enum):
    CSV = 'csv'
    EXCEL = 'excel'
    SQL = 'postgreSQL'
    
class ErrorHandling(Enum):
    DB_CONNECTION_ERROR = "Failed to connect to database (database_handler.py)"

class FilterFields(Enum):
    RENTAL_RATE = 'rental_rate'

class HandledType(Enum):
    TIMESTAMP = "timestamp"
    STRING = "string"
    LIST = "list"

