
SELECT * FROM customers;
SELECT * FROM addresses;
SELECT * FROM categories;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;

-- 1. Tampilkan jumlah pembayaran berstatus paid, total nominalnya, rata-rata nominal, nominal
-- tertinggi, dan nominal terendah dari tabel payments. Hanya hitung pembayaran dengan
-- payment_status = paid.

SELECT
    COUNT (payment_status) AS total_paid,
    SUM (amount) AS total_nominal,
    AVG (amount) AS rata_nominal,
    Max (amount) AS nominal_tertinggi,
    MIN (amount) AS nominal_terendah
    FROM payments
    WHERE payment_status = 'paid';

-- 2. Tampilkan payment_method, jumlah transaksi pembayaran, total nominal, dan rata-rata nominal
-- pada setiap metode pembayaran, termasuk semua status pembayaran. Kelompokkan per metode
-- dan urutkan dari total nominal terbesar.
SELECT
    payment_method,
    COUNT(payment_method) AS jumlah_pembayaran,
    SUM(amount) AS total_nominal,
    AVG(amount) AS rata_nominal
    FROM payments
    GROUP BY payment_method
    ORDER BY total_nominal DESC;
-- 3. Tampilkan status pesanan, jumlah pesanan, total biaya pengiriman, serta rata-rata biaya
-- pengiriman. Hanya tampilkan kelompok status dengan total biaya pengiriman lebih dari 50.000.
-- Urutkan dari total biaya pengiriman terbesar.
SELECT
    status,
    COUNT(order_id) AS jumlah_pesanan,
    SUM(shipping_cost) AS total_biaya,
    AVG(shipping_cost) AS rata2_biaya_pengiriman
    FROM orders
    GROUP BY status
    HAVING SUM(shipping_cost) > 50000
    ORDER BY total_biaya DESC;
-- 4. Tampilkan tahun registrasi, bulan registrasi, dan jumlah customer yang terdaftar pada setiap
-- kombinasi tahun dan bulan dari kolom registered_at. Gunakan EXTRACT dan urutkan secara
-- kronologis.
SELECT
    EXTRACT(YEAR FROM registered_at) AS TAHUN,
    EXTRACT(MONTH FROM registered_at) AS BULAN,
    COUNT (*) AS JUMLAH_CUSTOMERS
    FROM customers
    GROUP BY
        TAHUN,
        BULAN
    ORDER BY
        TAHUN,
        BULAN;

-- 5. Tampilkan order_code, city tujuan pengiriman, shipping_cost, payment_method, amount, dan
-- payment_status. Ambil data dari orders, addresses, dan payments. Urutkan berdasarkan
-- order_code.
SELECT
    o.order_code,
    a.city,
    o.shipping_cost,
    p.payment_method,
    p.amount,
    p.payment_status
FROM orders AS o
LEFT JOIN addresses AS a
    ON o.customer_id = a.customer_id
JOIN payments AS p
    ON p.order_id = o.order_id
ORDER BY
    order_code;
-- 6. Tampilkan customer_code, full_name, registered_at, order_code, order_date, city tujuan
-- pengiriman, dan lama_hari_dari_registrasi_ke_order. Lama hari diperoleh dari tanggal order
-- dikurangi tanggal registrasi, tanpa menghitung jam.
-- 7. Tampilkan order_code, city tujuan, category_name, product_name, quantity, weight_gram, dan
-- berat_item_total_gram untuk setiap item pesanan. Berat item total = quantity × weight_gram.
-- Gunakan orders, addresses, order_items, products, dan categories.
-- 8. Kembangkan laporan berat item: tampilkan order_code, full_name, city, category_name,
-- product_name, quantity, berat_item_total_gram, dan kategori_berat_item. Jika berat item total >=
-- 5.000 gram, kategorinya Berat; jika >= 1.000 gram, Sedang; selain itu Ringan. Gunakan enam
-- tabel yang relevan.
-- 9. Tampilkan order_code, full_name, city, product_name, category_name, berat_item_total_gram,
-- payment_method, dan payment_status. Gunakan ketujuh tabel yang relevan. Tampilkan hanya
-- transaksi yang menggunakan QRIS atau Transfer Bank.
-- 10. Tampilkan product_code, product_name, category_name, stock, price, nilai_persediaan, dan
-- status_stok. Nilai persediaan = stock × price. Jika stock < 60, status stok = Perlu Restok; jika
-- stock <= 100, status stok = Cukup; selain itu = Melimpah. Urutkan dari nilai persediaan tertinggi.
-- 11. Tampilkan kota tujuan pengiriman, jumlah pesanan, total biaya pengiriman, dan rata-rata biaya
-- pengiriman. Gunakan addresses dan orders. Hanya tampilkan kota dengan rata-rata biaya
-- pengiriman di atas 20.000.
-- 12. Tampilkan status pesanan, jumlah produk berbeda yang dipesan, total unit barang, dan total berat
-- seluruh item dalam gram. Gunakan orders, order_items, dan products. Hanya tampilkan status
-- dengan total berat lebih dari 10.000 gram.
-- 13. Tampilkan order_code, status, dan shipping_cost dari pesanan yang biaya pengirimannya lebih
-- besar daripada rata-rata biaya pengiriman seluruh pesanan. Urutkan dari biaya tertinggi.
-- 14. Tampilkan customer_code, full_name, dan email untuk customer yang pernah menggunakan E-
-- Wallet atau Virtual Account dengan status pembayaran paid.
-- 15. Tampilkan payment_id, order_id, payment_method, amount, dan payment_status untuk
-- pembayaran paid yang memiliki nominal tertinggi di antara semua pembayaran paid.
-- 16. Tampilkan customer_code, full_name, dan email untuk customer yang belum mempunyai
-- pembayaran dengan status paid, termasuk customer yang belum pernah memesan.
-- 17. Gunakan CTE berat_pesanan untuk menghitung total_berat_gram setiap order dari order_items
-- dan products. Kemudian tampilkan order_code, city, total_berat_gram, dan total_berat_kg (gram
-- / 1.000) dari setiap pesanan.
-- 18. Gunakan CTE untuk membuat ringkasan total berat per pesanan. Tampilkan order_code, status,
-- total_berat_gram, dan kelas_paket: >= 10.000 gram = Paket Besar, >= 3.000 gram = Paket
-- Sedang, selain itu = Paket Kecil. CASE diterapkan pada hasil CTE, bukan di dalam fungsi SUM.
-- 19. Buat dua CTE: biaya_per_status untuk menjumlahkan shipping_cost per status pesanan, dan
-- rata_rata_status untuk menghitung rata-rata total biaya dari seluruh kelompok status. Tampilkan
-- status, total_biaya, rata_rata_total_biaya, dan selisih_biaya hanya untuk status dengan total biaya
-- di atas rata-rata tersebut.
-- 20. Buat VIEW bernama v_latihan_monitor_pengiriman yang menampilkan order_code, full_name,
-- city, status_pesanan, shipping_cost, payment_method, payment_status, amount, dan
-- nominal_di_luar_ongkir (amount - shipping_cost). Gunakan JOIN empat tabel. VIEW akan
-- digunakan pada soal berikutnya.
-- 21. Gunakan VIEW v_latihan_monitor_pengiriman untuk menampilkan payment_method,
-- jumlah_pesanan, dan total_ongkir. Kelompokkan berdasarkan payment_method; tampilkan
-- hanya metode dengan total ongkir minimal 50.000.
-- 22. Tampilkan payment_method, order_id, amount, dan urutan_nominal dalam masing-masing
-- metode pembayaran. Nomor urut dimulai dari 1 pada setiap metode, berdasarkan amount
-- tertinggi, dan stabilkan urutan dengan payment_id.
-- 23. Tampilkan order_code, status, shipping_cost, dan jumlah_pesanan_status untuk setiap pesanan.
-- Kolom jumlah_pesanan_status menyatakan jumlah pesanan yang memiliki status sama, tanpa
-- menghilangkan baris detail. Gunakan COUNT(*) OVER (PARTITION BY ...).
-- 24. Tampilkan order_code, order_date, shipping_cost, ongkir_pesanan_sebelumnya, dan
-- perubahan_ongkir dibandingkan pesanan sebelumnya secara kronologis. Gunakan LAG() dan
-- urutkan dengan order_date serta order_id.
-- 25. Tampilkan order_code, status, shipping_cost, dan peringkat_ongkir_status dengan
-- DENSE_RANK(). Peringkat biaya pengiriman tertinggi dihitung terpisah untuk masing-masing
-- status pesanan.