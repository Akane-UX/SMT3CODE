-- Konfigurasi Foreign Data Wrapper untuk Node Surabaya
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Peer 1: jakarta
DROP SERVER IF EXISTS jakarta_server CASCADE;
CREATE SERVER jakarta_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'pg-jakarta', port '5432', dbname 'nusamart');

CREATE USER MAPPING FOR lab
  SERVER jakarta_server
  OPTIONS (user 'lab', password 'DBTech3Q');

DROP SCHEMA IF EXISTS jakarta CASCADE;
CREATE SCHEMA jakarta;
IMPORT FOREIGN SCHEMA public
  FROM SERVER jakarta_server
  INTO jakarta;

-- Peer 2: pontianak
DROP SERVER IF EXISTS pontianak_server CASCADE;
CREATE SERVER pontianak_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'pg-pontianak', port '5432', dbname 'nusamart');

CREATE USER MAPPING FOR lab
  SERVER pontianak_server
  OPTIONS (user 'lab', password 'DBTech3Q');

DROP SCHEMA IF EXISTS pontianak CASCADE;
CREATE SCHEMA pontianak;
IMPORT FOREIGN SCHEMA public
  FROM SERVER pontianak_server
  INTO pontianak;

-- Global Views
CREATE OR REPLACE VIEW v_all_customers AS
  SELECT * FROM public.customers
  UNION ALL
  SELECT * FROM jakarta.customers
  UNION ALL
  SELECT * FROM pontianak.customers;

CREATE OR REPLACE VIEW v_all_orders AS
  SELECT * FROM public.orders
  UNION ALL
  SELECT * FROM jakarta.orders
  UNION ALL
  SELECT * FROM pontianak.orders;

CREATE OR REPLACE VIEW v_all_order_details AS
  SELECT * FROM public.order_details
  UNION ALL
  SELECT * FROM jakarta.order_details
  UNION ALL
  SELECT * FROM pontianak.order_details;

CREATE OR REPLACE VIEW v_all_branch_stock AS
  SELECT * FROM public.branch_stock
  UNION ALL
  SELECT * FROM jakarta.branch_stock
  UNION ALL
  SELECT * FROM pontianak.branch_stock;
