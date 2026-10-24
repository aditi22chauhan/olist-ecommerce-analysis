-- Olist e-commerce schema (PostgreSQL)
-- Run this whole script in DBeaver while connected to the `olist` database.
-- Select all (Cmd+A) and press Option+X to run it as a script.

-- 1) Tables with no dependencies -------------------------------------------

CREATE TABLE customers (
    customer_id              VARCHAR(50) PRIMARY KEY,
    customer_unique_id       VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city            VARCHAR(100),
    customer_state           CHAR(2)
);

CREATE TABLE sellers (
    seller_id              VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city            VARCHAR(100),
    seller_state           CHAR(2)
);

CREATE TABLE products (
    product_id                 VARCHAR(50) PRIMARY KEY,
    product_category_name      VARCHAR(100),
    product_name_lenght        INTEGER,   -- spelling matches the CSV
    product_description_lenght INTEGER,   -- spelling matches the CSV
    product_photos_qty         INTEGER,
    product_weight_g           INTEGER,
    product_length_cm          INTEGER,
    product_height_cm          INTEGER,
    product_width_cm           INTEGER
);

CREATE TABLE product_category_translation (
    product_category_name         VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- Many rows per zip code, so no primary key here.
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat             DOUBLE PRECISION,
    geolocation_lng             DOUBLE PRECISION,
    geolocation_city            VARCHAR(100),
    geolocation_state           CHAR(2)
);

-- 2) Tables that depend on the ones above ----------------------------------

CREATE TABLE orders (
    order_id                      VARCHAR(50) PRIMARY KEY,
    customer_id                   VARCHAR(50) REFERENCES customers(customer_id),
    order_status                  VARCHAR(20),
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 3) Tables that depend on orders ------------------------------------------

-- One order can contain several items, so the key is order_id + order_item_id.
CREATE TABLE order_items (
    order_id            VARCHAR(50) REFERENCES orders(order_id),
    order_item_id       INTEGER,
    product_id          VARCHAR(50) REFERENCES products(product_id),
    seller_id           VARCHAR(50) REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10,2),
    freight_value       NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- One order can be paid in several parts (e.g. voucher + card).
CREATE TABLE order_payments (
    order_id             VARCHAR(50) REFERENCES orders(order_id),
    payment_sequential   INTEGER,
    payment_type         VARCHAR(30),
    payment_installments INTEGER,
    payment_value        NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- review_id is NOT unique in this dataset, so no primary key.
CREATE TABLE order_reviews (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50) REFERENCES orders(order_id),
    review_score            INTEGER,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
