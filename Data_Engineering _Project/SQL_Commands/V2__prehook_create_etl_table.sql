CREATE TABLE IF NOT EXISTS dwreporting.etl_watermark 
(
    ID SERIAL PRIMARY KEY NOT NULL,
    last_update_timestamp TIMESTAMP   ,
    table_name varchar(255) Unique 
   

);

 