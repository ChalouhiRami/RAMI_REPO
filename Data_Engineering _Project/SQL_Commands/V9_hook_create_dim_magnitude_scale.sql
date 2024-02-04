INSERT INTO dwreporting.dim_magnitude_scale (type)
SELECT DISTINCT type
FROM dwreporting.stg_magnitude_scale_manual
ON CONFLICT (type) 
DO UPDATE SET type = EXCLUDED.type;