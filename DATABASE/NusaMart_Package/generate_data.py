#!/usr/bin/env python3
import argparse
import csv
import random
from pathlib import Path
from datetime import datetime, timedelta, timezone


def write_csv(path, fields, rows):
    with path.open("w", encoding="utf-8", newline="") as out:
        wr = csv.DictWriter(out, fieldnames=fields)
        wr.writeheader()
        wr.writerows(rows)
    print(f"{path.name}: {len(rows)} baris")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--scale", type=int, default=1, help="Skala transaksi; 1 = 1000 pesanan")
    args = parser.parse_args()
    if not 1 <= args.scale <= 100:
        parser.error("--scale harus antara 1 dan 100")
    rng = random.Random(42)
    output = Path(__file__).parent / "dataset"
    output.mkdir(parents=True, exist_ok=True)

    branches = [
        dict(branch_id=1, branch_name="Jakarta", city="Jakarta", address="DKI Jakarta", phone="021000001"),
        dict(branch_id=2, branch_name="Surabaya", city="Surabaya", address="Jawa Timur", phone="031000002"),
        dict(branch_id=3, branch_name="Pontianak", city="Pontianak", address="Kalimantan Barat", phone="056100003"),
    ]
    write_csv(output / "branches.csv", list(branches[0]), branches)

    products = [
        dict(product_id=i, product_name=f"Produk {i:02d}", category=["Pangan", "Rumah Tangga", "Elektronik"][i % 3],
             unit_price=25000 + (i % 12) * 7500, stock=100, is_active="true")
        for i in range(1, 16)
    ]
    write_csv(output / "products.csv", list(products[0]), products)

    customers = []
    for site in range(1, 4):
        for n in range(1, 301 * args.scale):
            cid = site * 1000000 + n
            customers.append(dict(customer_id=cid, customer_name=f"Pelanggan {cid}",
                phone=f"08{site}{n:09d}", email=f"c{cid}@example.test", address=f"Alamat {cid}", branch_id=site))
    write_csv(output / "customers.csv", list(customers[0]), customers)

    by_site = {site: [r["customer_id"] for r in customers if r["branch_id"] == site] for site in range(1, 4)}
    orders, details = [], []
    counts = {1: 500 * args.scale, 2: 300 * args.scale, 3: 200 * args.scale}
    t0 = datetime(2026, 10, 1, 8, tzinfo=timezone(timedelta(hours=7)))
    for site, count in counts.items():
        for n in range(1, count + 1):
            oid = site * 10000000 + n
            local_customer = rng.random() < 0.85
            customer_site = site if local_customer else rng.choice([s for s in (1, 2, 3) if s != site])
            cid = rng.choice(by_site[customer_site])
            total = 0
            for idx in (1, 2):
                product = rng.choice(products)
                qty = rng.randint(1, 4)
                unit_price = int(product["unit_price"])
                subtotal = qty * unit_price
                total += subtotal
                details.append(dict(order_detail_id=oid * 10 + idx, order_id=oid,
                    product_id=product["product_id"], quantity=qty, unit_price=f"{unit_price:.2f}",
                    subtotal=f"{subtotal:.2f}"))
            orders.append(dict(order_id=oid,
                order_date=(t0 + timedelta(minutes=n * 2 + site * 11)).isoformat(),
                customer_id=cid, branch_id=site, total_amount=f"{total:.2f}", status="PAID"))
    write_csv(output / "orders.csv", list(orders[0]), orders)
    write_csv(output / "order_details.csv", list(details[0]), details)

    branch_stock = [dict(branch_id=site, product_id=p["product_id"],
         quantity_on_hand=100 + (site * 17) - int(p["product_id"]) * 3,
         updated_at=t0.isoformat())
         for site in (1, 2, 3) for p in products]
    write_csv(output / "branch_stock.csv", list(branch_stock[0]), branch_stock)
    print("Catatan: orders memuat ~15% transaksi pelanggan lintas cabang.")
    print("Produk memiliki stock tunggal placeholder; branch_stock menunjukkan stok per cabang yang berbeda.")


if __name__ == "__main__":
    main()
