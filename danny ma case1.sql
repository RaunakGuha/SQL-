SET sql_mode = '';

CREATE DATABASE dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(10),
  price INT
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  SHOW Tables FROM dannys_diner;
  
  /* 1)What is the total amount each customer spent at the restaurant? */
  SELECT s.customer_id, SUM(m2.price) AS amt
  FROM sales s
  JOIN menu m2 ON m2.product_id = s.product_id
  GROUP BY s.customer_id
  ORDER BY s.customer_id;
  
  /* 2. How many days has each customer visited the restaurant? */
SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited 
from sales
GROUP BY customer_id;

/* 3)What was the first item from the menu purchased by each customer? */
WITH cte AS
(SELECT s.customer_id, s.order_date, m2.product_name, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rank_by_date
FROM sales s
JOIN menu m2
ON s.product_id = m2.product_id)
SELECT customer_id, product_name,order_date
FROM cte
WHERE rank_by_date = 1
GROUP BY customer_id,product_name,order_date;

/* 4) What is the most purchased item on the menu and 
how many times was it purchased by all customers? */
SELECT m2.product_name, COUNT(s.product_id) AS most_purchased_item
FROM sales s
JOIN menu m2
ON s.product_id = m2.product_id
GROUP BY m2.product_name
ORDER BY most_purchased_item DESC;

/* 5) Which item was the most popular for each customer? */
WITH cte AS (
  SELECT 
    sales.customer_id, menu.product_name, 
    COUNT(menu.product_id) AS order_count,
    DENSE_RANK() OVER(
      PARTITION BY sales.customer_id 
      ORDER BY COUNT(sales.customer_id) DESC) AS ranking
  FROM menu
  JOIN sales
    ON menu.product_id = sales.product_id
  GROUP BY sales.customer_id, menu.product_name
)
SELECT 
  customer_id, product_name, order_count
FROM cte
WHERE ranking = 1;

/* 6) Which item was purchased first by the customer after they became a member? */
WITH cte AS 
(SELECT s.customer_id, s.order_date, m1.join_date, m2.product_name,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as rnk
FROM sales s
JOIN members m1 ON
m1.customer_id = s.customer_id
JOIN menu m2 ON m2.product_id = s.product_id
WHERE s.order_date >= m1.join_date)
SELECT customer_id,product_name
FROM cte
WHERE rnk = 1;

/* 7) Which item was purchased just before the customer became a member? */

WITH cte AS
(SELECT s.customer_id, s.order_date, m1.join_date, m2.product_name,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) as rnk
FROM sales s
JOIN members m1 ON
m1.customer_id = s.customer_id
JOIN menu m2 ON m2.product_id = s.product_id
WHERE s.order_date < m1.join_date)
SELECT customer_id,product_name
FROM cte
WHERE rnk = 1;

/* 8)What is the total items and amount spent for each member before they became a member? */
SELECT s.customer_id,COUNT(m2.product_name) AS total_items, SUM(price) AS amt
FROM sales s
JOIN members m1 ON
m1.customer_id = s.customer_id
JOIN menu m2 ON m2.product_id = s.product_id
WHERE s.order_date < m1.join_date
GROUP BY s.customer_id;

/* 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
— how many points would each customer have? */
SELECT s.customer_id,
SUM(
CASE 
    WHEN product_name = "sushi" THEN price * 10 * 2
    ELSE price * 10 
    END
) AS total_pts
FROM sales s
JOIN menu m ON
s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_pts;

/* 10)In the first week after a customer joins 
the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January? */

SELECT 
  s.customer_id, 
  SUM(
    CASE 
      WHEN (DAY(s.order_date)-DAY(m1.join_date))>=0 AND (DAY(s.order_date)-DAY(m1.join_date))<=6 THEN price * 10 * 2 
      WHEN product_name = 'sushi' THEN price * 10 * 2 
      ELSE price * 10 
    END
  ) as points 
FROM sales s
JOIN members m1 ON
s.customer_id = m1.customer_id
JOIN menu m2 ON
s.product_id = m2.product_id
WHERE MONTH(s.order_date) = 1
GROUP BY s.customer_id;

/* Q1) Join All The Things */
SELECT s.customer_id, s.order_date, m1.product_name, m1.price,
CASE
    WHEN m2.join_date > s.order_date THEN 'N'
    WHEN m2.join_date <= s.order_date THEN 'Y'
    ELSE 'N' 
    END AS member_status
FROM sales s
LEFT JOIN members m2
  ON s.customer_id = m2.customer_id
JOIN menu m1
  ON s.product_id = m1.product_id
ORDER BY m2.customer_id, s.order_date;

/* 2)                                */

CREATE VIEW XX AS
SELECT s.customer_id, s.order_date, m1.product_name, m1.price,
CASE
    WHEN m2.join_date > s.order_date THEN 'N'
    WHEN m2.join_date <= s.order_date THEN 'Y'
    ELSE 'N' 
    END AS member_status
FROM sales s
LEFT JOIN members m2
  ON s.customer_id = m2.customer_id
JOIN menu m1
  ON s.product_id = m1.product_id
ORDER BY m2.customer_id, s.order_date;

SELECT *,
 (
   CASE
     WHEN member_status = 'N' THEN null
     ELSE rank() over(PARTITION BY customer_id, member_status ORDER BY order_date)
   END
 ) AS ranking
FROM XX;



