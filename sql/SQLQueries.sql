use Alt_mobility

select count(*) from payments;

select * from payments

select name from sys.tables;

select count(*) from customer_orders;

--Analyze Order Status:
--It is used to check the status of the orders and number of orders according to that 
SELECT 
    order_status, 
    COUNT(*) AS order_count
FROM 
    customer_orders
GROUP BY 
    order_status;


--Analyze Sales Data:
-- Total amount of the sales and average how much we are getting


-- select order_amount from customer_orders where order_amount is null;

SELECT 
    SUM(order_amount) AS total_sales,
    AVG(order_amount) AS average_order_value
FROM 
    customer_orders;


--Analyze Trends Over Time

SELECT
    FORMAT(order_date, 'yyyy-MM') AS order_month,
    SUM(order_amount) AS monthly_sales
FROM
    customer_orders
GROUP BY 
    FORMAT(order_date, 'yyyy-MM')
ORDER BY
    order_month;

--Order count according to the customers(Each customer may have muliple orders)

SELECT 
    customer_id,
    COUNT(*) AS order_count
FROM 
    customer_orders
GROUP BY 
    customer_id
ORDER BY 
    order_count DESC;

-- To find the number of repeat customers (customers with more than 1 order):
SELECT 
    COUNT(DISTINCT customer_id)
FROM 
    (
        SELECT customer_id, COUNT(*) AS order_count
        FROM customer_orders
        GROUP BY customer_id
        HAVING COUNT(*) > 1
    ) AS subquery_alias;



select count(distinct customer_id) from customer_orders where customer_id IN (
select customer_id from customer_orders 
group by customer_id 
having  count(*)>1);



------------------------------------------------------------------------------------

--Repeat Ordering

SELECT 
    customer_id,
    COUNT(*) AS order_count
FROM 
    customer_orders
GROUP BY 
    customer_id
ORDER BY 
    order_count DESC;

 ----------Trends Over Time

 SELECT 
    customer_id,
    FORMAT(order_date, 'yyyy-MM') AS order_month,
    COUNT(*) AS orders_per_month
FROM 
    customer_orders
GROUP BY 
    customer_id, FORMAT(order_date, 'yyyy-MM')
ORDER BY 
    customer_id, order_month


---Analyze Payment Status:

SELECT 
    payment_status, 
    COUNT(*) AS payment_count
FROM 
    payments
GROUP BY 
    payment_status;


----Payment Methods:

SELECT 
    payment_method,
    COUNT(*) AS payment_count,
    SUM(CASE WHEN payment_status = 'failed' THEN 1 ELSE 0 END) AS failed_count,
    CAST(SUM(CASE WHEN payment_status = 'failed' THEN 1 ELSE 0 END) AS REAL) / COUNT(*) * 100 AS failure_rate
FROM 
    payments
GROUP BY 
    payment_method;



--Trends Over Time:

SELECT
    FORMAT(payment_date, 'yyyy-MM') AS payment_month,
    payment_status,
    COUNT(*) AS payment_count
FROM
    payments
GROUP BY
    FORMAT(payment_date, 'yyyy-MM'), payment_status
ORDER BY
    payment_month, payment_status;


--Order Details Report
SELECT 
    co.*,
    p.*
FROM 
    customer_orders co
JOIN 
    payments p ON co.order_id = p.order_id;


--Customer Retention Analysis

--  This query is a starting point and might need adaptation for specific SQL dialects
--  and to handle edge cases.  It's conceptually how you'd approach cohort analysis.

WITH FirstOrders AS (
    SELECT 
        customer_id,
        FORMAT(MIN(order_date), 'yyyy-MM') AS first_order_month
    FROM 
        customer_orders
    GROUP BY 
        customer_id
),
CohortMonths AS (
    SELECT DISTINCT
        fo.first_order_month,
        FORMAT(co.order_date, 'yyyy-MM') AS order_month,
        co.customer_id
    FROM 
        customer_orders co
    JOIN 
        FirstOrders fo ON co.customer_id = fo.customer_id
),
MonthDiffs AS (
    SELECT
        first_order_month,
        order_month,
        customer_id,
        (YEAR(CAST(order_month + '-01' AS DATE)) - YEAR(CAST(first_order_month + '-01' AS DATE))) * 12 + 
        (MONTH(CAST(order_month + '-01' AS DATE)) - MONTH(CAST(first_order_month + '-01' AS DATE))) AS month_diff
    FROM 
        CohortMonths
),
RetentionCounts AS (
    SELECT
        first_order_month,
        month_diff,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM
        MonthDiffs
    GROUP BY
        first_order_month, month_diff
)
SELECT
    first_order_month,
    month_diff,
    retained_customers
FROM
    RetentionCounts
ORDER BY
    first_order_month, month_diff;






