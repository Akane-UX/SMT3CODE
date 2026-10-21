# 🦀 Modul 06: Pemrograman Fungsional — Closures & Iterators

Rust sangat dipengaruhi oleh paradigma pemrograman fungsional. Modul ini membahas Closures (fungsi anonim) dan Iterators, yang dirancang dengan filosofi *Zero-Cost Abstraction* — Anda bisa menulis kode deklaratif tingkat tinggi tanpa mengorbankan performa mentah CPU.

## 📌 Topik Pembahasan:
1. **Closures (Fungsi Anonim)**:
   - Sintaks: `|parameter| body_ekspresi`.
   - Mengambil tipe secara inferensi tanpa harus menulis tipe data parameter secara eksplisit.
   - Menangkap variabel lingkungan (*capturing environment*):
     - Meminjam secara immutable (`Fn`).
     - Meminjam secara mutable (`FnMut`).
     - Mengambil kepemilikan nilai / memindahkan (`FnOnce` / keyword `move`).
2. **Iterators**:
   - Pola iterator memisahkan logika traversal dari struktur data.
   - Tiga metode pembuatan iterator:
     - `.iter()`: Menghasilkan referensi immutable (`&T`).
     - `.iter_mut()`: Menghasilkan referensi mutable (`&mut T`).
     - `.into_iter()`: Mengambil alih kepemilikan koleksi (`T`).
3. **Iterator Adapters**:
   - Metode yang mengubah iterator menjadi iterator baru (bersifat *lazy*, tidak akan dievaluasi sampai dipanggil oleh consumer):
     - `.map()`: Mentransformasi tiap elemen.
     - `.filter()`: Menyaring elemen berdasarkan predikat boolean.
     - `.zip()`, `.take()`, `.enumerate()`.
4. **Consumers**:
   - Metode yang memicu konsumsi iterator sampai habis:
     - `.collect()`: Mengumpulkan hasil iterator ke dalam koleksi seperti `Vec<T>`.
     - `.sum()`, `.count()`, `.fold()`, `.find()`.

## 🚀 Menjalankan Kode:
```bash
cargo run -p closures_iterators
```
