#!/usr/bin/env python3
"""
setup_fdw.py
Mengonfigurasi Foreign Data Wrapper (postgres_fdw) antar ketiga node
sehingga setiap cabang dapat melakukan kueri terdistribusi (Distributed Query)
dan mengakses Global Views (v_all_customers, v_all_orders, v_all_order_details, v_all_branch_stock).
"""

import subprocess

NODES = {
    "jakarta": {
        "container": "nusamart-lab-pg-jakarta-1",
        "host": "pg-jakarta",
        "port": 5433,
        "peers": [("surabaya", "pg-surabaya"), ("pontianak", "pg-pontianak")]
    },
    "surabaya": {
        "container": "nusamart-lab-pg-surabaya-1",
        "host": "pg-surabaya",
        "port": 5434,
        "peers": [("jakarta", "pg-jakarta"), ("pontianak", "pg-pontianak")]
    },
    "pontianak": {
        "container": "nusamart-lab-pg-pontianak-1",
        "host": "pg-pontianak",
        "port": 5435,
        "peers": [("jakarta", "pg-jakarta"), ("surabaya", "pg-surabaya")]
    }
}


def run_sql(container: str, sql: str):
    cmd = ["docker", "exec", "-i", container, "psql", "-U", "lab", "-d", "nusamart", "-v", "ON_ERROR_STOP=1"]
    res = subprocess.run(cmd, input=sql, text=True, capture_output=True)
    if res.returncode != 0:
        print(f"Error on {container}:\n{res.stderr}")
    return res


def main():
    print("=" * 65)
    print("Konfigurasi Foreign Data Wrapper (FDW) Antar-Cabang NusaMart")
    print("=" * 65)

    for node_name, info in NODES.items():
        print(f"\n[+] Mengonfigurasi FDW di Node {node_name.title()}...")
        sql = "CREATE EXTENSION IF NOT EXISTS postgres_fdw;\n"

        for peer_name, peer_host in info["peers"]:
            sql += f"""
            DROP SERVER IF EXISTS {peer_name}_server CASCADE;
            CREATE SERVER {peer_name}_server
              FOREIGN DATA WRAPPER postgres_fdw
              OPTIONS (host '{peer_host}', port '5432', dbname 'nusamart');

            CREATE USER MAPPING FOR lab
              SERVER {peer_name}_server
              OPTIONS (user 'lab', password 'DBTech3Q');

            DROP SCHEMA IF EXISTS {peer_name} CASCADE;
            CREATE SCHEMA {peer_name};
            IMPORT FOREIGN SCHEMA public
              FROM SERVER {peer_name}_server
              INTO {peer_name};
            """

        # Buat Global Views (Menggabungkan data lokal + 2 remote peer)
        p1, p2 = info["peers"][0][0], info["peers"][1][0]
        sql += f"""
        CREATE OR REPLACE VIEW v_all_customers AS
          SELECT * FROM public.customers
          UNION ALL
          SELECT * FROM {p1}.customers
          UNION ALL
          SELECT * FROM {p2}.customers;

        CREATE OR REPLACE VIEW v_all_orders AS
          SELECT * FROM public.orders
          UNION ALL
          SELECT * FROM {p1}.orders
          UNION ALL
          SELECT * FROM {p2}.orders;

        CREATE OR REPLACE VIEW v_all_order_details AS
          SELECT * FROM public.order_details
          UNION ALL
          SELECT * FROM {p1}.order_details
          UNION ALL
          SELECT * FROM {p2}.order_details;

        CREATE OR REPLACE VIEW v_all_branch_stock AS
          SELECT * FROM public.branch_stock
          UNION ALL
          SELECT * FROM {p1}.branch_stock
          UNION ALL
          SELECT * FROM {p2}.branch_stock;
        """

        run_sql(info["container"], sql)
        print(f"  [OK] FDW Server & Global Views aktif di Node {node_name.title()}")

    # Tes Kueri Terdistribusi
    print("\n" + "=" * 65)
    print("Pengujian Kueri Terdistribusi (Global Views):")
    print("=" * 65)
    test_sql = """
    SELECT 
      (SELECT count(*) FROM v_all_customers) as total_customers,
      (SELECT count(*) FROM v_all_orders) as total_orders,
      (SELECT count(*) FROM v_all_order_details) as total_order_details,
      (SELECT count(*) FROM v_all_branch_stock) as total_stock_rows;
    """
    res = run_sql(NODES["surabaya"]["container"], test_sql)
    print("\nHasil Kueri Global dari Node Surabaya:")
    print(res.stdout.strip())


if __name__ == "__main__":
    main()
