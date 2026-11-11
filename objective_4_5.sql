-- 4.5 Identify Delivery Problems

-- Examine which deliveries required multiple attempts before succeeding. 

-- Calculates the total delivery records and percentage share of each delivery status out of all delivery records.
select status, 
count(delivery_attempt) as "Delivery_Share", 
round((count(delivery_attempt)/(select count(*) from deliveries))*100, 4) as "Order_Rate"
from deliveries group by status;

-- Calculates the total delivery records and percentage share based on number of delivery attempts out of all delivery records.
select delivery_attempt, 
count(delivery_id) as "Delivery_Share", 
round((count(delivery_id)/(select count(*) from deliveries))*100, 4) as "Order_Rate"
from deliveries group by delivery_attempt;

-- Calculates the number and percentage of deliveries in each status (Delivered, Failed, Pending, and Rescheduled) for every delivery attempt number.
select d1.delivery_attempt, d1.status,
count(d1.delivery_id) as "Delivery_Share",
round((count(d1.delivery_id)/(select count(d2.delivery_id) from deliveries d2 where d1.delivery_attempt = d2.delivery_attempt))*100, 4) as "Share"
from deliveries d1 group by delivery_attempt, status
order by delivery_attempt, status;

-- Calculates the number of successful deliveries for each attempt number and their percentage of all successful delivery records.
select delivery_attempt, 
count(delivery_id) as "Delivered_orders",
round((count(delivery_id)/(select count(delivery_id) from deliveries where status = "Delivered"))*100,4) as "Attempt_wise_Delivered_Rate"
from deliveries where status = "Delivered" group by delivery_attempt;

select
case when delivery_attempt = 1 then "First_Attempt" else "Multiple_Attempt" end as Attempt_Category,
    COUNT(*) AS Total_Orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) over (),
        4
    ) as Percentage
from deliveries where status = "Delivered" group by Attempt_Category;

-- Identify common delivery statuses and problem patterns. 

-- status vs distance_km
select status, avg(distance_km) from deliveries group by status;

-- status vs delivery_duration_min
select status, avg(delivery_duration_min) from deliveries group by status;

-- status vs package_weight_kg
select dl.status, avg(o.package_weight_kg) from deliveries dl join orders o on dl.order_id = o.order_id group by status;

-- delivery_attempt vs distance_km
select delivery_attempt, avg(distance_km) from deliveries group by delivery_attempt;

-- delivery_attempt vs delivery_duration_min
select delivery_attempt, avg(delivery_duration_min) from deliveries group by delivery_attempt;

-- delivery_attempt vs package_weight_kg
select dl.delivery_attempt, avg(o.package_weight_kg) from deliveries dl join orders o on dl.order_id = o.order_id group by delivery_attempt;

-- Compare delivery performance for orders with multiple attempts. 

-- first attempt vs multiple attempts for delivered
select
case when delivery_attempt = 1 then "First_Attempt" else "Multiple_Attempt" end as Attempt_Category,
    COUNT(*) AS Total_Orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) over (),
        4
    ) as Percentage
from deliveries where status = "Delivered" group by Attempt_Category order by Attempt_Category;

-- first attempt vs multiple attempts for failed
select
case when delivery_attempt = 1 then "First_Attempt" else "Multiple_Attempt" end as Attempt_Category,
    COUNT(*) AS Total_Orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) over (),
        4
    ) as Percentage
from deliveries where status = "Failed" group by Attempt_Category order by Attempt_Category;

-- first attempt vs multiple attempts for Rescheduled
select
case when delivery_attempt = 1 then "First_Attempt" else "Multiple_Attempt" end as Attempt_Category,
    COUNT(*) AS Total_Orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) over (),
        4
    ) as Percentage
from deliveries where status = "Rescheduled" group by Attempt_Category order by Attempt_Category;

-- first attempt vs multiple attempts for delivered
select
case when delivery_attempt = 1 then "First_Attempt" else "Multiple_Attempt" end as Attempt_Category,
    COUNT(*) AS Total_Orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) over (),
        4
    ) as Percentage
from deliveries where status = "Pending" group by Attempt_Category order by Attempt_Category;

-- Analyzed first-attempt and multiple-attempt deliveries across all four delivery statuses, comparing their counts and percentage shares of total delivery records.
SELECT
    status,
    COUNT(CASE WHEN delivery_attempt = 1 THEN 1 END) AS First_Attempt,
    COUNT(CASE WHEN delivery_attempt > 1 THEN 1 END) AS Multiple_Attempt,
    COUNT(*) AS Total_Deliveries,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 4) AS Percentage
FROM deliveries
GROUP BY status;


-- Examine whether certain zones experience more delivery problems. 

-- Analyzed the number and percentage of Delivered, Failed, Pending, and Rescheduled deliveries across each delivery zone to identify zones with higher delivery success and failure rates.
select o.delivery_zone_id,
count(case when status = "Delivered" then 1 end) as "Delivered",
count(case when status = "Failed" then 1 end) as "Failed",
count(case when status = "Pending" then 1 end) as "Pending",
count(case when status = "Rescheduled" then 1 end) as "Rescheduled",
round((count(case when status = "Delivered" then 1 end)/count(dl.delivery_id))*100, 4) as "Delivered_Rate",
round((count(case when status = "Failed" then 1 end)/count(dl.delivery_id))*100, 4) as "Failed_Rate",
round((count(case when status = "Pending" then 1 end)/count(dl.delivery_id))*100, 4) as "Pending_Rate",
round((count(case when status = "Rescheduled" then 1 end)/count(dl.delivery_id))*100, 4) as "Rescheduled_Rate"
from orders o left join deliveries dl on o.order_id = dl.order_id group by o.delivery_zone_id order by o.delivery_zone_id;

-- Compared successful deliveries against deliveries with other statuses across each zone to evaluate overall delivery success and problem rates.
select o.delivery_zone_id,
count(case when status = "Delivered" then 1 end) as "Successful",
count(case when status != "Delivered" then 1 end) as "Problems",
round((count(case when status = "Delivered" then 1 end)/count(dl.delivery_id))*100,4) as "Success_Rate",
round((count(case when status != "Delivered" then 1 end)/count(dl.delivery_id))*100,4) as "Problem_Rate" 
from orders o left join deliveries dl on o.order_id = dl.order_id group by o.delivery_zone_id order by problems desc;

