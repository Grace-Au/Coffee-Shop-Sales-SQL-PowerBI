SELECT * FROM coffee_shop_sales;

/*Total Sales Analysis*/
-- find out the total sales of each month in targeted format: e.g 100k
SELECT ROUND(SUM(transaction_qty * unit_price)/1000) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 6;

-- find out the sales differences compare to last month and percentage change
SELECT 
	MONTH(transaction_date) AS transaction_month,
	ROUND(SUM(transaction_qty * unit_price)/1000) AS total_sales,
    ROUND(
		(SUM(transaction_qty * unit_price) 
		- LAG(SUM(transaction_qty * unit_price)) OVER (ORDER BY MONTH(transaction_date) ASC)) / 1000
	,1) AS changes,
    ROUND(
		(SUM(transaction_qty * unit_price) 
		- LAG(SUM(transaction_qty * unit_price)) OVER (ORDER BY MONTH(transaction_date) ASC))
		/ LAG(SUM(transaction_qty * unit_price)) OVER (ORDER BY MONTH(transaction_date) ASC) * 100
    ,1) AS percentage
FROM coffee_shop_sales
GROUP BY MONTH(transaction_date);


/*Total Order Analysis*/
-- find out the total order of the targeted month
SELECT 
	month(transaction_date) AS transaction_month
	, COUNT(transaction_id) AS total_order
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 6
GROUP BY MONTH(transaction_date);

-- find out the order differences compare to last month and percentage change
SELECT 
    MONTH(transaction_date) AS transaction_month
    , COUNT(transaction_id) AS total_order
    , COUNT(transaction_id) - LAG(COUNT(transaction_id)) OVER (ORDER BY MONTH(transaction_date) ASC) AS changes
    , ROUND(
		(COUNT(transaction_id) - LAG(COUNT(transaction_id)) OVER (ORDER BY MONTH(transaction_date) ASC))
		/LAG(COUNT(transaction_id)) OVER (ORDER BY MONTH(transaction_date) ASC) * 100
	  ,1 )AS percentage
FROM coffee_shop_sales
GROUP BY MONTH(transaction_date)

/*Total Quantity Sold Analysis*/
-- find out the total sales quantity of the targeted month
SELECT 
	MONTH(transaction_date) AS transaction_month
	, CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS total_sales_num
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY MONTH(transaction_date);

-- find out the order differences compare to last month and percentage change
WITH monthly_sales AS (
    SELECT 
        MONTH(transaction_date) AS transaction_month,
        SUM(transaction_qty) AS total_sales_num
    FROM coffee_shop_sales
    GROUP BY MONTH(transaction_date)
)
SELECT 
    transaction_month,
    total_sales_num,
    total_sales_num - LAG(total_sales_num) OVER (ORDER BY transaction_month) AS changes,
    ROUND(
        (total_sales_num - LAG(total_sales_num) OVER (ORDER BY transaction_month))
        / NULLIF(LAG(total_sales_num) OVER (ORDER BY transaction_month), 0) * 100
        ,1) AS percentage
FROM monthly_sales
ORDER BY transaction_month;

-- Calendar heat map 
SELECT 
	CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS total_sales
    , CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS total_qty_sold
    , CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS total_order
FROM coffee_shop_sales
WHERE transaction_date = '2023-05-18';

-- Sales analysis by weekdays and weekends 
SELECT 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type
    , CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY day_type;

-- Sales analysis by store location
SELECT
	store_location
    , CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,2),'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 6
GROUP BY store_location
ORDER BY SUM(unit_price*transaction_qty) DESC;

/*Daily sales analysis with average line*/
-- Average daily sales quantity
SELECT
	AVG(unit_price*transaction_qty) AS avg_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;

-- daily sales
SELECT 
	transaction_date
	, ROUND(SUM(transaction_qty*unit_price)) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY transaction_date;

-- Average monthly sales
SELECT CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS avg_sales
FROM
(SELECT 
	transaction_date
	, SUM(transaction_qty*unit_price) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY transaction_date) AS daily_sales;
 
-- check if the daily sales pass the average daily sales
SELECT 
	transaction_date
    , CASE 
		WHEN total_sales > avg_sales 
			THEN 'Above Average'
		WHEN total_sales < avg_sales 
			THEN 'Below Average'
		ELSE 'Average' END AS sales_status
	, total_sales
FROM 
	(SELECT 
		transaction_date
		, ROUND(SUM(transaction_qty*unit_price),2) AS total_sales
        , AVG(SUM(transaction_qty*unit_price)) OVER () AS avg_sales
	FROM coffee_shop_sales
	WHERE MONTH(transaction_date) = 5
	GROUP BY transactions_date) AS daily_sales

-- Sales analysis by product category
SELECT
	product_category
    , SUM(unit_price*transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category

-- Top 10 product by Sales
SELECT
	product_type
    , SUM(unit_price*transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = 'coffee'
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10;

-- Sales analysis by days and hours
-- days
SELECT 
	DATE_FORMAT(transaction_date,'%a') AS day_of_week
	, ROUND(SUM(unit_price*transaction_qty)) AS total_sales
    , SUM(transaction_qty) AS total_quantity
    , COUNT(transaction_id) AS total_order
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY day_of_week;

-- hour
SELECT 
	SUM(unit_price*transaction_qty) AS total_sales
    , SUM(transaction_qty) AS total_quantity
    , COUNT(transaction_id) AS total_order
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
AND DAYOFWEEK(transaction_date) = 2
AND HOUR(transaction_time) = 8;

SELECT 
	HOUR(transaction_time) AS hour_num
    , SUM(unit_price*transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY hour_num
ORDER BY hour_num;

