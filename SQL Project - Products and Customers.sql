-- Exploring the tables
SELECT *
  FROM customers
 LIMIT 10;

SELECT * 
  FROM offices
 LIMIT 5;

-- Exploring the number of attributes of each table (as integer) and 
-- the number of rows each table have

SELECT 'Customers' AS table_name, 
       13 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Customers
  
UNION ALL

SELECT 'Products' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Products

UNION ALL

SELECT 'ProductLines' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM ProductLines

UNION ALL

SELECT 'Orders' AS table_name, 
       7 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Orders

UNION ALL

SELECT 'OrderDetails' AS table_name, 
       5 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM OrderDetails

UNION ALL

SELECT 'Payments' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Payments

UNION ALL

SELECT 'Employees' AS table_name, 
       8 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Employees

UNION ALL

SELECT 'Offices' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Offices;
  
-- Explore the product performance and product in demand
-- to prevent the best-selling products from out of stock
-- Only choose top 10 products that have highest rates

-- Creating ctes to be used in the final query
WITH  
 order_status AS (
SELECT  od.productCode
	FROM orderdetails od
  JOIN orders o
    ON od.orderNumber = o.orderNumber
 WHERE o.status = "In Process"
 GROUP BY od.productCode
),
product_stock AS (
SELECT p.productCode , ROUND(SUM(od.quantityOrdered) / p.quantityInStock, 2) AS low_stock
  FROM  products p
  JOIN orderdetails od
    ON  p.productCode = od.productCode
 GROUP BY p.productCode
 ORDER by low_stock DESC
 LIMIT 10
 ),
 product_performance AS (	
SELECT p.productCode ,  SUM(od.quantityOrdered * p.quantityInStock ) AS product_performance
  FROM  products p
  JOIN orderdetails od
    ON  p.productCode = od.productCode
 GROUP BY p.productCode
 ORDER by product_performance DESC
 LIMIT 10 )

-- joining the CTEs to find the low stock products which are in
--the high performance categories  

SELECT p1.productCode, p1.low_stock , 
 	p2.product_performance
  FROM product_stock p1
  JOIN product_performance p2
 WHERE p1.productCode IN ( SELECT productCode 
		   	     FROM order_status)
 LIMIT 10;

-- To find how to create marketing communication strategies 
-- This involves customer behviors. First, we will find
-- the VIP customers (who bring the most profits) and the less-engaged customers

-- Creating two CTEs with high performing and low performing customer
--numbers
WITH 
profit_per_customer AS (
SELECT  o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM  products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  LEFT JOIN orders o
    ON od.orderNumber = o.orderNumber
 GROUP BY o.customerNumber)
	
-- Getting details of top 5 customers
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, pc.profit
  FROM profit_per_customer pc
  LEFT JOIN customers c
    ON pc.customerNumber = c.customerNumber
 ORDER BY profit DESC
 LIMIT 5		

-- Getting details of 5 least engaged customers
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, pc.profit
  FROM profit_per_customer pc
  LEFT JOIN customers c
    ON pc.customerNumber = c.customerNumber
 ORDER BY profit ASC
 LIMIT 5

-- Check how much new customers arriving each month to determine
-- should we spend money on acquire new customers or
-- increase brand loyalty
WITH 
payment_with_year_month_table AS (
SELECT *, 
       CAST(SUBSTR(paymentDate, 1,4) AS INTEGER)*100 + 
       CAST(SUBSTR(paymentDate, 6,7) AS INTEGER) AS year_month
  FROM payments p
),
customers_by_month AS (
SELECT year_month, COUNT(*) AS number_of_customer, 
       SUM(p1.amount) AS total_customer
  FROM payment_with_year_month_table p1
 GROUP BY p1. year_month
 ),
 new_customers_by_month AS (
SELECT p1.year_month, 
       COUNT(*) AS number_of_new_customers,
       SUM(p1.amount) AS new_customer_total,
       (SELECT number_of_customer
	  FROM customers_by_month c
	 WHERE c.year_month = p1.year_month) AS number_of_customer, 
       (SELECT total_customer
          FROM customers_by_month c
	 WHERE c.year_month = p1.year_month) AS total_customer
  FROM payment_with_year_month_table p1
 WHERE p1.customerNumber NOT IN (SELECT customerNumber
			     	   FROM payment_with_year_month_table p2
				  WHERE p2.year_month < p1.year_month)
 GROUP BY p1.year_month)
SELECT year_month, 
       ROUND(number_of_new_customers*100/number_of_customer,1) AS number_of_new_customers_props,
       ROUND(new_customer_total*100/total_customer,1) AS new_customers_total_props
  FROM new_customers_by_month; 

-- Determine how much money we should spend on marketing based on Customer Lifetime Value (LTV)

WITH
customer_profits AS (
SELECT o.customerNumber, sum(od.quantityOrdered*(od.priceEach - p.buyPrice)) AS profit
  FROM orders o
  JOIN orderdetails od 
    ON o.orderNumber = od.orderNumber
  JOIN products p 	
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber)
SELECT avg(profit) AS ltv
  FROM customer_profits

  
-- Q1) The products which were in urgent need of restocking would be those which have orders that are currently being 
-- processed in excess of the stock. So we took the products were the sum(quantityOrdered)/quantityInStock is highest.
-- In those we found the ones that overlap with the highest performing products. Hence, the results were:
-- S10_1949	1952 Alpine Renault 1300
-- S18_1749	1917 Grand Touring Sedan
-- S18_2238	1998 Chrysler Plymouth Prowler
-- These are the products which are currently the most in need of restocking.

-- Q2) The most engaged customers for the company are,
-- Freyre	Diego 	Madrid		326519.66
-- Nelson	Susan	San Rafael	CA	236769.39
-- Young	Jeff	NYC	NY	72370.09
-- Ferguson	Peter	Melbourne	Victoria	70311.07
-- Labrune	Janine 	Nantes		60875.3
-- Special discounts and offers for these people will incentivize them to purchase more 

-- The least engaged customers are,
-- Young	Mary	Glendale	CA	2610.87
-- Taylor	Leslie	Brickhaven	MA	6586.02
-- Ricotti	Franco	Milan		9532.93
-- Schmitt	Carine 	Nantes		10063.8
-- Smith	Thomas 	London		10868.04
-- Most of the least engaged customers seem to be from Europe. More advertisements and promotions in 
-- that area would be good. But we need to analyze customers more to determine whether the store should
-- focus on spend money on existing customers or acquiring new customers .

-- Q3) The number of new customers arriving each month
-- year_month	number_of_new_customers_props	new_customers_total_props
-- 200301	100.0	100.0
-- 200302	100.0	100.0
-- 200303	100.0	100.0
-- 200304	100.0	100.0
-- 200305	100.0	100.0
-- 200306	100.0	100.0
-- 200307	75.0	68.3
-- 200308	66.0	54.2
-- 200309	80.0	95.9
-- 200310	69.0	69.3
-- 200311	57.0	53.9
-- 200312	60.0	54.9
-- 200401	33.0	41.1
-- 200402	33.0	26.5
-- 200403	54.0	55.0
-- 200404	40.0	40.3
-- 200405	12.0	17.3
-- 200406	33.0	43.9
-- 200407	10.0	6.5
-- 200408	18.0	26.2
-- 200409	40.0	56.4
-- As we can, the number of new customers has been decreasing since 2003, and in the 2004, 
-- the store had the lowest values. The year 2005, which is present in the data as well did not show up.
-- This means that the store has not had new customers since September of 2004.
-- So, it makes sense that the store spends money on acquiring new customers.

-- Q4) How much we should spend on acquiring new customers
-- tv
-- 39039.594388
-- The Customer Lifetime Value (LTV) tells us how much profit an average customer generates during their
-- lifetime in the store. 
-- So, if we get ten new customers next month, we'll earn 390,395 dollars, and we can decide 
-- based on this prediction how much we can spend on acquiring new customers.
