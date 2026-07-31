# Business Insights & Recommendations

All figures below were computed directly against the CSVs in `01_Dataset/` (via DuckDB, replicating the SQL logic in `02_SQL/`), so they'll match what the Power BI dashboard shows once it's refreshed against the same data. Overall: **905 orders, ~6,715 units sold, €324,236.87 revenue, €141,153.50 profit, 43.5% blended margin.**

## 1. Profitability is concentrated, but not dramatically — this is a volume business, not a hits business

Category-level margin is tight across the board (41.7–44.7%), which means no single category is quietly dragging the business down:

| Category | Revenue | Profit | Margin |
|---|---|---|---|
| T-Shirts | €69,692.81 | €30,782.67 | 44.2% |
| Shoes | €70,074.01 | €30,473.47 | 43.5% |
| Dresses | €68,390.73 | €29,846.84 | 43.6% |
| Sleepwear | €62,276.61 | €26,000.58 | 41.8% |
| Pants | €53,802.71 | €24,049.94 | 44.7% |

**Recommendation:** with margins this close together, category-level investment decisions should be driven by growth headroom and inventory risk (see #4), not by chasing a "best margin" category — there isn't a clear winner.

**Brand and gender analysis were dropped from this deliverable** — `products.brand` and `products.gender` are single-valued in the source data (see `Business_Problem.md` → Known Limitations), so there's nothing to compare.

## 2. Discounting is working exactly against you above the 10% mark

This is the clearest signal in the dataset. Margin doesn't decline gently as discount increases — it falls off a cliff:

| Discount Band | Units | Revenue | Profit | Margin |
|---|---|---|---|---|
| No discount | 6,082 | €300,663.83 | €134,898.76 | 44.9% |
| Low (1–10%) | 218 | €8,440.74 | €3,073.68 | 36.4% |
| Medium (11–20%) | 319 | €11,549.68 | €2,437.51 | 21.1% |
| High (21–30%) | 28 | €1,478.40 | €352.10 | 23.8% |
| Very high (30%+) | 68 | €2,104.22 | €391.45 | 18.6% |

92% of all units sold at no discount at all, and that segment is also the highest-margin segment. Discounting isn't buying meaningful extra volume here — it's mostly just giving away margin on a small slice of sales. Total revenue given up to discounting across the whole dataset is **€7,642.71** (would-be revenue at list price minus actual revenue).

Worst individual offenders — high average discount paired with thin resulting margin:
- **Vintage Ribbed Dress** — 11.72% avg discount, ends at 5.3% margin
- **Tailored Wrap Dress** — 11.95% avg discount, ends at 16.6% margin
- **Bold Cotton Tee** — 11.03% avg discount, ends at 15.4% margin

**Recommendation:** cap standard promotional discounts at 10%. Anything past that is producing a 2x worse margin outcome for very little extra volume (only 96 units across the High + Very High bands combined). Flag the three products above for a pricing review rather than continuing to discount them.

## 3. Channel choice matters more than country or age does

| Channel | Revenue | Profit | Margin | Avg Discount | Orders | AOV |
|---|---|---|---|---|---|---|
| E-commerce | €171,675.72 | €76,537.03 | 44.6% | 0.25% | 473 | €362.95 |
| App Mobile | €152,560.94 | €64,616.47 | 42.4% | 2.18% | 432 | €353.15 |

E-commerce beats App Mobile on every metric — revenue, profit, margin, and order value — while using **roughly 9x less discounting** to get there. That's a real efficiency gap, not just a volume difference.

**Recommendation:** treat this as a channel-experience question before a pricing one. App Mobile is discounting almost 9x more just to land a slightly smaller average order — worth checking whether that's a deliberate app-only promo strategy or checkout friction being papered over with discounts.

By contrast, **country and age band are weak differentiators**. Profit margin is essentially flat across all six countries (43.3–43.9%), and per-customer spend across age bands only ranges €525.86–€574.10 — a ~9% spread. The country revenue gap (Germany €74.6K down to Portugal €29.9K) is a customer-count story, not a margin or pricing story:

| Country | Revenue | Profit | Customers |
|---|---|---|---|
| Germany | €74,590.69 | €32,438.11 | 145 |
| France | €72,300.66 | €31,457.22 | 125 |
| Italy | €59,458.11 | €26,131.25 | 103 |
| Netherlands | €46,841.46 | €20,328.23 | 84 |
| Spain | €41,114.79 | €17,806.35 | 75 |
| Portugal | €29,930.95 | €12,992.34 | 48 |

**Recommendation:** don't build country-specific pricing or discount strategy — the margin profile doesn't justify it. If expansion budget exists, Portugal and Spain have the smallest customer bases relative to the other four markets and no margin disadvantage, making them reasonable acquisition targets rather than problem markets.

## 4. Inventory: 349 stock lines are dead weight, and a separate 10 are already understocked

This wasn't in the original project scope but is arguably the most actionable finding in the dataset, because it's the one thing not already visible in a standard revenue/profit dashboard.

- **349 of 1,000 country/product stock lines** (35%) have units sitting on the shelf with **zero recorded sales** — a combined **9,424 units** of dead stock.
- At the other extreme, several product/country combinations have already sold **13–17x their current stock on hand** (all currently flagged in Germany), meaning demand has outpaced supply and they're likely stocked out or close to it right now.

**Recommendation:** this is a two-sided inventory rebalancing problem, not just a "buy more stock" problem. Before ordering more inventory anywhere, redistribute stock from the 349 dead-stock lines toward the handful of high sell-through products, particularly in Germany where the sell-through pressure is concentrated. Full list is in `02_SQL/03_Inventory_Queries.sql`.

## Summary — what to prioritize next quarter

1. **Cap discounts at 10%** on standard promotions; margin loss past that point isn't buying enough volume to justify it.
2. **Investigate why App Mobile discounts ~9x more than E-commerce** for a worse outcome — likely a UX or promo-strategy question, not a pricing one.
3. **Run an inventory redistribution pass** before placing new stock orders — 9,424 units are sitting idle while other lines are already stocked out.
4. **Don't over-invest in country- or age-specific strategy** — margin is flat across both; the differences are volume, not economics.
5. **Fix the data gaps** before extending this project further: add real brand variation, link `campaigns` to a real FK on `sales`, and extend the sales history window if this moves toward a live model — see `Business_Problem.md` → Known Limitations.
