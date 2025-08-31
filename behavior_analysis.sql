-- behavior_analysis.sql
-- MySQL script for analyzing user counts and behavior counts by type

-- Step 1: Count distinct users per behavior type (using temp_behavior sample)
SELECT behavior_type,
       COUNT(DISTINCT user_id) AS user_num
FROM temp_behavior
GROUP BY behavior_type
ORDER BY behavior_type DESC;

-- Step 2: Create a permanent table to store distinct user counts by behavior type
CREATE TABLE behavior_user_num (
  behavior_type VARCHAR(5),
  user_num INT
);

-- Insert results from the full user_behavior table
INSERT INTO behavior_user_num
SELECT behavior_type,
       COUNT(DISTINCT user_id) AS user_num
FROM user_behavior
GROUP BY behavior_type
ORDER BY behavior_type DESC;

-- Preview results
SELECT * FROM behavior_user_num;

-- Example: proportion of users who purchased during this period
SELECT 672404/984105;

-- Step 3: Count total actions per behavior type (using temp_behavior sample)
SELECT behavior_type,
       COUNT(*) AS behavior_num
FROM temp_behavior
GROUP BY behavior_type
ORDER BY behavior_type DESC;

-- Step 4: Create a permanent table to store behavior counts
CREATE TABLE behavior_num (
  behavior_type VARCHAR(5),
  behavior_count_num INT
);

-- Insert results from the full user_behavior table
INSERT INTO behavior_num
SELECT behavior_type,
       COUNT(*) AS behavior_count_num
FROM user_behavior
GROUP BY behavior_type
ORDER BY behavior_type DESC;

-- Preview results
SELECT * FROM behavior_num;

-- Example: purchase rate
SELECT 2015807/89660670;

-- Example: favorite + add-to-cart rate
SELECT (2888255+5530446)/89660670;
