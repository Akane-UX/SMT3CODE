# 🦀 Modul 01: Fondasi Sintaks & Tooling

Modul ini membahas fondasi sintaksis bahasa Rust dan alur kerja tooling Cargo.

## 📌 Topik Pembahasan:
1. **Immutability by Default**: Variabel di Rust secara default bersifat *immutable* (`let x = 5;`). Untuk membuatnya bisa diubah, gunakan kata kunci `mut` (`let mut x = 5;`).
2. **Variable Shadowing**: Mendeklarasikan ulang variabel dengan nama yang sama menggunakan `let`. Ini memungkinkan perubahan tipe data tanpa harus membuat nama variabel baru.
3. **Tipe Data Primitif**:
   - **Skalar**: Integer bertanda (`i8`..`i128`, `isize`), tanpa tanda (`u8`..`u128`, `usize`), floating-point (`f32`, `f64`), boolean (`bool`), dan karakter Unicode 4-byte (`char`).
   - **Majemuk (Compound)**: Tuple (kumpulan nilai berbagai tipe dengan panjang tetap) dan Array (kumpulan nilai bertipe sama dengan panjang tetap di stack).
4. **Statement vs Expression**:
   - *Statement*: Instruksi yang melakukan aksi dan **tidak** mengembalikan nilai (diakhiri titik koma `;`).
   - *Expression*: Menghasilkan nilai dan dievaluasi (tanpa titik koma pada akhir blok fungsi).
5. **Control Flow**:
   - `if` sebagai ekspresi (`let number = if condition { 5 } else { 6 };`).
   - Perulangan: `loop` (infinite loop dengan kemampuan mengembalikan nilai via `break value`), `while` bertanda kondisi, dan `for element in collection` yang aman dan efisien.

## 🚀 Menjalankan Kode:
```bash
cargo run -p basics
```
