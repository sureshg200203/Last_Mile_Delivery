-- 4.3 Evaluate Delivery Performance Business
-- Objective: The Operations team wants to understand how well deliveries are being completed. 

-- Compare delivery outcomes across different zones (zone information is on the orders table, so you will need to connect orders and deliveries).

select o.delivery_zone_id, count(d.delivery_id)
from deliveries d left join orders o on o.order_id = d.order_id
group by delivery_zone_id
order by delivery_zone_id;

select year(assigned_date) as "Year", 
count(delivery_id) as "no_of_deliveries", 
(count(delivery_id)/sum(count(delivery_id)) over())*100 as "Delivery_Share"
from deliveries group by Year;

select o.delivery_zone_id, 
sum(case when d.status = "Delivered" then 1 else 0 end) as Successful_Deliveries,
sum(case when d.status = "Failed" then 1 else 0 end) as Failed_Deliveries,
sum(case when d.status = "Rescheduled" then 1 else 0 end) as Rescheduled_Deliveries,
sum(case when d.status = "Pending" then 1 else 0 end) as Pending_Deliveries
from orders o join deliveries d on o.order_id = d.order_id
group by delivery_zone_id
order by delivery_zone_id;

select o.delivery_zone_id, 
round((sum(case when d.status = "Delivered" then 1 else 0 end)/count(*))*100, 4) as Successful_Deliveries_Rate,
round((sum(case when d.status = "Failed" then 1 else 0 end)/count(*))*100, 4) as Failed_Deliveries_Rate,
round((sum(case when d.status = "Rescheduled" then 1 else 0 end)/count(*))*100, 4) as Rescheduled_Deliveries_Rate,
round((sum(case when d.status = "Pending" then 1 else 0 end)/count(*))*100, 4)  as Pending_Deliveries_Rate
from orders o join deliveries d on o.order_id = d.order_id
group by delivery_zone_id
order by delivery_zone_id;

-- Examine delivery duration. 

-- 1. All deliveries duration analysis.
select max(delivery_duration_min) as "Maximum_Time_Taken", min(delivery_duration_min) as "Minimum_Time_Taken", avg(delivery_duration_min) as "Average_Time_Taken" from deliveries;

-- 2. Status wise delivery duration analysis.
select status, max(delivery_duration_min) as "Maximum_Time_Taken", min(delivery_duration_min) as "Minimum_Time_Taken", avg(delivery_duration_min) as "Average_Time_Taken" from deliveries group by status;

-- 3. Delivery Zone wise duration analysis.
select delivery_zone_id, 
max(d.delivery_duration_min) as "Maximum_Time_Taken", 
min(d.delivery_duration_min) as "Minimum_Time_Taken", 
avg(d.delivery_duration_min) as "Average_Time_Taken" 
from orders o left join deliveries d on o.order_id = d.order_id 
group by o.delivery_zone_id order by delivery_zone_id;

-- 4. Delivery Duration over time: Annual, Half-year, Quaterly.

-- Annual 
select year(assigned_date) as "Deliver_year", max(delivery_duration_min) as "Maximum_Time_Taken", min(delivery_duration_min) as "Minimum_Time_Taken", avg(delivery_duration_min) as "Average_Time_Taken" from deliveries group by Deliver_year;

-- Half-year analysis
select year(assigned_date) as "Deliver_year",
case 
when month(assigned_date) <= 6 then "H1"
else "H2"
end as "Category", 
max(delivery_duration_min) as "Maximum_Time_Taken", min(delivery_duration_min) as "Minimum_Time_Taken", avg(delivery_duration_min) as "Average_Time_Taken"
from deliveries group by Deliver_year, Category
order by Deliver_year, Category;

-- Quarterly Analysis
select year(assigned_date) as "Deliver_year",
case 
when month(assigned_date) <= 3 then "Q1"
when month(assigned_date) <= 6 then "Q2"
when month(assigned_date) <= 9 then "Q3"
else "Q4"
end as "Category", 
max(delivery_duration_min) as "Maximum_Time_Taken", min(delivery_duration_min) as "Minimum_Time_Taken", avg(delivery_duration_min) as "Average_Time_Taken"
from deliveries group by Deliver_year, Category
order by Deliver_year, Category;


-- Compare delivery outcomes by status (Delivered, Failed, Pending, Rescheduled) — these are not a simple success/failure split, so consider what each status actually represents.

-- 1. distribution over status
select status, count(*) as "No_of_deliveries" from deliveries group by status;
select status, 
count(*) as "No_of_deliveries", 
(count(*)/sum(count(*)) over()*100) as "Orders_Share"
from deliveries group by status;

-- 2. distribution over zones and status.
select o.delivery_zone_id, 
count(case when d.status = "Delivered" then 1 end) as "Delivered_orders",
count(case when d.status = "Failed" then 1 end) as "Failed_Orders",
count(case when d.status = "Rescheduled" then 1 end) as "Rescheduled_orders",
count(case when d.status = "Pending" then 1 end) as "Pending_orders"
from deliveries d join orders o on o.order_id = d.order_id group by o.delivery_zone_id order by o.delivery_zone_id;


--  Identify areas with higher delivery activity or poorer outcomes. 

-- 1. Status rate distribution over zones.
select o.delivery_zone_id, 
(count(case when d.status = "Delivered" then 1 end)/count(*))*100 as "Delivered_Rate",
(count(case when d.status = "Failed" then 1 end)/count(*))*100 as "Failure_Rate",
(count(case when d.status = "Rescheduled" then 1 end)/count(*))*100 as "Rescheduled_ Rate",
(count(case when d.status = "Pending" then 1 end) /count(*))*100 as "Pending_Rate"
from deliveries d join orders o on o.order_id = d.order_id group by o.delivery_zone_id order by o.delivery_zone_id;

-- 2. max and min rate zones in each status
-- `GROUP_CONCAT()` combines the delivery zone IDs into a single string if multiple zones share the highest rate.
create view status_rate as (select o.delivery_zone_id, 
(count(case when d.status = "Delivered" then 1 end)/count(*))*100 as "Delivered_Rate",
(count(case when d.status = "Failed" then 1 end)/count(*))*100 as "Failure_Rate",
(count(case when d.status = "Rescheduled" then 1 end)/count(*))*100 as "Rescheduled_Rate",
(count(case when d.status = "Pending" then 1 end) /count(*))*100 as "Pending_Rate"
from deliveries d join orders o on o.order_id = d.order_id group by o.delivery_zone_id order by o.delivery_zone_id);

select * from status_rate;

-- Max rate zone_ids
select 
(SELECT GROUP_CONCAT(delivery_zone_id)
     FROM status_rate
     WHERE Delivered_Rate = (SELECT MAX(Delivered_Rate) FROM status_rate)
    ) AS Highest_Delivered_Rate_Zones,

    (SELECT GROUP_CONCAT(delivery_zone_id)
     FROM status_rate
     WHERE Failure_Rate = (SELECT MAX(Failure_Rate) FROM status_rate)
    ) AS Highest_Failure_Rate_Zones,

    (SELECT GROUP_CONCAT(delivery_zone_id)
     FROM status_rate
     WHERE Rescheduled_Rate = (SELECT MAX(Rescheduled_Rate) FROM status_rate)
    ) AS Highest_Rescheduled_Rate_Zones,

    (SELECT GROUP_CONCAT(delivery_zone_id)
     FROM status_rate
     WHERE Pending_Rate = (SELECT MAX(Pending_Rate) FROM status_rate)
    ) AS Highest_Pending_Rate_Zones;

-- Min rate zone_ids
select 
(SELECT GROUP_CONCAT(delivery_zone_id)
     FROM status_rate
     WHERE Delivered_Rate = (SELECT min(Delivered_Rate) FROM status_rate)
    ) AS Lowest_Delivered_Rate_Zones,

    (SELECT GROUP_CONCAT(delivery_zone_id)
     FROM status_rate
     WHERE Failure_Rate = (SELECT min(Failure_Rate) FROM status_rate)
    ) AS Lowest_Failure_Rate_Zones,

    (SELECT GROUP_CONCAT(delivery_zone_id)
     FROM status_rate
     WHERE Rescheduled_Rate = (SELECT min(Rescheduled_Rate) FROM status_rate)
    ) AS Lowest_Rescheduled_Rate_Zones,

    (SELECT GROUP_CONCAT(delivery_zone_id)
     FROM status_rate
     WHERE Pending_Rate = (SELECT min(Pending_Rate) FROM status_rate)
    ) AS Lowest_Pending_Rate_Zones;
    
-- Compare delivery performance over time.

-- Year and status wise deliveries
select year(assigned_date) as "Year", status, count(status) as "Order_count", sum(count(status)) over(partition by year(assigned_date)) as "Year_count" from deliveries group by Year, status order by Year, status;

-- Year Wise and status wise performance_rate
create view Year_Performance_Rate as (select year, status, round((Order_count/Year_count)*100, 4) as "Performance_Rate" from (select year(assigned_date) as "Year", status, count(status) as "Order_count", sum(count(status)) over(partition by year(assigned_date)) as "Year_count" from deliveries group by Year, status) as Year_Performance);
select * from Year_Performance_Rate order by year, status;
-- round() will helps to make comparision better in later queries as comparing decimal values may result error becuase of internal decimal value precision even though the values looks identical. TO understand drop and modify the view without round().

-- It returns the year with maximum performance rate of each status
select * 
from Year_Performance_Rate
where (status, Performance_Rate) in (select status, max(Performance_Rate) from Year_Performance_Rate group by status);

-- It returns the year with minimum performance rate of each status
SELECT year, status, Performance_Rate
FROM Year_Performance_Rate y
WHERE Performance_Rate = (
    SELECT min(x.Performance_Rate)
    FROM Year_Performance_Rate x
    WHERE x.status = y.status
);