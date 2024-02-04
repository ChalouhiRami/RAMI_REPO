CREATE OR REPLACE FUNCTION get_continent_id(continent_name VARCHAR)
RETURNS INT
AS $$
DECLARE
    continent_id INT;
BEGIN
    SELECT id INTO continent_id
    FROM dwreporting.dim_continent
    WHERE name = continent_name;

    RETURN continent_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_subregion_id(subregion_name VARCHAR)
RETURNS INT
AS $$
DECLARE
    subregion_id INT;
BEGIN
    SELECT id INTO subregion_id
    FROM dwreporting.dim_subregion
    WHERE name = subregion_name;

    RETURN subregion_id;
END;
$$ LANGUAGE plpgsql;
 

INSERT INTO dwreporting.dim_country (
    name,
    continent_id,
    subregion_id,
    population,
    code,
    capital,
    tree_cover,
    grassland,
    wetland,
    shrubland,
    sparse_vegetation,
    cropland,
    artificial_surfaces,
    bare_area,
    inland_water
)
SELECT 
   stg_countries.Country_Territory,
    continent_id.id AS continent_id,
    subregion_id.id AS subregion_id,
    stg_countries.Population,
    stg_countries.Code,
    stg_countries.Capital,
    stg_valuable_data.Tree_cover,  
    stg_valuable_data.Grassland,
    stg_valuable_data.Wetland,
    stg_valuable_data.Shrubland,
    stg_valuable_data.Sparse_vegetation,
    stg_valuable_data.Cropland,
    stg_valuable_data.Artificial_surfaces,
    stg_valuable_data.Bare_area,
    stg_valuable_data.Inlandwater
FROM 
       dwreporting.stg_countries_kaggle stg_countries
 
    LEFT JOIN dwreporting.dim_continent continent_id ON stg_countries.Continent = continent_id.name
    LEFT JOIN dwreporting.dim_subregion subregion_id ON stg_countries.New_Subregion = subregion_id.name
    LEFT JOIN dwreporting.stg_valuable_country_data_oecd stg_valuable_data ON TRIM(LOWER(stg_countries.Country_Territory)) = TRIM(LOWER(stg_valuable_data.Country))

 ON CONFLICT(name) DO UPDATE
SET 
    continent_id = excluded.continent_id,
    subregion_id = excluded.subregion_id,
    population = excluded.population,
    code = excluded.code,
    capital = excluded.capital,
    tree_cover = excluded.tree_cover,
    grassland = excluded.grassland,
    wetland = excluded.wetland,
    shrubland = excluded.shrubland,
    sparse_vegetation = excluded.sparse_vegetation,
    cropland = excluded.cropland,
    artificial_surfaces = excluded.artificial_surfaces,
    bare_area = excluded.bare_area,
    inland_water = excluded.inland_water;
