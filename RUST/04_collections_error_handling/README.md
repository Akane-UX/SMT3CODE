# 🦀 Modul 04: Koleksi Standar & Penanganan Error

Modul ini membahas tiga struktur data koleksi yang paling penting dalam Rust dan paradigma penanganan error yang tangguh (*recoverable vs unrecoverable*).

## 📌 Topik Pembahasan:
1. **Vector (`Vec<T>`)**:
   - Array dinamis yang dialokasikan di heap dan bisa membesar secara fleksibel.
   - Operasi: `vec![]`, `.push()`, `.pop()`, dan akses aman via `.get(index)` yang mengembalikan `Option<&T>`.
2. **String vs String Slice (`&str`)**:
   - `String`: Tipe string yang tumbuh dinamis di heap, UTF-8 encoded, punya kepemilikan.
   - `&str`: *String slice*, view tak berpemilik yang menunjuk ke deretan byte UTF-8 valid (di stack, binary, atau heap).
3. **HashMap (`HashMap<K, V>`)**:
   - Struktur data asosiatif berbasis hash table.
   - Operasi: `.insert()`, `.get()`, dan `.entry(key).or_insert(default_val)` untuk pola update yang sangat idiomatik.
4. **Penanganan Error Idiomatis**:
   - **Unrecoverable Errors**: `panic!()` — Menghentikan program segera ketika terjadi bug kritis yang tidak dapat dipulihkan.
   - **Recoverable Errors**: `Result<T, E>` — Digunakan ketika suatu kegagalan adalah hal yang wajar (misal: file tidak ditemukan, jaringan timeout).
     ```rust
     enum Result<T, E> {
         Ok(T),
         Err(E),
     }
     ```
5. **Operator `?` (Error Propagation)**:
   - Jika fungsi menghasilkan `Ok(T)`, nilai `T` diekstrak.
   - Jika menghasilkan `Err(E)`, fungsi langsung melakukan return dini (*early return*) membawa `Err(E)` ke fungsi pemanggil.
   - Mencegah penulisan blok `match` bertingkat yang berantakan (*pyramid of doom*).

## 🚀 Menjalankan Kode:
```bash
cargo run -p collections_error_handling
```
