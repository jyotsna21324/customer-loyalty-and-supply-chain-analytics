-- ============================================================
-- Does Late Delivery Kill Customer Loyalty?
-- Customer-level RFM Segmentation + Cohort Retention Analysis
-- Dataset: DataCo Global Supply Chain (180,519 orders, 2015-2018)
-- ============================================================

-- ------------------------------------------------------------
-- PART 1: RFM SEGMENTATION
-- Recency = days since last order (from dataset's max date)
-- Frequency = number of orders placed
-- Monetary = total sales value
-- Uses NTILE() window function to score each dimension 1-4,
-- then combines scores into a business-readable segment.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS customer_rfm;

CREATE TABLE customer_rfm AS
WITH customer_base AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id)                       AS frequency,
        SUM(order_total)                                AS monetary,
        MAX(order_date)                                 AS last_order_date,
        (SELECT MAX(order_date) FROM orders) AS dataset_max_date,
        CAST(JULIANDAY((SELECT MAX(order_date) FROM orders)) -
             JULIANDAY(MAX(order_date)) AS INTEGER)      AS recency_days,
        AVG(late_delivery_risk)                         AS pct_orders_late
    FROM orders
    GROUP BY customer_id
),
rfm_scored AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        pct_orders_late,
        -- NTILE splits customers into 4 buckets per metric (4 = best)
        NTILE(4) OVER (ORDER BY recency_days DESC)  AS r_score,   -- lower recency_days = more recent = higher score
        NTILE(4) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)       AS m_score
    FROM customer_base
)
SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    ROUND(pct_orders_late * 100, 1) AS pct_orders_late,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 2                  THEN 'Loyal Customers'
        WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost / Churned'
        ELSE 'Needs Attention'
    END AS segment
FROM rfm_scored;

-- Sanity check: segment distribution
-- SELECT segment, COUNT(*), ROUND(AVG(monetary),2) FROM customer_rfm GROUP BY segment ORDER BY COUNT(*) DESC;


-- ------------------------------------------------------------
-- PART 2: COHORT RETENTION ANALYSIS
-- Group customers by the MONTH of their first order (cohort),
-- then track what % of each cohort placed another order in
-- each subsequent month. Uses window functions (MIN OVER) +
-- a CTE chain instead of a self-join.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS cohort_retention;

CREATE TABLE cohort_retention AS
WITH order_months AS (
    SELECT
        customer_id,
        order_id,
        strftime('%Y-%m', order_date) AS order_month,
        MIN(strftime('%Y-%m', order_date)) OVER (PARTITION BY customer_id) AS cohort_month
    FROM orders
),
cohort_index AS (
    SELECT
        customer_id,
        cohort_month,
        order_month,
        -- month_number = how many calendar months after the cohort month this order happened
        (CAST(strftime('%Y', order_month || '-01') AS INTEGER) * 12 + CAST(strftime('%m', order_month || '-01') AS INTEGER))
      - (CAST(strftime('%Y', cohort_month || '-01') AS INTEGER) * 12 + CAST(strftime('%m', cohort_month || '-01') AS INTEGER))
        AS month_number
    FROM order_months
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS num_customers
    FROM cohort_index
    WHERE month_number = 0
    GROUP BY cohort_month
)
SELECT
    ci.cohort_month,
    ci.month_number,
    COUNT(DISTINCT ci.customer_id) AS active_customers,
    cs.num_customers AS cohort_size,
    ROUND(100.0 * COUNT(DISTINCT ci.customer_id) / cs.num_customers, 1) AS retention_pct
FROM cohort_index ci
JOIN cohort_size cs ON ci.cohort_month = cs.cohort_month
GROUP BY ci.cohort_month, ci.month_number
ORDER BY ci.cohort_month, ci.month_number;


-- ------------------------------------------------------------
-- PART 3: THE CORE QUESTION -
-- Does experiencing a LATE delivery on a customer's FIRST order
-- change whether they ever come back for a second order?
-- Uses ROW_NUMBER() window function to isolate each customer's
-- first order, then a CTE to compute repeat-purchase rate.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS first_order_impact;

CREATE TABLE first_order_impact AS
WITH ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        late_delivery_risk,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS order_seq,
        COUNT(*) OVER (PARTITION BY customer_id) AS total_orders_by_customer
    FROM orders
),
first_orders AS (
    SELECT
        customer_id,
        late_delivery_risk AS first_order_was_late,
        CASE WHEN total_orders_by_customer > 1 THEN 1 ELSE 0 END AS came_back
    FROM ranked_orders
    WHERE order_seq = 1
)
SELECT
    CASE WHEN first_order_was_late = 1 THEN 'Late on First Order' ELSE 'On-Time on First Order' END AS first_order_experience,
    COUNT(*) AS num_customers,
    SUM(came_back) AS customers_who_returned,
    ROUND(100.0 * SUM(came_back) / COUNT(*), 1) AS repeat_purchase_rate_pct
FROM first_orders
GROUP BY first_order_was_late;
