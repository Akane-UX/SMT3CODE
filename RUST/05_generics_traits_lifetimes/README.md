# 🦀 Modul 05: Generics, Traits & Lifetimes

Modul ini membahas sistem tipe canggih dalam Rust yang memungkinkan kita menulis kode yang modular, polimorfik, dan bebas duplikasi tanpa mengorbankan performa saat runtime (*Zero-Cost Abstractions*).

## 📌 Topik Pembahasan:
1. **Generics**:
   - Mendefinisikan fungsi, struct, dan enum yang bisa beroperasi pada berbagai tipe data (`fn swap<T>(a: T, b: T)`).
   - *Monomorphization*: Saat kompilasi, Rust menghasilkan kode mesin spesifik untuk setiap tipe konkrit yang digunakan, sehingga eksekusi tetap secepat kode non-generik tanpa penalti runtime.
2. **Traits (Interfaces di Rust)**:
   - Trait mendefinisikan perilaku atau kapabilitas bersama yang harus dimiliki oleh suatu tipe.
   - Menggunakan sintaks `pub trait Summarizable { fn summarize(&self) -> String; }`.
   - Mengimplementasikan trait pada struct menggunakan `impl Summarizable for Article { ... }`.
   - Mendukung implementasi default (*default implementation*).
3. **Trait Bounds**:
   - Membatasi generic agar hanya menerima tipe yang mengimplementasikan trait tertentu:
     - Sintaks ringkas: `fn notify(item: &impl Summarizable)`
     - Sintaks standar: `fn notify<T: Summarizable + Display>(item: &T)`
     - Sintaks klausa `where`: Lebih rapi saat terdapat banyak batasan trait.
4. **Lifetimes (`'a`)**:
   - Setiap referensi di Rust memiliki *lifetime* (rentang waktu di mana referensi tersebut valid).
   - Kebanyakan waktu compiler melakukan inferensi otomatis (*lifetime elision*).
   - Anotasi eksplisit (seperti `&'a str`) dibutuhkan ketika sebuah fungsi menerima banyak referensi dan mengembalikan sebuah referensi, agar compiler bisa memastikan bahwa data yang dikembalikan tidak mengarah ke memori yang sudah hangus (*dangling reference*).

## 🚀 Menjalankan Kode:
```bash
cargo run -p generics_traits_lifetimes
```
