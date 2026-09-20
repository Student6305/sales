-- ============================================================
-- Q1. Profile the orders table
-- ============================================================

SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id) AS distinct_customers,
    COUNT(DISTINCT product_id) AS distinct_products,
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date
FROM orders;


-- ============================================================
-- Q2. NULL count for every column
-- ============================================================

SELECT
    SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS row_id_nulls,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS ship_date_nulls,
    SUM(CASE WHEN ship_mode IS NULL THEN 1 ELSE 0 END) AS ship_mode_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_name_nulls,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS segment_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS state_nulls,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END) AS postal_code_nulls,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS region_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END) AS sub_category_nulls,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS product_name_nulls,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS sales_nulls,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS discount_nulls,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS profit_nulls
FROM orders;


-- ============================================================
-- Q3. Duplicate order lines
-- ============================================================

SELECT
    order_id,
    product_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;


-- ============================================================
-- Q4. Average days to ship by Ship Mode
-- ============================================================

SELECT
    ship_mode,
    ROUND(
        AVG(julianday(ship_date) - julianday(order_date)),
        2
    ) AS avg_days_to_ship
FROM orders
GROUP BY ship_mode
ORDER BY avg_days_to_ship;


-- ============================================================
-- Q5. Sales and Profit by Region, Category and Sub-Category
-- ============================================================

SELECT
    region,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_pct
FROM orders
GROUP BY region, category, sub_category
ORDER BY total_profit ASC;


-- ============================================================
-- Q6. Top 5 and Bottom 5 Sub-Categories
-- ============================================================

WITH subcategory_profit AS (
    SELECT
        sub_category,
        SUM(profit) AS total_profit
    FROM orders
    GROUP BY sub_category
),

ranked AS (
    SELECT
        sub_category,
        total_profit,
        RANK() OVER (ORDER BY total_profit DESC) AS top_rank,
        RANK() OVER (ORDER BY total_profit ASC) AS bottom_rank
    FROM subcategory_profit
)

SELECT
    'Top 5' AS ranking_group,
    sub_category,
    ROUND(total_profit, 2) AS total_profit,
    top_rank AS rank
FROM ranked
WHERE top_rank <= 5

UNION ALL

SELECT
    'Bottom 5' AS ranking_group,
    sub_category,
    ROUND(total_profit, 2) AS total_profit,
    bottom_rank AS rank
FROM ranked
WHERE bottom_rank <= 5

ORDER BY ranking_group, rank;


-- ============================================================
-- Q7. Discount Band Analysis
-- ============================================================

WITH discount_bands AS (
    SELECT
        CASE
            WHEN discount = 0 THEN '0%'
            WHEN discount > 0 AND discount <= 0.20 THEN '1-20%'
            WHEN discount > 0.20 AND discount <= 0.40 THEN '21-40%'
            ELSE '41%+'
        END AS discount_band,
        order_id,
        profit
    FROM orders
)

SELECT
    discount_band,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(AVG(profit), 2) AS avg_profit,
    ROUND(SUM(profit), 2) AS total_profit
FROM discount_bands
GROUP BY discount_band
ORDER BY
    CASE discount_band
        WHEN '0%' THEN 1
        WHEN '1-20%' THEN 2
        WHEN '21-40%' THEN 3
        WHEN '41%+' THEN 4
    END;


-- ============================================================
-- Q8. Yearly Sales and YoY Change
-- ============================================================

WITH yearly_sales AS (
    SELECT
        CAST(strftime('%Y', order_date) AS INTEGER) AS order_year,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY CAST(strftime('%Y', order_date) AS INTEGER)
),

with_previous AS (
    SELECT
        order_year,
        total_sales,
        LAG(total_sales) OVER (ORDER BY order_year) AS previous_year_sales
    FROM yearly_sales
)

SELECT
    order_year,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(total_sales - previous_year_sales, 2) AS yoy_change,
    ROUND(
        (total_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0) * 100,
        2
    ) AS yoy_change_pct
FROM with_previous
ORDER BY order_year;


-- ============================================================
-- Q9. Loss-Making Sub-Categories
-- ============================================================

WITH subcategory_summary AS (
    SELECT
        sub_category,
        SUM(sales) AS total_sales,
        SUM(profit) AS total_profit
    FROM orders
    GROUP BY sub_category
),

total_revenue AS (
    SELECT SUM(sales) AS company_sales
    FROM orders
)

SELECT
    s.sub_category,
    ROUND(s.total_sales, 2) AS total_sales,
    ROUND(s.total_profit, 2) AS total_profit,
    ROUND(
        s.total_sales / NULLIF(t.company_sales, 0) * 100,
        2
    ) AS revenue_share_pct
FROM subcategory_summary s
CROSS JOIN total_revenue t
WHERE s.total_profit < 0
ORDER BY s.total_profit ASC;


-- ============================================================
-- Q10. Top 10 Customers by Lifetime Profit
-- ============================================================

SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(SUM(sales), 2) AS lifetime_sales,
    ROUND(SUM(profit), 2) AS lifetime_profit,
    ROUND(
        SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM orders
GROUP BY customer_id, customer_name
ORDER BY lifetime_profit DESC
LIMIT 10;