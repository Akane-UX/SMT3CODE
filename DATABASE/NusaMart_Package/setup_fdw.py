#!/usr/bin/env python3
"""
setup_fdw.py
Mengonfigurasi Foreign Data Wrapper (postgres_fdw) antar ketiga node
sehingga setiap cabang dapat melakukan kueri terdistribusi (Distributed Query)
dan mengakses Global Views (v_all_customers, v_all_orders, v_all_order_details, v_all_branch_stock).
"""

import subprocess
import sys

NODES = {
    "jakarta": {
        "container": "nusamart-lab-pg-jakarta-1",
        "alt_container": "pg-jakarta",
        "host": "pg-jakarta",
        "port": 5433,
        "peers": [("surabaya", "pg-surabaya"), ("pontianak", "pg-pontianak")]
    },
    "surabaya": {
        "container": "nusamart-lab-pg-surabaya-1",
        "alt_container": "pg-surabaya",
        "host": "pg-surabaya",
        "port": 5434,
        "peers": [("jakarta", "pg-jakarta"), ("pontianak", "pg-pontianak")]
    },
    "pontianak": {
        "container": "nusamart-lab-pg-pontianak-1",
        "alt_container": "pg-pontianak",
        "host": "pg-pontianak",
        "port": 5435,
        "peers": [("jakarta", "pg-jakarta"), ("surabaya", "pg-surabaya")]
    }
}

_resolved_containers = {}

def get_container(info: dict, name: str) -> str:
    if name in _resolved_containers:
        return _resolved_containers[name]
    
    c1 = info["container"]
    chk = subprocess.run(["docker", "inspect", c1], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if chk.returncode == 0:
        _resolved_containers[name] = c1
        return c1
        
    c2 = info["alt_container"]
    chk2 = subprocess.run(["docker", "inspect", c2], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if chk2.returncode == 0:
        _resolved_containers[name] = c2
        return c2

    _resolved_containers[name] = c1
    return c1


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
        container = get_container(info, node_name)
        print(f"\n[+] Mengonfigurasi FDW di Node {node_name.title()} ({container})...")
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

        res = run_sql(container, sql)
        if res.returncode == 0:
            print(f"  [OK] FDW dan Global Views siap di {node_name.title()}")
        else:
            print(f"  [FAIL] Gagal konfigurasi FDW di {node_name.title()}")

    # Tes Kueri Terdistribusi
    print("\n" + "=" * 65)
    print("Pengujian Kueri Terdistribusi (Global View dari Node Jakarta):")
    print("=" * 65)
    test_query = """
    SELECT 
      (SELECT count(*) FROM v_all_customers) as total_global_customers,
      (SELECT count(*) FROM v_all_orders) as total_global_orders,
      (SELECT count(*) FROM v_all_order_details) as total_global_order_details,
      (SELECT count(*) FROM v_all_branch_stock) as total_global_stock_rows;
    """
    res = run_sql(get_container(NODES["jakarta"], "jakarta"), test_query)
    if res and res.returncode == 0:
        print(res.stdout.strip())
    else:
        print("Pengujian query gagal.")


if __name__ == "__main__":
    main()
