@echo off
setlocal enabledelayedexpansion
title NusaMart Distributed Database - Lab Setup Helper

echo ====================================================================
echo      NUSAMART DISTRIBUTED DATABASE - LAB SETUP (WINDOWS)
echo ====================================================================
echo.

:: 1. Verifikasi Docker
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker tidak terdeteksi atau Docker Desktop belum berjalan!
    echo Silakan buka Docker Desktop terlebih dahulu, lalu jalankan script ini kembali.
    echo.
    pause
    exit /b 1
)
echo [OK] Docker Desktop terdeteksi aktif.

:: 2. Cek image postgres:17-alpine
docker image inspect postgres:17-alpine >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Image postgres:17-alpine belum ada di Docker lokal.
    if exist "docker_images\postgres_17_alpine.tar.gz" (
        echo [*] Memuat image offline dari docker_images\postgres_17_alpine.tar.gz...
        docker load -i docker_images\postgres_17_alpine.tar.gz
    ) else (
        echo [*] Mengunduh postgres:17-alpine dari Docker Hub...
        docker pull postgres:17-alpine
    )
) else (
    echo [OK] Image postgres:17-alpine sudah tersedia.
)

:: 3. Siapkan file .env jika belum ada
if not exist ".env" (
    echo [*] Membuat file .env dari .env.example...
    copy .env.example .env >nul
)
echo [OK] File .env siap.

:: 4. Jalankan cluster 3 Node PostgreSQL
echo.
echo [*] Menjalankan 3 Node PostgreSQL (Jakarta, Surabaya, Pontianak)...
docker compose up -d

:: Tunggu 6 detik agar database selesai inisialisasi
echo [*] Menunggu node PostgreSQL siap menerima koneksi...
timeout /t 6 /nobreak >nul

:: 5. Memuat Data & Skema
echo.
echo [*] Menginisialisasi Skema, Data Terfragmentasi, dan FDW...

python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Python terdeteksi. Menjalankan load_data.py dan setup_fdw.py...
    python load_data.py
    python setup_fdw.py
) else (
    echo [*] Python tidak terdeteksi di PATH. Menjalankan seed SQL murni via Docker exec...
    
    :: Inisialisasi skema di semua node
    docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\schema.sql
    docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\schema.sql
    docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\schema.sql
    
    :: Inisialisasi data terfragmentasi
    docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\seed_jakarta.sql
    docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\seed_surabaya.sql
    docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\seed_pontianak.sql
    
    :: Inisialisasi Foreign Data Wrapper & Global Views
    docker exec -i nusamart-lab-pg-jakarta-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\fdw_jakarta.sql
    docker exec -i nusamart-lab-pg-surabaya-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\fdw_surabaya.sql
    docker exec -i nusamart-lab-pg-pontianak-1 psql -U lab -d nusamart -v ON_ERROR_STOP=1 < sql\fdw_pontianak.sql
    echo [OK] Data dan FDW berhasil diinisialisasi via SQL.
)

:: 6. Opsi pgAdmin
echo.
echo ====================================================================
echo Cluster NusaMart Berhasil Dijalankan!
echo ====================================================================
echo - Node Jakarta   : localhost:5433 (Container: pg-jakarta)
echo - Node Surabaya  : localhost:5434 (Container: pg-surabaya)
echo - Node Pontianak : localhost:5435 (Container: pg-pontianak)
echo - User Database  : lab
echo - Password       : DBTech3Q
echo - Database Name  : nusamart
echo ====================================================================
echo.
echo Apakah Anda ingin menyalakan pgAdmin di browser (port 5050)? [Y/N]
set /p START_PGA="Pilihan (default N): "
if /i "%START_PGA%"=="Y" (
    docker image inspect dpage/pgadmin4:latest >nul 2>&1
    if !errorlevel! neq 0 (
        if exist "docker_images\pgadmin4_latest.tar.gz" (
            echo [*] Memuat image pgAdmin offline...
            docker load -i docker_images\pgadmin4_latest.tar.gz
        )
    )
    echo [*] Menyalakan pgAdmin di port 5050...
    docker compose --profile with-pgadmin up -d pgadmin
    echo.
    echo [*] pgAdmin siap diakses di: http://localhost:5050
    echo     Email   : lab@nusamart.com
    echo     Password: DBTech3Q
)

echo.
echo Setup Selesai! Selamat berpraktikum!
pause
