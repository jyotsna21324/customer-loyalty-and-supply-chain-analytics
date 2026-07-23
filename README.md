# Dataset

**Source:** DataCo Global Supply Chain Dataset
**Original source:** Constante, F., Silva, F., Pereira, A. (2019). *DataCo Smart Supply Chain
For Big Data Analysis*. Mendeley Data. Also mirrored on Kaggle as
"DataCo Smart Supply Chain for Big Data Analysis."

- 180,519 orders
- 20,652 unique customers
- Jan 2015 – Jan 2018
- 53 raw fields (order, product, customer, and shipping details)

## Files in this folder

- `sample_orders.csv` — a 500-row random sample of the cleaned columns used in this
  analysis, included so the schema is visible without downloading the full dataset.
- The full `DataCoSupplyChainDataset.csv` (~90 MB) is **not** committed to this repo due
  to size. Download it from Kaggle/Mendeley and place it here before running `load_data.py`.

## Columns used in this analysis

| Column | Description |
|---|---|
| `customer_id` | Unique customer identifier |
| `order_id` | Unique order identifier |
| `order_date` | Date the order was placed |
| `sales` / `order_total` | Order value |
| `late_delivery_risk` | 1 if the order was delivered late, 0 if on time |
| `order_region`, `market` | Geography |
| `customer_segment` | Consumer / Corporate / Home Office |
| `category_name` | Product category |
| `profit_per_order` | Profit earned on the order |
| `shipping_mode` | Standard / First / Second Class / Same Day |
