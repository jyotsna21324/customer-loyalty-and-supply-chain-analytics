# Customer Loyalty and Supply Chain Analytics

This project uses the DataCo Global Supply Chain dataset to explore customer purchasing behaviour and the relationship between delivery experience and repeat purchases.

The analysis is built around three questions:

1. Which customers appear most valuable or at risk based on their purchasing history?
2. How does customer activity change after the month of a customer's first purchase?
3. Do customers whose first order is marked as late have a different repeat-purchase rate from customers whose first order is marked as on time?

## Dataset

The source is the DataCo Global Supply Chain dataset, originally published on Mendeley Data and also available through Kaggle. The full dataset contains 180,519 order records from January 2015 to January 2018.

The repository includes `sample_orders.csv`, a 500-row sample with the cleaned columns used in the analysis. The full source file is not included because of its size. The loading script expects the original DataCo CSV.

## Analysis

**Customer segmentation**

The SQL analysis calculates recency, frequency and monetary value (RFM) for each customer. It uses quartile scores to group customers into segments such as Champions, Loyal Customers, At Risk and Needs Attention.

**Cohort retention**

Customers are grouped by the month of their first order. The query then counts how many customers from each cohort place orders in later calendar months.

**First-order delivery experience**

The final query identifies each customer's first recorded order and compares the repeat-purchase rate for customers whose first order was marked late versus those whose first order was marked on time.

The SQL uses common table expressions, window functions such as `NTILE()`, `MIN() OVER` and `ROW_NUMBER()`, and conditional aggregation.

## Files

- `load_data.py` — selects the required columns from the source CSV, renames them and loads them into SQLite
- `analysis.sql` — creates the RFM, cohort-retention and first-order-impact analysis tables
- `sample_orders.csv` — small sample showing the cleaned table structure
- `Customer_Loyalty_SQL_Analysis.xlsx` — supplementary analysis workbook
- `customer-loyalty-sql-analysis.zip` — project archive

## Run

Install the dependencies:

```bash
pip install -r requirements.txt
```

Download the full DataCo Global Supply Chain CSV from its original dataset source, then run:

```bash
python load_data.py path/to/DataCoSupplyChainDataset.csv
sqlite3 dataco.db < analysis.sql
```

The loading script creates a SQLite database named `dataco.db` with an `orders` table. The SQL file creates three analysis tables: `customer_rfm`, `cohort_retention` and `first_order_impact`.

The included 500-row sample is for inspecting the cleaned columns; the analysis script is designed for the full source dataset.

## Interpreting the results

The queries describe patterns in this historical dataset. They can show whether late delivery on a first order is associated with a different repeat-purchase rate, but they do not establish that late delivery caused a customer to leave. Other factors may also influence whether a customer places another order.
