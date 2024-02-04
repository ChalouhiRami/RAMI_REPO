 
 INSERT INTO dwreporting.dim_subregion (name)
SELECT DISTINCT subregion FROM dwreporting.stg_subregions_manual
ON CONFLICT(name) DO UPDATE
SET name = excluded.name
