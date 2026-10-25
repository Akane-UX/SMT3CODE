# 🦀 Modul 07: Smart Pointers & Fearless Concurrency

Modul ini membahas tingkat lanjutan manajemen memori di Rust menggunakan Smart Pointers, serta bagaimana Rust mewujudkan filosofi *Fearless Concurrency* (pemrograman paralel multi-thread tanpa takut terjadi *data races*).

## 📌 Topik Pembahasan:
1. **Smart Pointers**:
   - Struktur data yang bertindak seperti pointer namun memiliki metadata dan kapabilitas tambahan:
     - `Box<T>`: Menyimpan data di heap, sangat berguna untuk tipe data rekursif atau ketika ukuran tipe belum diketahui saat compile time.
     - `Rc<T>` (*Reference Counted*): Memungkinkan kepemilikan ganda (*multiple ownership*) dalam lingkungan **single-thread**.
     - `Arc<T>` (*Atomic Reference Counted*): Versi thread-safe dari `Rc<T>` untuk berbagi kepemilikan antar **multi-thread**.
     - `RefCell<T>`: Menerapkan *Interior Mutability* (memungkinkan perubahan data dari referensi immutable, dengan pengecekan borrow rules saat *runtime* alih-alih *compile-time*).
2. **Fearless Concurrency**:
   - Kompiler Rust mencegah bug konkurensi (seperti data race dan dangling references) saat kompilasi.
   - **Thread Spawning**: `std::thread::spawn(move || { ... })` dan `.join()`.
   - **Message Passing (Channel)**: Filosofi *"Do not communicate by sharing memory; instead, share memory by communicating"*.
     - `std::sync::mpsc::channel()` (*Multiple Producer, Single Consumer*).
   - **Shared State Concurrency**:
     - Menggabungkan `Arc<Mutex<T>>` untuk mengizinkan banyak thread mengakses dan memodifikasi data yang sama secara aman dengan mekanisme mutual exclusion lock.
3. **Trait `Send` dan `Sync`**:
   - `Send`: Menandakan bahwa kepemilikan tipe data aman ditransfer antar thread.
   - `Sync`: Menandakan bahwa referensi ke tipe data aman diakses bersama oleh multi thread.

## 🚀 Menjalankan Kode:
```bash
cargo run -p smart_pointers_concurrency
```
