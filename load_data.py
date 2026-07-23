"""
load_data.py
Loads the DataCo Global Supply Chain CSV into a local SQLite database
(dataco.db), keeping only the columns needed for the analysis and
renaming them to clean, query-friendly names.

Usage:
    python load_data.py path/to/DataCoSupplyChainDataset.csv
"""

import sys
import pandas as pd
import sqlite3

def main():
    if len(sys.argv) < 2:
        print("Usage: python load_data.py path/to/DataCoSupplyChainDataset.csv")
        sys.exit(1)

    csv_path = sys.argv[1]
    df = pd.read_csv(csv_path, encoding="latin1")

    cols = [
        "Order Customer Id", "Order Id", "order date (DateOrders)", "Sales",
        "Order Item Total", "Late_delivery_risk", "Order Region",
        "Customer Segment", "Category Name", "Order Profit Per Order",
        "Shipping Mode", "Market",
    ]
    data = df[cols].copy()
    data.columns = [
        "customer_id", "order_id", "order_date", "sales", "order_total",
        "late_delivery_risk", "order_region", "customer_segment",
        "category_name", "profit_per_order", "shipping_mode", "market",
    ]
    data["order_date"] = pd.to_datetime(data["order_date"])

    conn = sqlite3.connect("dataco.db")
    data.to_sql("orders", conn, if_exists="replace", index=False)
    conn.execute("CREATE INDEX IF NOT EXISTS idx_cust ON orders(customer_id)")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_date ON orders(order_date)")
    conn.commit()

    print(f"Loaded {len(data):,} rows into dataco.db (table: orders)")
    print("Next step: run analysis.sql against dataco.db, e.g.")
    print("   sqlite3 dataco.db < analysis.sql")
    conn.close()

if __name__ == "__main__":
    main()
