/*CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
*/
-- 1)What is the total amount each customer spent at the restaurant?

SELECT 
customer_id,Sum(price) as Total_Price
FROM dannys_diner.sales S Inner Join dannys_diner.menu M
On S.product_id = M.product_id
Group By customer_id
Order by Total_Price desc ;

-- 2)How many days has each customer visited the restaurant?

SELECT
        S.customer_id,
         count(Distinct Order_date) as Number_of_visit 
    FROM dannys_diner.sales S
    Group By S.customer_id

-- 3)What was the first item from the menu purchased by each customer?

with cte as (
SELECT S.customer_id,S.order_date,M.product_name,
 Row_number() over(Partition by S.customer_id Order By S.order_date)as Date
FROM dannys_diner.sales S Inner Join dannys_diner.menu M
On S.product_id = M.product_id)
 Select customer_id,product_name From cte where Date = 1;


-- 4)What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT M.product_name, COUNT(*) AS total_purchases
FROM dannys_diner.sales AS S
INNER JOIN dannys_diner.menu AS M ON S.product_id = M.product_id
GROUP BY M.product_name
ORDER BY total_purchases DESC
LIMIT 1;

-- 5)Which item was the most popular for each customer?
WITH ItemCount AS ( SELECT S.customer_id, M.product_name, 
count(*) As   total_purchased,
RANK() OVER (PARTITION BY S.customer_id ORDER BY    count(*) Desc) AS rnk FROM dannys_diner.sales S
INNER JOIN dannys_diner.menu M 
ON S.product_id = M.product_id
GROUP BY M.product_name, S.customer_id)
SELECT customer_id,product_name FROM ItemCount
where rnk = 1;

-- 6)Which item was purchased first by the customer after they became a member?

with cte as (Select S.customer_id,Me.product_name,S.order_date, M.join_date ,
Rank() Over(partition by s .customer_id order by S.order_date ) as rnk 
from dannys_diner.sales S Inner Join 
dannys_diner.members M ON S.customer_id = M.customer_id
 And  S.order_date > M.join_date
 Join dannys_diner.menu Me ON S.product_id = Me.product_id)
 Select customer_id,product_name,join_date ,order_date from cte where rnk=1;

-- 7)Which item was purchased just before the customer became a member?
	
with cte as (Select S.customer_id,Me.product_name,
S.order_date, M.join_date ,
Rank() Over(partition by s .customer_id order by S.order_date ) as rnk 
from dannys_diner.sales S Inner Join 
dannys_diner.members M ON S.customer_id = M.customer_id
 And  S.order_date < M.join_date
 Join dannys_diner.menu Me ON S.product_id = Me.product_id)

 Select customer_id,product_name,join_date ,order_date from cte where rnk=1;

-- 8)What is the total items and amount spent for each member before they became a member?
Select S.customer_id,Count(Me.product_name)as Total_item,sum(Me.price) as Total_Price from dannys_diner.sales S Inner Join 
dannys_diner.members M ON S.customer_id = M.customer_id
 And  S.order_date < M.join_date
 Join dannys_diner.menu Me On S.product_id = Me.product_id
 group by S.customer_id
 Order by S.customer_id

-- 9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

 SELECT customer_id,
 SUM(CASE WHEN menu.product_name = 'sushi' 
THEN(price * 2) * 10 
ELSE price * 10 END) AS total_points
 FROM dannys_diner.sales s JOIN dannys_diner.menu
 ON s.product_id = menu.product_id
 GROUP BY   customer_id;