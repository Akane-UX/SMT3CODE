# 🏪 NusaMart Distributed Database - Panduan Setup Cepat Lab Kampus

Panduan ini disiapkan agar Anda dapat langsung menjalankan dan mendemonstrasikan sistem basis data terdistribusi **NusaMart** di komputer laboratorium kampus tanpa hambatan (bahkan jika komputer lab tidak memiliki akses internet).

---

## ⚡ Cara Cepat (1-Click Automated Setup)

### 🪟 Jika Komputer Lab Menggunakan Windows
1. Buka folder `NusaMart_Package` di File Explorer.
2. Klik ganda (**Double Click**) pada berkas:
   ```cmd
   setup_lab.bat
   ```
3. Script otomatis akan:
   - Memeriksa ketersediaan Docker Desktop.
   - Memuat image Docker offline (`postgres:17-alpine` dan `pgadmin4`) dari folder `docker_images/` tanpa perlu internet.
   - Menyiapkan `.env` (`POSTGRES_PASSWORD=DBTech3Q`).
   - Menjalankan 3 kontainer PostgreSQL (`pg-jakarta`, `pg-surabaya`, `pg-pontianak`).
   - Menginisialisasi skema tabel, data terfragmentasi, dan Foreign Data Wrapper (FDW) secara otomatis (bisa via Python maupun SQL murni).
   - Menawarkan aktivasi pgAdmin web UI di port `5050` (opsional).

---

### 🐧 Jika Komputer Lab Menggunakan Linux / macOS
1. Buka Terminal pada direktori `NusaMart_Package`.
2. Jalankan perintah:
   ```bash
   ./setup_lab.sh
   ```

---

## 🛠️ Cara Manual (PowerShell / Terminal)

Jika Anda diminta asisten lab/dosen untuk menjalankan langkah demi langkah secara manual di PowerShell:

### 1. Salin File Konfigurasi Lingkungan
```powershell
Copy-Item .env.example .env
```

### 2. (Opsional) Load Docker Image Offline Jika Tidak Ada Internet
```powershell
docker load -i docker_images\postgres_17_alpine.tar.gz
```

### 3. Jalankan Kontainer Cluster
```powershell
docker compose up -d
docker compose ps
```

### 4. Inisialisasi Data & FDW (Pilih salah satu metode):
- **Opsi A (Menggunakan Python)**:
  ```powershell
  python load_data.py
  python setup_fdw.py
  ```
- **Opsi B (Tanpa Python / Pure SQL via Docker)**:
  ```powershell
  # Skema
  docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart < sql/schema.sql
  docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart < sql/schema.sql
  docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart < sql/schema.sql

  # Data Terfragmentasi
  docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart < sql/seed_jakarta.sql
  docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart < sql/seed_surabaya.sql
  docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart < sql/seed_pontianak.sql

  # Foreign Data Wrapper & Global Views
  docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart < sql/fdw_jakarta.sql
  docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart < sql/fdw_surabaya.sql
  docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart < sql/fdw_pontianak.sql
  ```

---

## 🖥️ Informasi Port & Kredensial Node

| Node Cabang | Host Port | Internal Docker Host | Port Docker | User | Password | Database |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Jakarta** | `5433` | `pg-jakarta` | `5432` | `lab` | `DBTech3Q` | `nusamart` |
| **Surabaya** | `5434` | `pg-surabaya` | `5432` | `lab` | `DBTech3Q` | `nusamart` |
| **Pontianak**| `5435` | `pg-pontianak`| `5432` | `lab` | `DBTech3Q` | `nusamart` |

---

## 🌐 Koneksi ke pgAdmin

### Opsi 1: Menggunakan pgAdmin Bawaan Komputer Lab
Jika di komputer lab sudah ada container pgAdmin yang berjalan:
1. Hubungkan container pgAdmin ke network NusaMart:
   ```powershell
   docker network connect nusamart-net <NAMA_CONTAINER_PGADMIN>
   ```
2. Di web pgAdmin, daftarkan 3 server:
   - **Jakarta**: Host = `pg-jakarta`, Port = `5432`, DB = `nusamart`, User = `lab`, Pass = `DBTech3Q`
   - **Surabaya**: Host = `pg-surabaya`, Port = `5432`, DB = `nusamart`, User = `lab`, Pass = `DBTech3Q`
   - **Pontianak**: Host = `pg-pontianak`, Port = `5432`, DB = `nusamart`, User = `lab`, Pass = `DBTech3Q`

### Opsi 2: Menggunakan pgAdmin Paket NusaMart
Jika di komputer lab belum ada pgAdmin:
```powershell
docker compose --profile with-pgadmin up -d pgadmin
```
Buka browser ke `http://localhost:5050`:
- **Email**: `lab@nusamart.com`
- **Password**: `DBTech3Q`

---

## 🎯 Cheatsheet Query Demo untuk Dosen / Asisten Lab

### 1. Verifikasi Status Node Mandiri (Independensi Node)
Jalankan di Query Tool mana saja:
```sql
SELECT current_database() AS database,
       current_user AS user,
       inet_server_port() AS port,
       pg_is_in_recovery() AS standby;
```

### 2. Kueri Global Terdistribusi (Global View)
Melihat seluruh pelanggan se-Indonesia langsung dari node Jakarta:
```sql
SELECT branch_id, COUNT(*) AS total_pelanggan
FROM v_all_customers
GROUP BY branch_id
ORDER BY branch_id;
```

### 3. Kueri Cross-Branch Transparan (Pelanggan Cabang Lain yang Belanja di Surabaya)
Dari node Surabaya, cek transaksi yang dilakukan oleh customer asal Jakarta atau Pontianak:
```sql
SELECT o.order_id, o.order_date, c.customer_name, c.branch_id AS home_branch, o.total_amount
FROM orders o
JOIN v_all_customers c ON o.customer_id = c.customer_id
WHERE c.branch_id <> 2
LIMIT 10;
```

### 4. Pembuktian Akses Remote FDW (Bukan Replikasi Pasif)
1. Di Surabaya:
   ```sql
   UPDATE branch_stock SET quantity_on_hand = 999 WHERE product_id = 1;
   ```
2. Langsung cek dari Jakarta melalui skema remote:
   ```sql
   SELECT * FROM surabaya.branch_stock WHERE product_id = 1;
   ```
   *Data terupdate secara seketika (real-time), membuktikan FDW membaca data langsung dari node sumber.*
