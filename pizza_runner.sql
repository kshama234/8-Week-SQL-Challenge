CREATE SCHEMA pizza_runner;

USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);
INSERT INTO runners
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
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
CREATE TABLE runner_orders(
order_id int,
runner_id int,
pickup_time varchar(19),
distance varchar(7),
duration varchar(10),
cancellation varchar(33)
);

INSERT INTO runner_orders
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
CREATE TABLE pizza_names(
pizza_id int,
pizza_name text
);
INSERT INTO pizza_names
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes(
pizza_id int,
toppings text
);
INSERT INTO pizza_recipes
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings(
topping_id int,
topping_name text
);
INSERT INTO pizza_toppings VALUES
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
  
-------- A. Pizza Metrics
-------- 1: How many pizzas were ordered?

SELECT COUNT(pizza_id) AS num_pizzas FROM customer_orders;

----- Ans: Hence, 14 pizzas were ordered.

----- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS uni_customer_orders FROM customer_orders;

----- Ans: Hence, 10 unique customer orders were made.

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS delivered_orders FROM runner_orders  WHERE cancellation='' OR cancellation="null" OR cancellation IS NULL
GROUP BY runner_id;

-- Ans: Hence, runners with id 1,2,3 delivered 4, 3 and 1 orders respectively.

-- 4.How many of each type of pizza was delivered?

SELECT pizza_name, COUNT(co.order_id) as delivered_pizza 
FROM runner_orders  ro JOIN customer_orders co ON ro.order_id=co.order_id
JOIN pizza_names pn ON co.pizza_id=pn.pizza_id
WHERE cancellation='' OR cancellation="null" OR cancellation IS NULL
GROUP BY pizza_name;

----- Ans:  Hence, 9 Meatlovers pizzas were delivered while 3 vegetarian pizzas were delivered.

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_name, COUNT(co.order_id) AS pizza_ordered
FROM customer_orders co 
JOIN pizza_names pn ON co.pizza_id=pn.pizza_id
GROUP BY customer_id,pizza_name
ORDER BY customer_id;

-- Ans: Hence, customer with id 101 ordered 2 Meatlovers & 1 Vegetrain pizza, 102 ordered 2 Meatlovers & 1 Vegetrain pizza, 103 ordered 3 Meatlovers & 1 Vegetrain pizza, 104 ordered 3 Meatlovers pizza while 105 ordered only 1 Vegetrain pizza.

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT COUNT(*) AS num_delivered
FROM runner_orders  ro JOIN customer_orders co ON ro.order_id=co.order_id
WHERE cancellation='' OR cancellation="null" OR cancellation IS NULL
GROUP BY co.order_id
ORDER BY num_delivered DESC
LIMIT 1;

-- Ans:Hence, there were maximum 3 pizzas were delivered in a single order.

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SET SQL_SAFE_UPDATES = 0;

UPDATE customer_orders SET exclusions=Null WHERE exclusions='null';
UPDATE customer_orders SET extras=Null WHERE extras='null';
UPDATE customer_orders SET exclusions=Null WHERE exclusions='';
UPDATE customer_orders SET extras=Null WHERE extras='';


SELECT customer_id,SUM(IF((exclusions IS NULL) AND (extras IS NULL),1,0)) AS `No_Change`,
SUM(IF((exclusions IS NOT NULL) OR (extras IS NOT NULL),1,0)) AS `Changed`
FROM runner_orders  ro JOIN customer_orders co ON ro.order_id=co.order_id
WHERE cancellation='' OR cancellation="null" OR cancellation IS NULL
GROUP BY customer_id;

-- Ans: Hence, for 101, 2 pizzas were delivered with no change. For 102, 3 pizzas were delivered with no change. For 103, 3 changed pizzas were delivered. For 104, 1 pizza was delivered with no change & 2 pizzas were delivered with at least one change. For 105, 1pizzas were delivered with at least one change.

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT Sum(IF((exclusions IS NOT NULL) AND (extras IS NOT NULL),1,0)) AS `excl_extras`
FROM runner_orders  ro JOIN customer_orders co ON ro.order_id=co.order_id
WHERE cancellation='' OR cancellation="null" OR cancellation IS NULL;

-- Ans: Hence, only one pizzas was delivered with both exclusions & extras.

-- 9.What was the total volume of pizzas ordered for each hour of the day?

WITH order_details AS(
SELECT pizza_id,CAST(order_time AS time) AS ordered_time FROM customer_orders),
ordered_hour_details AS(
SELECT *,
(CASE  
WHEN ordered_time BETWEEN '00:00:00' AND '01:00:00' THEN 1 
WHEN ordered_time BETWEEN '01:00:00' AND '02:00:00' THEN 2 
WHEN ordered_time BETWEEN '02:00:00' AND '03:00:00' THEN 3 
WHEN ordered_time BETWEEN '03:00:00' AND '04:00:00' THEN 4 
WHEN ordered_time BETWEEN '04:00:00' AND '05:00:00' THEN 5 
WHEN ordered_time BETWEEN '05:00:00' AND '06:00:00' THEN 6 
WHEN ordered_time BETWEEN '06:00:00' AND '07:00:00' THEN 7 
WHEN ordered_time BETWEEN '07:00:00' AND '08:00:00' THEN 8 
WHEN ordered_time BETWEEN '08:00:00' AND '09:00:00' THEN 9 
WHEN ordered_time BETWEEN '09:00:00' AND '10:00:00' THEN 10 
WHEN ordered_time BETWEEN '10:00:00' AND '11:00:00' THEN 11 
WHEN ordered_time BETWEEN '11:00:00' AND '12:00:00' THEN 12 
WHEN ordered_time BETWEEN '12:00:00' AND '13:00:00' THEN 13 
WHEN ordered_time BETWEEN '13:00:00' AND '14:00:00' THEN 14 
WHEN ordered_time BETWEEN '14:00:00' AND '15:00:00' THEN 15 
WHEN ordered_time BETWEEN '15:00:00' AND '16:00:00' THEN 16 
WHEN ordered_time BETWEEN '16:00:00' AND '17:00:00' THEN 17 
WHEN ordered_time BETWEEN '17:00:00' AND '18:00:00' THEN 18 
WHEN ordered_time BETWEEN '18:00:00' AND '19:00:00' THEN 19 
WHEN ordered_time BETWEEN '19:00:00' AND '20:00:00' THEN 20 
WHEN ordered_time BETWEEN '20:00:00' AND '21:00:00' THEN 21 
WHEN ordered_time BETWEEN '21:00:00' AND '22:00:00' THEN 22
WHEN ordered_time BETWEEN '22:00:00' AND '23:00:00' THEN 23
WHEN ordered_time BETWEEN '23:00:00' AND '24:00:00' THEN 24
END) order_hour
FROM order_details)
SELECT order_hour, COUNT(pizza_id) AS num_pizza FROM ordered_hour_details
GROUP BY order_hour ORDER BY order_hour;

-- Hence, 12 hour has 1 order, 14th hour has 3 orders, 19th hour has 3 orders, 20 hour has 1 order, 22 hour has 3 order & 24 hour has 3 orders while other hours doesn't have any orders.

-- 10. What was the volume of orders for each day of the week?

WITH order_details AS(
SELECT pizza_id, WEEKDAY(order_time) AS ordered_day FROM customer_orders),
ordered_weekday_details AS(
SELECT *,
(CASE  
WHEN ordered_day=0 THEN 'Sunday' 
WHEN ordered_day=1 THEN 'Monday' 
WHEN ordered_day=2 THEN 'Tuesday' 
WHEN ordered_day=3 THEN 'Wednesday' 
WHEN ordered_day=4 THEN 'Thursday' 
WHEN ordered_day=5 THEN 'Friday' 
WHEN ordered_day=6 THEN 'Saturday' 
END) order_day
FROM order_details)
SELECT order_day, COUNT(pizza_id) AS num_pizza FROM ordered_weekday_details
GROUP BY order_day ORDER BY ordered_day;

-- Ans: Hence, Volume of orders was 5 for Tuesday, 3 for Wednesday, 1 for Thursday, 5 for Friday while other days of the week doesn't have any orders.

