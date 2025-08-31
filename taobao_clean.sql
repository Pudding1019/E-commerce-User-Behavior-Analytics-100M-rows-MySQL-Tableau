-- taobao_project.sql
-- Full MySQL script for creating and cleaning the taobao.user_behavior table

-- Create database and switch to it
CREATE DATABASE taobao;
USE taobao;

-- Create raw user_behavior table
CREATE TABLE user_behavior (
  user_id INT(9),
  item_id INT(9),
  category_id INT(9),
  behavior_type VARCHAR(5),
  timestamp INT(14)
);

-- Inspect the table
DESC user_behavior;
SELECT * FROM user_behavior LIMIT 5;

-- Rename column
ALTER TABLE user_behavior CHANGE timestamp timestamps INT(14);
DESC user_behavior;

-- Check NULL values
SELECT * FROM user_behavior WHERE user_id IS NULL;
SELECT * FROM user_behavior WHERE item_id IS NULL;
SELECT * FROM user_behavior WHERE category_id IS NULL;
SELECT * FROM user_behavior WHERE behavior_type IS NULL;
SELECT * FROM user_behavior WHERE timestamps IS NULL;

-- Check duplicate values
SELECT user_id, item_id, timestamps
FROM user_behavior
GROUP BY user_id, item_id, timestamps
HAVING COUNT(*) > 1;

-- Remove duplicates
ALTER TABLE user_behavior ADD id INT FIRST;
SELECT * FROM user_behavior LIMIT 5;
ALTER TABLE user_behavior MODIFY id INT PRIMARY KEY AUTO_INCREMENT;

DELETE user_behavior
FROM user_behavior
JOIN (
  SELECT user_id, item_id, timestamps, MIN(id) id
  FROM user_behavior
  GROUP BY user_id, item_id, timestamps
  HAVING COUNT(*) > 1
) t2
  ON user_behavior.user_id = t2.user_id
 AND user_behavior.item_id = t2.item_id
 AND user_behavior.timestamps = t2.timestamps
WHERE user_behavior.id > t2.id;

-- Add new fields: date, time, hour
-- Change buffer size
SHOW VARIABLES LIKE '%_buffer%';
SET GLOBAL innodb_buffer_pool_size = 1070000000;

-- Add datetime column
ALTER TABLE user_behavior ADD datetimes TIMESTAMP(0);
UPDATE user_behavior SET datetimes = FROM_UNIXTIME(timestamps);
SELECT * FROM user_behavior LIMIT 5;

-- Add date, time, hour columns
ALTER TABLE user_behavior ADD dates CHAR(10);
ALTER TABLE user_behavior ADD times CHAR(8);
ALTER TABLE user_behavior ADD hours CHAR(2);

-- Update the new fields with substring
UPDATE user_behavior SET dates = SUBSTRING(datetimes,1,10);
UPDATE user_behavior SET times = SUBSTRING(datetimes,12,8);
UPDATE user_behavior SET hours = SUBSTRING(datetimes,12,2);
SELECT * FROM user_behavior LIMIT 5;

-- Remove outliers (outside analysis window)
SELECT MAX(datetimes), MIN(datetimes) FROM user_behavior;
DELETE FROM user_behavior
WHERE datetimes < '2017-11-25 00:00:00'
   OR datetimes > '2017-12-03 23:59:59';

-- Data overview
DESC user_behavior;
SELECT * FROM user_behavior LIMIT 5;
SELECT COUNT(1) FROM user_behavior; -- 100,095,496 records
