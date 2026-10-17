# 🦀 Modul 03: Structs, Enums & Pattern Matching

Modul ini mempelajari cara memodelkan data kustom menggunakan Structs dan Enums tingkat lanjut, serta bagaimana memanfaatkan Pattern Matching untuk kontrol logika yang aman dan teruji kompilasi.

## 📌 Topik Pembahasan:
1. **Structs**:
   - Classic Structs: Memiliki nama field (`struct User { username: String, active: bool }`).
   - Tuple Structs: Struct tanpa nama field (`struct Color(u8, u8, u8);`).
   - Unit-like Structs: Struct tanpa field (`struct Marker;`), berguna untuk penanda trait.
2. **Methods & Associated Functions**:
   - Didefinisikan di dalam blok `impl`.
   - Method menerima parameter pertama `&self` (immutable) atau `&mut self` (mutable).
   - *Associated Function*: Fungsi yang tidak menerima `self` (biasanya bertindak sebagai konstruktor seperti `Self::new()`), dipanggil via `Struct::fn()`.
3. **Enums dengan Data (Algebraic Data Types)**:
   - Enum di Rust jauh lebih kuat dibanding C/Java/Python karena setiap varian dapat menampung tipe data berbeda (string, angka, struct, atau tuple).
4. **Pattern Matching (`match`)**:
   - Kompiler Rust menuntut *exhaustive checking* (semua varian enum harus ditangani).
   - Penggunaan wildcard `_` untuk kasus default.
5. **Tipe `Option<T>`**:
   - Rust tidak memiliki `null`. Sebagai gantinya, pustaka standar menyediakan:
     ```rust
     enum Option<T> {
         Some(T),
         None,
     }
     ```
   - Nilai tidak bisa digunakan sembarangan tanpa diekstrak terlebih dahulu, sehingga mustahil terjadi *Null Pointer Exception*!
6. **Sintaks Ringkas: `if let`**:
   - Alternatif ringkas ketika hanya ingin menangani satu varian enum tertentu tanpa menulis blok `match` lengkap.

## 🚀 Menjalankan Kode:
```bash
cargo run -p structs_enums
```
