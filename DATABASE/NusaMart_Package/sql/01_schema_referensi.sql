CREATE TABLE IF NOT EXISTS branches (
  branch_id integer PRIMARY KEY,
  branch_name varchar(100) NOT NULL,
  city varchar(50) NOT NULL,
  address varchar(200),
  phone varchar(20)
);

CREATE TABLE IF NOT EXISTS customers (
  customer_id bigint PRIMARY KEY,
  customer_name varchar(100) NOT NULL,
  phone varchar(20),
  email varchar(100),
  address varchar(200),
  branch_id integer NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
  product_id integer PRIMARY KEY,
  product_name varchar(150) NOT NULL,
  category varchar(50),
  unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  stock integer, -- MASALAH TERBUKA: apakah stock tunggal valid untuk semua cabang?
  is_active boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS orders (
  order_id bigint PRIMARY KEY,
  order_date timestamptz NOT NULL,
  customer_id bigint NOT NULL,
  branch_id integer NOT NULL,
  total_amount numeric(12,2) NOT NULL CHECK (total_amount >= 0),
  status varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS order_details (
  order_detail_id bigint PRIMARY KEY,
  order_id bigint NOT NULL,
  product_id integer NOT NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  subtotal numeric(12,2) NOT NULL CHECK (subtotal >= 0)
);

