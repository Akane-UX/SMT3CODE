SELECT current_database() AS nama_database,
       current_user AS nama_user,
       inet_server_port() AS port_internal,
       pg_is_in_recovery() AS standby;

CREATE TABLE IF NOT EXISTS site_identity (
    site_code VARCHAR(3) PRIMARY KEY,
    site_name VARCHAR(30) NOT NULL
);

INSERT INTO site_identity (site_code, site_name)
VALUES ('JKT', 'Jakarta')
ON CONFLICT (site_code) DO NOTHING;

SELECT * FROM site_identity;

CREATE TABLE IF NOT EXISTS public.demo_koneksi (
    id INT PRIMARY KEY,
    keterangan TEXT NOT NULL
);

INSERT INTO public.demo_koneksi (id, keterangan)
VALUES (1, 'Data milik Jakarta')
ON CONFLICT (id) DO NOTHING;

UPDATE public.demo_koneksi
SET keterangan = 'Jakarta: data sudah diperbarui oleh marian'
WHERE id = 1;

SELECT * FROM public.demo_koneksi;

-- 1. TABEL BRANCHES
CREATE TABLE IF NOT EXISTS public.branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

-- 2. TABEL PRODUCTS
CREATE TABLE IF NOT EXISTS public.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3. TABEL CUSTOMERS
CREATE TABLE IF NOT EXISTS public.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    address VARCHAR(200) NOT NULL,
    branch_id INT NOT NULL REFERENCES public.branches(branch_id)
);

-- 4. TABEL ORDERS
CREATE TABLE IF NOT EXISTS public.orders (
    order_id INT PRIMARY KEY,
    order_date TIMESTAMPTZ NOT NULL,
    customer_id INT NOT NULL REFERENCES public.customers(customer_id),
    branch_id INT NOT NULL REFERENCES public.branches(branch_id),
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'PAID'
);

-- 5. TABEL ORDER_DETAILS
CREATE TABLE IF NOT EXISTS public.order_details (
    order_detail_id BIGINT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES public.orders(order_id),
    product_id INT NOT NULL REFERENCES public.products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(12, 2) NOT NULL CHECK (subtotal >= 0)
);

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'branches';
--Tabel seblumnya di hapus karena tidak sesuai dan sangat wo cao
-- 1. Hapus tabel lama agar tidak bentrok dengan struktur baru
DROP TABLE IF EXISTS public.order_details CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;
DROP TABLE IF EXISTS public.customers CASCADE;
DROP TABLE IF EXISTS public.branch_stock CASCADE;
DROP TABLE IF EXISTS public.products CASCADE;
DROP TABLE IF EXISTS public.branches CASCADE;

-- 2. Buat ulang 5 tabel utama sesuai struktur CSV

--tabel branches
CREATE TABLE public.branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

--tabel products
CREATE TABLE public.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- tabel products
CREATE TABLE public.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    address VARCHAR(200) NOT NULL,
    branch_id INT NOT NULL REFERENCES public.branches(branch_id)
);

--tabel orders
CREATE TABLE public.orders (
    order_id INT PRIMARY KEY,
    order_date TIMESTAMPTZ NOT NULL,
    customer_id INT NOT NULL REFERENCES public.customers(customer_id),
    branch_id INT NOT NULL REFERENCES public.branches(branch_id),
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'PAID'
);

--tabel order_details
CREATE TABLE public.order_details (
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

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

SELECT 'branches' AS tabel, COUNT(*) FROM public.branches
UNION ALL SELECT 'products', COUNT(*) FROM public.products
UNION ALL SELECT 'customers', COUNT(*) FROM public.customers
UNION ALL SELECT 'orders', COUNT(*) FROM public.orders
UNION ALL SELECT 'order_details', COUNT(*) FROM public.order_details
UNION ALL SELECT 'branch_stock', COUNT(*) FROM public.branch_stock;

select * from public.order_details;
-- Query JKT
-- ============================================================================
-- SERVER JAKARTA: IDENTITAS, EKSPLORASI GLOBAL, & OPERASIONAL CABANG 1
-- ============================================================================

-- J01: Cek identitas server aktif
SELECT * FROM public.site_identity;

-- J02: Tampilkan seluruh cabang NusantaraMart
SELECT * FROM public.branches ORDER BY branch_id;

-- J03: Tampilkan seluruh katalog produk aktif urut dari harga termurah
SELECT product_id, product_name, category, unit_price, stock
FROM public.products
WHERE is_active = TRUE
ORDER BY unit_price ASC;

-- J04: Hitung jumlah produk per kategori
SELECT category, COUNT(*) AS jumlah_produk, ROUND(AVG(unit_price), 2) AS rata_rata_harga
FROM public.products
GROUP BY category
ORDER BY rata_rata_harga DESC;

-- J05: Tampilkan 20 pelanggan pertama di cabang Jakarta (branch_id = 1)
SELECT customer_id, customer_name, phone, email
FROM public.customers
WHERE branch_id = 1
ORDER BY customer_id
LIMIT 20;

-- J06: Hitung total pelanggan terdaftar di setiap cabang secara nasional
SELECT b.branch_id, b.branch_name, COUNT(c.customer_id) AS total_pelanggan
FROM public.branches b
LEFT JOIN public.customers c ON b.branch_id = c.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY b.branch_id;

-- J07: Cek rentang customer_id per cabang untuk validasi fragmentasi ID
SELECT branch_id, MIN(customer_id) AS min_id, MAX(customer_id) AS max_id, COUNT(*) AS total
FROM public.customers
GROUP BY branch_id
ORDER BY branch_id;

-- J08: Cek rentang order_id per cabang
SELECT branch_id, MIN(order_id) AS min_order, MAX(order_id) AS max_order, COUNT(*) AS total_order
FROM public.orders
GROUP BY branch_id
ORDER BY branch_id;

-- J09: Tampilkan 15 transaksi terbesar secara nasional
SELECT o.order_id, o.order_date, b.branch_name, c.customer_name, o.total_amount
FROM public.orders o
JOIN public.branches b ON o.branch_id = b.branch_id
JOIN public.customers c ON o.customer_id = c.customer_id
ORDER BY o.total_amount DESC
LIMIT 15;

-- J10: Tampilkan transaksi khusus cabang Jakarta dengan nilai di atas Rp300.000
SELECT order_id, order_date, customer_id, total_amount
FROM public.orders
WHERE branch_id = 1 AND total_amount > 300000
ORDER BY total_amount DESC;

-- ============================================================================
-- SERVER JAKARTA: KONSOLIDASI OMZET & PERFORMA NASIONAL
-- ============================================================================

-- J11: Perbandingan total transaksi, omzet, dan rata-rata struk antar-cabang
SELECT
    b.branch_id,
    b.branch_name,
    COUNT(o.order_id) AS total_struk,
    SUM(o.total_amount) AS total_omzet,
    ROUND(AVG(o.total_amount), 2) AS avg_struk
FROM public.branches b
LEFT JOIN public.orders o ON b.branch_id = o.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_omzet DESC;

-- J12: Persentase kontribusi omzet tiap cabang terhadap total omzet nasional
WITH omzet_cabang AS (
    SELECT b.branch_name, SUM(o.total_amount) AS omzet
    FROM public.orders o
    JOIN public.branches b ON o.branch_id = b.branch_id
    GROUP BY b.branch_name
)
SELECT
    branch_name,
    omzet,
    ROUND(100.0 * omzet / SUM(omzet) OVER (), 2) AS kontribusi_persen
FROM omzet_cabang
ORDER BY omzet DESC;

-- J13: Total unit terjual dan pendapatan nasional per kategori produk
SELECT
    p.category,
    SUM(od.quantity) AS total_unit,
    SUM(od.subtotal) AS total_pendapatan
FROM public.order_details od
JOIN public.products p ON od.product_id = p.product_id
GROUP BY p.category
ORDER BY total_pendapatan DESC;

-- J14: Top 5 produk terlaris secara nasional berdasarkan kuantitas terjual
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(od.quantity) AS total_terjual,
    SUM(od.subtotal) AS total_omzet
FROM public.order_details od
JOIN public.products p ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_terjual DESC
LIMIT 5;

-- J15: Top 5 produk penyumbang omzet tertinggi secara nasional
SELECT
    p.product_id,
    p.product_name,
    SUM(od.subtotal) AS total_omzet,
    SUM(od.quantity) AS total_unit
FROM public.order_details od
JOIN public.products p ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_omzet DESC
LIMIT 5;

-- J16: Rekapitulasi omzet harian per cabang
SELECT
    CAST(o.order_date AS DATE) AS tanggal,
    b.branch_name,
    COUNT(o.order_id) AS jumlah_order,
    SUM(o.total_amount) AS omzet_harian
FROM public.orders o
JOIN public.branches b ON o.branch_id = b.branch_id
GROUP BY CAST(o.order_date AS DATE), b.branch_name
ORDER BY tanggal, b.branch_name;

-- J17: Akumulasi omzet berjalan (Running Total) harian nasional
WITH harian AS (
    SELECT CAST(order_date AS DATE) AS tanggal, SUM(total_amount) AS omzet
    FROM public.orders
    GROUP BY CAST(order_date AS DATE)
)
SELECT
    tanggal,
    omzet,
    SUM(omzet) OVER (ORDER BY tanggal) AS akumulasi_omzet
FROM harian
ORDER BY tanggal;

-- J18: Distribusi transaksi nasional berdasarkan jam operasional
SELECT
    EXTRACT(HOUR FROM order_date) AS jam,
    COUNT(order_id) AS jumlah_struk,
    SUM(total_amount) AS total_omzet
FROM public.orders
GROUP BY EXTRACT(HOUR FROM order_date)
ORDER BY jam;

-- J19: Rata-rata jumlah item dan variasi produk per struk di tiap cabang
WITH basket AS (
    SELECT o.order_id, o.branch_id, SUM(od.quantity) AS total_item, COUNT(od.product_id) AS jenis_produk
    FROM public.orders o
    JOIN public.order_details od ON o.order_id = od.order_id
    GROUP BY o.order_id, o.branch_id
)
SELECT
    b.branch_name,
    ROUND(AVG(basket.total_item), 2) AS avg_item_per_struk,
    ROUND(AVG(basket.jenis_produk), 2) AS avg_jenis_per_struk
FROM basket
JOIN public.branches b ON basket.branch_id = b.branch_id
GROUP BY b.branch_name, b.branch_id
ORDER BY b.branch_id;

-- J20: Top 10 pelanggan paling loyal (total belanja terbesar) secara nasional
SELECT
    c.customer_id,
    c.customer_name,
    b.branch_name AS cabang_asal,
    COUNT(o.order_id) AS frekuensi,
    SUM(o.total_amount) AS total_belanja
FROM public.customers c
JOIN public.branches b ON c.branch_id = b.branch_id
JOIN public.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, b.branch_name
ORDER BY total_belanja DESC
LIMIT 10;

-- ============================================================================
-- SERVER JAKARTA: ANALISIS LINTAS CABANG & FRAGMENTASI (TANTANGAN 2, 3, 5)
-- ============================================================================

-- J21: Daftar seluruh transaksi lintas cabang (pelanggan luar kota)
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name,
    b_asal.branch_name AS cabang_asal,
    b_toko.branch_name AS cabang_belanja,
    o.total_amount
FROM public.orders o
JOIN public.customers c ON o.customer_id = c.customer_id
JOIN public.branches b_asal ON c.branch_id = b_asal.branch_id
JOIN public.branches b_toko ON o.branch_id = b_toko.branch_id
WHERE c.branch_id <> o.branch_id
ORDER BY o.order_date;

-- J22: Persentase transaksi lokal vs lintas cabang di tiap cabang
SELECT
    b.branch_name,
    COUNT(*) AS total_transaksi,
    SUM(CASE WHEN c.branch_id = o.branch_id THEN 1 ELSE 0 END) AS lokal,
    SUM(CASE WHEN c.branch_id <> o.branch_id THEN 1 ELSE 0 END) AS lintas_cabang,
    ROUND(100.0 * SUM(CASE WHEN c.branch_id = o.branch_id THEN 1 ELSE 0 END) / COUNT(*), 2) AS persen_lokal,
    ROUND(100.0 * SUM(CASE WHEN c.branch_id <> o.branch_id THEN 1 ELSE 0 END) / COUNT(*), 2) AS persen_lintas
FROM public.orders o
JOIN public.customers c ON o.customer_id = c.customer_id
JOIN public.branches b ON o.branch_id = b.branch_id
GROUP BY b.branch_name, b.branch_id
ORDER BY b.branch_id;

-- J23: Matriks arus kunjungan pelanggan antar-cabang (Asal -> Tujuan)
SELECT
    b_asal.branch_name AS asal_pelanggan,
    b_toko.branch_name AS lokasi_belanja,
    COUNT(o.order_id) AS jumlah_transaksi,
    SUM(o.total_amount) AS total_nilai
FROM public.orders o
JOIN public.customers c ON o.customer_id = c.customer_id
JOIN public.branches b_asal ON c.branch_id = b_asal.branch_id
JOIN public.branches b_toko ON o.branch_id = b_toko.branch_id
GROUP BY b_asal.branch_name, b_toko.branch_name
ORDER BY b_asal.branch_name, b_toko.branch_name;

-- J24: Pelanggan yang pernah berbelanja di lebih dari 1 cabang berbeda
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.branch_id) AS jumlah_cabang_dikunjungi,
    COUNT(o.order_id) AS total_transaksi
FROM public.customers c
JOIN public.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.branch_id) > 1
ORDER BY jumlah_cabang_dikunjungi DESC, total_transaksi DESC;

-- J25: Pelanggan yang belum pernah melakukan transaksi sama sekali
SELECT c.customer_id, c.customer_name, b.branch_name
FROM public.customers c
JOIN public.branches b ON c.branch_id = b.branch_id
LEFT JOIN public.orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- J26: Perbandingan stok per cabang (Pivot 3 cabang) untuk setiap produk
SELECT
    p.product_id,
    p.product_name,
    p.stock AS stok_master_products,
    MAX(CASE WHEN bs.branch_id = 1 THEN bs.quantity_on_hand END) AS stok_jakarta,
    MAX(CASE WHEN bs.branch_id = 2 THEN bs.quantity_on_hand END) AS stok_surabaya,
    MAX(CASE WHEN bs.branch_id = 3 THEN bs.quantity_on_hand END) AS stok_pontianak,
    SUM(bs.quantity_on_hand) AS total_stok_nasional
FROM public.products p
JOIN public.branch_stock bs ON p.product_id = bs.product_id
GROUP BY p.product_id, p.product_name, p.stock
ORDER BY p.product_id;

-- J27: Produk dengan stok cabang paling sedikit secara nasional
SELECT b.branch_name, p.product_name, bs.quantity_on_hand
FROM public.branch_stock bs
JOIN public.branches b ON bs.branch_id = b.branch_id
JOIN public.products p ON bs.product_id = p.product_id
ORDER BY bs.quantity_on_hand ASC
LIMIT 10;

-- J28: Estimasi sisa stok nasional per produk setelah dikurangi total penjualan
SELECT
    p.product_id,
    p.product_name,
    (SELECT SUM(bs.quantity_on_hand) FROM public.branch_stock bs WHERE bs.product_id = p.product_id) AS stok_awal_nasional,
    COALESCE(SUM(od.quantity), 0) AS total_terjual_nasional,
    (SELECT SUM(bs.quantity_on_hand) FROM public.branch_stock bs WHERE bs.product_id = p.product_id) - COALESCE(SUM(od.quantity), 0) AS estimasi_sisa
FROM public.products p
LEFT JOIN public.order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY estimasi_sisa ASC;

-- J29: Peringkat produk terlaris di dalam masing-masing cabang (Window Function)
WITH jual_cabang AS (
    SELECT b.branch_name, p.product_name, SUM(od.subtotal) AS omzet, SUM(od.quantity) AS qty
    FROM public.order_details od
    JOIN public.orders o ON od.order_id = o.order_id
    JOIN public.branches b ON o.branch_id = b.branch_id
    JOIN public.products p ON od.product_id = p.product_id
    GROUP BY b.branch_name, p.product_name
)
SELECT
    branch_name,
    product_name,
    qty,
    omzet,
    RANK() OVER (PARTITION BY branch_name ORDER BY omzet DESC) AS ranking_cabang
FROM jual_cabang
ORDER BY branch_name, ranking_cabang;

-- J30: Top 3 pelanggan dengan belanja tertinggi di masing-masing cabang
WITH top_cust AS (
    SELECT
        b.branch_name,
        c.customer_id,
        c.customer_name,
        SUM(o.total_amount) AS total_belanja,
        DENSE_RANK() OVER (PARTITION BY b.branch_name ORDER BY SUM(o.total_amount) DESC) AS peringkat
    FROM public.orders o
    JOIN public.customers c ON o.customer_id = c.customer_id
    JOIN public.branches b ON o.branch_id = b.branch_id
    GROUP BY b.branch_name, c.customer_id, c.customer_name
)
SELECT * FROM top_cust WHERE peringkat <= 3 ORDER BY branch_name, peringkat;

-- ============================================================================
-- SERVER JAKARTA: AUDIT INTEGRITAS, VIEW GLOBAL, & RINGKASAN EKSEKUTIF
-- ============================================================================

-- J31: Audit konsistensi total_amount di orders vs SUM(subtotal) di order_details
SELECT
    o.order_id,
    o.total_amount,
    SUM(od.subtotal) AS hitung_ulang,
    (o.total_amount - SUM(od.subtotal)) AS selisih
FROM public.orders o
JOIN public.order_details od ON o.order_id = od.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> SUM(od.subtotal);

-- J32: Audit kesesuaian harga satuan di order_details dengan master products
SELECT
    od.order_detail_id,
    od.order_id,
    p.product_name,
    p.unit_price AS harga_master,
    od.unit_price AS harga_transaksi
FROM public.order_details od
JOIN public.products p ON od.product_id = p.product_id
WHERE od.unit_price <> p.unit_price;

-- J33: Audit kesesuaian subtotal = quantity * unit_price di order_details
SELECT order_detail_id, order_id, quantity, unit_price, subtotal
FROM public.order_details
WHERE subtotal <> (quantity * unit_price);

-- J34: Transaksi yang nilainya di atas rata-rata nasional
SELECT order_id, branch_id, customer_id, total_amount
FROM public.orders
WHERE total_amount > (SELECT AVG(total_amount) FROM public.orders)
ORDER BY total_amount DESC
LIMIT 20;

-- J35: Performa penjualan per kategori produk di masing-masing cabang
SELECT
    b.branch_name,
    p.category,
    SUM(od.quantity) AS unit_terjual,
    SUM(od.subtotal) AS omzet_kategori
FROM public.order_details od
JOIN public.orders o ON od.order_id = o.order_id
JOIN public.branches b ON o.branch_id = b.branch_id
JOIN public.products p ON od.product_id = p.product_id
GROUP BY b.branch_name, p.category
ORDER BY b.branch_name, omzet_kategori DESC;

-- J36: Nilai total inventaris (stok * harga satuan) per cabang
SELECT
    b.branch_name,
    SUM(bs.quantity_on_hand) AS total_unit_gudang,
    SUM(bs.quantity_on_hand * p.unit_price) AS nilai_aset_stok
FROM public.branch_stock bs
JOIN public.branches b ON bs.branch_id = b.branch_id
JOIN public.products p ON bs.product_id = p.product_id
GROUP BY b.branch_name, b.branch_id
ORDER BY b.branch_id;

-- J37: Daftar transaksi Pontianak pada jam gangguan 14:00-16:00 (Monitoring Pusat)
SELECT order_id, order_date, customer_id, total_amount
FROM public.orders
WHERE branch_id = 3
  AND EXTRACT(HOUR FROM order_date) >= 14
  AND EXTRACT(HOUR FROM order_date) < 16
ORDER BY order_date;

-- J38: Membuat VIEW ringkasan omzet nasional untuk dashboard pusat
CREATE OR REPLACE VIEW public.v_ringkasan_nasional AS
SELECT
    b.branch_id,
    b.branch_name,
    b.city,
    COUNT(DISTINCT o.order_id) AS total_transaksi,
    COALESCE(SUM(o.total_amount), 0) AS total_omzet
FROM public.branches b
LEFT JOIN public.orders o ON b.branch_id = o.branch_id
GROUP BY b.branch_id, b.branch_name, b.city;

-- J39: Menampilkan isi VIEW ringkasan nasional
SELECT * FROM public.v_ringkasan_nasional ORDER BY total_omzet DESC;

-- J40: Executive Dashboard lengkap seluruh cabang NusantaraMart
SELECT
    b.branch_id,
    b.branch_name,
    (SELECT COUNT(*) FROM public.customers c WHERE c.branch_id = b.branch_id) AS member_lokal,
    (SELECT SUM(bs.quantity_on_hand) FROM public.branch_stock bs WHERE bs.branch_id = b.branch_id) AS stok_gudang,
    COUNT(DISTINCT o.order_id) AS jumlah_struk,
    COALESCE(SUM(od.quantity), 0) AS barang_terjual,
    COALESCE(SUM(od.subtotal), 0) AS total_omzet
FROM public.branches b
LEFT JOIN public.orders o ON b.branch_id = o.branch_id
LEFT JOIN public.order_details od ON o.order_id = od.order_id
GROUP BY b.branch_id, b.branch_name
ORDER BY b.branch_id;