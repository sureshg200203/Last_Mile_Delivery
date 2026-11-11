-- 4.2: Understand Customer Order Behaviour

-- 1. Compare customers based on the number of orders they place. 
select c.customer_id, c.customer_name, COALESCE(count(o.order_id), 0) as"Total_Orders" from customers c left join orders o on c.customer_id = o.customer_id group by c.customer_id order by Total_Orders desc;

-- 2. Identify customers with higher total order value. 
select c.customer_id, c.customer_name, COALESCE(count(o.order_id), 0) as"Total_Orders", COALESCE(sum(o.total_value), 0) as"Total_Amount", COALESCE(avg(o.total_value), 0) as"Average_Amount" from customers c left join orders o on c.customer_id = o.customer_id group by c.customer_id order by Total_Amount desc;

-- 3. Compare customer activity across delivery zones. 
select delivery_zone_id, count(customer_id) as "Total_Customers" from customers group by delivery_zone_id order by Total_Customers desc;

-- this can also be done with only orders table
select delivery_zone_id, count(customer_id) as "Total_Customers" from orders group by delivery_zone_id order by Total_Customers desc;
-- without disctinct it count for customer_id for each order so it sums to number of orders in each zone than the number of customers.

select delivery_zone_id, count(distinct customer_id) as "Total_Customers" from orders group by delivery_zone_id order by Total_Customers desc;
-- with disctinct it count for only once for each customer_id so it returns the number of customers in each zone.

select o.delivery_zone_id, count(distinct c.customer_id) as "Total_Customers" from customers c join orders o on c.customer_id = o.customer_id group by o.delivery_zone_id order by Total_Customers desc;
-- it returns the number of customers placed orders in each delivery zone but if a customer ordered in multiple zones then he counted for multiple times for each zone. so, the final count would be 400 or higher.


select c.customer_id, count(distinct o.delivery_zone_id) as "Total_zones" from customers c join orders o on c.customer_id = o.customer_id group by c.customer_id order by Total_zones desc;
-- As each customer ordered from exactly one delivery zone. so earlier total would be 400.

-- 4. Look at differences between business and individual customers.
select distinct customer_type from customers;
select c.customer_type, COALESCE(count(o.order_id), 0) as"Total_Orders", COALESCE(sum(o.total_value), 0) as"Total_Amount", COALESCE(avg(o.total_value), 0) as"Average_Amount" from customers c left join orders o on c.customer_id = o.customer_id group by c.customer_type;

-- 5. Examine customer ordering patterns over time. 

-- it returns number of customers registered in each year based on order_since
select year(account_since) as "Each_year", count(*) as "no_of_customers_registered", SUM(COUNT(*)) OVER (ORDER BY YEAR(account_since)) AS no_of_customers_available from customers group by Each_Year order by Each_Year;

-- It returns the number of distinct customers who placed at least one order in each year, regardless of their registration year.
WITH years AS (
    SELECT 2020 AS analysis_year
    UNION ALL SELECT 2021
    UNION ALL SELECT 2022
    UNION ALL SELECT 2023
    UNION ALL SELECT 2024
),
/*
1. Creates a CTE named years containing the years 2020–2024 using SELECT and UNION ALL, enabling analysis for every specified year, including years with no records.
2. here first it generates a row 2020 to years with column name "analysis_year"
3. with "union all" it generates new rows with years as values.
*/
registered AS (
    SELECT YEAR(account_since) AS analysis_year,
           COUNT(*) AS customers_registered
    FROM customers
    GROUP BY YEAR(account_since)
),
ordered AS (
    SELECT YEAR(order_date) AS analysis_year,
           COUNT(DISTINCT customer_id) AS customers_who_ordered
    FROM orders
    GROUP BY YEAR(order_date)
),
registered_and_ordered AS (
    SELECT YEAR(c.account_since) AS analysis_year,
           COUNT(DISTINCT c.customer_id) AS customers_registered_and_ordered
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
       AND YEAR(c.account_since) = YEAR(o.order_date)
    GROUP BY YEAR(c.account_since)
)
SELECT
    y.analysis_year,
    COALESCE(r.customers_registered, 0) AS customers_registered,
    COALESCE(o.customers_who_ordered, 0) AS customers_who_ordered,
    COALESCE(ro.customers_registered_and_ordered, 0)
        AS customers_registered_and_ordered
FROM years y
LEFT JOIN registered r
    ON y.analysis_year = r.analysis_year
LEFT JOIN ordered o
    ON y.analysis_year = o.analysis_year
LEFT JOIN registered_and_ordered ro
    ON y.analysis_year = ro.analysis_year
ORDER BY y.analysis_year;