CREATE TABLE IF NOT EXISTS dwreporting.agg_country_yearly_summary (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    year INT,
    total_population DECIMAL,
    average_malnourishment NUMERIC ,
    GDP_per_year NUMERIC ,
    perc_pop_without_water NUMERIC ,
    avg_temp NUMERIC ,
    total_affected_by_disasters INT,

    storm INT,
    flood INT,
    epidemic INT,
    volcanic_activity INT,
    earthquake INT,
    drought INT,
    mass_movement_dry INT,
    infestation INT,
    mass_movement_wet INT,
    extreme_temperature INT,
    animal_incident INT,
    wildfire INT,
    fog INT,
    glacial_lake_outburst_flood INT,
    impact INT,

    total_disasters INT
);

INSERT INTO dwreporting.agg_country_yearly_summary (
    name,
    year,
    total_population,
    average_malnourishment,
    GDP_per_year,
    perc_pop_without_water,
    avg_temp,
    total_affected_by_disasters,

    storm,
    flood,
    epidemic,
    volcanic_activity,
    earthquake,
    drought,
    mass_movement_dry,
    infestation,
    mass_movement_wet,
    extreme_temperature,
    animal_incident,
    wildfire,
    fog,
    glacial_lake_outburst_flood,
    impact,

    total_disasters
)

 SELECT
    dc.name,
    fcd.year,
    fcd.population as population,
    fcd.perc_malnourishment AS average_malnourishment,
    fcd.GDP_per_year as GDP_per_year,
    fcd.perc_pop_without_water AS perc_pop_without_water,
    fcd.avg_temp as avg_temp,
    SUM(fd.total_affected) AS total_affected_by_disasters,
    
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 1) AS storm,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 2) AS flood,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 3) AS epidemic,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 4) AS volcanic_activity,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 5) AS earthquake,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 6) AS drought,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 7) AS mass_movement_dry,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 8) AS infestation,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 9) AS mass_movement_wet,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 10) AS extreme_temperature,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 11) AS animal_incident,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 12) AS wildfire,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 13) AS fog,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 14) AS glacial_lake_outburst_flood,
    COUNT(fd.id) FILTER (WHERE fd.disaster_id = 15) AS impact,
    
    COUNT(fd.id) AS total_disasters
FROM
    dwreporting.fct_country_details fcd
JOIN
    dwreporting.dim_country dc ON fcd.country_id = dc.id
LEFT JOIN
    dwreporting.fct_disasters fd ON fd.country_id = dc.id AND fd.year = fcd.year
	
GROUP BY
    dc.name, fcd.year, fcd.population, fcd.perc_malnourishment, fcd.GDP_per_year, fcd.perc_pop_without_water, fcd.avg_temp

ORDER BY
    dc.name, year;
