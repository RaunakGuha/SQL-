SET sql_mode = '';

CREATE DATABASE pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners( 
runner_id INT,
registration_date DATE
);
INSERT INTO runners (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
SHOW TABLES FROM pizza_runner;


/* DATA CLEANING ON customers_orders and runner_order table */
DROP TABLE IF EXISTS customer_orders_2;
CREATE TABLE customer_orders_2 AS
SELECT 
    order_id, 
    customer_id, 
    pizza_id, 
    order_time,
    CASE
        WHEN exclusions IS NULL OR exclusions = 'null' THEN ''
        ELSE exclusions
    END AS exclusions,
    CASE
        WHEN extras IS NULL OR extras = 'null' THEN ''
        ELSE extras
    END AS extras
FROM customer_orders;

SELECT * FROM customer_orders_2;

DROP TABLE IF EXISTS runner_orders_2;
CREATE TABLE runner_orders_2 AS
SELECT 
    order_id, 
    runner_id, 
    CASE
        WHEN pickup_time = 'null' THEN NULL
        ELSE pickup_time
    END AS pickup_time,
    CASE
        WHEN distance = 'null' THEN NULL
        WHEN distance LIKE '%km' THEN TRIM('km' from distance)
        ELSE distance 
    END AS distance,
    CASE
        WHEN duration = 'null' THEN NULL
        WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
        WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
        WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
        ELSE duration
    END AS duration,
    CASE
        WHEN cancellation IS NULL or cancellation = 'null' THEN ''
        ELSE cancellation
    END AS cancellation
FROM runner_orders;

ALTER TABLE runner_orders_2
MODIFY COLUMN pickup_time datetime null, 
MODIFY COLUMN distance FLOAT null,
MODIFY COLUMN duration INT null;

SELECT * FROM runner_orders_2;

SELECT * FROM customer_orders_2;
SELECT * FROM pizza_names;
SELECT * FROM pizza_toppings;
SELECT * FROM pizza_recipes;
SELECT * FROM runner_orders_2;
SELECT * FROM runners;

/* A. Pizza Metrics 
1) How many pizzas were ordered? = 14 */
SELECT COUNT(pizza_id) AS ordered_pizza 
FROM customer_orders_2;

/*
2) How many unique customer orders were made? == 10*/
SELECT COUNT(DISTINCT(order_id)) AS unique_customer_orders 
FROM customer_orders_2;

/* 3)How many successful orders were delivered by each runner? */
SELECT runner_id, COUNT(runner_id) AS succ_order_count 
FROM runner_orders_2
WHERE DISTANCE IS NOT NULL
GROUP BY runner_id
ORDER BY succ_order_count DESC;

/* 4) How many of each type of pizza was delivered? */
SELECT pn.pizza_name, COUNT(co.pizza_id) AS pizza_delivered
FROM runner_orders_2 ro
JOIN customer_orders_2 co ON co.order_id = ro.order_id
JOIN pizza_names pn ON pn.pizza_id = co.pizza_id
WHERE ro.DISTANCE IS NOT NULL
GROUP BY pn.pizza_name;

/* 5) How many Vegetarian and Meatlovers were ordered by each customer? */
SELECT co.customer_id, pn.pizza_name,COUNT(co.pizza_id) AS pizzas_ordered
FROM customer_orders_2 co
JOIN pizza_names pn ON pn.pizza_id = co.pizza_id
GROUP BY co.customer_id,pn.pizza_name
ORDER BY co.customer_id;

/* 6. What was the maximum number of pizzas delivered in a single order? */
SELECT co.order_id,COUNT(co.pizza_id) AS max_pizza_ordered
FROM customer_orders_2 co
JOIN runner_orders_2 ro on co.order_id = ro.order_id
WHERE ro.DISTANCE IS NOT NULL
GROUP BY co.order_id 
ORDER BY max_pizza_ordered DESC LIMIT 1;

/* 7)For each customer, how many delivered pizzas had at least 1 change, and how many had no changes? */
 SELECT co.customer_id,
 SUM(CASE 
  WHEN (co.exclusions <> ''  AND co.exclusions <> 0 ) OR (co.extras <> '' AND co.extras <> 0) THEN 1
  ELSE 0
  END) AS at_least_1_change,
 SUM(CASE 
  WHEN (co.exclusions = ' ' OR co.exclusions = 0 ) AND (co.extras = '' OR co.extras = 0) THEN 1
  ELSE 0
  END) AS no_change
FROM customer_orders_2 AS co
JOIN runner_orders_2 AS ro
ON ro.order_id = co.order_id
WHERE ro.distance != 0
GROUP BY co.customer_id
ORDER BY co.customer_id;

/* 8)How many pizzas were delivered that had both exclusions and extras? */
SELECT COUNT(*) AS pizza_having_exclusions_n_extras
FROM 
  customer_orders_2 as co 
  JOIN runner_orders_2 ro on ro.order_id = co.order_id 
WHERE 
  pickup_time IS NOT NULL
  AND (exclusions IS NOT NULL AND exclusions!= 0) 
  AND (extras IS NOT NULL AND extras!=0); 
  
-- 9) What was the total volume of pizzas ordered for each hour of the day? --
SELECT HOUR(order_time) AS hr_day, COUNT(*) AS pizza_count
FROM customer_orders_2
GROUP BY hr_day
ORDER BY hr_day;

/*  10) What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS day, COUNT(*) AS orders_vol
FROM customer_orders_2
GROUP BY day
ORDER BY day;

-- B) Runner and Customer Experience
1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) --

SELECT WEEKOFYEAR(registration_date + 3) AS week_of_year, COUNT(runner_id) AS no_runner
FROM runners
GROUP BY week_of_year
ORDER BY week_of_year;

/* 2. What was the average time in minutes it took for each runner 
to arrive at the Pizza Runner HQ to pickup the order? */
SELECT ro.runner_id, AVG(TIMESTAMPDIFF(MINUTE,co.order_time,ro.pickup_time)) as avg_time 
FROM runner_orders_2 ro 
JOIN customer_orders_2 co ON co.order_id = ro.order_id
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

-- 3)Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH X AS
(SELECT co.order_id, COUNT(co.order_id) AS no_pizza, TIMESTAMPDIFF(MINUTE,co.order_time,ro.pickup_time) AS prep_time
FROM customer_orders_2 co
JOIN runner_orders_2 ro ON co.order_id = ro.order_id
WHERE pickup_time IS NOT NULL
GROUP BY order_id)
SELECT no_pizza, AVG(prep_time) AS avg_prep_time
FROM X
GROUP BY no_pizza;

-- We see that more the no of pizzas per order more the order takes to prepare on avg

-- 4)What was the average distance travelled for each customer?
SELECT co.customer_id, AVG(ro.distance) AS dist
FROM customer_orders_2 co
JOIN runner_orders_2 ro ON co.order_id = ro.order_id
WHERE pickup_time IS NOT NULL
GROUP BY co.customer_id;

-- 5)What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS diff
FROM runner_orders_2
WHERE duration IS NOT NULL;

-- 6)What was the average speed for each runner for each delivery and 
-- do you notice any trend for these values?
SELECT runner_id, order_id, AVG(round((distance * 60 )/duration,2)) AS speedkmh
FROM runner_orders_2
WHERE distance is not null
GROUP BY runner_id,order_id
ORDER BY runner_id;

-- 7)What is the successful delivery percentage for each runner?
WITH Y
AS (SELECT runner_id,
CASE
    WHEN pickup_time IS NOT NULL THEN 1
    ELSE 0
END AS succ
FROM runner_orders_2)
SELECT runner_id, SUM(succ)/COUNT(runner_id) * 100 AS succ_per
FROM Y
GROUP BY runner_id;

-- C. Ingredient Optimisation
-- 1)What are the standard ingredients for each pizza?
SELECT * FROM pizza_toppings;

-- Normalize Pizza Recipe table
drop table if exists pizza_recipes2;
create table pizza_recipes2
(
 pizza_id int,
    toppings int);
insert into pizza_recipes2
(pizza_id, toppings) 
values
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);

SELECT * FROM pizza_recipes2;

SELECT pn.pizza_name, pt.topping_name
FROM pizza_names pn
JOIN pizza_recipes2 pr ON pn.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON pr.toppings = pt.topping_id;

-- 2) What was the most commonly added extra?

SELECT * FROM customer_orders_2;
WITH a1 AS
(SELECT 
    order_id,customer_id,pizza_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', numbers.n), ',', -1) AS extras
FROM
    customer_orders_2 co
JOIN
    (SELECT 1 AS n UNION ALL SELECT 2) AS numbers
    ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= numbers.n - 1
ORDER BY
    order_id)    
SELECT a1.extras,pt.topping_name,COUNT(*) as total_extra
FROM a1
JOIN pizza_toppings pt ON a1.extras = pt.topping_id
GROUP BY a1.extras,pt.topping_name
ORDER BY total_extra DESC
LIMIT 1;

-- 3) What was the most common exclusion? */
WITH a2 AS
(SELECT 
    order_id,customer_id,pizza_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', numbers.n), ',', -1) AS exclusions
FROM
    customer_orders_2 co
JOIN
    (SELECT 1 AS n UNION ALL SELECT 2) AS numbers
    ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= numbers.n - 1
ORDER BY
    order_id)    
SELECT a2.exclusions,pt.topping_name,COUNT(*) as total_exclu
FROM a2
JOIN pizza_toppings pt ON a2.exclusions = pt.topping_id
GROUP BY a2.exclusions,pt.topping_name
ORDER BY total_exclu DESC
LIMIT 1;

 /* 4)Generate an order item for each record in the customers_orders table 
 in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */

SELECT * FROM customer_orders_2;
SELECT co.order_id, co.customer_id,co.pizza_id,co.order_time,co.exclusions, co.extras, 
CASE
when co.pizza_id = 1 and (exclusions is null or exclusions=0) and (extras is null or extras=0) then 'Meat Lovers'
when co.pizza_id = 2 and (exclusions is null or exclusions=0) and (extras is null or extras=0) then 'Veg Lovers'
when co.pizza_id = 2 and (exclusions =4 ) and (extras is null or extras=0) then 'Veg Lovers - Exclude Cheese'
when co.pizza_id = 2 and (exclusions is null or exclusions =0 ) and (extras like "%1%" or extras=1) then 'Veg Lovers - Extra  Cheese'
when co.pizza_id = 1 and (exclusions =4 ) and (extras is null or extras=0) then 'Meat Lovers - Exclude Cheese'
when co.pizza_id=1 and (exclusions like '%3%' or exclusions =3) and (extras is null or extras=0) then 'Meat Lovers - Exclude Beef'
when co.pizza_id =1 and (exclusions is null or exclusions=0) and (extras like '%1%' or extras =1) then 'Meat Lovers - Extra Bacon'
when co.pizza_id=1 and (exclusions like '1, 4' ) and (extras like '6, 9') then 'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
when co.pizza_id=1 and (exclusions like '2, 6' ) and (extras like '1, 4') then 'Meat Lovers - Exclude BBQ Sauce,Mushroom - Extra Bacon, Cheese'
when co.pizza_id=1 and (exclusions =4) and (extras like '1, 5') then 'Meat Lovers - Exclude Cheese - Extra Bacon, Chicken'
end as OrderItem
from customer_orders_2 co
join pizza_names pn
on pn.pizza_id = co.pizza_id;


ALTER TABLE customer_orders_2
ADD record_id INT AUTO_INCREMENT PRIMARY KEY;

SELECt * FROM customer_orders_2;


/* 6)What is the total quantity of each ingredient used in all
 delivered pizzas sorted by most frequent first? */
 
DROP TABLE IF EXISTS extra;
CREATE TABLE extra AS
SELECT 
    record_id,order_id,customer_id,pizza_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', numbers.n), ',', -1) AS extras
FROM
    customer_orders_2 co
JOIN
    (SELECT 1 AS n UNION ALL SELECT 2) AS numbers
    ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= numbers.n - 1
ORDER BY
    order_id;
    
DROP TABLE IF EXISTS exclu;
CREATE TABLE exclu AS
SELECT 
    record_id,order_id,customer_id,pizza_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', numbers.n), ',', -1) AS exclusions
FROM
    customer_orders_2 co
JOIN
    (SELECT 1 AS n UNION ALL SELECT 2) AS numbers
    ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= numbers.n - 1
ORDER BY
    order_id;   

SELECT 
    topping_name, SUM(times_used) AS num_of_times_used
FROM
    (SELECT 
        c.record_id,
            pt.topping_name,
            CASE
                WHEN
                    pr.toppings IN (SELECT 
                            extras
                        FROM
                            extra e
                        WHERE
                            e.record_id = c.record_id)
                THEN
                    2
                WHEN
                    pr.toppings IN (SELECT 
                            exclusions
                        FROM
                            exclu e
                        WHERE
                            c.record_id = e.record_id)
                THEN
                    0
                ELSE 1
            END AS times_used
    FROM
        customer_orders_2 c
    JOIN pizza_recipes2 pr ON pr.pizza_id = c.pizza_id
    JOIN pizza_toppings pt ON pt.topping_id = pr.toppings
    JOIN pizza_names p ON p.pizza_id = c.pizza_id) AS ingredients
GROUP BY topping_name
ORDER BY num_of_times_used DESC;

/* Pricing and Ratings
Q1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes — 
how much money has Pizza Runner made so far if there are no delivery fees? */

select CONCAT('$ ',sum(case 
when c.pizza_id = 1 then 12
else 10
end)) as TotalAmount
from runner_orders_2 r
join customer_orders_2 c
on c.order_id = r.order_id
where r.distance is not null;

/* 2) What if there was an additional $1 charge for any pizza extras? */

WITH k AS (
  SELECT
    SUM(CASE WHEN c.pizza_id = 1 THEN 12 ELSE 10 END)AS TotalAmount,
    c.extras,
    c.exclusions
  FROM
    runner_orders_2 r
    JOIN customer_orders_2 c ON c.order_id = r.order_id
  WHERE
    r.cancellation IS NOT NULL
)
SELECT
  SUM(
    CASE
      WHEN extras IS NULL THEN TotalAmount
      WHEN LENGTH(extras) = 1 THEN TotalAmount + 1
      ELSE TotalAmount + 2
    END
  ) AS total_earn
FROM k;

/* 3)                                                         */

SELECT order_id, distance, duration, ((distance * 60)/duration) AS speed_kmph
FROM runner_orders_2
WHERE cancellation is not null
GROUP BY order_id;

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings AS
SELECT order_id,
  CASE
    WHEN (distance * 60 / duration) >= 75 THEN 5
    WHEN (distance * 60 / duration) >= 60 THEN 4
    WHEN (distance * 60/ duration) >= 45 THEN 3
    WHEN (distance * 60 / duration) >= 37 THEN 2
    ELSE 1
END AS rating
FROM runner_orders_2
WHERE distance is not null;

select * from ratings;

/* 4)Using your newly generated table - can you join all of the information 
together to form a table which has the following information for successful deliveries? */

select co.customer_id, co.order_id, ro.runner_id, ratings.rating, co.order_time,
ro.pickup_time, timestampdiff(minute, order_time, pickup_time) as TimebwOrderandPickup, 
ro.duration, round(avg(ro.distance*60/ro.duration),1) as avgspeed, count(co.pizza_id) as PizzaCount
from customer_orders_2 co
join runner_orders_2 ro
on co.order_id = ro.order_id
join ratings
on ratings.order_id = co.order_id
group by co.customer_id, co.order_id, ro.runner_id, ratings.rating, co.order_time,
ro.pickup_time, TimebwOrderandPickup, ro.duration
order by customer_id;

/* 5)If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and 
each runner is paid $0.30 per kilometre traveled - 
how much money does Pizza Runner have left over after these deliveries? */

WITH k AS(
SELECT SUM(CASE 
when c.pizza_id = 1 then 12
else 10
end) as TotalAmount,ro.distance
FROM
runner_orders_2 ro
JOIN customer_orders_2 c ON c.order_id = ro.order_id
WHERE
ro.cancellation IS NOT NULL
)
SELECT TotalAmount - (SUM(ro.distance))*0.3 AS earned
FROM k;