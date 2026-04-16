# Data Profiling Findings

## Purpose
This document summarizes the results of data profiling checks performed on the staging (stg) layer before transformation in the data model (dwh) layer.

## Scope
Profiled tables:
- stg.raw_orders
- stg.raw_order_items
- stg.raw_order_payments
- stg.raw_order_reviews
- stg.raw_closed_deals
- stg.raw_marketing_qualified_leads
- stg.raw_products
- stg.raw_customers
- stg.raw_sellers
- stg.raw_geolocation
- stg.raw_product_category_name_translations

## Summary of Key Findings
- Most tables 


## Table Findings

### stg.raw_orders
Checks performed:

## Table Findings

### `stg.raw_orders`
Checks performed:
- Row count check
- NULL check on `order_id`
- Duplicate check on `order_id`
- NULL check on `customer_id`
- Referential check to customers
- Completeness check to order items
- Completeness check to order payments
- Completeness check to order reviews
- Data consistency check on `order_status`
- NULL check on all the date fields
- Date sequence checks across purchase, approval, carrier delivery, customer delivery, and estimated delivery timestamps

Findings:
- Row count: 99,441 rows; successful data import
- `order_id`: no NULLs found
- `order_id`: no duplicates found
- `customer_id`: no NULLs found; all rows are matched to customers
- Completeness check to order items: 775 records in the orders table do not have matching records in the order items table; these most likely represent cancelled/unprocessed orders that never had items recorded against them
- Completeness check to order payments: all records in the orders table have a matching record in the order payments table, except 1 record
- Completeness check to order reviews: 768 records in the orders table do not have matching records in the order reviews table; these most likely represent orders that have not yet been reviewed by customers and not necessarily an error
- `order_status`: values are standardized
- `order_purchase_timestamp`: no NULLs found
- `order_approved_at`: 160 NULLs found; these represent orders that haven't been approved yet
- `order_delivered_carrier_date`: 1,783 NULLs found; these represent orders that haven't been delivered to the carrier yet
- `order_delivered_customer_date`: 2,965 NULLs found; these represent orders that haven't been delivered to the customer yet
- `order_estimated_delivery_date`: no NULLs found
- Count of records that contain inconsistent date order/sequence and should be investigated: 1,350 rows where `order_delivered_carrier_date` is earlier than `order_approved_at`; 23 rows where `order_delivered_customer_date` is earlier than `order_delivered_carrier_date`

### `stg.raw_order_items`
Checks performed:
- Row count check
- Duplicate check on `(order_id, order_item_id)`
- NULL check on key columns
- NULL check on `shipping_limit_date`
- Referential checks to orders, products, and sellers
- Numeric checks on `price` and `freight_value`

Findings:
- Row count: 112,650 rows; successful data import
- Data granularity: one row per `(order_id, order_item_id)`; no duplicates found
- No NULLs found in the key columns (`order_id`, `product_id`, `seller_id`)
- `shipping_limit_date`: no NULLs found
- No missing parent keys found (`order_id`, `product_id`, `seller_id`)
- No negative price values found
- No negative freight values found, but there are 383 rows with zero freight value – these most likely represent orders which involved free shipping

### `stg.raw_order_payments`
Checks performed:
- Row count check
- Duplicate check on `(order_id, payment_sequential)`
- NULL check on `order_id`
- Data consistency check on `payment_type`
- Referential check to orders
- Numeric checks on installments and payment value

Findings:
- Row count: 103,886 rows; successful data import
- Data granularity: one row per `(order_id, payment_sequential)`; no duplicates found
- `order_id`: no NULLs found
- `payment_type`: values are standardized
- No missing parent keys found in `order_id`
- `payment_installments`: 2 rows with zero value
- `payment_value`: 9 rows with zero value

### `stg.raw_order_reviews`
Checks performed:
- Row count check
- Duplicate check on `review_id`
- Duplicate check on `order_id`
- NULL checks on key columns
- Referential check to orders
- Data consistency check on `review_score`
- NULL checks on `review_comment_title` and `review_comment_message`

Findings:
- Row count: 99,224 rows; successful data import
- `review_id`: not unique; 789 rows have duplicates (but not exact row duplicates) with `review_id` values shared across two different `order_id` values – same review linked to two orders; root cause should be investigated
- `order_id`: also not strictly one-to-one with reviews; 547 rows have duplicates (2 records)
- No NULLs found in the key columns (`review_id`, `order_id`)
- No missing parent keys found in `order_id`
- `review_score`: values are within the expected 1-5 range; no NULLs found
- `review_comment_title`: 87,658 NULLs found; these represent reviews with scores/ratings but no feedback given
- `review_comment_message`: 58,256 NULLs found; these represent values with scores/ratings but no feedback given
- `review_creation_date`: no NULLs found
- `review_answer_timestamp`: no NULLs found

### `stg.raw_marketing_qualified_leads`
Checks performed:
- Row count check
- NULL and duplicate checks on `mql_id`
- NULL check on `first_contact_date`
- NULL check on `landing_page_id`
- Data consistency check on `origin`

Findings:
- Row count: 8,000 rows; successful data import
- `mql_id`: no NULLs and duplicates found
- `first_contact_date`: no NULLs found
- `landing_page_id`: no NULLs found
- `origin`: values are standardized; 60 NULLs found

### `stg.raw_closed_deals`
Checks performed:
- Row count check
- NULL and duplicate checks on `mql_id`
- NULL and duplicate checks on `seller_id`
- Referential check to marketing qualified leads
- Referential check to sellers
- NULL check on `sdr_id` and `sr_id`
- NULL check on `won_date`
- Data consistency check on `business_segment`, `lead_type`, `lead_behaviour_profile`, `has_company`, and `has_gtin`, `average_stock`, `business_type`
- Numeric checks on `declared_product_catalog_size` and `declared_monthly_revenue`
- Date sequence check on `first_contact_date` and `won_date`

Findings:
- Row count: 842 rows; successful data import
- `mql_id`: no NULLs and duplicates found
- `seller_id`: no NULLs and duplicates found
- No missing parent keys found in `mql_id`
- 462 missing parent keys found in `seller_id`
- No NULLs found in `sdr_id` and `sr_id`
- `won_date`: no NULLs found
- `business_segment`: values are standardized; 1 NULL found
- `lead_type`: values are standardized; 6 NULLs found
- `lead_behaviour_profile`: values are not fully standardized as some records have multiple values; 177 NULLs found
- `has_company`: values are standardized; 779 NULLs found; unusable
- `has_gtin`: values are standardized; 778 NULLs found; unusable
- `average_stock`: values are standardized; 776 NULLs found; unusable
- `business_type`: values are standardized; 10 NULLs found
- `declared_product_catalog_size`: 773 NULLs found; unusable
- `declared_monthly_revenue`: 797 zero values found; unusable
- 1 record found where `won_date` is earlier than `first_contact_date`

### `stg.raw_products`
Checks performed:
- Row count check
- NULL and duplicate checks on `product_id`
- Data consistency check on `product_category_name`
- NULL profiling on descriptive and physical columns
- Numeric checks on dimensions and weight
- Category translation coverage check

Findings:
- Row count: 32,951 rows; successful data import
- `product_id`: no NULLs and duplicates found
- `product_category_name`: values are standardized; 610 NULLs found
- `product_name_length`: 610 NULLs found
- `product_description_length`: 610 NULLs found
- `product_photos_qty`: 610 NULLs found
- `product_weight_g`: 2 NULLs and 4 zero values found
- `product_length_cm`: 2 NULLs found
- `product_height_cm`: 2 NULLs found
- `product_width_cm`: 2 NULLs found
- 623 product categories have no corresponding English translations in the `product_category_name_translations` table

### `stg.raw_customers`
Checks performed:
- Row count check
- NULL and duplicate checks on `customer_id`
- NULL check on `customer_unique_id`
- Format check on `customer_zip_code_prefix`
- Data consistency check on city/state fields
- Referential check to geolocation

Findings:
- Row count: 99,441 rows; successful data import
- `customer_id`: no NULLs and duplicates found
- `customer_unique_id`: no NULLs found
- `customer_zip_code_prefix`: no NULLs found
- `customer_city`: values are standardized; no NULLs found
- `customer_state`: values are standardized; no NULLs found
- 278 records do not have a matching zip code prefix in the geolocation table

### `stg.raw_sellers`
Checks performed:
- Row count check
- NULL and duplicate checks on `seller_id`
- Format check on `seller_zip_code_prefix`
- Data consistency check on city/state fields
- Referential check to geolocation

Findings:
- Row count: 3,095 rows; successful data import
- `seller_id`: no NULLs and duplicates found
- `seller_zip_code_prefix`: no NULLs found
- `seller_city`: some values are not standardized; no NULLs found; one invalid data (04482255)
- `seller_state`: values are standardized; no NULLs found
- 7 records do not have a matching zip code prefix in the geolocation table

### `stg.raw_geolocation`
Checks performed:
- Row count check
- NULL and duplicate checks on `geolocation_zip_code_prefix`
- NULL check on `geolocation_lat`
- NULL check on `geolocation_lng`
- Data consistency check on city/state fields

Findings:
- Row count: 1,000,163 rows; successful data import
- `geolocation_zip_code_prefix`: no NULLs found; with duplicates – this means that the geolocation table is not supposed to be a one-row-per-zip-code table i.e., the table is not strictly unique at the zip code prefix level
- `geolocation_lat`: no NULLs found
- `geolocation_lng`: no NULLs found
- `geolocation_city`: values are not standardized; no NULLs found
- `geolocation_state`: values are standardized; no NULLs found

### `stg.raw_product_category_name_translations`
Checks performed:
- Row count check
- NULL and duplicate checks on `product_category_name`
- NULL and duplicate checks on `product_category_name_english`

Findings:
- Row count: 71 rows; successful data import
- `product_category_name`: no NULLs and duplicates found
- `product_category_name_english`: no NULLs and duplicates found