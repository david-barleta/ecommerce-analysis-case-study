/*
Data Profiling Script: This SQL script performs data profiling to identify the data quality
issues in the tables in the staging layer.
*/

-- Check data quality of stg.raw_orders

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_orders;

-- Check for duplicates and NULLs in primary key (order_id)
SELECT order_id, COUNT(*) AS duplicate_null_count
FROM stg.raw_orders
GROUP BY order_id
HAVING COUNT(*) > 1 OR order_id IS NULL;

-- Check for NULLs in customer_id
SELECT COUNT(*) AS null_customer_id_count
FROM stg.raw_orders
WHERE customer_id IS NULL;

-- Referential check: customer_id -> customers
SELECT COUNT(*) AS orphaned_customer_id_count
FROM stg.raw_orders AS o
LEFT JOIN stg.raw_customers AS c
	ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Completeness check: order_id -> order items
SELECT COUNT(*) AS orders_without_items_count
FROM stg.raw_orders AS o
LEFT JOIN stg.raw_order_items AS i
	ON o.order_id = i.order_id
WHERE i.order_id IS NULL;

-- Completeness check: order_id -> order payments
SELECT COUNT(*) AS orders_without_payments_count
FROM stg.raw_orders AS o
LEFT JOIN stg.raw_order_payments AS p
	ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

-- Completeness check: order_id -> order reviews
SELECT COUNT(*) AS orders_without_reviews_count
FROM stg.raw_orders AS o
LEFT JOIN stg.raw_order_reviews AS r
	ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

-- Check if order_status is standardized and consistent
SELECT DISTINCT order_status
FROM stg.raw_orders;

-- Check for NULLs in the date columns
SELECT COUNT(*) AS null_purchase_timestamp_count
FROM stg.raw_orders
WHERE order_purchase_timestamp IS NULL;

SELECT COUNT(*) AS null_order_approved_at_count
FROM stg.raw_orders
WHERE order_approved_at IS NULL;

SELECT COUNT(*) AS null_delivered_carrier_date_count
FROM stg.raw_orders
WHERE order_delivered_carrier_date IS NULL;

SELECT COUNT(*) AS null_delivered_customer_date_count
FROM stg.raw_orders
WHERE order_delivered_customer_date IS NULL;

SELECT COUNT(*) AS null_estimated_delivery_date_count
FROM stg.raw_orders
WHERE order_estimated_delivery_date IS NULL;

-- Check for records where order_estimated_delivery_date is earlier than order_purchase_timestamp
SELECT COUNT(*) AS incorrect_date_sequence_count
FROM stg.raw_orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;

-- Check for records where the other date fields are earlier than order_purchase_timestamp
WITH completed_orders AS (
	SELECT *
	FROM stg.raw_orders
	WHERE order_approved_at IS NOT NULL
		AND order_delivered_carrier_date IS NOT NULL
		AND order_delivered_customer_date IS NOT NULL
)
SELECT COUNT(*) AS incorrect_date_sequence_count
FROM completed_orders
WHERE order_approved_at < order_purchase_timestamp
	OR order_delivered_carrier_date < order_approved_at
	OR order_delivered_customer_date < order_delivered_carrier_date;

-- ================================================== 

-- Check data quality of stg.raw_order_items

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_order_items;

-- Check for duplicates in (order_id, order_item_id)
SELECT COUNT(*) AS duplicate_count
FROM stg.raw_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Check for NULLs in order_id
SELECT COUNT(*) AS null_order_id_count
FROM stg.raw_order_items
WHERE order_id IS NULL;

-- Check for NULLs in product_id
SELECT COUNT(*) AS null_product_id_count
FROM stg.raw_order_items
WHERE product_id IS NULL;

-- Check for NULLs in seller_id
SELECT COUNT(*) AS null_seller_id_count
FROM stg.raw_order_items
WHERE seller_id IS NULL;

-- Check for NULLs in shipping_limit_date
SELECT COUNT(*) AS null_shipping_limit_date_count
FROM stg.raw_order_items
WHERE shipping_limit_date IS NULL;

-- Referential check: order_id -> orders
SELECT COUNT(*) AS orphaned_order_id_count
FROM stg.raw_order_items AS i
LEFT JOIN stg.raw_orders AS o
	ON i.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Referential check: product_id -> products
SELECT COUNT(*) AS orphaned_product_id_count
FROM stg.raw_order_items AS i
LEFT JOIN stg.raw_products AS p
	ON i.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Referential check: seller_id -> sellers
SELECT COUNT(*) AS orphaned_seller_id_count
FROM stg.raw_order_items AS i
LEFT JOIN stg.raw_sellers AS s
	ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Check for invalid data in price
SELECT COUNT(*) AS invalid_price_count
FROM stg.raw_order_items
WHERE price <= 0 OR price IS NULL;

-- Check for invalid data in freight_value
SELECT COUNT(*) AS invalid_freight_value_count
FROM stg.raw_order_items
WHERE freight_value <= 0 OR freight_value IS NULL;

-- ================================================== 

-- Check data quality of stg.raw_order_payments

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_order_payments;

-- Check for duplicates in (order_id, payment_sequential)
SELECT COUNT(*) AS duplicate_count
FROM stg.raw_order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- Check for NULLs in order_id
SELECT COUNT(*) AS null_order_id_count
FROM stg.raw_order_payments
WHERE order_id IS NULL;

-- Check if payment_type is standardized and consistent
SELECT DISTINCT payment_type
FROM stg.raw_order_payments;

-- Referential check: order_id -> orders
SELECT COUNT(*) AS orphaned_order_id_count
FROM stg.raw_order_payments AS p
LEFT JOIN stg.raw_orders AS o
	ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check for invalid data in payment_installments
SELECT COUNT(*) AS invalid_payment_installments_count
FROM stg.raw_order_payments
WHERE payment_installments <= 0 OR payment_installments IS NULL;

-- Check for invalid data in payment_value
SELECT COUNT(*) AS invalid_payment_value_count
FROM stg.raw_order_payments
WHERE payment_value <= 0 OR payment_value IS NULL;

-- ================================================== 

-- Check data quality of stg.raw_order_reviews

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_order_reviews;

-- Check for duplicates in review_id
SELECT review_id, COUNT(*) AS duplicate_count
FROM stg.raw_order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

-- Check if review_id duplicates are exact row duplicates
SELECT
	review_id,
	order_id,
	review_score,
	review_comment_title,
	review_comment_message,
	review_creation_date,
	review_answer_timestamp,
	COUNT(*)
FROM stg.raw_order_reviews
GROUP BY
	review_id,
	order_id,
	review_score,
	review_comment_title,
	review_comment_message,
	review_creation_date,
	review_answer_timestamp
HAVING COUNT(*) > 1;

-- Investigate differences between duplicate records
SELECT *
FROM stg.raw_order_reviews
WHERE review_id IN (
    SELECT review_id
    FROM stg.raw_order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
)
ORDER BY review_id;

-- Check for duplicates in order_id
SELECT order_id, COUNT(*) AS duplicate_count
FROM stg.raw_order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check for NULLs in review_id
SELECT COUNT(*) AS null_review_id_count
FROM stg.raw_order_reviews
WHERE review_id IS NULL;

-- Check for NULLs in order_id
SELECT COUNT(*) AS null_order_id_count
FROM stg.raw_order_reviews
WHERE order_id IS NULL;

-- Referential check: order_id -> orders
SELECT COUNT(*) AS orphaned_order_id_count
FROM stg.raw_order_reviews AS r
LEFT JOIN stg.raw_orders AS o
	ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check for invalid data in review_score
SELECT DISTINCT review_score
FROM stg.raw_order_reviews;

-- Check for NULLs in review_comment_title
SELECT COUNT(*) AS null_review_title_count
FROM stg.raw_order_reviews
WHERE review_comment_title IS NULL;

-- Check for NULLs in review_comment_message
SELECT COUNT(*) AS null_review_message_count
FROM stg.raw_order_reviews
WHERE review_comment_message IS NULL;

-- Check for NULLs in review_creation_date
SELECT COUNT(*) AS null_review_date_count
FROM stg.raw_order_reviews
WHERE review_creation_date IS NULL;

-- Check for NULLs in review_answer_timestamp
SELECT COUNT(*) AS null_review_answer_timestamp_count
FROM stg.raw_order_reviews
WHERE review_answer_timestamp IS NULL;

-- ================================================== 

-- Check data quality of stg.raw_marketing_qualified_leads

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_marketing_qualified_leads;

-- Check for duplicates and NULLs in primary key (mql_id)
SELECT mql_id, COUNT(*) AS duplicate_null_count
FROM stg.raw_marketing_qualified_leads
GROUP BY mql_id
HAVING COUNT(*) > 1 OR mql_id IS NULL;

-- Check for NULLs in first_contact_date
SELECT COUNT(*) AS null_first_contact_date_count
FROM stg.raw_marketing_qualified_leads
WHERE first_contact_date IS NULL;

-- Check for NULLs in landing_page_id
SELECT COUNT(*) AS null_landing_page_id_count
FROM stg.raw_marketing_qualified_leads
WHERE landing_page_id IS NULL;

-- Check if origin is standardized and consistent
SELECT DISTINCT origin
FROM stg.raw_marketing_qualified_leads;

SELECT COUNT(*) AS null_origin_count
FROM stg.raw_marketing_qualified_leads
WHERE origin IS NULL;

-- ================================================== 

-- Check data quality of stg.raw_closed_deals

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_closed_deals;

-- Check for duplicates and NULLs in primary key (mql_id)
SELECT mql_id, COUNT(*) AS duplicate_null_count
FROM stg.raw_closed_deals
GROUP BY mql_id
HAVING COUNT(*) > 1 OR mql_id IS NULL;

-- Check for duplicates and NULLs in primary key (mql_id)
SELECT seller_id, COUNT(*) AS duplicate_null_count
FROM stg.raw_closed_deals
GROUP BY seller_id
HAVING COUNT(*) > 1 OR seller_id IS NULL;

-- Referential check: mql_id -> marketing qualified leads
SELECT COUNT(*) AS orphaned_mql_id_count
FROM stg.raw_closed_deals AS cd
LEFT JOIN stg.raw_marketing_qualified_leads AS mql
	ON cd.mql_id = mql.mql_id
WHERE mql.mql_id IS NULL;

-- Referential check: seller_id -> sellers
SELECT COUNT(*) AS orphaned_seller_id_count
FROM stg.raw_closed_deals AS cd
LEFT JOIN stg.raw_sellers AS s
	ON cd.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Check for NULLs in sdr_id
SELECT COUNT(*) AS null_sdr_id_count
FROM stg.raw_closed_deals
WHERE sdr_id IS NULL;

-- Check for NULLs in sr_id
SELECT COUNT(*) AS null_sr_id_count
FROM stg.raw_closed_deals
WHERE sr_id IS NULL;

-- Check for NULLs in won_date
SELECT COUNT(*) AS null_won_date_count
FROM stg.raw_closed_deals
WHERE won_date IS NULL;

-- Check if business_segment is standardized and consistent
SELECT DISTINCT business_segment
FROM stg.raw_closed_deals;

SELECT COUNT(*) AS null_business_segment_count
FROM stg.raw_closed_deals
WHERE business_segment IS NULL;

-- Check if lead_type is standardized and consistent
SELECT DISTINCT lead_type
FROM stg.raw_closed_deals;

SELECT COUNT(*) AS null_lead_type_count
FROM stg.raw_closed_deals
WHERE lead_type IS NULL;

-- Check if lead_behaviour_profile is standardized and consistent
SELECT DISTINCT lead_behaviour_profile
FROM stg.raw_closed_deals;

SELECT COUNT(*) AS null_lead_behaviour_profile_count
FROM stg.raw_closed_deals
WHERE lead_behaviour_profile IS NULL;

-- Check if has_company is standardized and consistent
SELECT DISTINCT has_company
FROM stg.raw_closed_deals;

SELECT COUNT(*) AS null_has_company_count
FROM stg.raw_closed_deals
WHERE has_company IS NULL;

-- Check if has_gtin is standardized and consistent
SELECT DISTINCT has_gtin
FROM stg.raw_closed_deals;

SELECT COUNT(*) AS null_has_gtin_count
FROM stg.raw_closed_deals
WHERE has_gtin IS NULL;

-- Check if average_stock is standardized and consistent
SELECT DISTINCT average_stock
FROM stg.raw_closed_deals;

SELECT COUNT(*) AS null_average_stock_count
FROM stg.raw_closed_deals
WHERE average_stock IS NULL;

-- Check if business_type is standardized and consistent
SELECT DISTINCT business_type
FROM stg.raw_closed_deals;

SELECT COUNT(*) AS null_business_type_count
FROM stg.raw_closed_deals
WHERE business_type IS NULL;

-- Check for invalid data in declared_product_catalog_size
SELECT COUNT(*) AS invalid_product_size_count
FROM stg.raw_closed_deals
WHERE declared_product_catalog_size <= 0 OR declared_product_catalog_size IS NULL;

-- Check for invalid data in declared_monthly_revenue
SELECT COUNT(*) AS invalid_monthly_revenue_count
FROM stg.raw_closed_deals
WHERE declared_monthly_revenue <= 0 OR declared_monthly_revenue IS NULL;

-- Check for records where won_date is earlier than first_contact_date
SELECT COUNT(*) AS invalid_date_sequence_count
FROM stg.raw_closed_deals AS cd
LEFT JOIN stg.raw_marketing_qualified_leads AS mql
	ON cd.mql_id = mql.mql_id
WHERE cd.won_date < mql.first_contact_date;

-- ================================================== 

-- Check data quality of stg.raw_products

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_products;

-- Check for duplicates and NULLs in primary key (product_id)
SELECT product_id, COUNT(*) AS duplicate_null_count
FROM stg.raw_products
GROUP BY product_id
HAVING COUNT(*) > 1 OR product_id IS NULL;

-- Check if product_category_name is standardized and consistent
SELECT DISTINCT product_category_name
FROM stg.raw_products
ORDER BY product_category_name;

SELECT COUNT(*) AS null_product_category_name_count
FROM stg.raw_products
WHERE product_category_name IS NULL;

-- Check for invalid data in product_name_length
SELECT COUNT(*) AS invalid_product_name_length_count
FROM stg.raw_products
WHERE product_name_lenght <= 0 OR product_name_lenght IS NULL;

-- Check for invalid data in product_description_length
SELECT COUNT(*) AS invalid_product_description_length_count
FROM stg.raw_products
WHERE product_description_lenght <= 0 OR product_description_lenght IS NULL;

-- Check for invalid data in product_photos_qty
SELECT COUNT(*) AS invalid_product_photos_qty_count
FROM stg.raw_products
WHERE product_photos_qty <= 0 OR product_photos_qty IS NULL;

-- Check for invalid data in product_weight_g
SELECT COUNT(*) AS invalid_product_weight_g_count
FROM stg.raw_products
WHERE product_weight_g <= 0;

-- Check for invalid data in product_length_cm
SELECT COUNT(*) AS invalid_product_length_cm_count
FROM stg.raw_products
WHERE product_length_cm <= 0 OR product_length_cm IS NULL;

-- Check for invalid data in product_height_cm
SELECT COUNT(*) AS invalid_product_height_cm_count
FROM stg.raw_products
WHERE product_height_cm <= 0 OR product_height_cm IS NULL;

-- Check for invalid data in product_width_cm
SELECT COUNT(*) AS invalid_product_width_cm_count
FROM stg.raw_products
WHERE product_width_cm <= 0 OR product_width_cm IS NULL;

-- Category translation coverage check
SELECT COUNT(*) AS categories_without_translations_count
FROM stg.raw_products AS p
LEFT JOIN stg.raw_product_category_name_translations AS t
	ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL;

-- ================================================== 

-- Check data quality of stg.raw_customers

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_customers;

-- Check for duplicates and NULLs in customer_id
SELECT customer_id, COUNT(*) AS duplicate_null_count
FROM stg.raw_customers
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL;

-- Check for NULLs in customer_unique_id
SELECT COUNT(*) AS null_customer_unique_id_count
FROM stg.raw_customers
WHERE customer_unique_id IS NULL;

-- Check for NULLs in customer_zip_code_prefix
SELECT COUNT(*) AS null_zip_code_count
FROM stg.raw_customers
WHERE customer_zip_code_prefix IS NULL;

-- Check if customer_city is standardized and consistent
SELECT DISTINCT customer_city
FROM stg.raw_customers
ORDER BY customer_city;

SELECT COUNT(*) AS null_city_count
FROM stg.raw_customers
WHERE customer_city IS NULL;

-- Check if customer_state is standardized and consistent
SELECT DISTINCT customer_state
FROM stg.raw_customers
ORDER BY customer_state;

SELECT COUNT(*) AS null_state_count
FROM stg.raw_customers
WHERE customer_state IS NULL;

-- Referential check: customer_zip_code_prefix -> geolocation
SELECT COUNT(*) AS orphaned_zip_code_count
FROM stg.raw_customers AS c
LEFT JOIN stg.raw_geolocation AS g
	ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

-- ================================================== 

-- Check data quality of stg.raw_sellers

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_sellers;

-- Check for duplicates and NULLs in seller_id
SELECT seller_id, COUNT(*) AS duplicate_null_count
FROM stg.raw_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1 OR seller_id IS NULL;

-- Check for NULLs in seller_zip_code_prefix
SELECT COUNT(*) AS null_zip_code_count
FROM stg.raw_sellers
WHERE seller_zip_code_prefix IS NULL;

-- Check if seller_city is standardized and consistent
SELECT DISTINCT seller_city
FROM stg.raw_sellers
ORDER BY seller_city;

SELECT COUNT(*) AS null_city_count
FROM stg.raw_sellers
WHERE seller_city IS NULL;

-- Check if seller_state is standardized and consistent
SELECT DISTINCT seller_state
FROM stg.raw_sellers
ORDER BY seller_state;

SELECT COUNT(*) AS null_state_count
FROM stg.raw_sellers
WHERE seller_state IS NULL;

-- Referential check: seller_zip_code_prefix -> geolocation
SELECT COUNT(*) AS orphaned_zip_code_count
FROM stg.raw_sellers AS s
LEFT JOIN stg.raw_geolocation AS g
	ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

-- ================================================== 

-- Check data quality of stg.raw_geolocation

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_geolocation;

-- Check for duplicates and NULLs in geolocation_zip_code_prefix
SELECT geolocation_zip_code_prefix, COUNT(*) AS duplicate_null_count
FROM stg.raw_geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1 OR geolocation_zip_code_prefix IS NULL;

-- Check for NULLs in geolocation_lat
SELECT COUNT(*) AS null_lat_count
FROM stg.raw_geolocation
WHERE geolocation_lat IS NULL;

-- Check for NULLs in geolocation_lng
SELECT COUNT(*) AS null_lng_count
FROM stg.raw_geolocation
WHERE geolocation_lng IS NULL;

-- Check if geolocation_city is standardized and consistent
SELECT DISTINCT geolocation_city
FROM stg.raw_geolocation
ORDER BY geolocation_city;

SELECT COUNT(*) AS null_city_count
FROM stg.raw_geolocation
WHERE geolocation_city IS NULL;

-- Check if geolocation_state is standardized and consistent
SELECT DISTINCT geolocation_state
FROM stg.raw_geolocation
ORDER BY geolocation_state;

SELECT COUNT(*) AS null_state_count
FROM stg.raw_geolocation
WHERE geolocation_state IS NULL;

-- ================================================== 

-- Check data quality of stg.raw_product_category_name_translations

-- Check row count
SELECT COUNT(*) AS row_count
FROM stg.raw_product_category_name_translations;

-- Check for duplicates and NULLs in product_category_name
SELECT product_category_name, COUNT(*) AS duplicate_null_count
FROM stg.raw_product_category_name_translations
GROUP BY product_category_name
HAVING COUNT(*) > 1 OR product_category_name IS NULL;

-- Check for duplicates and NULLs in product_category_name_english
SELECT product_category_name_english, COUNT(*) AS duplicate_null_count
FROM stg.raw_product_category_name_translations
GROUP BY product_category_name_english
HAVING COUNT(*) > 1 OR product_category_name_english IS NULL;