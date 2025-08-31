-- product_popularity_analysis.sql
-- MySQL script for analyzing popular categories, items, and popular items within categories

-- Step 1: Top 10 popular categories (by PV)
SELECT category_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS category_pv
FROM temp_behavior
GROUP BY category_id
ORDER BY category_pv DESC
LIMIT 10;

-- Step 2: Top 10 popular items (by PV)
SELECT item_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS item_pv
FROM temp_behavior
GROUP BY item_id
ORDER BY item_pv DESC
LIMIT 10;

-- Step 3: Top items within each category (using RANK)
SELECT category_id, item_id, category_item_pv
FROM (
  SELECT category_id, item_id,
         COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS category_item_pv,
         RANK() OVER (PARTITION BY category_id 
                      ORDER BY COUNT(IF(behavior_type='pv', behavior_type, NULL)) DESC) AS r
  FROM temp_behavior
  GROUP BY category_id, item_id
  ORDER BY category_item_pv DESC
) a
WHERE a.r = 1
ORDER BY a.category_item_pv DESC
LIMIT 10;

-- Step 4: Create permanent tables for storing results
CREATE TABLE popular_categories (
  category_id INT,
  pv INT
);

CREATE TABLE popular_items (
  item_id INT,
  pv INT
);

CREATE TABLE popular_cateitems (
  category_id INT,
  item_id INT,
  pv INT
);

-- Step 5: Insert Top 10 popular categories
INSERT INTO popular_categories
SELECT category_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS category_pv
FROM user_behavior
GROUP BY category_id
ORDER BY category_pv DESC
LIMIT 10;

-- Step 6: Insert Top 10 popular items
INSERT INTO popular_items
SELECT item_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS item_pv
FROM user_behavior
GROUP BY item_id
ORDER BY item_pv DESC
LIMIT 10;

-- Step 7: Insert most popular item per category
INSERT INTO popular_cateitems
SELECT category_id, item_id, category_item_pv
FROM (
  SELECT category_id, item_id,
         COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS category_item_pv,
         RANK() OVER (PARTITION BY category_id 
                      ORDER BY COUNT(IF(behavior_type='pv', behavior_type, NULL)) DESC) AS r
  FROM user_behavior
  GROUP BY category_id, item_id
  ORDER BY category_item_pv DESC
) a
WHERE a.r = 1
ORDER BY a.category_item_pv DESC
LIMIT 10;

-- Step 8: Preview results
SELECT * FROM popular_categories;
SELECT * FROM popular_items;
SELECT * FROM popular_cateitems;
