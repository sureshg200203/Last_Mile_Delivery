-- 4.4 Understand Driver and Vehicle Performance

-- 1. Compare the number of deliveries handled by drivers.

-- drivers vs no.of deliveries
select 
d.driver_id, d.driver_name, coalesce(count(dl.delivery_id), 0)  as "No_of_deliveries"
from drivers d left join deliveries dl on d.driver_id = dl.driver_id 
group by d.driver_id order by No_of_deliveries desc;

select round(avg(No_of_deliveries)) from (select 
d.driver_id, d.driver_name, coalesce(count(dl.delivery_id), 0)  as "No_of_deliveries"
from drivers d left join deliveries dl on d.driver_id = dl.driver_id 
group by d.driver_id order by No_of_deliveries desc) as orders_count;

-- active drivers vs no of deliveries
select 
d.is_active, coalesce(count(dl.delivery_id), 0)  as "No_of_deliveries"
from drivers d left join deliveries dl on d.driver_id = dl.driver_id 
group by d.is_active
ORDER BY No_of_deliveries DESC;

-- months vs no.of deliveries
select 
d.driver_id, d.driver_name, coalesce(count(dl.delivery_id), 0)  as "No_of_deliveries", 
timestampdiff(month, min(dl.assigned_date), max(dl.assigned_date)) as "Months",
count(dl.delivery_id)/timestampdiff(month, min(dl.assigned_date), max(dl.assigned_date)) as "Deliveries_per_month"
from deliveries dl left join drivers d on d.driver_id = dl.driver_id 
group by d.driver_id order by driver_id;


-- 2. Compare driver performance across delivery outcomes.

select distinct employment_type from drivers;
select d.employment_type , 
count(dl.delivery_id),
round((count(dl.delivery_id)/(select count(*) from deliveries))*100, 4) as "Order_Share",
count(case when dl.status = "Delivered" then 1 end) as "Delivered",
count(case when dl.status = "Failed" then 1 end) as "Failed",
count(case when dl.status = "Rescheduled" then 1 end) as "Rescheduled",
count(case when dl.status = "Pending" then 1 end) as "Pending",
round((count(case when dl.status = "Delivered" then 1 end)/count(dl.delivery_id))*100, 4) as "Delivered_Rate",
round((count(case when dl.status = "Failed" then 1 end)/count(dl.delivery_id))*100, 4) as "Failed_Rate",
round((count(case when dl.status = "Rescheduled" then 1 end)/count(dl.delivery_id))*100, 4) as "Rescheduled_Rate",
round((count(case when dl.status = "Pending" then 1 end)/count(dl.delivery_id))*100, 4) as "Pending_Rate"
from deliveries dl left join drivers d on dl.driver_id = d.driver_id group by d.employment_type
order by
case d.employment_type
when "Full-time" then 1
when "Contract" then 2
when "Part-time" then 3 end;
 
-- maximum and minimum deliveries of each status
create view drive_analysis as (select 
d.driver_id, d.driver_name,
coalesce(count(dl.delivery_id), 0)  as "No_of_deliveries",
count(case when dl.status = "Delivered" then 1 end) as "Delivered",
count(case when dl.status = "Failed" then 1 end) as "Failed",
count(case when dl.status = "Rescheduled" then 1 end) as "Rescheduled",
count(case when dl.status = "Pending" then 1 end) as "Pending",
round((count(case when dl.status = "Delivered" then 1 end)/count(dl.delivery_id))*100, 4) as "Delivered_Rate",
round((count(case when dl.status = "Failed" then 1 end)/count(dl.delivery_id))*100, 4) as "Failed_Rate",
round((count(case when dl.status = "Rescheduled" then 1 end)/count(dl.delivery_id))*100, 4) as "Rescheduled_Rate",
round((count(case when dl.status = "Pending" then 1 end)/count(dl.delivery_id))*100, 4) as "Pending_Rate"
from deliveries dl left join drivers d on d.driver_id = dl.driver_id 
group by d.driver_id);

select * from drive_analysis order by No_of_deliveries;
 
 -- maximum
select driver_id, driver_name, Delivered from drive_analysis where Delivered = (select max(Delivered) from drive_analysis);
select driver_id, driver_name, Failed from drive_analysis where Failed = (select max(Failed) from drive_analysis);
select driver_id, driver_name, Pending from drive_analysis where pending = (select max(Pending) from drive_analysis);
select driver_id, driver_name, Rescheduled from drive_analysis where Rescheduled = (select max(Rescheduled) from drive_analysis);
select driver_id, driver_name, Delivered_Rate from drive_analysis where Delivered_Rate = (select max(Delivered_Rate) from drive_analysis);
select driver_id, driver_name, Failed_Rate from drive_analysis where Failed_Rate = (select max(Failed_Rate) from drive_analysis);
select driver_id, driver_name, Pending_Rate from drive_analysis where pending_Rate = (select max(Pending_Rate) from drive_analysis);
select driver_id, driver_name, Rescheduled_Rate from drive_analysis where Rescheduled_Rate = (select max(Rescheduled_Rate) from drive_analysis);

-- minimum
select driver_id, driver_name, Delivered from drive_analysis where Delivered = (select min(Delivered) from drive_analysis);
select driver_id, driver_name, Failed from drive_analysis where Failed = (select min(Failed) from drive_analysis);
select driver_id, driver_name, Pending from drive_analysis where pending = (select min(Pending) from drive_analysis);
select driver_id, driver_name, Rescheduled from drive_analysis where Rescheduled = (select min(Rescheduled) from drive_analysis);
select driver_id, driver_name, Delivered_Rate from drive_analysis where Delivered_Rate = (select min(Delivered_Rate) from drive_analysis);
select driver_id, driver_name, Failed_Rate from drive_analysis where Failed_Rate = (select min(Failed_Rate) from drive_analysis);
select driver_id, driver_name, Pending_Rate from drive_analysis where pending_Rate = (select min(Pending_Rate) from drive_analysis);
select driver_id, driver_name, Rescheduled_Rate from drive_analysis where Rescheduled_Rate = (select min(Rescheduled_Rate) from drive_analysis);

-- Examine delivery duration across drivers. 

-- driver delivery duration analysis
select dl.driver_id, d.driver_name, 
max(delivery_duration_min) as "Maximum_duration",
min(delivery_duration_min)as "Minimum_duration", 
avg(delivery_duration_min) as "Average_duration",
avg(distance_km) as "Average_distance"
from deliveries dl join drivers d on dl.driver_id = d.driver_id group by driver_id order by driver_id;

select dl.driver_id, d.driver_name, 
max(distance_km) as "Maximum_distance",
min(distance_km)as "Minimum_distance", 
avg(distance_km) as "Average_distance" 
from deliveries dl join drivers d on dl.driver_id = d.driver_id group by driver_id order by driver_id;

-- driver vs delivered_duration analysis
select dl.driver_id, d.driver_name, max(delivery_duration_min) as "Delivered_Max_duration", min(delivery_duration_min)as "Delivered_Min_duration", avg(delivery_duration_min) as "Delivered_Avg_duration" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Delivered" group by driver_id;

select dl.driver_id, d.driver_name, max(distance_km) as "Delivered_Max_distance", min(distance_km)as "Delivered_Min_distance", avg(distance_km) as "Delivered_Avg_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Delivered" group by driver_id;

-- driver vs failed_duration analysis
select dl.driver_id, d.driver_name, max(delivery_duration_min) as "Failed_Max_duration", min(delivery_duration_min)as "Failed_Min_duration", avg(delivery_duration_min) as "Failed_Avg_duration" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Failed" group by driver_id;

select dl.driver_id, d.driver_name, max(distance_km) as "Failed_Max_distance", min(distance_km)as "Failed_Min_distance", avg(distance_km) as "Failed_Avg_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Failed" group by driver_id;

-- driver vs Pending_duration analysis
select dl.driver_id, d.driver_name, max(delivery_duration_min) as "Pending_Max_duration", min(delivery_duration_min)as "Pending_Min_duration", avg(delivery_duration_min) as "Pending_Avg_duration" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Pending" group by driver_id;

select dl.driver_id, d.driver_name, max(distance_km) as "Pending_Max_distance", min(distance_km)as "Pending_Min_distance", avg(distance_km) as "Pending_Avg_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Pending" group by driver_id;

-- driver vs Rescheduled_duration analysis
select dl.driver_id, d.driver_name, max(delivery_duration_min) as "Rescheduled_Max_duration", min(delivery_duration_min)as "Rescheduled_Min_duration", avg(delivery_duration_min) as "Rescheduled_Avg_duration" from deliveries  dl join drivers d on dl.driver_id = d.driver_id where status = "Rescheduled" group by driver_id;

select dl.driver_id, d.driver_name, max(distance_km) as "Rescheduled_Max_distance", min(distance_km)as "Rescheduled_Min_distance", avg(distance_km) as "Rescheduled_Avg_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Rescheduled" group by driver_id;

-- driver analysis with the distance of each delivery

-- overall driver vs distance analysis
select dl.driver_id, d.driver_name, max(distance_km) as "Maximum_distance", min(distance_km)as "Minimum_distance", avg(distance_km) as "Average_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id group by driver_id;

-- driver vs delivered_duration analysis
select dl.driver_id, d.driver_name, max(distance_km) as "Delivered_Max_distance", min(distance_km)as "Delivered_Min_distance", avg(distance_km) as "Delivered_Avg_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Delivered" group by driver_id;

-- driver vs failed_duration analysis
select dl.driver_id, d.driver_name, max(distance_km) as "Failed_Max_distance", min(distance_km)as "Failed_Min_distance", avg(distance_km) as "Failed_Avg_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Failed" group by driver_id;

-- driver vs Pending_distance analysis
select dl.driver_id, d.driver_name, max(distance_km) as "Pending_Max_distance", min(distance_km)as "Pending_Min_distance", avg(distance_km) as "Pending_Avg_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Pending" group by driver_id;

-- driver vs Rescheduled_distance analysis
select dl.driver_id, d.driver_name, max(delivery_duration_min) as "Rescheduled_Max_distance", min(delivery_duration_min)as "Rescheduled_Min_distance", avg(delivery_duration_min) as "Rescheduled_Avg_distance" from deliveries dl join drivers d on dl.driver_id = d.driver_id where status = "Rescheduled" group by driver_id;


-- 4. Compare vehicle usage across different vehicle types. 

select depot, count(vehicle_id) from vehicles group by depot;

select depot, vehicle_type, count(vehicle_id) from vehicles group by depot, vehicle_type order by depot, vehicle_type;

select v.vehicle_type, count(dl.delivery_id) as "Total_Deliveries", avg(o.package_weight_kg) as "Avg_pkg_weight" from deliveries dl join vehicles v on dl.vehicle_id = v.vehicle_id join orders o on o.order_id = dl.order_id group by v.vehicle_type;

select v.fuel_type, count(dl.delivery_id) as "Total_Deliveries", avg(o.package_weight_kg) as "Avg_pkg_weight" from deliveries dl join vehicles v on dl.vehicle_id = v.vehicle_id join orders o on o.order_id = dl.order_id group by v.fuel_type;

select v.vehicle_id, count(dl.delivery_id) as "Total_Deliveries", avg(o.package_weight_kg) as "Avg_pkg_weight" from deliveries dl join vehicles v on dl.vehicle_id = v.vehicle_id join orders o on o.order_id = dl.order_id group by v.vehicle_id;

-- payload analysis based on vehicle types
select vehicle_type, max(max_payload_kg), min(max_payload_kg), avg(max_payload_kg) from vehicles group by vehicle_type;

-- payload analysis based on fuel types
select fuel_type, max(max_payload_kg), min(max_payload_kg), avg(max_payload_kg) from vehicles group by fuel_type;


-- 5. Look at delivery performance across different vehicles.
select v.vehicle_type, 
count(dl.delivery_id) as "Total_Deliveries",
count(case when dl.status = "Delivered" then 1 end) as "Delivered",
count(case when dl.status = "Failed" then 1 end) as "Failed",
count(case when dl.status = "Pending" then 1 end) as "Pending",
count(case when dl.status = "Rescheduled" then 1 end) as "Rescheduled",
round((count(case when dl.status = "Delivered" then 1 end)/count(*))*100, 4) as "Delivered_Rate",
round(count(case when dl.status = "Failed" then 1 end)/count(*)*100, 4) as "Failed_Rate",
round(count(case when dl.status = "Pending" then 1 end)/count(*)*100, 4) as "Pending_Rate",
round(count(case when dl.status = "Rescheduled" then 1 end)/count(*)*100, 4) as "Rescheduled_Rate"
from deliveries dl join vehicles v on dl.vehicle_id = v.vehicle_id group by v.vehicle_type;

select v.fuel_type, 
count(dl.delivery_id) as "Total_Deliveries",
count(case when dl.status = "Delivered" then 1 end) as "Delivered",
count(case when dl.status = "Failed" then 1 end) as "Failed",
count(case when dl.status = "Pending" then 1 end) as "Pending",
count(case when dl.status = "Rescheduled" then 1 end) as "Rescheduled",
round((count(case when dl.status = "Delivered" then 1 end)/count(*))*100, 4) as "Delivered_Rate",
round(count(case when dl.status = "Failed" then 1 end)/count(*)*100, 4) as "Failed_Rate",
round(count(case when dl.status = "Pending" then 1 end)/count(*)*100, 4) as "Pending_Rate",
round(count(case when dl.status = "Rescheduled" then 1 end)/count(*)*100, 4) as "Rescheduled_Rate"
from deliveries dl join vehicles v on dl.vehicle_id = v.vehicle_id group by v.fuel_type;

select v.vehicle_id, 
count(dl.delivery_id) as "Total_Deliveries",
count(case when dl.status = "Delivered" then 1 end) as "Delivered",
count(case when dl.status = "Failed" then 1 end) as "Failed",
count(case when dl.status = "Pending" then 1 end) as "Pending",
count(case when dl.status = "Rescheduled" then 1 end) as "Rescheduled",
round((count(case when dl.status = "Delivered" then 1 end)/count(*))*100, 4) as "Delivered_Rate",
round(count(case when dl.status = "Failed" then 1 end)/count(*)*100, 4) as "Failed_Rate",
round(count(case when dl.status = "Pending" then 1 end)/count(*)*100, 4) as "Pending_Rate",
round(count(case when dl.status = "Rescheduled" then 1 end)/count(*)*100, 4) as "Rescheduled_Rate"
from deliveries dl join vehicles v on dl.vehicle_id = v.vehicle_id group by v.vehicle_id;