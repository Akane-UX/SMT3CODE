-- Konfigurasi Foreign Data Wrapper untuk Node Pontianak
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

-- Peer 2: surabaya
DROP SERVER IF EXISTS surabaya_server CASCADE;
CREATE SERVER surabaya_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'pg-surabaya', port '5432', dbname 'nusamart');

CREATE USER MAPPING FOR lab
  SERVER surabaya_server
  OPTIONS (user 'lab', password 'DBTech3Q');

DROP SCHEMA IF EXISTS surabaya CASCADE;
CREATE SCHEMA surabaya;
IMPORT FOREIGN SCHEMA public
  FROM SERVER surabaya_server
  INTO surabaya;

-- Global Views
CREATE OR REPLACE VIEW v_all_customers AS
  SELECT * FROM public.customers
  UNION ALL
  SELECT * FROM jakarta.customers
  UNION ALL
  SELECT * FROM surabaya.customers;

CREATE OR REPLACE VIEW v_all_orders AS
  SELECT * FROM public.orders
  UNION ALL
  SELECT * FROM jakarta.orders
  UNION ALL
  SELECT * FROM surabaya.orders;

CREATE OR REPLACE VIEW v_all_order_details AS
  SELECT * FROM public.order_details
  UNION ALL
  SELECT * FROM jakarta.order_details
  UNION ALL
  SELECT * FROM surabaya.order_details;

CREATE OR REPLACE VIEW v_all_branch_stock AS
  SELECT * FROM public.branch_stock
  UNION ALL
  SELECT * FROM jakarta.branch_stock
  UNION ALL
  SELECT * FROM surabaya.branch_stock;
