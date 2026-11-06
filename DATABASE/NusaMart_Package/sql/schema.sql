-- Skema Basis Data NusaMart (Multi-Node / Terdistribusi)

-- 1. Master Cabang (Ada di semua node)
CREATE TABLE IF NOT EXISTS branches (
  branch_id integer PRIMARY KEY,
  branch_name varchar(100) NOT NULL,
  city varchar(50) NOT NULL,
  address varchar(200),
  phone varchar(20)
);

-- 2. Master Produk (Katalog seragam di semua node)
CREATE TABLE IF NOT EXISTS products (
  product_id integer PRIMARY KEY,
  product_name varchar(150) NOT NULL,
  category varchar(50),
  unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  stock integer, -- Nilai placeholder / agregat
  is_active boolean NOT NULL DEFAULT true
);

-- 3. Stok Produk per Cabang (Fisik per cabang)
CREATE TABLE IF NOT EXISTS branch_stock (
  branch_id integer NOT NULL REFERENCES branches(branch_id),
  product_id integer NOT NULL REFERENCES products(product_id),
  quantity_on_hand integer NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (branch_id, product_id)
);

-- 4. Pelanggan (Terfragmentasi secara horizontal berdasarkan branch_id)
CREATE TABLE IF NOT EXISTS customers (
  customer_id bigint PRIMARY KEY,
  customer_name varchar(100) NOT NULL,
  phone varchar(20),
  email varchar(100),
  address varchar(200),
  branch_id integer NOT NULL REFERENCES branches(branch_id)
);

-- 5. Transaksi Pesanan (Tersimpan di cabang kasir tempat transaksi dibuat)
-- Catatan: customer_id tidak diberi foreign key langsung ke customers lokal
-- karena mendukung transaksi lintas-cabang (~15% pelanggan cabang lain belanja di cabang ini).
CREATE TABLE IF NOT EXISTS orders (
  order_id bigint PRIMARY KEY,
  order_date timestamptz NOT NULL,
  customer_id bigint NOT NULL,
  branch_id integer NOT NULL REFERENCES branches(branch_id),
  total_amount numeric(12,2) NOT NULL CHECK (total_amount >= 0),
  status varchar(20) NOT NULL
);

-- 6. Detail Item Pesanan (Tersimpan bersama dengan orders di cabang lokal)
CREATE TABLE IF NOT EXISTS order_details (
  order_detail_id bigint PRIMARY KEY,
  order_id bigint NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id integer NOT NULL REFERENCES products(product_id),
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  subtotal numeric(12,2) NOT NULL CHECK (subtotal >= 0)
);

-- Indeks untuk optimasi query
CREATE INDEX IF NOT EXISTS idx_customers_branch ON customers(branch_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_order_details_order ON order_details(order_id);
CREATE INDEX IF NOT EXISTS idx_order_details_product ON order_details(product_id);
