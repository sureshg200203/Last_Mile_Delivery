-- Counts the number of customers in each preferred time slot.
select preferred_time_slot, count(*) from customers group by preferred_time_slot;

-- Calculates each preferred time slot’s share of all customers as a percentage, using a subquery for the total customer count.
select preferred_time_slot, round((count(*)/(select count(*) from customers))*100, 4) from customers group by preferred_time_slot;


-- Counts delivery records by status (Delivered, Failed, Rescheduled, Pending) for each customer preferred time slot.
select c.preferred_time_slot, 
count(case when d.status = "Delivered" then 1 end) as "Delivered",
count(case when d.status = "Failed" then 1 end) as "Failed",
count(case when d.status = "Rescheduled" then 1 end) as "Rescheduled",
count(case when d.status = "Pending" then 1 end) as "Pending"
from deliveries d left join orders o on d.order_id = o.order_id join customers c on o.customer_id = c.customer_id group by c.preferred_time_slot;

-- Counts delivery records by attempt number (1, 2 or 3 attempts) for each preferred time slot.
select c.preferred_time_slot, 
count(case when d.delivery_attempt = 1 then 1 end) as "single_attempt",
count(case when d.delivery_attempt = 2 then 1 end) as "Two_attempts",
count(case when d.delivery_attempt = 3 then 1 end) as "Three_attempts"
from deliveries d left join orders o on d.order_id = o.order_id join customers c on o.customer_id = c.customer_id group by c.preferred_time_slot;

-- Splits records into single and multiple attempts and counts each delivery status for every time slot, ordered Morning, Afternoon, Evening, Any.
select c.preferred_time_slot, 
case when d.delivery_attempt = 1 then "Single_Attempt" else "Multiple_Attempt" end as "Attempt_type",
count(case when d.status = "Delivered" then 1 end) as "Delivered",
count(case when d.status = "Failed" then 1 end) as "Failed",
count(case when d.status = "Rescheduled" then 1 end) as "Rescheduled",
count(case when d.status = "Pending" then 1 end) as "Pending"
from deliveries d left join orders o on d.order_id = o.order_id join customers c on o.customer_id = c.customer_id group by c.preferred_time_slot, Attempt_type
order by 
case c.preferred_time_slot
when "Morning (8-12)" then 1
when "Afternoon (12-17)" then 2
when "Evening (17-21)" then 3
when "Any" then 4 end;

-- For each delivery zone, shows the count of records by preferred time slot and by delivery status.
select c.delivery_zone_id, 
count(case when preferred_time_slot = "Morning (8-12)" then 1 end) as "Morning_slot",
count(case when preferred_time_slot = "Afternoon (12-17)" then 1 end) as "Afternoon_slot",
count(case when preferred_time_slot = "Evening (17-21)" then 1 end) as "Evening_slot",
count(case when preferred_time_slot = "Any" then 1 end) as "Any_slot",
count(case when d.status = "Delivered" then 1 end) as "Delivered",
count(case when d.status = "Failed" then 1 end) as "Failed",
count(case when d.status = "Rescheduled" then 1 end) as "Rescheduled",
count(case when d.status = "Pending" then 1 end) as "Pending"
from deliveries d left join orders o on d.order_id = o.order_id join customers c on o.customer_id = c.customer_id group by c.delivery_zone_id order by c.delivery_zone_id;

-- For each delivery zone, shows the percentage mix of preferred time slots and the percentage rate for each delivery status.
select c.delivery_zone_id, 
round((count(case when preferred_time_slot = "Morning (8-12)" then 1 end)/count(c.preferred_time_slot))*100, 4) as "Morning_slot",
round((count(case when preferred_time_slot = "Afternoon (12-17)" then 1 end)/count(c.preferred_time_slot))*100, 4) as "Afternoon_slot",
round((count(case when preferred_time_slot = "Evening (17-21)" then 1 end)/count(c.preferred_time_slot))*100, 4) as "Evening_slot",
round((count(case when preferred_time_slot = "Any" then 1 end)/count(c.preferred_time_slot))*100, 4) as "Any_slot",
round((count(case when d.status = "Delivered" then 1 end)/count(d.delivery_id))*100, 4) as "Delivered_rate",
round((count(case when d.status = "Failed" then 1 end)/count(d.delivery_id))*100, 4) as "Failed_rate",
round((count(case when d.status = "Rescheduled" then 1 end)/count(d.delivery_id))*100, 4) as "Rescheduled_rate",
round((count(case when d.status = "Pending" then 1 end)/count(d.delivery_id))*100, 4) as "Pending_rate"
from deliveries d left join orders o on d.order_id = o.order_id join customers c on o.customer_id = c.customer_id group by c.delivery_zone_id order by c.delivery_zone_id;
