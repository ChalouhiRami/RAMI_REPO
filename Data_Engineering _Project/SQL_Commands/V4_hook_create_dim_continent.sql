 INSERT INTO dwreporting.dim_continent (name)
SELECT DISTINCT stg_continents_manual.continents FROM dwreporting.stg_continents_manual
ON CONFLICT(name) DO UPDATE
SET name = excluded.name;



