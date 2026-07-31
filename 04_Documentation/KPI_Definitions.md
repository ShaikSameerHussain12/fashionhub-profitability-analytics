# KPI Definitions

Every formula below is exactly what's used in `01_SQL/02_Business_Queries.sql` and `02_Inventory_Queries.sql` — this isn't a generic glossary, it's a record of what each number in the dashboard actually means.

| KPI | Formula | Notes |
|---|---|---|
| Revenue | `SUM(quantity × unit_price)` | Uses the price actually charged (post-discount), not `original_price`. |
| Cost | `SUM(quantity × cost_price)` | `cost_price` comes from `products`, not from `salesitems`. |
| Profit | `SUM((unit_price − cost_price) × quantity)` | Line-item gross profit. |
| Profit Margin % | `Profit ÷ Revenue × 100` | Guarded with `NULLIF` in queries where revenue could be zero. |
| Average Order Value (AOV) | `Revenue ÷ COUNT(DISTINCT sale_id)` | Computed at order grain, not line-item grain. |
| Average Customer Value | `Revenue ÷ COUNT(DISTINCT customer_id)` | Per channel or per country depending on the query. |
| Discount Applied | `salesitems.discount_applied` | Numeric amount, already usable — `discount_percent` (text with `%`) is intentionally not used, see Data Dictionary. |
| Sell-Through Ratio *(new)* | `units_sold ÷ stock_quantity` | Country/product grain. Ratio > 1 means more has sold than is currently on the shelf — reorder signal. |
| Dead Stock | `stock_quantity > 0 AND units_sold IS NULL` | Country/product combinations with inventory but zero recorded sales. |

## Segments used throughout

- **Discount bands:** No Discount (0), Low (1–10), Medium (11–20), High (21–30), Very High (30+) — applied to `discount_applied`, not `discount_percent`.
- **Age bands:** 16-25, 26-35, 36-45, 46-55, 56-65 (pre-binned in source data, not derived).
- **Channels:** E-commerce, App Mobile — only two values in this dataset.
