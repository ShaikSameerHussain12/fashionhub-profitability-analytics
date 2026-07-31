/* ============================================================
   FashionHub Retail Analytics — Inventory Queries (NEW)
   ============================================================ */

USE sprj1;

-- Dead stock: products with inventory sitting in a country but zero
-- sales recorded against that country/product combination.
WITH sold AS (
    SELECT S.country, SI.product_id, SUM(SI.quantity) AS units_sold
    FROM sales AS S
    JOIN salesitems AS SI ON S.sale_id = SI.sale_id
    GROUP BY S.country, SI.product_id
)
SELECT ST.country, ST.product_id, P.product_name, P.category, ST.stock_quantity
FROM stock AS ST
JOIN products AS P ON ST.product_id = P.product_id
LEFT JOIN sold ON ST.country = sold.country AND ST.product_id = sold.product_id
WHERE sold.units_sold IS NULL AND ST.stock_quantity > 0
ORDER BY ST.stock_quantity DESC;

-- Stockout risk: sell-through ratio (units sold / current stock on hand).
-- A ratio well above 1 means demand has already outpaced what's on the
-- shelf right now — these are the reorder-first candidates.
WITH sold AS (
    SELECT S.country, SI.product_id, SUM(SI.quantity) AS units_sold
    FROM sales AS S
    JOIN salesitems AS SI ON S.sale_id = SI.sale_id
    GROUP BY S.country, SI.product_id
)
SELECT TOP(20)
    ST.country, ST.product_id, P.product_name, P.category,
    ST.stock_quantity,
    COALESCE(sold.units_sold, 0) AS units_sold,
    CAST(COALESCE(sold.units_sold, 0) * 1.0 / NULLIF(ST.stock_quantity, 0) AS DECIMAL(10,2)) AS SELL_THROUGH_RATIO
FROM stock AS ST
JOIN products AS P ON ST.product_id = P.product_id
LEFT JOIN sold ON ST.country = sold.country AND ST.product_id = sold.product_id
ORDER BY SELL_THROUGH_RATIO DESC;

-- Inventory position by category and country: total units on hand vs.
-- total units sold, side by side.
WITH sold AS (
    SELECT S.country, SI.product_id, SUM(SI.quantity) AS units_sold
    FROM sales AS S
    JOIN salesitems AS SI ON S.sale_id = SI.sale_id
    GROUP BY S.country, SI.product_id
)
SELECT ST.country, P.category,
    SUM(ST.stock_quantity) AS TOTAL_STOCK_ON_HAND,
    SUM(COALESCE(sold.units_sold, 0)) AS TOTAL_UNITS_SOLD
FROM stock AS ST
JOIN products AS P ON ST.product_id = P.product_id
LEFT JOIN sold ON ST.country = sold.country AND ST.product_id = sold.product_id
GROUP BY ST.country, P.category
ORDER BY ST.country, TOTAL_STOCK_ON_HAND DESC;
