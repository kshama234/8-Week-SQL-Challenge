create database dannys_diner;
use dannys_diner;
create table sales(
customer_id varchar(1),
order_date date,
product_id int
);
create table members(
customer_id varchar(1),
join_date timestamp
);
create table menu(
product_id integer,
product_name varchar(5),
price integer
);

insert into sales (customer_id,order_date,product_id) values
('A','2021-01-01',1),('A','2021-01-01',2),('A','2021-01-07',2),
('A','2021-01-10',3),('A','2021-01-11',3),('A','2021-01-11',3),
('B','2021-01-01',2),('B','2021-01-02',2),('B','2021-01-04',1),
('B','2021-01-11',1),('B','2021-01-16',3),('B','2021-02-01',3),
('C','2021-01-01',3),('C','2021-01-01',3),('C','2021-01-07',3);

insert into menu (product_id,product_name,price) values
(1,'sushi',10),(2,'curry',15),(3,'ramen',12);

insert into members (customer_id,join_date) values
('A','2021-01-07'),('B','2021-01-09');

----- Question 1. What is the total amount each customer spent at the restaurant?


select customer_id,sum(price) as total_amount_spent from sales s 
join menu m on s.product_id=m.product_id
group by customer_id; 


----- Question 2. How many days has each customer visited the restaurant?


select customer_id,count(distinct order_date) as number_of_days_visited 
from sales group by customer_id;


----- Question 3. What was the first item from the menu purchased by each customer?



select distinct customer_id,first_value(product_name) over(partition by customer_id order by order_date) as first_item 
from sales s join menu m
on s.product_id=m.product_id;


----- Question 4. What is the most purchased item on the menu and how many times was it purchased by all customers?



select product_name as most_purchased_item, count(*) as num_times from sales s join menu m
on s.product_id=m.product_id 
group by s.product_id order by num_times desc limit 1;

----- Question 5. Which item was the most popular for each customer?
 

WITH order_priority AS 
		(
			WITH ordered_items AS 
				(
                SELECT customer_id, product_name, COUNT(*) AS num_times 
				FROM sales s JOIN menu m ON
				s.product_id=m.product_id
				GROUP BY customer_id, product_name
				)
			SELECT *, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY num_times desc) AS priority 
			FROM  ordered_items
		) 
SELECT customer_id, product_name as most_popular_item FROM order_priority WHERE priority=1;


----- Question 6. Which item was purchased first by the customer after they became a member?


WITH order_details as (SELECT s.customer_id as customer_id, order_date, join_date, product_name FROM sales s 
JOIN members m ON s.customer_id=m.customer_id 
JOIN menu ON s.product_id=menu.product_id WHERE join_date<=order_date)
SELECT customer_id, product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS ranking FROM order_details ;

----- Question 7. Which item was purchased just before the customer became a member?


WITH order_details AS (SELECT s.customer_id as customer_id, product_name, 
RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date desc) AS ranking FROM sales s 
JOIN members m ON s.customer_id=m.customer_id 
JOIN menu ON s.product_id=menu.product_id WHERE join_date>order_date)
SELECT customer_id,product_name FROM order_detailS WHERE ranking=1;


----- Question 8. What is the total items and amount spent for each member before they became a member?


SELECT s.customer_id as customer_id, count(s.product_id) AS num_items, SUM(price) as total_amount FROM sales s 
JOIN members m ON s.customer_id=m.customer_id 
JOIN menu ON s.product_id=menu.product_id WHERE join_date>order_date 
GROUP BY  s.customer_id ORDER BY s.customer_id;


----- Question 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


SELECT s.customer_id as customer_id, 
SUM(IF(s.product_id=2, 20*price, 10*price)) AS points FROM sales s 
JOIN menu m ON s.product_id=m.product_id 
GROUP BY customer_id;


----- Question 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? 


With validity AS (
SELECT *,
join_date +  interval 6 day AS valid_date,
'2021-01-31' AS last_date FROM members)
SELECT s.customer_id,v.join_date, valid_date, last_date,
SUM(CASE 
WHEN product_name='sushi' THEN 2*10*m.price
WHEN order_date BETWEEN  join_date AND valid_date THEN 2*10*m.price
ELSE 10*m.price 
END) AS points
FROM validity v JOIN sales s ON v.customer_id=s.customer_id 
JOIN menu m ON s.product_id=m.product_id 
WHERE order_Date<last_date
GROUP BY s.customer_id;

----- Bonus Question: Join All The Things, Recreate the table with customer_id, order_date, product_name, price, member(Y/N)


SELECT s.customer_id,order_date, product_name, price,
(CASE 
WHEN order_date>=join_date THEN 'Y'
ELSE 'N'
END) AS member 
FROM sales s JOIN menu m ON
s.product_id=m.product_id LEFT JOIN members mem ON s.customer_id=mem.customer_id
ORDER BY s.customer_id,order_date;


----- Bonus Question: Rank All The Things, Recreate the table with customer_id, order_date, product_name, price, member(Y/N), ranking but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

WITH details AS (SELECT s.customer_id,order_date, product_name, price,
(CASE 
WHEN order_date>=join_date THEN 'Y'
ELSE 'N'
END) AS member 
FROM sales s JOIN menu m ON
s.product_id=m.product_id LEFT JOIN members mem ON s.customer_id=mem.customer_id
ORDER BY s.customer_id,order_date)
SELECT *, 
(CASE 
WHEN member='N' THEN 'null'
ELSE 
DENSE_RANK() OVER (PARTITION BY s.customer_id,member ORDER BY order_date) 
END) AS ranking  
FROM  details;