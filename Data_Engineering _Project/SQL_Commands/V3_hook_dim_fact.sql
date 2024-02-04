

CREATE TABLE IF NOT EXISTS dwreporting.dim_continent (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS dwreporting.dim_subregion (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS dwreporting.dim_country (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE,
    continent_id INT REFERENCES dwreporting.dim_continent(id),
    subregion_id INT REFERENCES dwreporting.dim_subregion(id),
    population INT,
    code VARCHAR(255),
    capital VARCHAR(255),
    tree_cover DECIMAL(5, 2),
    grassland DECIMAL(5, 2),
    wetland DECIMAL(5, 2),
    shrubland DECIMAL(5, 2),
    sparse_vegetation DECIMAL(5, 2),
    cropland DECIMAL(5, 2),
    artificial_surfaces DECIMAL(5, 2),
    bare_area DECIMAL(5, 2),
    inland_water DECIMAL(5, 2)
);

CREATE TABLE IF NOT EXISTS dwreporting.dim_city (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) ,
    population INT,
    country_id INT REFERENCES dwreporting.dim_country(id)
);
ALTER TABLE dwreporting.dim_city
ADD CONSTRAINT unique_dim_city_name UNIQUE (name);
CREATE TABLE IF NOT EXISTS dwreporting.dim_disaster (
    id SERIAL   PRIMARY KEY,
    disaster_name VARCHAR(255) ,
    disaster_subgroup VARCHAR(255)  
);
ALTER TABLE dwreporting.dim_disaster
ADD CONSTRAINT unique_disaster_name_subgroup UNIQUE (disaster_name, disaster_subgroup);
CREATE TABLE IF NOT EXISTS dwreporting.dim_magnitude_scale (
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) UNIQUE
);


CREATE TABLE IF NOT EXISTS dwreporting.fct_disaster_magnitude (
    id SERIAL PRIMARY KEY,
    disaster_id INT REFERENCES dwreporting.dim_disaster(id)  ,
    magnitude_scale_id INT REFERENCES dwreporting.dim_magnitude_scale(id) 
);

ALTER TABLE dwreporting.fct_disaster_magnitude
ADD CONSTRAINT unique_disaster_magnitude
UNIQUE (disaster_id, magnitude_scale_id);



  CREATE TABLE IF NOT EXISTS dwreporting.fct_subregion (
    id serial  PRIMARY KEY,
    subregion_id INT REFERENCES dwreporting.dim_subregion(id) ,
    year INT ,
    perc_malnourishment NUMERIC(10,4),
    perc_pop_without_water NUMERIC(10,4)
     
);

 
ALTER TABLE dwreporting.fct_subregion
ADD CONSTRAINT unique_subregion_year
UNIQUE (subregion_id, year);

CREATE OR REPLACE FUNCTION get_fct_subregion_id(subregion_name VARCHAR)
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
CREATE table if not EXISTS dwreporting.fct_population(


  country_name VARCHAR,
  year INT,
  population INT

);
--
CREATE TABLE IF NOT EXISTS dwreporting.fct_country_details (
    id SERIAL PRIMARY KEY,
    country_id INT REFERENCES dwreporting.dim_country(id)  ,
     year INT  ,
    perc_malnourishment NUMERIC,
    population DECIMAL,     
    GDP_per_year NUMERIC,
    perc_pop_without_water NUMERIC,
    avg_temp NUMERIC

);
		ALTER TABLE dwreporting.fct_country_details
ADD CONSTRAINT unique_country_year UNIQUE (country_id, year);
		
--
CREATE TABLE IF NOT EXISTS dwreporting.fct_disasters (
    id SERIAL PRIMARY KEY,
    disaster_id INT REFERENCES dwreporting.dim_disaster(id), --disaster 
    country_id INT REFERENCES dwreporting.dim_country(id),
    city_id INT REFERENCES dwreporting.dim_city(id),--probably mush lah tezbat
    subregion_id INT REFERENCES dwreporting.dim_subregion(id),
    month INT,
    year INT,
    OFDA BOOLEAN,
    magnitude_value VARCHAR(255),
    magnitude_scale_id INT REFERENCES dwreporting.dim_magnitude_scale(id),
    total_affected INT
);
 INSERT INTO dwreporting.dim_continent (name)
SELECT DISTINCT stg_continents_manual.continents FROM dwreporting.stg_continents_manual
ON CONFLICT(name) DO UPDATE
SET name = excluded.name;

 
 INSERT INTO dwreporting.dim_subregion (name)
SELECT DISTINCT subregion FROM dwreporting.stg_subregions_manual
ON CONFLICT(name) DO UPDATE
SET name = excluded.name;

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
-- Define the get_country_id function
CREATE OR REPLACE FUNCTION get_country_id(country_name VARCHAR)
RETURNS INT
AS $$
DECLARE
    country_id INT;
BEGIN
    SELECT id INTO country_id
    FROM dwreporting.dim_country
    WHERE name = country_name;

    RETURN country_id;
END;
$$ LANGUAGE plpgsql;
INSERT INTO dwreporting.dim_city (name, population, country_id)
SELECT
    DISTINCT ON (s.city) s.city AS name,
    s.population,
    c.id AS country_id
FROM
    dwreporting.stg_worldcities_simplemaps s
LEFT JOIN
    dwreporting.dim_country c ON s.country = c.name
ORDER BY
    s.city, s.population  
ON CONFLICT(name) DO UPDATE
SET
    population = EXCLUDED.population,
    country_id = EXCLUDED.country_id;

INSERT INTO dwreporting.dim_disaster (disaster_name, disaster_subgroup)
SELECT
    disaster_name,
    disaster_subgroup
FROM dwreporting.stg_disaster_types_manual
ON CONFLICT(disaster_name, disaster_subgroup) DO UPDATE SET 
    disaster_name = excluded.disaster_name, 
    disaster_subgroup = excluded.disaster_subgroup;
INSERT INTO dwreporting.dim_magnitude_scale (type)
SELECT DISTINCT type
FROM dwreporting.stg_magnitude_scale_manual
ON CONFLICT (type) 
DO UPDATE SET type = EXCLUDED.type;
INSERT INTO "dwreporting"."fct_disaster_magnitude" ("disaster_id", "magnitude_scale_id")
SELECT DISTINCT
    disaster_id,
    magnitude_scale_id
FROM
"dwreporting"."stg_disaster_magnitude_manual";

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
    dwreporting.stg_prevalence_of_undernourishment_ourworldindata pou
JOIN
    dwreporting.dim_subregion dsr ON pou.Entity = dsr.name
JOIN
    dwreporting.stg_share_without_improved_water_kaggle siw ON pou.Entity = siw.Entity
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
INSERT INTO "dwreporting"."fct_population" ("country_name", "year", "population")
SELECT
  "country_name",
  gs.year::varchar,
  COALESCE("year_1960", 0) + COALESCE("year_1961", 0) + COALESCE("year_1962", 0) + COALESCE("year_1963", 0) +
  COALESCE("year_1964", 0) + COALESCE("year_1965", 0) + COALESCE("year_1966", 0) + COALESCE("year_1967", 0) +
  COALESCE("year_1968", 0) + COALESCE("year_1969", 0) + COALESCE("year_1970", 0) + COALESCE("year_1971", 0) +
  COALESCE("year_1972", 0) + COALESCE("year_1973", 0) + COALESCE("year_1974", 0) + COALESCE("year_1975", 0) +
  COALESCE("year_1976", 0) + COALESCE("year_1977", 0) + COALESCE("year_1978", 0) + COALESCE("year_1979", 0) +
  COALESCE("year_1980", 0) + COALESCE("year_1981", 0) + COALESCE("year_1982", 0) + COALESCE("year_1983", 0) +
  COALESCE("year_1984", 0) + COALESCE("year_1985", 0) + COALESCE("year_1986", 0) + COALESCE("year_1987", 0) +
  COALESCE("year_1988", 0) + COALESCE("year_1989", 0) + COALESCE("year_1990", 0) + COALESCE("year_1991", 0) +
  COALESCE("year_1992", 0) + COALESCE("year_1993", 0) + COALESCE("year_1994", 0) + COALESCE("year_1995", 0) +
  COALESCE("year_1996", 0) + COALESCE("year_1997", 0) + COALESCE("year_1998", 0) + COALESCE("year_1999", 0) +
  COALESCE("year_2000", 0) + COALESCE("year_2001", 0) + COALESCE("year_2002", 0) + COALESCE("year_2003", 0) +
  COALESCE("year_2004", 0) + COALESCE("year_2005", 0) + COALESCE("year_2006", 0) + COALESCE("year_2007", 0) +
  COALESCE("year_2008", 0) + COALESCE("year_2009", 0) + COALESCE("year_2010", 0) + COALESCE("year_2011", 0) +
  COALESCE("year_2012", 0) + COALESCE("year_2013", 0) + COALESCE("year_2014", 0) + COALESCE("year_2015", 0) +
  COALESCE("year_2016", 0) + COALESCE("year_2017", 0) + COALESCE("year_2018", 0) + COALESCE("year_2019", 0) +
  COALESCE("year_2020", 0) + COALESCE("year_2021", 0) + COALESCE("year_2022", 0) AS "population"
FROM
  "dwreporting"."stg_world_population_kaggle" spk
JOIN
  generate_series(1960, 2022) gs(year) ON true;







-- DO $$
-- DECLARE
--   query_text text;
--   result_cursor REFCURSOR;
--   result_row RECORD;
-- BEGIN
--   FOR query_text IN
--     SELECT
--       'SELECT Country_Name, ''' || column_name || ''' AS year, ' || column_name || ' AS population FROM dwreporting.stg_world_population_kaggle'
--     FROM
--       information_schema.columns
--     WHERE
--       table_schema = 'dwreporting'
--       AND table_name = 'stg_world_population_kaggle'
--       AND column_name LIKE 'year_%'
--     ORDER BY
--       ordinal_position
--   LOOP
--     OPEN result_cursor FOR EXECUTE query_text;

--      LOOP
--       FETCH NEXT FROM result_cursor INTO result_row;
--       EXIT WHEN NOT FOUND;

--        INSERT INTO dwreporting.fct_population (country_name, year, population)
--       VALUES (result_row.Country_Name, substring(result_row.year from 6)::VARCHAR, result_row.population::BIGINT);
--     END LOOP;

--     CLOSE result_cursor;
--   END LOOP;
-- END $$;		
--not working . 




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
ON CONFLICT (country_id, year) DO NOTHING;
CREATE OR REPLACE FUNCTION get_city_id(city_name VARCHAR)
RETURNS INT
AS $$
DECLARE
    city_id INT;
BEGIN
    SELECT id INTO city_id
    FROM dwreporting.dim_city
    WHERE name = city_name;

    RETURN city_id;
END;
$$ LANGUAGE plpgsql;
  
INSERT INTO dwreporting.fct_disasters (
    disaster_id,
    country_id,
    city_id,
    subregion_id,
    month,
    year,
    OFDA,
    magnitude_scale_id,
    magnitude_value,
    total_affected
)
SELECT
    get_disaster_id(nd.Disaster_Type) AS disaster_id,
		get_country_id(nd.Country) AS country_id,
		get_city_id(nd.location),
    
    
    get_subregion_id(nd.Subregion) AS subregion_id,
    nd.Start_Month AS month,
    nd.Start_Year AS year,
		CASE WHEN nd.OFDA_Response = 'Yes' THEN TRUE ELSE FALSE END AS OFDA,
    get_magnitude_scale_id(nd.Magnitude_Scale) AS magnitude_scale_id,
    nd.Magnitude AS magnitude_value,
    nd.Total_Affected AS total_affected
FROM
    stg_natural_disasters_emdat nd;
		
		
		