-- date_hour_behavior.sql
-- MySQL script for analyzing user behavior by date and hour

-- Step 1: Analyze behavior counts grouped by date and hour (using temp_behavior sample)
SELECT dates, hours,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS pv,
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS cart,
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS fav,
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS buy
FROM temp_behavior
GROUP BY dates, hours
ORDER BY dates, hours;

-- Step 2: Create a permanent table to store date-hour level behavior statistics
CREATE TABLE date_hour_behavior (
  dates CHAR(10),
  hours CHAR(2),
  pv INT,
  cart INT,
  fav INT,
  buy INT
);

-- Step 3: Insert aggregated results from the full user_behavior table
INSERT INTO date_hour_behavior
SELECT dates, hours,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS pv,
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS cart,
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS fav,
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS buy
FROM user_behavior
GROUP BY dates, hours
ORDER BY dates, hours;

-- Step 4: Preview the results
SELECT * FROM date_hour_behavior;
