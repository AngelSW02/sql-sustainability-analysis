-- Sustainability Impact Analysis
-- Portfolio version based on the Intel sustainability SQL project.
-- Demonstrates JOINs, CASE expressions, CTEs, aggregations,
-- GROUP BY analysis, and window functions.

-- ============================================================
-- 1. Join device and impact data
-- ============================================================

SELECT
    d.device_id,
    d.device_type,
    d.model_year,
    i.impact_id,
    i.usage_purpose,
    i.power_consumption,
    i.energy_savings_yr,
    i.co2_saved_kg_yr,
    i.recycling_rate,
    i.region
FROM intel.device_data AS d
JOIN intel.impact_data AS i
    ON d.device_id = i.device_id;


-- ============================================================
-- 2. Add device age and age buckets
-- ============================================================

SELECT
    d.device_id,
    d.device_type,
    d.model_year,
    i.impact_id,
    i.usage_purpose,
    i.power_consumption,
    i.energy_savings_yr,
    i.co2_saved_kg_yr,
    i.recycling_rate,
    i.region,
    2024 - d.model_year AS device_age,
    CASE
        WHEN 2024 - d.model_year <= 3 THEN 'newer'
        WHEN 2024 - d.model_year <= 6 THEN 'mid-age'
        ELSE 'older'
    END AS device_age_bucket
FROM intel.device_data AS d
JOIN intel.impact_data AS i
    ON d.device_id = i.device_id
ORDER BY d.model_year;


-- ============================================================
-- 3. Overall sustainability metrics
-- ============================================================

WITH joined_data AS (
    SELECT
        d.device_id,
        d.device_type,
        d.model_year,
        i.energy_savings_yr,
        i.co2_saved_kg_yr,
        i.region,
        2024 - d.model_year AS device_age,
        CASE
            WHEN 2024 - d.model_year <= 3 THEN 'newer'
            WHEN 2024 - d.model_year <= 6 THEN 'mid-age'
            ELSE 'older'
        END AS device_age_bucket
    FROM intel.device_data AS d
    JOIN intel.impact_data AS i
        ON d.device_id = i.device_id
)

SELECT
    COUNT(*) AS total_devices,
    AVG(device_age) AS average_device_age,
    AVG(energy_savings_yr) AS average_energy_savings_kwh,
    SUM(co2_saved_kg_yr) / 1000.0 AS total_co2_saved_tons
FROM joined_data;


-- ============================================================
-- 4. Sustainability impact by device type
-- ============================================================

WITH joined_data AS (
    SELECT
        d.device_id,
        d.device_type,
        d.model_year,
        i.energy_savings_yr,
        i.co2_saved_kg_yr,
        i.region,
        2024 - d.model_year AS device_age,
        CASE
            WHEN 2024 - d.model_year <= 3 THEN 'newer'
            WHEN 2024 - d.model_year <= 6 THEN 'mid-age'
            ELSE 'older'
        END AS device_age_bucket
    FROM intel.device_data AS d
    JOIN intel.impact_data AS i
        ON d.device_id = i.device_id
)

SELECT
    device_type,
    COUNT(*) AS total_devices,
    AVG(energy_savings_yr) AS average_energy_savings_kwh,
    AVG(co2_saved_kg_yr) / 1000.0 AS average_co2_saved_tons
FROM joined_data
GROUP BY device_type
ORDER BY total_devices DESC;


-- ============================================================
-- 5. Sustainability impact by device age bucket
-- ============================================================

WITH joined_data AS (
    SELECT
        d.device_id,
        d.device_type,
        d.model_year,
        i.energy_savings_yr,
        i.co2_saved_kg_yr,
        i.region,
        2024 - d.model_year AS device_age,
        CASE
            WHEN 2024 - d.model_year <= 3 THEN 'newer'
            WHEN 2024 - d.model_year <= 6 THEN 'mid-age'
            ELSE 'older'
        END AS device_age_bucket
    FROM intel.device_data AS d
    JOIN intel.impact_data AS i
        ON d.device_id = i.device_id
)

SELECT
    device_age_bucket,
    COUNT(*) AS total_devices,
    AVG(energy_savings_yr) AS average_energy_savings_kwh,
    AVG(co2_saved_kg_yr) / 1000.0 AS average_co2_saved_tons
FROM joined_data
GROUP BY device_age_bucket
ORDER BY
    CASE
        WHEN device_age_bucket = 'newer' THEN 1
        WHEN device_age_bucket = 'mid-age' THEN 2
        WHEN device_age_bucket = 'older' THEN 3
    END;


-- ============================================================
-- 6. Sustainability impact by region
-- ============================================================

WITH joined_data AS (
    SELECT
        d.device_id,
        d.device_type,
        d.model_year,
        i.energy_savings_yr,
        i.co2_saved_kg_yr,
        i.region,
        2024 - d.model_year AS device_age
    FROM intel.device_data AS d
    JOIN intel.impact_data AS i
        ON d.device_id = i.device_id
)

SELECT
    region,
    COUNT(*) AS total_devices,
    AVG(energy_savings_yr) AS average_energy_savings_kwh,
    AVG(co2_saved_kg_yr) / 1000.0 AS average_co2_saved_tons
FROM joined_data
GROUP BY region
ORDER BY total_devices DESC;


-- ============================================================
-- 7. Regional contribution by device type
-- ============================================================

WITH joined_data AS (
    SELECT
        d.device_id,
        d.device_type,
        i.energy_savings_yr,
        i.co2_saved_kg_yr,
        i.region
    FROM intel.device_data AS d
    JOIN intel.impact_data AS i
        ON d.device_id = i.device_id
),
region_device_totals AS (
    SELECT
        region,
        device_type,
        COUNT(*) AS total_devices,
        AVG(energy_savings_yr) AS average_energy_savings_kwh,
        AVG(co2_saved_kg_yr) / 1000.0 AS average_co2_saved_tons,
        SUM(energy_savings_yr) AS total_energy_savings_kwh,
        SUM(co2_saved_kg_yr) / 1000.0 AS total_co2_saved_tons
    FROM joined_data
    GROUP BY region, device_type
)

SELECT
    region,
    device_type,
    total_devices,
    average_energy_savings_kwh,
    average_co2_saved_tons,
    total_energy_savings_kwh,
    total_co2_saved_tons,
    total_energy_savings_kwh
        / SUM(total_energy_savings_kwh) OVER (PARTITION BY region)
        * 100.0 AS percent_region_energy_savings,
    total_co2_saved_tons
        / SUM(total_co2_saved_tons) OVER (PARTITION BY region)
        * 100.0 AS percent_region_co2_savings
FROM region_device_totals
ORDER BY region, device_type;
