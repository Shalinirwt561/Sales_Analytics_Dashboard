#NAME?

create database Sales_table

/************************************************************************************************
Import tables  in the database as per schema
************************************************************************************************/

--Fetch all the data from the tables .
select * from customers
select * from orders
select * from products

--Q1) Find total Revenue .

SELECT 
    SUM(o.quantity * p.price) AS total_revenue
FROM orders o
JOIN products p 
ON o.product_id = p.product_id


--Q2) Find total Revenue by category .

SELECT 
"    p.category,"
    SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN products p 
ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC


--Q3) Find Top 3 customers by spending .

WITH customer_spending AS (
    SELECT 
"        c.customer_id,"
        SUM(o.quantity * p.price) AS total_spent
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p ON o.product_id = p.product_id
    GROUP BY c.customer_id
)

SELECT *
FROM (
"    SELECT *,"
           RANK() OVER (ORDER BY total_spent DESC) AS rnk
    FROM customer_spending
) t
WHERE rnk <= 3


--Q4) Find monthly sales by trend .

SELECT 
"    FORMAT(o.order_date, 'yyyy-MM') AS month,"
    SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
"GROUP BY FORMAT(o.order_date, 'yyyy-MM')"
ORDER BY month


--Q5) Find Revenue by city .


SELECT 
"    c.city,"
    SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.city
ORDER BY revenue DESC


--Q6) Find payment method by Analysis.

SELECT 
"    o.payment_method,"
"    COUNT(*) AS total_orders,"
    SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY o.payment_method


--Q7) Find Loyal customers and NOn- Loyal customers .

SELECT 
"    c.loyalty_member,"
"    COUNT(DISTINCT o.customer_id) AS customers,"
    SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.loyalty_member


--Q8) Find mostly sold products .

SELECT TOP 10
"    p.product_name,"
    SUM(o.quantity) AS total_quantity
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC


--Q9) Find Age group Analysis.

SELECT 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 40 THEN '25-40'
        WHEN age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
"    END AS age_group,"
    SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 40 THEN '25-40'
        WHEN age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END


--Q10) Fins the Average value of orders.

SELECT 
    SUM(o.quantity * p.price) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id


--Q11) Find monthly Revenue Growth .

WITH monthly_sales AS (
    SELECT 
"        FORMAT(o.order_date, 'yyyy-MM') AS month,"
        SUM(o.quantity * p.price) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
"    GROUP BY FORMAT(o.order_date, 'yyyy-MM')"
"),"

growth AS (
    SELECT 
"        month,"
"        revenue,"
        LAG(revenue) OVER (ORDER BY month) AS prev_month
    FROM monthly_sales
)

SELECT 
"    month,"
"    revenue,"
"    prev_month,"
    (revenue - prev_month) AS growth
FROM growth


--Q12) Find customers who spent above average . 

WITH customer_spending AS (
    SELECT 
"        c.customer_id,"
        SUM(o.quantity * p.price) AS total_spent
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p ON o.product_id = p.product_id
    GROUP BY c.customer_id
)

SELECT *
FROM customer_spending
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spending)


--Q13) Rank products by sales within each category .

SELECT 
"    p.category,"
"    p.product_name,"
"    SUM(o.quantity) AS total_sold,"
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(o.quantity) DESC) AS rank_in_category
FROM orders o
JOIN products p ON o.product_id = p.product_id
"GROUP BY p.category, p.product_name"


---Q14) find first order of each customer.

SELECT *
FROM (
    SELECT 
"        o.*,"
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
    FROM orders o
) t
WHERE rn = 1


--Q15)  Find customers who order more than one .

SELECT DISTINCT customer_id
FROM (
    SELECT 
"        customer_id,"
        COUNT(*) OVER (PARTITION BY customer_id) AS order_count
    FROM orders
) t
WHERE order_count > 1


--Q16) Find  Revenue Contribution % of Each Product.

SELECT 
"    p.product_name,"
"    SUM(o.quantity * p.price) AS revenue,"
    SUM(o.quantity * p.price) * 100.0 
        / SUM(SUM(o.quantity * p.price)) OVER () AS contribution_percent
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name


---Q17) Find top products of per month .

WITH product_sales AS (
    SELECT 
"        FORMAT(o.order_date, 'yyyy-MM') AS month,"
"        p.product_name,"
        SUM(o.quantity) AS total_sold
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
"    GROUP BY FORMAT(o.order_date, 'yyyy-MM'), p.product_name"
)

SELECT *
FROM (
"    SELECT *,"
           RANK() OVER (PARTITION BY month ORDER BY total_sold DESC) AS rnk
    FROM product_sales
) t
WHERE rnk = 1
