INSERT INTO dwreporting.dim_disaster (disaster_name, disaster_subgroup)
SELECT
    disaster_name,
    disaster_subgroup
FROM dwreporting.stg_disaster_types_manual
ON CONFLICT(disaster_name, disaster_subgroup) DO UPDATE SET 
    disaster_name = excluded.disaster_name, 
    disaster_subgroup = excluded.disaster_subgroup;
