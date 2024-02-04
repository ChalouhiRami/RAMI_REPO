CREATE TABLE IF NOT EXISTS dwreporting.agg_country_summary (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    total_population INT,
    average_malnourishment DECIMAl,
    average_perc_pop_without_water DECIMAL,
    total_affected_by_disasters DECIMAL,
    

	tree_cover NUMERIC,
    grassland NUMERIC,
    wetland NUMERIC,
    shrubland NUMERIC,
    sparse_vegetation NUMERIC,
    cropland NUMERIC,
    artificial_surfaces NUMERIC,
    bare_area NUMERIC,
    inland_water NUMERIC,
	
    storm  INT,
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



 
 INSERT INTO dwreporting.agg_country_summary (
    name,
    total_population,
    average_malnourishment,
    average_perc_pop_without_water,
    total_affected_by_disasters,
    tree_cover,
    grassland,
    wetland,
    shrubland,
    sparse_vegetation,
    cropland,
    artificial_surfaces,
    bare_area,
    inland_water,
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
    dc."name",
    round(AVG(dc.population)) AS total_population,
    round(AVG(fcd.perc_malnourishment), 2) AS average_malnourishment,
    round(AVG(fcd.perc_pop_without_water), 2) AS average_perc_pop_without_water,
    SUM(fd.total_affected) AS total_affected_by_disasters,
    dc.tree_cover as tree_cover,
    dc.grassland as grassland,
    dc.wetland as wetland,
    dc.shrubland as shrubland,
    dc.sparse_vegetation as sparse_vegetation,
    dc.cropland as cropland,
    dc.artificial_surfaces as artificial_surfaces,
    dc.bare_area as bare_area,
    dc.inland_water as inland_water,
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
    dwreporting.fct_disasters fd ON fd.subregion_id = dc.id
GROUP BY
    dc."name", dc.tree_cover, dc.grassland, dc.wetland, dc.shrubland, dc.sparse_vegetation, dc.cropland, dc.artificial_surfaces, dc.bare_area, dc.inland_water
ORDER BY
    dc."name";
