/*
DDL Script: This SQL script creates table in the bronze layer, dropping tables if they already exist.
*/

IF OBJECT_ID('bronze.orders', 'U') IS NOT NULL
	DROP TABLE bronze.orders;
GO

CREATE TABLE bronze.orders (
	order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
	order_status NVARCHAR(50),
	order_purchase_timestamp DATETIME2,
	order_approved_at DATETIME2,
	order_delivered_carrier_date DATETIME2,
	order_delivered_customer_date DATETIME2,
	order_estimated_delivery_date DATETIME2
);
GO

IF OBJECT_ID('bronze.order_items', 'U') IS NOT NULL
	DROP TABLE bronze.order_items;
GO

CREATE TABLE bronze.order_items (
	order_id NVARCHAR(50),
	order_item_id INT,
	product_id NVARCHAR(50),
	seller_id NVARCHAR(50),
	shipping_limit_date DATETIME2,
	price DECIMAL(15, 2),
	freight_value DECIMAL(15, 2)
);
GO

IF OBJECT_ID('bronze.order_payments', 'U') IS NOT NULL
	DROP TABLE bronze.order_payments;
GO

CREATE TABLE bronze.order_payments (
	order_id NVARCHAR(50),
	payment_sequential INT,
	payment_type NVARCHAR(50),
	payment_installments INT,
	payment_value DECIMAL(15, 2)
);
GO

IF OBJECT_ID('bronze.order_reviews', 'U') IS NOT NULL
	DROP TABLE bronze.order_reviews;
GO

CREATE TABLE bronze.order_reviews (
	review_id NVARCHAR(50),
	order_id NVARCHAR(50),
	review_score INT,
	review_comment_title NVARCHAR(100),
	review_comment_message NVARCHAR(500),
	review_creation_date DATETIME2,
	review_answer_timestamp DATETIME2
);
GO

IF OBJECT_ID('bronze.closed_deals', 'U') IS NOT NULL
	DROP TABLE bronze.closed_deals;
GO

CREATE TABLE bronze.closed_deals (
	mql_id NVARCHAR(50),
	seller_id NVARCHAR(50),
	sdr_id NVARCHAR(50),
	sr_id NVARCHAR(50),
	won_date DATETIME2,
	business_segment NVARCHAR(50),
	lead_type NVARCHAR(50),
	lead_behaviour_profile NVARCHAR(50),
	has_company NVARCHAR(10),
	has_gtin NVARCHAR(10),
	average_stock NVARCHAR(50),
	business_type NVARCHAR(50),
	declared_product_catalog_size INT,
	declared_monthly_revenue DECIMAL(15, 2)
);
GO

IF OBJECT_ID('bronze.marketing_qualified_leads', 'U') IS NOT NULL
	DROP TABLE bronze.marketing_qualified_leads;
GO

CREATE TABLE bronze.marketing_qualified_leads (
	mql_id NVARCHAR(50),
	first_contact_date DATE,
	landing_page_id NVARCHAR(50),
	origin NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.products', 'U') IS NOT NULL
	DROP TABLE bronze.products;
GO

CREATE TABLE bronze.products (
	product_id NVARCHAR(50),
	product_category_name NVARCHAR(50),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);
GO

IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
	DROP TABLE bronze.customers;
GO

CREATE TABLE bronze.customers (
	customer_id NVARCHAR(50),
	customer_unique_id NVARCHAR(50),
	customer_zip_code_prefix NVARCHAR(10),
	customer_city NVARCHAR(50),
	customer_state NVARCHAR(10)
);
GO

IF OBJECT_ID('bronze.sellers', 'U') IS NOT NULL
	DROP TABLE bronze.sellers;
GO

CREATE TABLE bronze.sellers (
	seller_id NVARCHAR(50),
	seller_zip_code_prefix NVARCHAR(10),
	seller_city NVARCHAR(50),
	seller_state NVARCHAR(10)
);
GO

IF OBJECT_ID('bronze.geolocation', 'U') IS NOT NULL
	DROP TABLE bronze.geolocation;
GO

CREATE TABLE bronze.geolocation (
	geolocation_zip_code_prefix NVARCHAR(10),
	geolocation_lat DECIMAL(22, 20),
	geolocation_lng DECIMAL(19, 16),
	geolocation_city NVARCHAR(50),
	geolocation_state NVARCHAR(10)
);
GO

IF OBJECT_ID('bronze.product_category_name_translations', 'U') IS NOT NULL
	DROP TABLE bronze.product_category_name_translations;
GO

CREATE TABLE bronze.product_category_name_translations (
	product_category_name NVARCHAR(100),
	product_category_name_english NVARCHAR(100)
);
GO