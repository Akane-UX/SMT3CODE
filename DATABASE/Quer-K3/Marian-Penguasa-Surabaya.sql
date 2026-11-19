SELECT current_database() AS nama_database,
       current_user AS nama_user,
       inet_server_port() AS port_internal,
       pg_is_in_recovery() AS standby;

CREATE TABLE IF NOT EXISTS site_identity (
    site_code VARCHAR(3) PRIMARY KEY,
    site_name VARCHAR(30) NOT NULL
);

INSERT INTO site_identity (site_code, site_name)
VALUES ('SBY', 'Surabaya')
ON CONFLICT (site_code) DO NOTHING;

SELECT * FROM site_identity;

-- Koneksi FDW ke Server Jakarta (nama server diseragamkan: server_jakarta)
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS server_jakarta
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'pg-jakarta', port '5432', dbname 'nusamart');

CREATE USER MAPPING IF NOT EXISTS FOR lab
SERVER server_jakarta
OPTIONS (user 'lab', password 'DBTech3Q');

CREATE SCHEMA IF NOT EXISTS remote_jakarta;

IMPORT FOREIGN SCHEMA public
LIMIT TO (demo_koneksi, branches, products)
FROM SERVER server_jakarta
INTO remote_jakarta;

SELECT * FROM remote_jakarta.demo_koneksi;

-- Tabel Lokal Cabang Surabaya
--Table Branches
CREATE TABLE IF NOT EXISTS public.branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

--Table Products
CREATE TABLE IF NOT EXISTS public.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

--Table Customers
CREATE TABLE IF NOT EXISTS public.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    address VARCHAR(200) NOT NULL,
    branch_id INT NOT NULL REFERENCES public.branches(branch_id)
);

--Table Orders
CREATE TABLE IF NOT EXISTS public.orders (
    order_id INT PRIMARY KEY,
    order_date TIMESTAMPTZ NOT NULL,
    customer_id INT NOT NULL REFERENCES public.customers(customer_id),
    branch_id INT NOT NULL REFERENCES public.branches(branch_id),
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'PAID'
);

--Table OrderDetails
CREATE TABLE IF NOT EXISTS public.order_details (
    order_detail_id BIGINT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES public.orders(order_id),
    product_id INT NOT NULL REFERENCES public.products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(12, 2) NOT NULL CHECK (subtotal >= 0)
);

CREATE TABLE public.branch_stock (
    branch_id INT NOT NULL REFERENCES public.branches(branch_id),
    product_id INT NOT NULL REFERENCES public.products(product_id),
    quantity_on_hand INT NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (branch_id, product_id)
);

-- 1. Pastikan koneksi FDW ke server Jakarta aktif
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS server_jakarta
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'pg-jakarta', port '5432', dbname 'nusamart');

CREATE USER MAPPING IF NOT EXISTS FOR lab
SERVER server_jakarta
OPTIONS (user 'lab', password 'DBTech3Q');

DROP SCHEMA IF EXISTS remote_jakarta CASCADE;
CREATE SCHEMA remote_jakarta;

IMPORT FOREIGN SCHEMA public
LIMIT TO (branches, products, customers, orders, order_details, branch_stock)
FROM SERVER server_jakarta
INTO remote_jakarta;

-- 2. Lepas FK customer_id di orders agar transaksi tamu luar kota (15%) bisa masuk
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_customer_id_fkey;

-- 3. INSERT INTO data khusus cabang Surabaya (branch_id = 2)
INSERT INTO public.branches
SELECT * FROM remote_jakarta.branches
ON CONFLICT (branch_id) DO NOTHING;

INSERT INTO public.products (product_id, product_name, category, unit_price, stock, is_active)
SELECT p.product_id, p.product_name, p.category, p.unit_price, bs.quantity_on_hand, p.is_active
FROM remote_jakarta.products p
JOIN remote_jakarta.branch_stock bs ON p.product_id = bs.product_id
WHERE bs.branch_id = 2
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO public.customers
SELECT * FROM remote_jakarta.customers
WHERE branch_id = 2
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO public.orders
SELECT * FROM remote_jakarta.orders
WHERE branch_id = 2
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO public.order_details
SELECT od.*
FROM remote_jakarta.order_details od
JOIN remote_jakarta.orders o ON od.order_id = o.order_id
WHERE o.branch_id = 2
ON CONFLICT (order_detail_id) DO NOTHING;

INSERT INTO public.branch_stock
SELECT * FROM remote_jakarta.branch_stock
WHERE branch_id = 2
ON CONFLICT (branch_id, product_id) DO NOTHING;

-- 4. Cek hasil jumlah data di Surabaya
-- Target: branches=3, products=15, customers=300, orders=300, order_details=600, branch_stock=15
SELECT 'branches' AS tabel, COUNT(*) FROM public.branches
UNION ALL SELECT 'products', COUNT(*) FROM public.products
UNION ALL SELECT 'customers', COUNT(*) FROM public.customers
UNION ALL SELECT 'orders', COUNT(*) FROM public.orders
UNION ALL SELECT 'order_details', COUNT(*) FROM public.order_details
UNION ALL SELECT 'branch_stock', COUNT(*) FROM public.branch_stock;

-- 1. Melihat daftar seluruh tabel di server tersebut
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- 2. Melihat isi data masing-masing tabel (jalankan satu per satu)
SELECT * FROM public.branches;
SELECT * FROM public.products;
SELECT * FROM public.customers;
SELECT * FROM public.orders;
SELECT * FROM public.order_details;
SELECT * FROM public.branch_stock;

-- ============================================================================
-- SERVER SURABAYA: IDENTITAS & OPERASIONAL LOKAL (BRANCH_ID = 2)
-- ============================================================================

-- S01: Cek identitas server Surabaya
SELECT * FROM public.site_identity;

-- S02: Cek jumlah baris seluruh tabel lokal di Surabaya
SELECT 'branches' AS tabel, COUNT(*) FROM public.branches
UNION ALL SELECT 'products', COUNT(*) FROM public.products
UNION ALL SELECT 'customers', COUNT(*) FROM public.customers
UNION ALL SELECT 'orders', COUNT(*) FROM public.orders
UNION ALL SELECT 'order_details', COUNT(*) FROM public.order_details
UNION ALL SELECT 'branch_stock', COUNT(*) FROM public.branch_stock;

-- S03: Tampilkan informasi profil cabang Surabaya dari tabel replika branches
SELECT * FROM public.branches WHERE branch_id = 2;

-- S04: Tampilkan seluruh produk beserta stok lokal Surabaya
SELECT product_id, product_name, category, unit_price, stock
FROM public.products
ORDER BY product_id;

-- S05: Tampilkan produk kategori 'Elektronik' di cabang Surabaya
SELECT product_id, product_name, unit_price, stock
FROM public.products
WHERE category = 'Elektronik'
ORDER BY unit_price DESC;

-- S06: Tampilkan 20 pelanggan pertama yang terdaftar di Surabaya
SELECT customer_id, customer_name, phone, email
FROM public.customers
ORDER BY customer_id
LIMIT 20;

-- S07: Validasi bahwa seluruh pelanggan di tabel lokal Surabaya ber-branch_id = 2
SELECT branch_id, COUNT(*) AS jumlah_pelanggan
FROM public.customers
GROUP BY branch_id;

-- S08: Validasi bahwa seluruh transaksi di tabel lokal Surabaya ber-branch_id = 2
SELECT branch_id, COUNT(*) AS jumlah_transaksi, SUM(total_amount) AS total_omzet
FROM public.orders
GROUP BY branch_id;

-- S09: Tampilkan 10 transaksi dengan nilai belanja tertinggi di Surabaya
SELECT order_id, order_date, customer_id, total_amount, status
FROM public.orders
ORDER BY total_amount DESC
LIMIT 10;

-- S10: Tampilkan rincian item dari transaksi pertama di Surabaya (order_id terkecil)
SELECT od.order_id, p.product_name, od.quantity, od.unit_price, od.subtotal
FROM public.order_details od
JOIN public.products p ON od.product_id = p.product_id
WHERE od.order_id = (SELECT MIN(order_id) FROM public.orders);

-- ============================================================================
-- SERVER SURABAYA: ANALITIK PENJUALAN & STOK LOKAL
-- ============================================================================

-- S11: Total omzet, jumlah struk, min, max, dan rata-rata nilai transaksi Surabaya
SELECT
    COUNT(order_id) AS total_struk,
    SUM(total_amount) AS total_omzet,
    ROUND(AVG(total_amount), 2) AS avg_struk,
    MIN(total_amount) AS struk_terkecil,
    MAX(total_amount) AS struk_terbesar
FROM public.orders;

-- S12: Rekapitulasi omzet harian cabang Surabaya
SELECT
    CAST(order_date AS DATE) AS tanggal,
    COUNT(order_id) AS jumlah_struk,
    SUM(total_amount) AS omzet_harian
FROM public.orders
GROUP BY CAST(order_date AS DATE)
ORDER BY tanggal;

-- S13: Akumulasi omzet berjalan (Running Total) harian cabang Surabaya
WITH harian_sby AS (
    SELECT CAST(order_date AS DATE) AS tanggal, SUM(total_amount) AS omzet
    FROM public.orders
    GROUP BY CAST(order_date AS DATE)
)
SELECT tanggal, omzet, SUM(omzet) OVER (ORDER BY tanggal) AS akumulasi_omzet
FROM harian_sby
ORDER BY tanggal;

-- S14: Analisis jam sibuk (Peak Hours) operasional kasir Surabaya
SELECT
    EXTRACT(HOUR FROM order_date) AS jam,
    COUNT(order_id) AS jumlah_transaksi,
    SUM(total_amount) AS total_omzet
FROM public.orders
GROUP BY EXTRACT(HOUR FROM order_date)
ORDER BY jumlah_transaksi DESC;

-- S15: Penjualan per kategori produk di cabang Surabaya
SELECT
    p.category,
    SUM(od.quantity) AS total_unit,
    SUM(od.subtotal) AS total_omzet
FROM public.order_details od
JOIN public.products p ON od.product_id = p.product_id
GROUP BY p.category
ORDER BY total_omzet DESC;

-- S16: Top 5 produk terlaris di Surabaya berdasarkan jumlah unit terjual
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(od.quantity) AS total_unit,
    SUM(od.subtotal) AS total_omzet
FROM public.order_details od
JOIN public.products p ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_unit DESC
LIMIT 5;

-- S17: 5 produk dengan penjualan terendah di Surabaya
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS total_unit,
    COALESCE(SUM(od.subtotal), 0) AS total_omzet
FROM public.products p
LEFT JOIN public.order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_unit ASC
LIMIT 5;

-- S18: Peringkat seluruh produk di Surabaya berdasarkan omzet (Window Function)
SELECT
    p.product_name,
    p.category,
    SUM(od.subtotal) AS omzet_sby,
    RANK() OVER (ORDER BY SUM(od.subtotal) DESC) AS peringkat
FROM public.order_details od
JOIN public.products p ON od.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY peringkat;

-- S19: Top 10 pelanggan lokal Surabaya berdasarkan total belanja
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS frekuensi,
    SUM(o.total_amount) AS total_belanja
FROM public.customers c
JOIN public.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_belanja DESC
LIMIT 10;

-- S20: Pelanggan lokal Surabaya yang belum pernah berbelanja di cabang Surabaya
SELECT c.customer_id, c.customer_name, c.phone
FROM public.customers c
LEFT JOIN public.orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- S21: Rata-rata jumlah item per struk di Surabaya
WITH basket_sby AS (
    SELECT order_id, SUM(quantity) AS total_item, COUNT(product_id) AS variasi_produk
    FROM public.order_details
    GROUP BY order_id
)
SELECT
    ROUND(AVG(total_item), 2) AS avg_item_per_struk,
    ROUND(AVG(variasi_produk), 2) AS avg_variasi_produk,
    MAX(total_item) AS max_item_satu_struk
FROM basket_sby;

-- S22: Transaksi di Surabaya yang nilainya di atas rata-rata transaksi Surabaya
SELECT order_id, order_date, customer_id, total_amount
FROM public.orders
WHERE total_amount > (SELECT AVG(total_amount) FROM public.orders)
ORDER BY total_amount DESC;

-- S23: Audit stok awal cabang Surabaya vs total unit terjual di Surabaya
SELECT
    p.product_id,
    p.product_name,
    bs.quantity_on_hand AS stok_awal_sby,
    COALESCE(SUM(od.quantity), 0) AS terjual_sby,
    (bs.quantity_on_hand - COALESCE(SUM(od.quantity), 0)) AS estimasi_sisa_stok
FROM public.branch_stock bs
JOIN public.products p ON bs.product_id = p.product_id
LEFT JOIN public.order_details od ON bs.product_id = od.product_id
GROUP BY p.product_id, p.product_name, bs.quantity_on_hand
ORDER BY estimasi_sisa_stok ASC;

-- S24: Total nilai aset inventaris gudang Surabaya
SELECT
    SUM(bs.quantity_on_hand) AS total_unit_gudang,
    SUM(bs.quantity_on_hand * p.unit_price) AS nilai_aset_sby
FROM public.branch_stock bs
JOIN public.products p ON bs.product_id = p.product_id;

-- S25: Audit integritas header orders vs sum(subtotal) order_details di Surabaya
SELECT o.order_id, o.total_amount, SUM(od.subtotal) AS hitung_ulang
FROM public.orders o
JOIN public.order_details od ON o.order_id = od.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> SUM(od.subtotal);

-- S26: Deteksi transaksi pelanggan tamu luar kota di Surabaya (secara lokal tanpa FDW)
SELECT o.order_id, o.order_date, o.customer_id, o.total_amount
FROM public.orders o
LEFT JOIN public.customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
ORDER BY o.order_date;

-- S27: Hitung rasio transaksi pelanggan lokal vs tamu luar kota di Surabaya
SELECT
    COUNT(*) AS total_transaksi,
    COUNT(c.customer_id) AS transaksi_warga_sby,
    COUNT(*) - COUNT(c.customer_id) AS transaksi_tamu_luar_kota,
    ROUND(100.0 * COUNT(c.customer_id) / COUNT(*), 2) AS persen_lokal
FROM public.orders o
LEFT JOIN public.customers c ON o.customer_id = c.customer_id;

-- S28: Total omzet yang berasal dari pelanggan tamu luar kota di Surabaya
SELECT
    COUNT(o.order_id) AS jumlah_transaksi_tamu,
    SUM(o.total_amount) AS total_omzet_tamu
FROM public.orders o
LEFT JOIN public.customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- S29: Produk yang paling banyak dibeli oleh pelanggan tamu luar kota di Surabaya
SELECT
    p.product_name,
    SUM(od.quantity) AS qty_dibeli_tamu,
    SUM(od.subtotal) AS omzet_dari_tamu
FROM public.order_details od
JOIN public.orders o ON od.order_id = o.order_id
JOIN public.products p ON od.product_id = p.product_id
LEFT JOIN public.customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
GROUP BY p.product_name
ORDER BY qty_dibeli_tamu DESC;

-- S30: Buat VIEW laporan penjualan produk lokal Surabaya
CREATE OR REPLACE VIEW public.v_penjualan_produk_sby AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(od.quantity), 0) AS total_terjual,
    COALESCE(SUM(od.subtotal), 0) AS total_omzet
FROM public.products p
LEFT JOIN public.order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, p.category;

-- ============================================================================
-- SERVER SURABAYA: QUERY TERDISTRIBUSI VIA FDW (remote_jakarta)
-- ============================================================================

-- S31: [FDW] Cek profil lengkap pelanggan tamu luar kota di Surabaya dengan lookup ke Jakarta
SELECT
    o.order_id,
    o.order_date,
    rc.customer_id,
    rc.customer_name,
    rb.branch_name AS cabang_asal_tamu,
    o.total_amount
FROM public.orders o
LEFT JOIN public.customers lc ON o.customer_id = lc.customer_id
JOIN remote_jakarta.customers rc ON o.customer_id = rc.customer_id
JOIN remote_jakarta.branches rb ON rc.branch_id = rb.branch_id
WHERE lc.customer_id IS NULL
ORDER BY o.order_date;

-- S32: [FDW] Hitung asal kota pelanggan tamu yang berbelanja di Surabaya
SELECT
    rb.branch_name AS asal_tamu,
    COUNT(o.order_id) AS jumlah_transaksi,
    SUM(o.total_amount) AS total_belanja
FROM public.orders o
LEFT JOIN public.customers lc ON o.customer_id = lc.customer_id
JOIN remote_jakarta.customers rc ON o.customer_id = rc.customer_id
JOIN remote_jakarta.branches rb ON rc.branch_id = rb.branch_id
WHERE lc.customer_id IS NULL
GROUP BY rb.branch_name;

-- S33: [FDW] Cek warga Surabaya yang pernah berbelanja di luar kota (Jakarta/Pontianak)
SELECT
    ro.order_id,
    ro.order_date,
    lc.customer_name,
    rb.branch_name AS belanja_di_cabang,
    ro.total_amount
FROM public.customers lc
JOIN remote_jakarta.orders ro ON lc.customer_id = ro.customer_id
JOIN remote_jakarta.branches rb ON ro.branch_id = rb.branch_id
WHERE ro.branch_id <> 2
ORDER BY ro.order_date;

-- S34: [FDW] Bandingkan stok lokal Surabaya vs stok gudang Jakarta per produk
SELECT
    p.product_id,
    p.product_name,
    ls.quantity_on_hand AS stok_surabaya,
    rs.quantity_on_hand AS stok_jakarta,
    (ls.quantity_on_hand - rs.quantity_on_hand) AS selisih_stok
FROM public.products p
JOIN public.branch_stock ls ON p.product_id = ls.product_id
JOIN remote_jakarta.branch_stock rs ON p.product_id = rs.product_id AND rs.branch_id = 1
ORDER BY p.product_id;

-- S35: [FDW] Bandingkan omzet lokal Surabaya terhadap total omzet nasional di Jakarta
SELECT
    (SELECT SUM(total_amount) FROM public.orders) AS omzet_surabaya,
    (SELECT SUM(total_amount) FROM remote_jakarta.orders) AS omzet_nasional,
    ROUND(
        100.0 * (SELECT SUM(total_amount) FROM public.orders) /
        (SELECT SUM(total_amount) FROM remote_jakarta.orders), 2
    ) AS porsi_surabaya_persen;

-- S36: [FDW] Validasi kesinkronan jumlah order Surabaya di lokal vs di Pusat Jakarta
SELECT
    (SELECT COUNT(*) FROM public.orders) AS jumlah_di_lokal_sby,
    (SELECT COUNT(*) FROM remote_jakarta.orders WHERE branch_id = 2) AS jumlah_di_pusat_jkt;

-- S37: [FDW] Deteksi order lokal Surabaya yang belum tersinkron ke Pusat Jakarta (Antrean Sync)
SELECT o.order_id, o.order_date, o.total_amount
FROM public.orders o
WHERE NOT EXISTS (
    SELECT 1 FROM remote_jakarta.orders ro WHERE ro.order_id = o.order_id
);

-- S38: [FDW] Cek apakah ada perubahan harga di katalog Pusat Jakarta dibanding lokal Surabaya
SELECT
    lp.product_id,
    lp.product_name,
    lp.unit_price AS harga_lokal_sby,
    rp.unit_price AS harga_pusat_jkt
FROM public.products lp
JOIN remote_jakarta.products rp ON lp.product_id = rp.product_id
WHERE lp.unit_price <> rp.unit_price;

-- S39: [FDW] Perbandingan rata-rata nilai struk Surabaya vs rata-rata nasional
SELECT
    ROUND((SELECT AVG(total_amount) FROM public.orders), 2) AS avg_struk_sby,
    ROUND((SELECT AVG(total_amount) FROM remote_jakarta.orders), 2) AS avg_struk_nasional;

-- S40: Menampilkan isi VIEW penjualan produk lokal Surabaya
SELECT * FROM public.v_penjualan_produk_sby ORDER BY total_omzet DESC;