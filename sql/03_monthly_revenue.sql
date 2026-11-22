-- Q1: Monthly revenue and order count
-- Decision: canceled and unavailable orders are excluded (no real revenue)
-- Finding: revenue peaked in Nov 2017 (~1.0M) and plateaued at 0.85-1.0M in 2018
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(i.price), 2) AS revenue
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY 1;

-- Black Friday check: 24 Nov 2017 had 1,176 orders vs ~206/day baseline (5.7x)
SELECT order_purchase_timestamp::date AS day, COUNT(*) AS orders
FROM orders
WHERE order_purchase_timestamp >= '2017-11-15' AND order_purchase_timestamp < '2017-12-01'
GROUP BY 1
ORDER BY 1;
