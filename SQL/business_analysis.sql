create database ecommerce_analytics; 

-- Q1: View all records from the analysis table
select * from anal; 

-- Q2: Count total orders
Select count(order_id) as total_orders from anal; 

-- Q3: View order dates in ascending order
select order_date  from anal order by order_date asc ; 

-- Q4: View order dates in descending order
select order_date  from anal order by order_date desc ; 

-- Q5: Count unique customers
select count(distinct(customer_email)) as unique_customers from anal; 

-- Q6: Count unique products
select count(distinct(product_sku)) as unique_products from anal; 

-- Q7: Identify the order statuses present in the dataset
select distinct(status) as order_status from anal; 

-- Q8: Identify the sales channels present in the dataset
select distinct(channel) as sales_channel from anal; 

-- Q9: Calculate total revenue from completed orders
select sum(order_total ) as Total_Revenue from anal  where status="completed"; 

-- Q10: Calculate the total amount from refunded orders
select sum(order_total ) as Refunded_Amount from anal  where status="refunded"; 

-- Q11: Calculate net revenue by subtracting refunded amount from completed revenue
SELECT  
    (SUM(CASE WHEN status = 'completed' THEN order_total ELSE 0 END) 
     - SUM(CASE WHEN status = 'refunded' THEN order_total ELSE 0 END)) AS net_revenue 
FROM anal; 

-- Q12: Calculate overall refund rate
select count(case when status="refunded" then order_id end)/count(order_id)*100 as Refund_Rate from anal; 

-- Q13: Calculate completed revenue by country
select country,count(order_id) as Completed_orders, sum(order_total)as Revenue from anal  where status="completed"  group by country order by revenue desc; 

 -- Q14: Calculate completed revenue by sales channel
 select channel,count(order_id) as Completed_orders, sum(order_total)as Revenue from anal  where status="completed"  group by channel order by revenue desc; 

-- Q15: Find the top 10 products by revenue
select product_name,count(order_id) as completed_orders,sum(quantity) as quantity_ordered,sum(order_total) as Revenue from anal where status="completed" group by product_name order by revenue limit 10; 

 -- Q16: Calculate AOV by country
 select country,count(order_id) as completed_orders,sum(order_total) as Revenue,avg(order_total) as Average_order_value 
                    from anal where status="completed" group by country  
                    order by Average_order_value desc; 

-- Q17: Calculate AOV by sales channel
select channel,count(order_id) as completed_orders,sum(order_total) as Revenue,avg(order_total) as Average_order_value 
                    from anal where status="completed" group by channel 
                    order by Average_order_value desc; 

-- Q18: Analyze the top 10 customers by revenue
select customer_email,count(order_id) as orders ,sum(quantity) as quantity_ordered ,sum(order_total) as Revenue from anal where status="completed" group by customer_email order by revenue desc limit 10;  

-- Q19: Analyze the top 10 customers by AOV/revenue
select customer_email,count(order_id) as orders ,sum(order_total) as Revenue ,avg(order_total) as AOV from anal where status="completed" group by customer_email order by revenue desc limit 10;  

-- Q20: Count unique customers with completed orders
     SELECT count(distinct(customer_email)) from anal where status="completed";   


-- Q21: Calculate revenue and revenue percentage by customer type
-- Customer type is based on completed order frequency
WITH customer_orders AS ( 
    SELECT 
        customer_email, 
        COUNT(*) AS completed_orders 
    FROM anal 
    WHERE status = 'completed' 
    GROUP BY customer_email 
), 

customer_type AS ( 
    SELECT 
        customer_email, 
        CASE 
            WHEN completed_orders = 1 THEN 'One-time' 
            ELSE 'Repeat' 
        END AS customer_type 
    FROM customer_orders 
), 

revenue_by_type AS ( 
    SELECT 
        ct.customer_type, 
        COUNT(DISTINCT a.customer_email) AS customers, 
        SUM(a.order_total) AS revenue 
    FROM anal a 
    JOIN customer_type ct 
        ON a.customer_email = ct.customer_email 
    WHERE a.status = 'completed' 
    GROUP BY ct.customer_type 
) 

SELECT 
    customer_type AS Customer_Type, 
    customers AS Customers, 
    ROUND(revenue, 2) AS Revenue, 
    ROUND( 
        revenue * 100 / SUM(revenue) OVER (), 
        2 
    ) AS Revenue_Percentage 
FROM revenue_by_type 
ORDER BY revenue DESC; 

-- Q22: Count one-time customers
select count(*) as one_time_customers from ( 
select customer_email from anal where status="completed" group by customer_email having count(order_id)=1)t; 

-- Q23: Count repeated customers
select count(*) as repeated_customers from ( 
select customer_email from anal where status="completed" group by customer_email having count(order_id)>1)t; 

-- Q24: View sample order dates before monthly analysis
SELECT order_date 
FROM anal 
LIMIT 10; 

-- Q25: Add a new DATE column for converted order dates
-- add new coulmn 
ALTER TABLE anal 
ADD COLUMN order_date_new DATE; 

-- Q26: Modify order_id and create a primary key
-- changing the data types and creating primary key 
ALTER TABLE anal 
MODIFY order_id VARCHAR(20) NOT NULL; 
ALTER TABLE anal 
ADD PRIMARY KEY (order_id); 
SHOW INDEX FROM anal; 

-- Q27: Convert text-based order dates into DATE values
-- tranfer text to dates 
UPDATE anal 
SET order_date_new = STR_TO_DATE(order_date, '%d-%m-%Y') 
WHERE order_id <> ''; 

-- Q28: Analyze revenue and AOV by month
-- revenue and aov by month 
SELECT 
    monthname(order_date_new) AS Month, 
    COUNT(*) AS Completed_Orders, 
    ROUND(SUM(order_total), 2) AS Revenue, 
    ROUND(SUM(order_total) / COUNT(*), 2) AS AOV 
FROM anal 
WHERE status = 'completed' 
GROUP BY month(order_date_new) ,monthname(order_date_new) 
ORDER BY Month(order_date_new); 

-- Q29: Analyze refund percentage by month
-- refund percentage by month 
SELECT 
    monthname(order_date_new) AS Month, 
    count(*) as Total_orders ,count(case when status="refunded" then order_id end) as Refunded_orders ,count(case when status="refunded" then order_id end)*100/count(order_id) 
   as Refund_per from anal  
    GROUP BY month(order_date_new) ,monthname(order_date_new) 
	ORDER BY Month(order_date_new); 

-- Q30: Analyze revenue by channel and product name
-- revenue by channel and product name 
select channel,product_name ,count(*) as Completed_orders, round(sum(order_total),2)as revenue from anal  where status="completed"  group by channel,product_name order by revenue desc; 

-- Additional analysis: AOV by country and channel
-- aov by country and channel  
 select country,channel,count(order_id) as completed_orders,sum(order_total) as Revenue,avg(order_total) as Average_order_value 
                    from anal where status="completed" group by country,channel  
                    order by Average_order_value desc; 

-- Additional analysis: revenue by country and product
-- revenue by country,product 
select country,product_name,count(order_id) as completed_orders,round(sum(order_total),2) as Revenue,round(avg(order_total),2) as Average_order_value 
                    from anal where status="completed" group by country,product_name; 

-- Additional analysis: products with highest revenue
-- products with highest revenue  
select product_name,count(*) as completed_orders,sum(quantity) as quantity,round(sum(order_total),2) as revenue,round(avg(order_total),2) as AOV from anal where status="completed" group by product_name order by revenue desc; 

-- Additional analysis: refund by product
-- refund by product 
SELECT 
    product_name, 
    count(*) as Total_orders ,count(case when status="refunded" then order_id end) as Refunded_orders ,round(count(case when status="refunded" then order_id end)*100/count(order_id),2) 
   as Refund_rate ,round(sum(case when status="refunded" then order_total end),2) as Refunded_amount from anal  
    GROUP BY product_name 
	ORDER BY refund_rate desc; 

-- Additional analysis: refund rate by channel
-- refund rate by channel 
SELECT 
    channel, 
    count(*) as Total_orders ,count(case when status="refunded" then order_id end) as Refunded_orders ,round(count(case when status="refunded" then order_id end)*100/count(order_id),2) 
   as Refund_rate ,round(sum(case when status="refunded" then order_total end),2) as Refunded_amount from anal  
    GROUP BY channel 
	ORDER BY refund_rate desc; 

-- Additional analysis: customer refund analysis
-- customer refund analysis 
SELECT 
    customer_email, 
    count(*) as Total_orders ,count(case when status="refunded" then order_id end) as Refunded_orders ,round(count(case when status="refunded" then order_id end)*100/count(order_id),2) 
   as Refund_rate ,round(sum(case when status="refunded" then order_total end),2) as Refunded_amount from anal  
    GROUP BY customer_email 
	ORDER BY refunded_amount desc; 

-- Additional analysis: complete analysis by country
-- complete analysis by country 
select 
country, 
    count(*) as Total_orders ,count(case when status="completed" then order_id end) as completed_orders ,round(sum(case when status="completed" then order_total end),2) as Completed_revenue,count(case when status="refunded" then order_id end) as Refunded_orders ,round(count(case when status="refunded" then order_id end)*100/count(order_id),2) 
   as Refund_rate ,round(sum(case when status="refunded" then order_total end),2) as Refunded_amount,round((SUM(CASE WHEN status = 'completed' THEN order_total ELSE 0 END) 
     - SUM(CASE WHEN status = 'refunded' THEN order_total ELSE 0 END)),2) AS net_revenue from anal  
    GROUP BY country 
	ORDER BY refunded_amount desc; 

-- Additional analysis: View the complete analysis table
    select * from anal;