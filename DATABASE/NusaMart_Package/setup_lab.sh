#!/usr/bin/env bash
set -e

echo "===================================================================="
echo "     NUSAMART DISTRIBUTED DATABASE - LAB SETUP (LINUX/MAC)"
echo "===================================================================="
echo ""

# 1. Verifikasi Docker
if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker tidak terdeteksi atau daemon Docker belum berjalan!"
    echo "Jalankan 'sudo systemctl start docker' jika menggunakan Linux native."
    exit 1
fi
echo "[OK] Docker terdeteksi aktif."

# 2. Cek image postgres:17-alpine
if ! docker image inspect postgres:17-alpine >/dev/null 2>&1; then
    echo "[*] Image postgres:17-alpine belum ada di Docker lokal."
    if [ -f "docker_images/postgres_17_alpine.tar.gz" ]; then
        echo "[*] Memuat image offline dari docker_images/postgres_17_alpine.tar.gz..."
        docker load -i docker_images/postgres_17_alpine.tar.gz
    else
        echo "[*] Mengunduh postgres:17-alpine dari Docker Hub..."
        docker pull postgres:17-alpine
    fi
else
    echo "[OK] Image postgres:17-alpine sudah tersedia."
fi

# 3. Siapkan file .env jika belum ada
if [ ! -f ".env" ]; then
    echo "[*] Membuat file .env dari .env.example..."
    cp .env.example .env
fi
echo "[OK] File .env siap."

# 4. Jalankan cluster 3 Node PostgreSQL
echo ""
echo "[*] Menjalankan 3 Node PostgreSQL (Jakarta, Surabaya, Pontianak)..."
docker compose up -d

echo "[*] Menunggu node PostgreSQL siap menerima koneksi (5 detik)..."
sleep 5

# 5. Memuat Data & Skema
echo ""
echo "[*] Menginisialisasi Skema, Data Terfragmentasi, dan FDW..."

if command -v python3 >/dev/null 2>&1; then
    echo "[*] Python3 terdeteksi. Menjalankan load_data.py dan setup_fdw.py..."
    python3 load_data.py
    python3 setup_fdw.py
else
    echo "[*] Python3 tidak terdeteksi. Menjalankan seed SQL murni via Docker exec..."
    docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/schema.sql
    docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/schema.sql
    docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/schema.sql

    docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/seed_jakarta.sql
    docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/seed_surabaya.sql
    docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/seed_pontianak.sql

    docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/fdw_jakarta.sql
    docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/fdw_surabaya.sql
    docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql/fdw_pontianak.sql
    echo "[OK] Data dan FDW berhasil diinisialisasi via SQL."
fi

# 6. Informasi Selesai
echo ""
echo "===================================================================="
echo "Cluster NusaMart Berhasil Dijalankan!"
echo "===================================================================="
echo "- Node Jakarta   : localhost:5433 (Container: pg-jakarta)"
echo "- Node Surabaya  : localhost:5434 (Container: pg-surabaya)"
echo "- Node Pontianak : localhost:5435 (Container: pg-pontianak)"
echo "- User Database  : lab"
echo "- Password       : DBTech3Q"
echo "- Database Name  : nusamart"
echo "===================================================================="
echo ""
read -p "Nyalakan pgAdmin web UI (port 5050)? [y/N]: " start_pga
if [[ "$start_pga" =~ ^[Yy]$ ]]; then
    if ! docker image inspect dpage/pgadmin4:latest >/dev/null 2>&1; then
        if [ -f "docker_images/pgadmin4_latest.tar.gz" ]; then
            echo "[*] Memuat image pgAdmin offline..."
            docker load -i docker_images/pgadmin4_latest.tar.gz
        fi
    fi
    docker compose --profile with-pgadmin up -d pgadmin
    echo "[*] pgAdmin siap diakses di: http://localhost:5050"
    echo "    Email   : lab@nusamart.com"
    echo "    Password: DBTech3Q"
fi

echo ""
echo "Setup Selesai!"
