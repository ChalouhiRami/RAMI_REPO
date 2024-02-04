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