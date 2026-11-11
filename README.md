# Last_Mile_Delivery

A MySQL-based business analytics project that analyses delivery demand, customer ordering behaviour, delivery performance, driver and vehicle performance, and delivery problems for QuickRoute Logistics, a last-mile delivery company. The project turns raw operational data into business insights and practical recommendations.

Completed as part of the learning programme at Innomatics Research Labs.

## Table of Contents
- [Project Overview](#project-overview)
- [Business Scenario](#business-scenario)
- [Business Objectives](#business-objectives)
- [Dataset and Database](#dataset-and-database)
- [ER Diagram and Relationships](#er-diagram-and-relationships)
- [Tools and Technologies](#tools-and-technologies)
- [Key Findings](#key-findings)
- [Business Recommendations](#business-recommendations)
- [Repository Structure](#repository-structure)
- [How to Run](#how-to-run)
- [Team](#team)
- [Acknowledgements](#acknowledgements)

---

## Project Overview
This project uses data from five related tables (customers, orders, deliveries, drivers and vehicles) to analyse business patterns, evaluate delivery performance, understand resource utilisation and draw meaningful insights using SQL.

## Business Scenario
QuickRoute Logistics is a last-mile delivery company that moves orders from distribution points to customers through its fleet of vehicles and team of drivers. The company handles orders across multiple delivery zones and needs to monitor its operations, understand delivery performance and identify areas for improvement.

## Business Objectives
* **Understand Delivery Demand:** how orders are distributed across zones, service types, time periods and priority levels
* **Understand Customer Order Behaviour:** ordering frequency, spending, customer segments and registration trends
* **Evaluate Delivery Performance:** delivery status, success rates, duration and trends across zones and years
* **Understand Driver and Vehicle Performance:** performance by employment type, driver, vehicle type, fuel type and individual vehicle
* **Identify Delivery Problems:** failed, pending and rescheduled deliveries, repeat attempts and problem hotspots by zone and time slot

## Dataset and Database
The database contains five tables:

| Table | Records | Columns | Description |
|---|---|---|---|
| **customers** | 400 | 7 | Customer name, city, delivery zone, preferred time slot, customer type, account creation date |
| **orders** | 3,000 | 8 | Customer, order date, delivery zone, package weight, service type, priority, total order value |
| **deliveries** | 3,500 | 10 | Order, driver, vehicle, assigned and actual delivery date, status, attempts, distance, duration |
| **drivers** | 80 | 6 | Driver name, hire date, rating, employment type, active status |
| **vehicles** | 50 | 7 | Vehicle type, fuel type, maximum payload, depot, last service date, active status |

> **Note:** `actual_delivery_date` is empty for deliveries with a status of Failed, Pending or Rescheduled, because the delivery has not been completed.

## ER Diagram and Relationships

| Relationship | Type | Description |
|---|---|---|
| **Customers to Orders** | 1:M | A customer can place many orders, but each order belongs to one customer |
| **Orders to Deliveries** | 1:M | An order can have multiple delivery attempts, and each delivery record belongs to one order |
| **Drivers to Deliveries** | 1:M | A driver can handle many delivery records, and each record has one driver |
| **Vehicles to Deliveries** | 1:M | A vehicle can be used for many delivery records, and each record has one vehicle |
| **Orders to Drivers** | M:N | Through the Deliveries table |
| **Orders to Vehicles** | M:N | Through the Deliveries table |

### Keys
* **customers:** Primary Key: `customer_id` | Foreign Keys: None
* **orders:** Primary Key: `order_id` | Foreign Keys: `customer_id`
* **deliveries:** Primary Key: `delivery_id` | Foreign Keys: `order_id`, `driver_id`, `vehicle_id`
* **drivers:** Primary Key: `driver_id` | Foreign Keys: None
* **vehicles:** Primary Key: `vehicle_id` | Foreign Keys: None

*The ER diagram is available in the presentation (`Last_Mile_Delivery.pptx`) and in the project documentation file.*

## Tools and Technologies
* **MySQL** for database design, data import and analysis
* **SQL** for querying, aggregation and business analysis
* **Microsoft PowerPoint** for presenting the findings

## Key Findings

### Demand and Customers
* Order volume and value rose from 2022 to a peak in 2024, and the second half of each year consistently had more orders.
* High- and Urgent-priority orders increased every year, while Normal-priority orders fell from 2023 to 2024.
* **ZONE0005** led in orders (240) and order value (₹5,89,285.70).
* **Standard** service had the most orders (620), **Next Day** the highest total value, and **Same Day** the highest average value.
* Individual customers generated 2,050 orders worth about ₹50.78 lakh, against 950 orders worth about ₹24.44 lakh from business customers.

### Delivery Reliability
* Only **73.74%** of 3,500 deliveries were successful, and **26.26%** were Pending, Failed or Rescheduled.
* Success rate fell from 75.72% in 2023 to 71.24% in 2024, even though average delivery duration improved by about 3.75% since 2022.
* **ZONE0010** had the best success rate (79.33%) and **ZONE0020** the lowest (68.33%).
* Each problem type has its own hotspot: failures in **ZONE0003**, rescheduling in **ZONE0016**, and pending deliveries in **ZONE0008**.

### Drivers and Vehicles
* Success rates were similar across employment types (73% to 75%), but varied widely between individual drivers (55.32% to 89.66%).
* Electric vehicles had a higher success rate than Petrol vehicles (74.57% vs 72.10%), though Electric Vans had the highest failure rate (9.82%).
* Individual vehicles varied the most, from **VEH0010** (82.19% success) to **VEH0027** (61.04%).

### Delivery Problems
* Distance, duration and package weight were lowest for first-attempt deliveries and highest for third attempts.
* **95.20%** of successful deliveries were completed on the first attempt.
* Morning (8 to 12) had the highest failure rate (10.31%).

> **Data note:** Only 5 records fall in 2025, so the analysis rests mainly on 2022 to 2024 data.

## Business Recommendations
1. Target the weakest zones, starting with **ZONE0020**, and fix each zone's specific issue.
2. Reverse the 2024 decline in success rate by targeting at least 75.72% and adding SMS or app confirmation before dispatch.
3. Manage drivers actively through coaching, shared best practices and balanced workloads.
4. Optimise vehicle allocation by reviewing weak vehicles and shifting suitable routes to Electric vehicles.
5. Handle long-distance and heavy orders better by flagging them at dispatch.
6. Align capacity with demand for the second half of the year and growing priority orders.
7. Retain and grow customers through loyalty programmes and targeted acquisition.
8. Strengthen monitoring with a dashboard that treats success rate as the primary KPI and speed as secondary.

## Repository Structure
```text
Last_Mile_Delivery/
│
├── Last Mile Delivery Services documentation   # Project documentation
├── Last_Mile_Delivery.pptx                     # Project presentation
├── db_creation.sql                             # Database and table creation
├── data_exploration.sql                        # Initial data exploration queries
├── objective_4_1.sql                           # Objective 4 queries (1 of 5)
├── objective_4_2.sql                           # Objective 4 queries (2 of 5)
├── objective_4_3.sql                           # Objective 4 queries (3 of 5)
├── objective_4_4.sql                           # Objective 4 queries (4 of 5)
├── objective_4_5.sql                           # Objective 4 queries (5 of 5)
├── preferred_time_slot_based.sql               # Preferred time slot based analysis
└── README.md
```

## How to Run
1. Install **MySQL** and a client such as **MySQL Workbench**.
2. Run `db_creation.sql` to create the database and tables.
3. Import the dataset into the matching tables.
4. Run `data_exploration.sql` to check and understand the data.
5. Run the analysis queries (`objective_4_1.sql` to `objective_4_5.sql` and `preferred_time_slot_based.sql`) to reproduce the results.

## Team
* **Gurugubelli Suresh** ([@sureshg200203](https://github.com/sureshg200203))

## Acknowledgements
* **Innomatics Research Labs** for providing project guidance and data context.
