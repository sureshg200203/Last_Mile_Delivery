-- SPRINT-3: Basic Analysis/ Data Exploration

-- 1. What is the total number of customers? 
select count(*) as "Total Customers" from customers;

-- 2. What is the total number of orders? 
select count(*) as "Total number of Orders" from orders;

-- 3. What is the total number of deliveries?
select count(*) as "Total number of Deliveries" from deliveries;

-- 4. What are the different service types available? 
select distinct(service_type) as "Types of Services" from orders;

-- 5. How many drivers are currently active?
select count(*) as "Total Active Drivers" from drivers where is_active = "Yes";

-- 6. What are the different vehicle types? 
select distinct(vehicle_type) as "Types of Vehicles" from vehicles;

-- 7. What is the total order value? 
select sum(total_value) as "Total Orders Value" from orders;

-- 8. What is the average package weight? 
select avg(package_weight_kg) as "Average Package Weight" from orders;