USE restaurant_db;

SELECT *
FROM menu_items;

-- Items Table exploration
-- View the menu_items table and write a query to find the number of items on the menu
SELECT 
	COUNT(*)
FROM menu_items;


-- What are the least and most expensive items on the menu?
SELECT
	MIN(price) AS least_expensive,
    MAX(price) AS most_expensive
    FROM menu_items;
    
    
-- How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT 
	category,
    COUNT(menu_item_id),
    MIN(price),
    MAX(price)
FROM menu_items
GROUP BY category
HAVING category = 'Italian';


-- How many dishes are in each category? What is the average dish price within each category?
SELECT 
	category,
    COUNT(menu_item_id),
    AVG(price)
FROM menu_items
GROUP BY category;


-- Explore orders table
-- View the order_details table. What is the date range of the table?

SELECT * 
FROM order_details;

SELECT 
	MIN(order_date),
    MAX(order_date)
FROM order_details;

-- How many orders were made within this date range? How many items were ordered within this date range?
SELECT 
	COUNT(order_details_id)
FROM order_details;

-- Which orders had the most number of items?
SELECT 
	order_id,
	COUNT(order_details_id) AS No_of_items
FROM order_details
GROUP BY order_id;

SELECT
	MAX(No_of_items)
FROM (
		SELECT 
	order_id,
	COUNT(order_details_id) AS No_of_items
   FROM order_details
   GROUP BY order_id
    ) AS subquery;
    
    
-- How many orders had more than 12 items?
SELECT 
	order_id,
	COUNT(order_details_id) AS No_of_items
FROM order_details
GROUP BY order_id
HAVING COUNT(order_details_id) > 12;

SELECT 
	COUNT(No_of_items)
    FROM
    ( SELECT 
	order_id,
	COUNT(order_details_id) AS No_of_items
	FROM order_details
	GROUP BY order_id
	HAVING COUNT(order_details_id) > 12) AS subquery;
    

-- Aalyze customer behavior

-- Combine the menu_items and order_details tables into a single table

SELECT * 
FROM menu_items
	FULL JOIN order_details
		ON menu_item_id=item_id;
       
        
-- What were the least and most ordered items? What categories were they in?


(SELECT 
	item_id,
    item_name,
    category,
    COUNT(order_details_id) AS Total_orders_by_category
FROM 
	(
    SELECT * 
	FROM menu_items
		FULL JOIN order_details
			ON menu_item_id=item_id
            ) AS combined_table
GROUP BY item_id
ORDER BY COUNT(order_details_id) DESC
LIMIT 1 )

UNION

(SELECT 
	item_id,
    item_name,
    category,
    COUNT(order_details_id) AS Total_orders_by_category
FROM 
	(
    SELECT * 
	FROM menu_items
		FULL JOIN order_details
			ON menu_item_id=item_id
            ) AS combined_table
GROUP BY item_id
ORDER BY COUNT(order_details_id) 
LIMIT 1 );


-- What were the top 5 orders that spent the most money?

SELECT 
	order_id,
    COUNT(order_details_id) AS total_items,
    SUM(price) AS Total_price_by_order
FROM 
	(
    SELECT * 
	FROM menu_items
		FULL JOIN order_details
			ON menu_item_id=item_id
            ) AS combined_table
GROUP BY order_id
ORDER BY SUM(price) DESC
LIMIT 5;

-- View the details of the highest spend order. Which specific items were purchased?
SELECT * 
FROM menu_items
	FULL JOIN order_details
		ON menu_item_id=item_id
WHERE order_id = 440;



-- View the details of top 5 highest spend orders
SELECT order_id, category, COUNT(order_details_id) AS no_items
FROM menu_items
	FULL JOIN order_details
		ON menu_item_id=item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY order_id, category;
