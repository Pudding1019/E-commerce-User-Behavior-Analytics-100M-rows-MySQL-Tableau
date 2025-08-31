-- conversion_rate_analysis.sql
-- MySQL script for analyzing item-level and category-level conversion rates

-- Step 1: Conversion rate for specific items (using sample/temp data)
SELECT item_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS pv,
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS fav,
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS cart,
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS buy,
       COUNT(DISTINCT IF(behavior_type='buy', user_id, NULL)) / COUNT(DISTINCT user_id) AS item_conversion_rate
FROM temp_behavior
GROUP BY item_id
ORDER BY item_conversion_rate DESC;

-- Step 2: Create permanent table for item conversion analysis
CREATE TABLE item_detail (
  item_id INT,
  pv INT,
  fav INT,
  cart INT,
  buy INT,
  user_buy_rate FLOAT
);

-- Step 3: Insert conversion results for all items
INSERT INTO item_detail
SELECT item_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS pv,
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS fav,
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS cart,
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS buy,
       COUNT(DISTINCT IF(behavior_type='buy', user_id, NULL)) / COUNT(DISTINCT user_id) AS item_conversion_rate
FROM user_behavior
GROUP BY item_id
ORDER BY item_conversion_rate DESC;

-- Preview item conversion rates
SELECT * FROM item_detail;

-- Step 4: Create permanent table for category-level conversion analysis
CREATE TABLE category_detail (
  category_id INT,
  pv INT,
  fav INT,
  cart INT,
  buy INT,
  user_buy_rate FLOAT
);

-- Step 5: Insert conversion results for all categories
INSERT INTO category_detail
SELECT category_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS pv,
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS fav,
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS cart,
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS buy,
       COUNT(DISTINCT IF(behavior_type='buy', user_id, NULL)) / COUNT(DISTINCT user_id) AS category_conversion_rate
FROM user_behavior
GROUP BY category_id
ORDER BY category_conversion_rate DESC;

-- Preview category conversion rates
SELECT * FROM category_detail;
