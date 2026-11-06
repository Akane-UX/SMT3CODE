#!/usr/bin/env python3
"""
load_data.py
Script untuk menginisialisasi skema dan memuat dataset NusaMart ke 3 Node PostgreSQL
(pg-jakarta, pg-surabaya, pg-pontianak) sesuai konsep basis data terdistribusi.
"""

import csv
import io
import subprocess
from pathlib import Path

BASE_DIR = Path(__file__).parent
DATASET_DIR = BASE_DIR / "dataset"
SCHEMA_FILE = BASE_DIR / "sql" / "schema.sql"

NODES = {
    1: {"container": "nusamart-lab-pg-jakarta-1", "name": "Jakarta", "port": 5433},
    2: {"container": "nusamart-lab-pg-surabaya-1", "name": "Surabaya", "port": 5434},
    3: {"container": "nusamart-lab-pg-pontianak-1", "name": "Pontianak", "port": 5435},
}


def run_psql(container: str, query: str = None, file_path: Path = None):
    cmd = ["docker", "exec", "-i", container, "psql", "-U", "lab", "-d", "nusamart", "-v", "ON_ERROR_STOP=1"]
    if query:
        cmd.extend(["-c", query])
        res = subprocess.run(cmd, capture_output=True, text=True)
        return res
    elif file_path:
        with file_path.open("r", encoding="utf-8") as f:
            res = subprocess.run(cmd, stdin=f, capture_output=True, text=True)
            return res


def copy_csv_to_table(container: str, table_name: str, columns: list, rows: list):
    cols_str = f"({', '.join(columns)})"
    copy_sql = f"COPY {table_name} {cols_str} FROM STDIN WITH (FORMAT csv, HEADER true);"
    
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=columns)
    writer.writeheader()
    writer.writerows(rows)
    csv_data = output.getvalue()

    psql_cmd = [
        "docker", "exec", "-i", container,
        "psql", "-U", "lab", "-d", "nusamart",
        "-v", "ON_ERROR_STOP=1",
        "-c", copy_sql
    ]
    res = subprocess.run(psql_cmd, input=csv_data, text=True, capture_output=True)
    if res.returncode != 0:
        print(f"  [ERROR] {table_name} -> {container}: {res.stderr.strip()}")
    return res


def load_csv(path: Path):
    with path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return list(reader), reader.fieldnames


def main():
    print("=" * 65)
    print("Inisialisasi Skema & Data NusaMart (Distributed Nodes)")
    print("=" * 65)

    # 1. Pastikan skema dijalankan di ketiga node
    print("\n1. Membuat skema tabel di semua node...")
    for site_id, node in NODES.items():
        res = run_psql(node["container"], file_path=SCHEMA_FILE)
        if res and res.returncode == 0:
            print(f"  [OK] Skema siap di Node {node['name']} ({node['container']})")
        else:
            print(f"  [FAIL] Gagal membuat skema di {node['name']}: {res.stderr if res else ''}")

    # 2. Baca seluruh dataset CSV
    branches_data, branches_cols = load_csv(DATASET_DIR / "branches.csv")
    products_data, products_cols = load_csv(DATASET_DIR / "products.csv")
    customers_data, customers_cols = load_csv(DATASET_DIR / "customers.csv")
    orders_data, orders_cols = load_csv(DATASET_DIR / "orders.csv")
    details_data, details_cols = load_csv(DATASET_DIR / "order_details.csv")
    stock_data, stock_cols = load_csv(DATASET_DIR / "branch_stock.csv")

    # 3. Load Master Data ke SEMUA node (Full Replication)
    print("\n2. Memuat Master Data (Full Replication: branches, products)...")
    for site_id, node in NODES.items():
        # Kosongkan tabel dahulu untuk idempotensi
        run_psql(node["container"], "TRUNCATE TABLE order_details, orders, customers, branch_stock, products, branches CASCADE;")
        
        copy_csv_to_table(node["container"], "branches", branches_cols, branches_data)
        copy_csv_to_table(node["container"], "products", products_cols, products_data)
        print(f"  [OK] Master branches & products dimuat ke Node {node['name']}")

    # 4. Load Data Terpartisi (Horizontal Fragmentation) per Node
    print("\n3. Memuat Data Terfragmentasi (customers, branch_stock, orders, order_details)...")
    for site_id, node in NODES.items():
        c_node = node["container"]
        name = node["name"]
        
        # Filter data spesifik cabang ini
        site_customers = [r for r in customers_data if int(r["branch_id"]) == site_id]
        site_stock = [r for r in stock_data if int(r["branch_id"]) == site_id]
        site_orders = [r for r in orders_data if int(r["branch_id"]) == site_id]
        site_order_ids = {int(r["order_id"]) for r in site_orders}
        site_details = [r for r in details_data if int(r["order_id"]) in site_order_ids]

        copy_csv_to_table(c_node, "customers", customers_cols, site_customers)
        copy_csv_to_table(c_node, "branch_stock", stock_cols, site_stock)
        copy_csv_to_table(c_node, "orders", orders_cols, site_orders)
        copy_csv_to_table(c_node, "order_details", details_cols, site_details)

        print(f"  [OK] Node {name}: {len(site_customers)} customers, {len(site_stock)} stock, "
              f"{len(site_orders)} orders, {len(site_details)} order_details")

    # 5. Verifikasi jumlah baris
    print("\n4. Verifikasi Data:")
    for site_id, node in NODES.items():
        c_node = node["container"]
        name = node["name"]
        check_query = """
        SELECT 
          (SELECT count(*) FROM branches) as branches,
          (SELECT count(*) FROM products) as products,
          (SELECT count(*) FROM branch_stock) as stock,
          (SELECT count(*) FROM customers) as customers,
          (SELECT count(*) FROM orders) as orders,
          (SELECT count(*) FROM order_details) as order_details;
        """
        res = run_psql(c_node, check_query)
        print(f"\n--- Node {name} (Port {node['port']}) ---")
        if res and res.returncode == 0:
            print(res.stdout.strip())

    print("\n" + "=" * 65)
    print("Selesai! Seluruh database cabang NusaMart berhasil dibuat & diverifikasi.")
    print("=" * 65)


if __name__ == "__main__":
    main()
