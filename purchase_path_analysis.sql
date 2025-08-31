-- purchase_path_analysis.sql
-- MySQL script for analyzing user purchase paths

-- Drop existing views if they already exist
DROP VIEW IF EXISTS user_behavior_view;
DROP VIEW IF EXISTS user_behavior_standard;
DROP VIEW IF EXISTS user_behavior_path;
DROP VIEW IF EXISTS path_count;

-- Step 1: Create a view summarizing user actions per item
CREATE VIEW user_behavior_view AS
SELECT user_id, item_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS pv,
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS fav,
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS cart,
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS buy
FROM temp_behavior
GROUP BY user_id, item_id;

-- Step 2: Standardize user actions into binary values
CREATE VIEW user_behavior_standard AS
SELECT user_id,
       item_id,
       (CASE WHEN pv>0 THEN 1 ELSE 0 END) AS viewed,
       (CASE WHEN fav>0 THEN 1 ELSE 0 END) AS favorited,
       (CASE WHEN cart>0 THEN 1 ELSE 0 END) AS added_to_cart,
       (CASE WHEN buy>0 THEN 1 ELSE 0 END) AS purchased
FROM user_behavior_view;

-- Step 3: Create purchase path type (only for purchased items)
CREATE VIEW user_behavior_path AS
SELECT *,
       CONCAT(viewed, favorited, added_to_cart, purchased) AS path_type
FROM user_behavior_standard AS a
WHERE a.purchased > 0;

-- Step 4: Count purchases by path type
CREATE VIEW path_count AS
SELECT path_type,
       COUNT(*) AS num
FROM user_behavior_path
GROUP BY path_type
ORDER BY num DESC;

-- Step 5: Create mapping table for path descriptions
CREATE TABLE renhua (
  path_type CHAR(4),
  description VARCHAR(40)
);

-- Insert path descriptions (human-readable)
INSERT INTO renhua VALUES
('0001','Direct purchase'),
('1001','View then purchase'),
('0011','Add to cart then purchase'),
('1011','View, add to cart, then purchase'),
('0101','Favorite then purchase'),
('1101','View, favorite, then purchase'),
('0111','Favorite, add to cart, then purchase'),
('1111','View, favorite, add to cart, then purchase');

-- Preview mapping table
SELECT * FROM renhua;

-- Step 6: Join path counts with descriptions
SELECT * 
FROM path_count p
JOIN renhua r 
  ON p.path_type = r.path_type
ORDER BY num DESC;

-- Step 7: Create result table to store purchase path summary
CREATE TABLE path_result (
  path_type CHAR(4),
  description VARCHAR(40),
  num INT
);

-- Insert summarized results into path_result
INSERT INTO path_result
SELECT path_type, description, num
FROM path_count p
JOIN renhua r
  ON p.path_type = r.path_type
ORDER BY num DESC;

-- Preview results
SELECT * FROM path_result;

-- Step 8: Additional calculations
-- Count direct purchases without favorites or add-to-cart
SELECT SUM(buy)
FROM user_behavior_view
WHERE buy > 0 AND fav = 0 AND cart = 0; 
-- Example result: 1528016

-- Calculate difference (total purchases - direct purchases)
SELECT 2015807 - 1528016; 
-- Example result: 487791

-- Calculate ratio of assisted purchases to (favorites + add-to-cart)
SELECT 487791 / (2888255 + 5530446);
