-- customers table
CREATE TABLE customers (
  customer_id VARCHAR(50),
  customer_unique_id VARCHAR(50),
  customer_zip_code_prefix INT,
  customer_city VARCHAR(100),
  customer_state VARCHAR(5)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from customers;

-- order_items Table
CREATE TABLE order_items (
  order_id VARCHAR(50),
  order_item_id INT,
  product_id VARCHAR(50),
  seller_id VARCHAR(50),
  shipping_limit_date DATETIME,
  price DECIMAL(10,2),
  freight_value DECIMAL(10,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from order_items;

-- order_review table
CREATE TABLE order_review (
  review_id VARCHAR(50),
  order_id VARCHAR(50),
  review_score INT,
  review_comment_title TEXT,
  review_comment_message TEXT,
  review_creation_date DATETIME,
  review_answer_timestamp DATETIME
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/olist_order_reviews_dataset.csv'
INTO TABLE order_review
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from order_review;
-- This is invalid and doesn't work
SET GLOBAL secure_file_priv = 1;

-- order_payments table
CREATE TABLE order_payments (
  order_id VARCHAR(50),
  payment_sequential INT,
  payment_type VARCHAR(50),
  payment_installments INT,
  payment_value DECIMAL(10,2)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from order_payments;

CREATE TABLE products (
  product_id VARCHAR(50),
  product_category_name VARCHAR(100),
  product_name_length INT,
  product_description_length INT,
  product_photos_qty INT,
  product_weight_g INT,
  product_length_cm INT,
  product_height_cm INT,
  product_width_cm INT
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from products;

-- product_category_name table
CREATE TABLE product_category_name_translation (
  product_category_name VARCHAR(100),
  product_category_name_english VARCHAR(100)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from product_category_name_translation;

-- sellers table
CREATE TABLE sellers (
  seller_id VARCHAR(50),
  seller_zip_code_prefix INT,
  seller_city VARCHAR(100),
  seller_state VARCHAR(10)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from sellers;

-- geolocation table
CREATE TABLE geolocation(
  geolocation_zip_code_prefix int,
  geolocation_lat double,
  geolocation_lng double,
  geolocation_city VARCHAR(50),
  geolocation_state varchar(20)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from geolocation;

-- orders table
 
CREATE TABLE orders (
  order_id VARCHAR(50),
  customer_id VARCHAR(50),
  order_status VARCHAR(20),
  order_purchase_timestamp DATE,
  order_approved_at DATE,
  order_delivered_carrier_date DATE,
  order_delivered_customer_date DATE,
  order_estimated_delivery_date DATE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, 
 @order_purchase_timestamp, @order_approved_at, 
 @order_delivered_carrier_date, @order_delivered_customer_date, 
 @order_estimated_delivery_date)
SET 
 order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
 order_approved_at = NULLIF(@order_approved_at, ''),
 order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
 order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
 order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');
select * from orders;



-- Total orders
SELECT
    COUNT(DISTINCT order_id) AS Total_Orders
FROM
    orders;
    
-- Total Revenue
SELECT 
  CONCAT('₹ ', FORMAT(SUM(payment_value)/1000000, 2), ' M') AS Total_Revenue_Millions
FROM order_payments;

-- Total Customers
SELECT COUNT(DISTINCT customer_id) AS Total_Customers FROM customers;

-- Total Products sold
SELECT COUNT(DISTINCT product_id) AS Total_Products_Sold FROM order_items;

-- Average Delievery days
SELECT 
  ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 2) AS Avg_Delivery_Days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Order by status
SELECT order_status, COUNT(*) AS Total_Orders
FROM orders
GROUP BY order_status;

-- Delievery Time by Product Category
SELECT 
    p.product_category_name,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS Avg_Delivery_Days
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name;

-- Payment type Distribution
SELECT payment_type, COUNT(*) AS Payment_Count
FROM order_payments
GROUP BY payment_type;

-- Average review score
SELECT ROUND(AVG(review_score), 2) AS Avg_Review_Score FROM order_review;

-- Review score distribution
SELECT review_score, COUNT(*) AS Total_Reviews
FROM order_review
GROUP BY review_score;

-- Top cities by orders
SELECT customer_city, COUNT(*) AS Total_Orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_city
ORDER BY Total_Orders DESC
LIMIT 10;

-- orders per state
SELECT customer_state, COUNT(*) AS Total_Orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_state
ORDER BY Total_Orders DESC;

-- Top 5 selling categories
SELECT 
  p.product_category_name, 
  COUNT(*) AS Total_Sold
FROM order_items i
JOIN products p ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY Total_Sold DESC
LIMIT 5;

-- Average price per product category
SELECT 
  p.product_category_name,
  ROUND(AVG(price), 2) AS Avg_Price
FROM order_items i
JOIN products p ON i.product_id = p.product_id
GROUP BY p.product_category_name;

-- Monthly trends over time
SELECT 
  DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS Month,
  COUNT(*) AS Total_Orders
FROM orders
GROUP BY Month
ORDER BY Month;

-- Monthly revenue trend
SELECT 
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS Month,
  ROUND(SUM(p.payment_value), 2) AS Monthly_Revenue
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY Month
ORDER BY Month;


-- KPI 1: Weekday vs Weekend Payment Statistics
SELECT
    o.order_id,
    o.order_purchase_timestamp,
    p.payment_value
FROM
    orders o
JOIN
    order_payments p ON o.order_id = p.order_id
WHERE
    o.order_purchase_timestamp IS NOT NULL;

SELECT
    CASE 
        WHEN DAYOFWEEK(order_purchase_timestamp) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    CONCAT('₹ ', COUNT(*)) AS Total_Payments,
    
    CONCAT('₹ ', ROUND(SUM(p.payment_value)/1000000, 2), ' M') AS Total_Payment_Value,
    CONCAT('₹ ', ROUND(AVG(p.payment_value), 2)) AS Avg_Payment_Value

FROM
    orders o
JOIN
    order_payments p ON o.order_id = p.order_id
WHERE
    o.order_purchase_timestamp IS NOT NULL
GROUP BY
    Day_Type;
    SELECT *
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
LIMIT 10;

-- KPI 2: Count of Orders with Review Score 5 and Payment Type as Credit Card
SELECT
    COUNT(DISTINCT o.order_id) AS Orders_With_Review_5_And_CreditCard
FROM
    orders o
JOIN
    order_review r ON o.order_id = r.order_id
JOIN
    order_payments p ON o.order_id = p.order_id
WHERE
    r.review_score = 5
    AND LOWER(p.payment_type) = 'credit_card';
    
-- KPI 3: Average Delivery Time for Pet Shop Products
SELECT
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS Avg_Delivery_Days_Pet_Shop
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
JOIN
    products p ON oi.product_id = p.product_id
WHERE
    p.product_category_name = 'pet_shop'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_purchase_timestamp IS NOT NULL;
    
-- KPI 4: Average Order Price and Payment Amount for Customers in São Paulo
SELECT
    c.customer_city,
    CONCAT('₹', ROUND(AVG(oi.price), 2)) AS Avg_Order_Price,
    CONCAT('₹', ROUND(AVG(p.payment_value), 2)) AS Avg_Payment_Amount
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
JOIN
    order_items oi ON o.order_id = oi.order_id
JOIN
    order_payments p ON o.order_id = p.order_id
WHERE
    c.customer_city = 'sao paulo'
GROUP BY
    c.customer_city;
    
-- KPI 5: Relationship Between Shipping Days and Review Scores
SELECT
    r.review_score,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS Avg_Shipping_Days,
    COUNT(*) AS Total_Orders
FROM
    order_review r
JOIN
    orders o ON r.order_id = o.order_id
WHERE
    o.order_delivered_customer_date IS NOT NULL
    AND o.order_purchase_timestamp IS NOT NULL
    AND r.review_score BETWEEN 1 AND 5
GROUP BY
    r.review_score
ORDER BY
    r.review_score;





