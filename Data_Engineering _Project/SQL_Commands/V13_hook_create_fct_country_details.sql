--not working . 

CREATE OR REPLACE FUNCTION get_fct_subregion_id(subregion_name VARCHAR)
RETURNS INT
AS $$
DECLARE
    subregion_id INT;
BEGIN
    SELECT id INTO subregion_id
    FROM dwreporting.fct_subregion
    WHERE name = subregion_name;

    RETURN subregion_id;
END;
$$ LANGUAGE plpgsql;


INSERT INTO dwreporting.fct_country_details (
    country_id,
    year,
    perc_malnourishment,
    population,
    GDP_per_year,
    perc_pop_without_water,
    avg_temp
)
SELECT DISTINCT
    dc.id AS country_id,
    spou.year,
    spou.prevalence_of_undernourishment_percentage_of_population AS perc_malnourishment,
    fp.population AS population,
    sg.value AS GDP_per_year,
    sswiw.wat_imp_without AS perc_pop_without_water,
    satk.avgtemperature AS avg_temp
FROM
    "dwreporting"."dim_country" dc
JOIN
    "dwreporting"."stg_prevalence_of_undernourishment_ourworldindata" spou ON dc.name = spou.entity
JOIN
    "dwreporting"."fct_population" fp ON dc.name = fp.country_name AND spou.year::varchar = fp.year
LEFT JOIN
    "dwreporting"."stg_gdp_undata" sg ON dc.name = sg.country_or_area AND spou.year = sg.year
LEFT JOIN
    "dwreporting"."stg_avg_temperature_kaggle" satk ON dc.name = satk.country AND spou.year = satk.year
LEFT JOIN
    "dwreporting"."stg_share_without_improved_water_kaggle" sswiw ON dc.name = sswiw.entity AND spou.year = sswiw.year
ON CONFLICT (country_id, year) DO NOTHING