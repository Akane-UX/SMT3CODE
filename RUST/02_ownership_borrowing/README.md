# 🦀 Modul 02: Ownership, References & Borrowing

Ownership adalah fitur paling unik dan inovatif dalam Rust yang memungkinkannya menjamin keamanan memori (*memory safety*) tanpa bantuan *garbage collector*.

## 📌 3 Aturan Emas Ownership:
1. **Setiap nilai di Rust memiliki sebuah variabel yang disebut sebagai pemiliknya (*owner*)**.
2. **Hanya boleh ada satu pemilik dalam satu waktu**.
3. **Ketika pemilik keluar dari scope (`}`), nilai tersebut otomatis dihapus (*dropped*) dari memori**.

## 📌 Move Semantics vs Copy:
- Tipe data dengan ukuran pasti yang berada sepenuhnya di Stack (seperti `i32`, `bool`, `char`, `f64`, dan tuple yang seluruh isinya bertipe stack) mengimplementasikan trait `Copy`. Ketika di-assign ke variabel baru, nilainya **disalin secara dangkal**.
- Tipe data kompleks di Heap (seperti `String`, `Vec`) tidak mengimplementasikan `Copy`. Ketika di-assign ke variabel baru, kepemilikannya **dipindahkan (*move*)**. Variabel pertama langsung menjadi **tidak valid**, sehingga compiler mencegah *double free error*.

## 📌 Aturan Peminjaman (*Borrowing*):
Daripada memindahkan kepemilikan, kita bisa **meminjam** nilai menggunakan referensi:
1. **Immutable Reference (`&T`)**: Membaca data tanpa mengubahnya. Boleh ada banyak referensi immutable secara bersamaan.
2. **Mutable Reference (`&mut T`)**: Mengubah data yang dipinjam. **HANYA BOLEH ADA SATU mutable reference dan TIDAK BOLEH ada referensi lain sama sekali** pada cakupan waktu yang sama.
   - *Aturan ini menghapus kemungkinan Data Race pada saat kompilasi!*

## 📌 Slices (`&str`, `&[T]`):
Referensi ke urutan elemen yang berurutan dalam suatu koleksi tanpa mengambil kepemilikan koleksi tersebut.

## 🚀 Menjalankan Kode:
```bash
cargo run -p ownership_borrowing
```
