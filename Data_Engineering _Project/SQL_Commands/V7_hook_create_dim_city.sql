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


