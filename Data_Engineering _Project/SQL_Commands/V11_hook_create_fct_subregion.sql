CREATE OR REPLACE FUNCTION get_fct_subregion_id(subregion_name VARCHAR)
RETURNS INT
AS $$
DECLARE
    subregion_id INT;
BEGIN
    SELECT id INTO subregion_id
    FROM dwreporting.dim_subregion
    WHERE "name" = subregion_name;

    RETURN subregion_id;
END;
$$ LANGUAGE plpgsql;








 INSERT INTO dwreporting.fct_subregion (
    subregion_id,
    year,
    perc_malnourishment,
    perc_pop_without_water
)
SELECT
    get_fct_subregion_id(dsr.name) AS subregion_id,
    pou.Year AS year,
    pou.Prevalence_of_undernourishment_percentage_of_population AS perc_malnourishment,
    siw.wat_imp_without
FROM
    stg_prevalence_of_undernourishment_ourworldindata pou
JOIN
    dim_subregion dsr ON pou.Entity = dsr.name
JOIN
    stg_share_without_improved_water_kaggle siw ON pou.Entity = siw.Entity
WHERE
    pou.Year BETWEEN 2001 AND 2019
    AND pou.Entity IN (
        'East Asia and South-Eastern Asia and Pacific',
        'South Asia',
        'Central Asia',
        'Arab World',
        'Sub-Saharan Africa',
        'North America',
        'Latin America and the Caribbean',
        'Europe',
        'Australia and New Zealand'
    )
ON CONFLICT (subregion_id, year) DO NOTHING;
		