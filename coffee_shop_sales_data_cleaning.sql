SELECT * FROM coffee_shop_sales;

/*DATA CLEANING*/

/*adjust the data type*/
-- change the date format from text to date
-- 1st step: change the date text to a data date format 
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date,'%d/%m/%Y');

-- 2nd step: change the data type
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

-- change the time format from text to date
-- 1st step: change the time text to a data time format 
UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time,'%T');

-- 2nd step: change the data type
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

/*adjust the column name*/
-- change the column name from ï»¿transaction_id to transaction_id
ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

DESCRIBE coffee_shop_sales;
