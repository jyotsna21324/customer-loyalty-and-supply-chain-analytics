# Customer Loyalty and Supply Chain Analytics

This project uses the DataCo Global Supply Chain dataset to explore customer purchasing behaviour and the relationship between delivery experience and repeat purchases.

The main question I wanted to investigate was: **does a late delivery on a customer's first order affect whether they place another order?**

## What the analysis covers

- **RFM segmentation:** groups customers using recency, frequency and monetary value, then assigns readable customer segments.
- **Cohort retention:** tracks the share of each first-purchase cohort that places orders in later months.
- **First-order delivery experience:** compares repeat-purchase rates for customers whose first order was flagged as late and those whose first order was not.
- **Order-level context:** retains fields such as region, customer segment, product category, shipping mode and profit per order for further analysis.

The SQL uses CTEs, window functions such as `NTILE()`, `MIN() OVER` and `ROW_NUMBER()`, and aggregate calculations.

## Data

The source is the DataCo Global Supply Chain dataset by Constante, Silva and Pereira (2019), available through Mendeley Data and mirrored on Kaggle.

The original dataset contains 180,519 orders from January 2015 to January 2018. The repository includes `sample_orders.csv`, a 500-row sample showing the cleaned columns used in the analysis. The full source CSV is not included because of its size.

## Running the analysis

Install the required packages:

```bash
pip install -r requirements.txt
```

Download the full DataCo CSV and load it into a local SQLite database:

```bash
python load_data.py path/to/DataCoSupplyChainDataset.csv
```

Run the SQL file against the database:

```bash
sqlite3 dataco.db < analysis.sql
```

The SQL creates three analysis tables: `customer_rfm`, `cohort_retention` and `first_order_impact`.

The included `Customer_Loyalty_SQL_Analysis.xlsx` is provided as a supplementary analysis file.

## Files

- `load_data.py` — selects and renames the fields needed for analysis, then loads them into SQLite.
- `analysis.sql` — RFM segmentation, cohort retention and first-order delivery analysis.
- `sample_orders.csv` — small sample of the cleaned data structure.
- `Customer_Loyalty_SQL_Analysis.xlsx` — supplementary workbook.
- `customer-loyalty-sql-analysis.zip` — archived project files.

The 500-row sample is for previewing the data structure; use the full source dataset to reproduce the complete analysis.
