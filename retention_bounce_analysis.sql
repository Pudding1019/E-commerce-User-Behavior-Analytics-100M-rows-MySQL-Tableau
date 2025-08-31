-- retention_bounce_analysis.sql
-- MySQL script for retention analysis and bounce rate calculation

-- Remove rows with NULL dates (if any)
SELECT * FROM user_behavior WHERE dates IS NULL;
DELETE FROM user_behavior WHERE dates IS NULL;

-- Check distinct user_id + dates combinations
SELECT user_id, dates
FROM temp_behavior
GROUP BY user_id, dates;

-- Self-join to compare user activity across dates
SELECT *
FROM (
  SELECT user_id, dates
  FROM temp_behavior
  GROUP BY user_id, dates
) a,
(
  SELECT user_id, dates
  FROM temp_behavior
  GROUP BY user_id, dates
) b
WHERE a.user_id = b.user_id;

-- Filter only cases where the second date is later than the first
SELECT *
FROM (
  SELECT user_id, dates
  FROM temp_behavior
  GROUP BY user_id, dates
) a,
(
  SELECT user_id, dates
  FROM temp_behavior
  GROUP BY user_id, dates
) b
WHERE a.user_id = b.user_id
  AND a.dates < b.dates;

-- Retention counts (Day 0, Day 1, Day 3)
SELECT a.dates,
       COUNT(IF(DATEDIFF(b.dates,a.dates)=0, b.user_id, NULL)) AS retention_0,
       COUNT(IF(DATEDIFF(b.dates,a.dates)=1, b.user_id, NULL)) AS retention_1,
       COUNT(IF(DATEDIFF(b.dates,a.dates)=3, b.user_id, NULL)) AS retention_3
FROM (
  SELECT user_id, dates
  FROM temp_behavior
  GROUP BY user_id, dates
) a,
(
  SELECT user_id, dates
  FROM temp_behavior
  GROUP BY user_id, dates
) b
WHERE a.user_id = b.user_id
  AND a.dates <= b.dates
GROUP BY a.dates;

-- Retention rate (Day 1 / Day 0)
SELECT a.dates,
       COUNT(IF(DATEDIFF(b.dates,a.dates)=1, b.user_id, NULL)) /
       COUNT(IF(DATEDIFF(b.dates,a.dates)=0, b.user_id, NULL)) AS retention_1
FROM (
  SELECT user_id, dates
  FROM temp_behavior
  GROUP BY user_id, dates
) a,
(
  SELECT user_id, dates
  FROM temp_behavior
  GROUP BY user_id, dates
) b
WHERE a.user_id = b.user_id
  AND a.dates <= b.dates
GROUP BY a.dates;

-- Save Day 1 retention rate into a permanent table
CREATE TABLE retention_rate (
  dates CHAR(10),
  retention_1 FLOAT
);

INSERT INTO retention_rate
SELECT a.dates,
       COUNT(IF(DATEDIFF(b.dates,a.dates)=1, b.user_id, NULL)) /
       COUNT(IF(DATEDIFF(b.dates,a.dates)=0, b.user_id, NULL)) AS retention_1
FROM (
  SELECT user_id, dates
  FROM user_behavior  -- corrected to use the main table
  GROUP BY user_id, dates
) a,
(
  SELECT user_id, dates
  FROM user_behavior
  GROUP BY user_id, dates
) b
WHERE a.user_id = b.user_id
  AND a.dates <= b.dates
GROUP BY a.dates;

-- Preview retention_rate table
SELECT * FROM retention_rate;

-- Bounce rate analysis
-- Bounce users (users with only 1 action)
SELECT COUNT(*)
FROM (
  SELECT user_id
  FROM user_behavior
  GROUP BY user_id
  HAVING COUNT(behavior_type) = 1
) a;

-- Total PV (from pv_uv_puv table)
SELECT SUM(pv) FROM pv_uv_puv; -- e.g. 89660670

-- Bounce rate = bounce_users / total PV
-- Example: 88 / 89660670
