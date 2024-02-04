INSERT INTO "dwreporting"."fct_disaster_magnitude" ("disaster_id", "magnitude_scale_id")
SELECT DISTINCT
    disaster_id,
    magnitude_scale_id
FROM
"dwreporting"."stg_disaster_magnitude_manual"