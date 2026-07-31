# Business Problem Statement

## Background

FashionHub is a fashion retailer operating across two sales channels (E-commerce, App Mobile) and six European countries. Revenue has been healthy, but leadership doesn't have a unified view of whether that revenue is actually profitable — Sales, Merchandising, and Inventory each work off separate reports.

## Business Objective

Build an analytics solution that answers:
- Which products, categories, and customer segments generate sustainable profit, not just revenue?
- Is the current discount strategy protecting or eroding margin?
- Which countries and channels are performing best, and where should inventory attention go?

## Workstreams

### Problem 1 — Revenue Is Growing, But Profitability Is Unclear
Identify products, categories, and (in theory) brands that maximize profit vs. ones that generate high revenue but thin margins.
> **Scope note:** the brand-level cut of this analysis isn't possible with the current dataset — see `Known Limitations` below.

### Problem 2 — Discount Strategy May Be Reducing Profit
Evaluate whether discounting is trading margin for volume, and identify which products/categories are over-discounted relative to what they return in profit.

### Problem 3 — Customer Value Is Not Fully Understood
Segment customers by age band, country, and order value to find which segments are worth the most.

### Problem 4 — Inventory Risk 
- Which product/country combinations are sitting as dead stock (inventory on hand, zero sales)?
- Which products have already sold through more units than are currently on hand (stockout risk)?

### Problem 5 — Channel Performance
Compare revenue, profit, discount dependency, and average order value between E-commerce and App Mobile.

### Problem 6 — Geographic Performance
Compare revenue and profit across the six countries in the dataset.

## Final Deliverable
An executive Power BI dashboard (`03_PowerBI/FashionHub_Retail_Analytics.pbix`) consolidating the above into six pages: Executive Summary, Revenue & Profitability, Customer Analytics, Pricing & Discount Analysis, Channel & Geographic Analysis, and Product Insights & Recommendations.

---

## Known Limitations

I'm calling these out instead of hiding them — being upfront about what the data can't tell you is part of the job, not a weakness in the analysis.

1. **Brand analysis is not possible.** `products.brand` has a single value ("Tiva") across all 500 products. The "which brand deserves investment" question can't be answered from this dataset.
2. **Gender segmentation is not possible.** `products.gender` is single-valued ("Female") across all products.

