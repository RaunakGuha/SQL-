CREATE DATABASE zomato;

USE zomato;

SHOW TABLES FROM zomato;


/* 1: Find Customers who never ordered */
/* check user and order table. find user id which are not there in order table. */

SELECT * FROM users
WHERE user_id NOT IN 
( SELECT user_id FROM orders);

/* 2: Average Price/dish ? */
/* Check food and menu table. connect with f_id col */
SELECT food.f_name, AVG(menu.price) AS avg_price
FROM food
INNER JOIN menu ON food.f_id = menu.f_id
GROUP BY food.f_name;


/*Find the top restaurant in terms of the number of orders for a given month */
SELECT r.r_name, COUNT(*) AS 'May' 
FROM orders o 
INNER JOIN restaurants r
ON o.r_id=r.r_id         
WHERE MONTH(date) = 5
GROUP BY r.r_name
ORDER BY COUNT(*) DESC;

SELECT r.r_name, COUNT(*) AS 'June' 
FROM orders o 
INNER JOIN restaurants r
ON o.r_id=r.r_id         
WHERE MONTH(date) = 6
GROUP BY r.r_name
ORDER BY COUNT(*) DESC;

SELECT r.r_name, COUNT(*) AS 'July' 
FROM orders o 
INNER JOIN restaurants r
ON o.r_id=r.r_id         
WHERE MONTH(date) = 7
GROUP BY r.r_name
ORDER BY COUNT(*) DESC;

/* restaurants with monthly sales greater than x for a given month */
SELECT r.r_name, SUM(amount) AS 'May_reve' 
FROM orders o 
INNER JOIN restaurants r
ON o.r_id=r.r_id         
WHERE MONTH(date) = 5
GROUP BY r.r_name
HAVING May_reve>=700
ORDER BY May_reve DESC;

SELECT r.r_name, SUM(amount) AS 'June_reve' 
FROM orders o 
INNER JOIN restaurants r
ON o.r_id=r.r_id         
WHERE MONTH(date) = 6
GROUP BY r.r_name
HAVING June_reve > 500
ORDER BY June_reve DESC;

SELECT r.r_name, SUM(amount) AS 'July_reve' 
FROM orders o 
INNER JOIN restaurants r
ON o.r_id=r.r_id         
WHERE MONTH(date) = 7
GROUP BY r.r_name
HAVING July_reve>=1000
ORDER BY July_reve DESC;

/* Show all orders with order details for a particular customer in a particular date range */
/* for ex I want to see entire order history for a user named nitish */

SELECT o.order_id,f.f_name,f.type,r.r_name,o.date,o.amount
FROM orders o
JOIN restaurants r
ON r.r_id = o.r_id
JOIN order_details od
ON od.order_id = o.order_id
JOIN food f
ON f.f_id = od.f_id
WHERE user_id= 
(SELECT user_id FROM users WHERE name LIKE "Nitish" )
HAVING date>= '2022-05-10' AND date<= '2022-06-10'
ORDER BY date;

/* Find restaurants with max repeated customers */
/* Check tables:= restaurants,users and orders */

SELECT r.r_name,COUNT(*) AS "Most_Visited"
FROM(
     SELECT r_id,user_id,COUNT(*)
     FROM orders
     GROUP BY r_id,user_id
	 HAVING COUNT(*)>1
) t 
JOIN restaurants r
ON r.r_id = t.r_id
GROUP BY t.r_id
ORDER BY Most_Visited DESC;

/* Month over month revenue growth of zomato */
/* We will check total revenue or amount collected each month and check percent of inc or dec monthwise */
SELECT MONTHNAME(date) AS 'month',SUM(amount)
FROM orders
GROUP BY month;

/* Every Customer - favorite food */
/* First Create a freq table which creates the no of freqs of each user id wrt food id*/ 
WITH freq 
AS
(SELECT o.user_id,od.f_id,COUNT(*) AS Freq
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
GROUP BY o.user_id,od.f_id
)
SELECT u.name,f.f_name 
FROM freq fr
JOIN users u
ON u.user_id = fr.user_id
JOIN food f
ON f.f_id = fr.f_id
WHERE fr.Freq = (
      SELECT MAX(Freq)
      FROM freq f2
      WHERE f2.user_id = fr.user_id);
      
/* Find the most loyal customers for all restaurant */
WITH table_name AS (
  SELECT user_id, r_id, COUNT(*) AS ct
  FROM orders
  GROUP BY user_id, r_id
  HAVING COUNT(*) > 1
)
SELECT r.r_name, users.name
FROM table_name t
JOIN restaurants r ON r.r_id = t.r_id
JOIN users ON users.user_id = t.user_id
WHERE t.ct = (
  SELECT MAX(ct)
  FROM table_name t1
  WHERE t1.r_id = t.r_id
);


