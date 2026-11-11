-- 4.1 Understand Delivery Demand

-- 1. Compare the number of orders across delivery zones.
select delivery_zone_id, count(*)as "No_of_Orders", 
round((count(*)/(select count(*) from orders))*100,2) as "orders_percentage",
sum(total_value) 
from orders group by delivery_zone_id order by orders_percentage desc;
select delivery_zone_id, count(*)as "No_of_Orders", sum(total_value) from orders group by delivery_zone_id order by No_of_Orders limit 1;
select delivery_zone_id, count(*)as "No_of_Orders", sum(total_value) from orders group by delivery_zone_id order by No_of_Orders desc limit 1;
select delivery_zone_id, count(*)as "No_of_Orders", sum(total_value) as "Whole" from orders group by delivery_zone_id order by Whole limit 1;
select delivery_zone_id, count(*)as "No_of_Orders", sum(total_value) as "Whole" from orders group by delivery_zone_id order by Whole desc limit 1;

-- 2. Compare orders across different service types. 
select service_type, count(*) as "No_of_Orders", sum(total_value) as "total_amount" from orders group by service_type order by No_of_Orders desc;

-- 3. Compare orders based on priority. 
select priority, count(*)as "No_of_Orders", sum(total_value) as "total_amount" from orders group by priority order by No_of_Orders desc;

-- 4. Examine how order volume changes over time.
-- year wise analysis
select year(order_date) as "Each_year", count(*) as "no_of_orders", sum(total_value) as "Total_Gross", avg(total_value) as "Average_order_value" from orders group by Each_Year order by Each_Year;

-- half year analaysis
select year(order_date) as order_year,
case 
when month(order_date) <= 6 then "H1"
else "H2"
end as "Category", 
count(*) as "Total_Orders",
sum(total_value) as "Total_Gross",
avg(total_value) as "Average_order_value"
from orders group by order_year, Category
order by order_year, Category;

-- Quarterly Analysis
select year(order_date) as order_year,
case 
when month(order_date) <= 3 then "Q1"
when month(order_date) <= 6 then "Q2"
when month(order_date) <= 9 then "Q3"
else "Q4"
end as "Category", 
count(*) as "Total_Orders",
sum(total_value) as "Total_Gross",
avg(total_value) as "Average_order_value"
from orders group by order_year, Category
order by order_year, Category;

-- 5. Look at order value across different groups.
select service_type, sum(total_value), avg(total_value) from orders group by service_type;
select priority, sum(total_value), avg(total_value) from orders group by priority;

-- How does the distribution of orders across different priority levels change year by year
select year(order_date) as "order_year", 
priority, 
count(*) as "No_of_Orders",
round((count(*)/(select count(*) from orders o where year(o.order_date) = order_year))*100,2) as "Percentage_of_year", -- here, "No_of_Orders" instead of count(*) can be used but in same select alias name can't be used in same query but cna be with subquery.
sum(total_value) as "Sum_Total_Value", 
avg(total_value) as "Average_value" 
from orders
group by order_year, priority 
order by order_year,
case Priority
when "High" then 1
when "Urgent" then 2
when "Normal" then 3
end;

-- How does the distribution of orders across different service types change year by year
select year(order_date) as "order_year", 
service_type, 
count(*) as "No_of_Orders", 
round((count(*)/(select count(*) from orders o where year(o.order_date) = order_year))*100,2) as "Percentage_of_year",
sum(total_value) as "Sum_Total_Value", 
avg(total_value) as "Average_value" 
from orders 
group by order_year, service_type 
order by order_year,
case service_type
when "Same Day" then 1
when "Next Day" then 2
when "Express" then 3
when "Economy" then 4
when "Standard" then 5
end;