-- pv_uv_analysis.sql
-- MySQL script for calculating PV, UV, and PV/UV metrics

-- Create a temporary table with the same structure as user_behavior
CREATE TABLE temp_behavior LIKE user_behavior;

-- Insert a subset of data (first 100,000 rows) into the temporary table
INSERT INTO temp_behavior
SELECT * FROM user_behavior LIMIT 100000;

-- Preview the temp_behavior table
SELECT * FROM temp_behavior;

-- Calculate PV (page views) per day
SELECT dates,
       COUNT(*) AS pv
FROM temp_behavior
WHERE behavior_type = 'pv'
GROUP BY dates;

-- Calculate UV (unique visitors) per day
SELECT dates,
       COUNT(DISTINCT user_id) AS uv
FROM temp_behavior
WHERE behavior_type = 'pv'
GROUP BY dates;

-- Single query: calculate PV, UV, and PV/UV ratio per day
SELECT dates,
       COUNT(*) AS pv,
       COUNT(DISTINCT user_id) AS uv,
       ROUND(COUNT(*)/COUNT(DISTINCT user_id),1) AS `pv/uv`
FROM temp_behavior
WHERE behavior_type = 'pv'
GROUP BY dates;

-- Create a permanent table to store daily PV, UV, and PV/UV
CREATE TABLE pv_uv_puv (
  dates CHAR(10),
  pv INT(9),
  uv INT(9),
  puv DECIMAL(10,1)
);

-- Insert aggregated data from user_behavior into pv_uv_puv
INSERT INTO pv_uv_puv
SELECT dates,
       COUNT(*) AS pv,
       COUNT(DISTINCT user_id) AS uv,
       ROUND(COUNT(*)/COUNT(DISTINCT user_id),1) AS `pv/uv`
FROM user_behavior
WHERE behavior_type = 'pv'
GROUP BY dates;

-- Preview the result table
SELECT * FROM pv_uv_puv;

-- Delete rows with NULL dates (if any)
DELETE FROM pv_uv_puv WHERE dates IS NULL;
