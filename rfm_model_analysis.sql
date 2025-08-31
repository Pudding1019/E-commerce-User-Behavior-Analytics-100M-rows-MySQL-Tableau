-- rfm_model_analysis.sql
-- MySQL script for building an RFM model

-- Step 1: Most recent purchase date per user (sample)
SELECT user_id,
       MAX(dates) AS recent_purchase_date
FROM temp_behavior
WHERE behavior_type = 'buy'
GROUP BY user_id
ORDER BY 2 DESC;

-- Step 2: Purchase frequency per user (sample)
SELECT user_id,
       COUNT(user_id) AS purchase_count
FROM temp_behavior
WHERE behavior_type = 'buy'
GROUP BY user_id
ORDER BY 2 DESC;

-- Step 3: Unified purchase frequency and recent purchase date (full dataset)
SELECT user_id,
       COUNT(user_id) AS purchase_count,
       MAX(dates) AS recent_purchase_date
FROM user_behavior
WHERE behavior_type = 'buy'
GROUP BY user_id
ORDER BY 2 DESC, 3 DESC;

-- Step 4: Store results in an RFM model table
DROP TABLE IF EXISTS rfm_model;
CREATE TABLE rfm_model (
  user_id INT,
  frequency INT,
  recent CHAR(10)
);

INSERT INTO rfm_model
SELECT user_id,
       COUNT(user_id) AS purchase_count,
       MAX(dates) AS recent_purchase_date
FROM user_behavior
WHERE behavior_type = 'buy'
GROUP BY user_id
ORDER BY 2 DESC, 3 DESC;

-- Step 5: Add frequency score (F-score) based on purchase count
ALTER TABLE rfm_model ADD COLUMN fscore INT;

UPDATE rfm_model
SET fscore = CASE
  WHEN frequency BETWEEN 100 AND 262 THEN 5
  WHEN frequency BETWEEN 50 AND 99 THEN 4
  WHEN frequency BETWEEN 20 AND 49 THEN 3
  WHEN frequency BETWEEN 5 AND 20 THEN 2
  ELSE 1
END;

-- Step 6: Add recency score (R-score) based on most recent purchase date
ALTER TABLE rfm_model ADD COLUMN rscore INT;

UPDATE rfm_model
SET rscore = CASE
  WHEN recent = '2017-12-03' THEN 5
  WHEN recent IN ('2017-12-01','2017-12-02') THEN 4
  WHEN recent IN ('2017-11-29','2017-11-30') THEN 3
  WHEN recent IN ('2017-11-27','2017-11-28') THEN 2
  ELSE 1
END;

-- Preview results
SELECT * FROM rfm_model;

-- Step 7: Classify users based on average F-score and R-score
SET @f_avg = NULL;
SET @r_avg = NULL;
SELECT AVG(fscore) INTO @f_avg FROM rfm_model;
SELECT AVG(rscore) INTO @r_avg FROM rfm_model;

SELECT *,
       (CASE
          WHEN fscore > @f_avg AND rscore > @r_avg THEN 'Valuable users'
          WHEN fscore > @f_avg AND rscore < @r_avg THEN 'Loyal users'
          WHEN fscore < @f_avg AND rscore > @r_avg THEN 'New/Developing users'
          WHEN fscore < @f_avg AND rscore < @r_avg THEN 'At-risk users'
        END) AS class
FROM rfm_model;

-- Step 8: Save classification back to table
ALTER TABLE rfm_model ADD COLUMN class VARCHAR(40);

UPDATE rfm_model
SET class = CASE
  WHEN fscore > @f_avg AND rscore > @r_avg THEN 'Valuable users'
  WHEN fscore > @f_avg AND rscore < @r_avg THEN 'Loyal users'
  WHEN fscore < @f_avg AND rscore > @r_avg THEN 'New/Developing users'
  WHEN fscore < @f_avg AND rscore < @r_avg THEN 'At-risk users'
END;

-- Step 9: Count users in each class
SELECT class, COUNT(user_id) 
FROM rfm_model
GROUP BY class;
