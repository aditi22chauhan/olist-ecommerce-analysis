-- Olist data quality checks (PostgreSQL)
-- Run each query on its own (select it, then Cmd+Enter in DBeaver).

-- 0. Row counts: should match the Kaggle files
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers UNION ALL
SELECT 'orders', COUNT(*) FROM orders UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews UNION ALL
SELECT 'products', COUNT(*) FROM products UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation UNION ALL
SELECT 'category_translation', COUNT(*) FROM product_category_translation;

-- 1. Duplicate order IDs (expect 0 rows)
SELECT order_id, COUNT(*) FROM orders GROUP BY order_id HAVING COUNT(*) > 1;

-- 2. Orders with no delivery date, by status
SELECT order_status, COUNT(*) FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status ORDER BY 2 DESC;

-- 2b. Orders marked delivered but with no delivery date (data errors)
SELECT order_id, order_status, order_purchase_timestamp, order_delivered_carrier_date
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL;

-- 3. Delivered before purchased (impossible, expect 0)
SELECT COUNT(*) FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- 4. Products with no category (blanks were stored as empty text)
SELECT COUNT(*) FROM products
WHERE product_category_name IS NULL OR product_category_name = '';

-- 5. Orders pointing to a customer that does not exist (expect 0)
SELECT COUNT(*) FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 6. Orders with no items, by status
SELECT o.order_status, COUNT(*)
FROM orders o
LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
GROUP BY o.order_status ORDER BY 2 DESC;
