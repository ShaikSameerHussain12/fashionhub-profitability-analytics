/* ============================================================
   FashionHub Retail Analytics — Business Queries
   SQL Server (T-SQL). Organized by workstream from
   04_Documentation/Business_Problem.md.
   ============================================================ */

USE sprj1;

/* ============================================================
   PROBLEM 1 — Product / Brand / Category Profitability
   ============================================================ */

-- Which products generate the highest revenue?
SELECT P.product_id, SUM(S.quantity*S.unit_price) AS REVENUE
FROM salesitems AS S
JOIN products AS P ON S.product_id = P.product_id
GROUP BY P.product_id
ORDER BY REVENUE DESC;

-- Which products generate the highest profit?
SELECT product_id, CAST(revenue-cost AS DECIMAL(10,2)) AS PROFIT
FROM (
    SELECT S.product_id AS product_id, SUM(S.quantity*S.unit_price) AS REVENUE,
           SUM(S.quantity*P.cost_price) AS COST
    FROM salesitems AS S
    JOIN products AS P ON S.product_id = P.product_id
    GROUP BY S.product_id
) AS T
ORDER BY PROFIT DESC;

-- Which products sell well but have poor margins?
SELECT S.product_id, P.product_name,
    SUM(S.quantity) AS TOTAL_UNITS_SOLD,
    SUM(S.quantity*S.unit_price) AS REVENUE,
    SUM(S.quantity*P.cost_price) AS COST,
    SUM((S.unit_price-P.cost_price)*S.quantity) AS PROFIT,
    CAST(
        (SUM((S.unit_price - P.cost_price) * S.quantity) * 100.0)
        / SUM(S.quantity * S.unit_price)
    AS DECIMAL(10,2)) AS PROFIT_MARGIN_PERCENT
FROM salesitems AS S
JOIN products AS P ON S.product_id = P.product_id
GROUP BY S.product_id, P.product_name
ORDER BY REVENUE DESC, PROFIT_MARGIN_PERCENT;

-- Which category contributes most to profit?
SELECT P.category, CAST(SUM(PROFIT) AS DECIMAL(10,2)) AS PROFIT_CONTRIBUTION
FROM (
    SELECT S.product_id,
           SUM(S.quantity*S.unit_price) AS REVENUE,
           SUM(S.quantity*P.cost_price) AS COST,
           SUM((S.unit_price-P.cost_price)*S.quantity) AS PROFIT
    FROM salesitems AS S
    JOIN products AS P ON S.product_id = P.product_id
    GROUP BY S.product_id
) AS T
JOIN products AS P ON P.product_id = T.product_id
GROUP BY P.category;

-- Which brand should receive greater investment?
SELECT P.brand,
    SUM(S.quantity) AS TOTAL_UNITS_SOLD,
    SUM(S.quantity*S.unit_price) AS REVENUE,
    SUM((S.unit_price-P.cost_price)*S.quantity) AS PROFIT,
    CAST(
        (SUM((S.unit_price - P.cost_price) * S.quantity) * 100.0)
        / SUM(S.quantity * S.unit_price)
    AS DECIMAL(10,2)) AS PROFIT_MARGIN_PERCENT
FROM salesitems AS S
JOIN products AS P ON S.product_id = P.product_id
GROUP BY P.brand
ORDER BY PROFIT DESC, PROFIT_MARGIN_PERCENT DESC;


/* ============================================================
   PROBLEM 2 — Discount Strategy
   ============================================================ */

-- Which products receive the highest discounts?
SELECT S.product_id, P.product_name,
    MAX(S.discount_applied) AS HIGHEST_DISCOUNT_APPLIED
FROM salesitems AS S
JOIN products AS P ON S.product_id = P.product_id
GROUP BY S.product_id, P.product_name
HAVING MAX(S.discount_applied) > 0;

-- How does discount affect revenue and profit?
SELECT S.discount_applied,
    SUM(S.quantity) AS TOTAL_UNITS_SOLD,
    SUM(S.quantity*S.unit_price) AS REVENUE,
    SUM((S.unit_price-P.cost_price)*S.quantity) AS PROFIT
FROM salesitems AS S
JOIN products AS P ON S.product_id = P.product_id
GROUP BY S.discount_applied
ORDER BY S.discount_applied;

-- Which categories are over-discounted?
SELECT P.category,
    CAST(AVG(S.discount_applied) AS DECIMAL(10,2)) AS AVG_DISCOUNT
FROM salesitems AS S
JOIN products AS P ON S.product_id = P.product_id
GROUP BY P.category
ORDER BY AVG_DISCOUNT DESC;

-- Which discount ranges maximize profitability?
SELECT
    CASE WHEN S.discount_applied = 0 THEN 'NO DISCOUNT'
         WHEN S.discount_applied BETWEEN 1 AND 10 THEN 'LOW DISCOUNT'
         WHEN S.discount_applied BETWEEN 11 AND 20 THEN 'MEDIUM DISCOUNT'
         WHEN S.discount_applied BETWEEN 21 AND 30 THEN 'HIGH DISCOUNT'
         ELSE 'VERY HIGH DISCOUNT'
    END discount_band,
    SUM(S.quantity) AS TOTAL_UNITS_SOLD,
    SUM(S.quantity*S.unit_price) AS REVENUE,
    SUM((S.unit_price-P.cost_price)*S.quantity) AS PROFIT
FROM salesitems AS S
JOIN products AS P ON S.product_id = P.product_id
GROUP BY CASE WHEN S.discount_applied = 0 THEN 'NO DISCOUNT'
              WHEN S.discount_applied BETWEEN 1 AND 10 THEN 'LOW DISCOUNT'
              WHEN S.discount_applied BETWEEN 11 AND 20 THEN 'MEDIUM DISCOUNT'
              WHEN S.discount_applied BETWEEN 21 AND 30 THEN 'HIGH DISCOUNT'
              ELSE 'VERY HIGH DISCOUNT'
         END
ORDER BY PROFIT DESC;

-- Which products should no longer receive aggressive discounts?
SELECT S.product_id, P.product_name,
    SUM(S.quantity) AS TOTAL_UNITS_SOLD,
    CAST(AVG(S.discount_applied) AS DECIMAL(10,2)) AS AVG_DISCOUNT,
    CAST(SUM(S.quantity*S.unit_price) AS DECIMAL(10,2)) AS REVENUE,
    CAST(SUM((S.unit_price-P.cost_price)*S.quantity) AS DECIMAL(10,2)) AS PROFIT,
    CAST(
        (SUM((S.unit_price - P.cost_price) * S.quantity) * 100.0)
        / SUM(S.quantity * S.unit_price)
    AS DECIMAL(10,2)) AS PROFIT_MARGIN_PERCENT
FROM salesitems AS S
JOIN products AS P ON S.product_id = P.product_id
GROUP BY S.product_id, P.product_name
ORDER BY AVG_DISCOUNT DESC, PROFIT ASC, PROFIT_MARGIN_PERCENT ASC;


/* ============================================================
   PROBLEM 3 — Customer Value
   ============================================================ */

-- Which age group spends the most?
SELECT C.age_range, SUM(SI.item_total) AS TOTAL_SPENDING
FROM customers AS C
JOIN sales AS S ON C.customer_id = S.customer_id
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
GROUP BY C.age_range
ORDER BY TOTAL_SPENDING DESC;

-- Which country generates the highest customer revenue?
SELECT C.country, SUM(SI.item_total) AS TOTAL_REVENUE
FROM customers AS C
JOIN sales AS S ON C.customer_id = S.customer_id
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
GROUP BY C.country
ORDER BY TOTAL_REVENUE DESC;

-- Who are the highest-value customers? (top 20)
SELECT TOP(20) C.customer_id, CAST(SUM(SI.item_total) AS DECIMAL(10,2)) AS TOTAL_REVENUE
FROM customers AS C
JOIN sales AS S ON C.customer_id = S.customer_id
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
GROUP BY C.customer_id
ORDER BY TOTAL_REVENUE DESC;

-- Which customer segments place the largest orders?
SELECT T.age_range, CAST(AVG(T.TOTAL_ORDER) AS DECIMAL(10,2)) AS AVG_ORDER_VALUE
FROM (
    SELECT S.sale_id, C.age_range, SUM(SI.item_total) AS TOTAL_ORDER
    FROM customers AS C
    JOIN sales AS S ON C.customer_id = S.customer_id
    JOIN salesitems AS SI ON S.sale_id = SI.sale_id
    GROUP BY S.sale_id, C.age_range
) AS T
GROUP BY T.age_range;

-- How does acquisition timing relate to purchasing behaviour?
WITH CustomerOrders AS (
    SELECT
        FORMAT(C.signup_date, 'MMM yyyy') AS signup_month,
        C.customer_id,
        S.sale_id,
        SUM(SI.item_total) AS order_value
    FROM customers AS C
    JOIN sales AS S ON C.customer_id = S.customer_id
    JOIN salesitems AS SI ON S.sale_id = SI.sale_id
    GROUP BY FORMAT(C.signup_date, 'MMM yyyy'), C.customer_id, S.sale_id
)
SELECT
    signup_month,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(sale_id) AS total_orders,
    CAST(SUM(order_value) AS DECIMAL(10,2)) AS total_revenue,
    CAST(AVG(order_value) AS DECIMAL(10,2)) AS avg_order_value
FROM CustomerOrders
GROUP BY signup_month
ORDER BY MIN(CONVERT(date, '01 ' + signup_month, 106));


/* ============================================================
   PROBLEM 5 — Channel Performance
   ============================================================ */

-- Which channel generates higher revenue?
SELECT S.channel, CAST(SUM(SI.item_total) AS DECIMAL(10,2)) AS REVENUE
FROM sales AS S
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
GROUP BY S.channel;

-- Which channel generates higher profit?
SELECT S.channel,
    SUM(SI.quantity*SI.unit_price) AS REVENUE,
    SUM(SI.quantity*P.cost_price) AS COST,
    SUM((SI.unit_price-P.cost_price)*SI.quantity) AS PROFIT
FROM sales AS S
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
JOIN products AS P ON SI.product_id = P.product_id
GROUP BY S.channel;

-- Which channel has larger average order values?
SELECT SI.channel, AVG(S.TOTAL_REVENUE) AS AVG_ORDER_VALUE
FROM (
    SELECT SI.sale_id, SUM(SI.item_total) AS TOTAL_REVENUE
    FROM salesitems AS SI
    GROUP BY SI.sale_id
) AS S
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
GROUP BY SI.channel
ORDER BY AVG_ORDER_VALUE DESC;

-- Which channel depends more heavily on discounts?
SELECT
    S.channel,
    CAST(AVG(SI.discount_applied) AS DECIMAL(10,2)) AS AVG_DISCOUNT,
    SUM(SI.item_total) AS REVENUE,
    SUM((SI.unit_price - P.cost_price) * SI.quantity) AS PROFIT,
    CAST(
        (SUM((SI.unit_price - P.cost_price) * SI.quantity) * 100.0)
        / NULLIF(SUM(SI.item_total), 0)
    AS DECIMAL(10,2)) AS PROFIT_MARGIN_PERCENT
FROM sales AS S
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
JOIN products AS P ON SI.product_id = P.product_id
GROUP BY S.channel
ORDER BY AVG_DISCOUNT DESC;

-- Which channel serves higher-value customers?
SELECT
    S.channel,
    COUNT(DISTINCT S.customer_id) AS TOTAL_CUSTOMERS,
    SUM(SI.item_total) AS TOTAL_REVENUE,
    CAST(SUM(SI.item_total) * 1.0 / COUNT(DISTINCT S.customer_id) AS DECIMAL(10,2)) AS AVG_CUSTOMER_VALUE
FROM sales AS S
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
GROUP BY S.channel
ORDER BY AVG_CUSTOMER_VALUE DESC;


/* ============================================================
   PROBLEM 6 — Geographic Performance
   ============================================================ */

-- Which country generates the highest revenue?
SELECT S.country, SUM(SI.item_total) AS TOTAL_REVENUE
FROM sales AS S
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
GROUP BY S.country
ORDER BY TOTAL_REVENUE DESC;

-- Which country generates the highest profit?
SELECT
    S.country,
    SUM((SI.unit_price - P.cost_price) * SI.quantity) AS TOTAL_PROFIT,
    CAST(
        (SUM((SI.unit_price - P.cost_price) * SI.quantity) * 100.0)
        / NULLIF(SUM(SI.item_total), 0)
    AS DECIMAL(10,2)) AS PROFIT_MARGIN_PERCENT
FROM sales AS S
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
JOIN products AS P ON SI.product_id = P.product_id
GROUP BY S.country
ORDER BY TOTAL_PROFIT DESC;

-- Full country scorecard: revenue, cost, profit, margin, orders, customers
SELECT S.country,
    SUM(SI.quantity*SI.unit_price) AS REVENUE,
    SUM(SI.quantity*P.cost_price) AS COST,
    SUM((SI.unit_price-P.cost_price)*SI.quantity) AS PROFIT,
    CAST(
        (SUM((SI.unit_price - P.cost_price) * SI.quantity) * 100.0)
        / SUM(SI.quantity * SI.unit_price)
    AS DECIMAL(10,2)) AS PROFIT_MARGIN_PERCENT,
    COUNT(DISTINCT SI.sale_id) AS TOTAL_ORDERS,
    COUNT(DISTINCT S.customer_id) AS TOTAL_CUSTOMERS
FROM sales AS S
JOIN salesitems AS SI ON S.sale_id = SI.sale_id
JOIN products AS P ON SI.product_id = P.product_id
GROUP BY S.country
ORDER BY PROFIT DESC;
