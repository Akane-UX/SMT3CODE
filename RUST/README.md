# 🦀 Rust Mastery Curriculum & Hands-On Playground

Selamat datang di repositori belajar **Rust**! Repositori ini dikonfigurasi sebagai **Cargo Workspace** modular agar setiap bab dapat dipelajari secara terisolasi sekaligus terhubung dalam satu ekosistem yang rapi dan efisien.

---

## 🗺️ Peta Pembelajaran & Daftar Modul

| No | Modul | Deskripsi Materi Inti | Perintah Jalankan |
|---|---|---|---|
| **01** | [`01_basics`](./01_basics) | Variables, Immutability, Tipe Data, Functions, Control Flow | `cargo run -p basics` |
| **02** | [`02_ownership_borrowing`](./02_ownership_borrowing) | Stack vs Heap, 3 Rules of Ownership, Move, Borrowing (`&`, `&mut`), Slices | `cargo run -p ownership_borrowing` |
| **03** | [`03_structs_enums`](./03_structs_enums) | Custom Structs, Methods (`impl`), Enums, Pattern Matching (`match`), `Option<T>` | `cargo run -p structs_enums` |
| **04** | [`04_collections_error_handling`](./04_collections_error_handling) | `Vec<T>`, `String` vs `&str`, `HashMap`, `Result<T, E>`, Operator `?` | `cargo run -p collections_error_handling` |
| **05** | [`05_generics_traits_lifetimes`](./05_generics_traits_lifetimes) | Generic Types, Traits (Interfaces), Trait Bounds, Lifetimes (`'a`) | `cargo run -p generics_traits_lifetimes` |
| **06** | [`06_closures_iterators`](./06_closures_iterators) | Anonymous Closures (`Fn`, `FnMut`, `FnOnce`), Iterators & Adapters (`map`, `filter`) | `cargo run -p closures_iterators` |
| **07** | [`07_smart_pointers_concurrency`](./07_smart_pointers_concurrency) | `Box<T>`, `Rc<T>`, `Arc<Mutex<T>>`, Multi-threading, Channels (`mpsc`) | `cargo run -p smart_pointers_concurrency` |
| **08** | [`08_mini_projects/minigrep`](./08_mini_projects/minigrep) | Proyek Utuh: CLI tool pencarian teks mirip `grep` dengan file I/O & testing | `cargo run -p minigrep -- poem sample.txt` |

---

## ⚡ Cara Menjalankan Modul

Setiap modul adalah binary crate tersendiri. Anda dapat menjalankannya langsung dari root folder ini:

```bash
# Menjalankan modul tertentu (misalnya Modul 01):
cargo run -p basics

# Memeriksa compile errors tanpa membuat binary:
cargo check -p basics

# Menjalankan clippy (linter cerdas Rust):
cargo clippy

# Menjalankan tests di seluruh workspace:
cargo test
```

Atau masuk langsung ke direktori modul yang bersangkutan:
```bash
cd 01_basics
cargo run
```

---

## 🧠 Tautan Integrasi Memori Obsidian

Dokumentasi, arsitektur, dan mindmap visual terhubung ke Obsidian Vault:
- **Peta Canvas Visual**: `AI_Memory/Canvas/Rust_Learning.canvas`
- **Catatan Proyek**: `AI_Memory/Projects/Rust_Learning.md`
- **Indeks Memori**: `AI_Memory/00_Memory_Index.md`
- **Konteks Aktif**: `AI_Memory/Active_Context.md`

---

## 💡 3 Kaidah Emas yang Perlu Diingat

1. **Borrow Checker adalah Sahabat, Bukan Musuh**: Jika compiler menolak kode Anda, ia sedang menyelamatkan Anda dari crash memori atau data race saat runtime.
2. **Eksplisit dan No Hidden Magic**: Rust tidak menyembunyikan alokasi memori di balik layar. Anda selalu tahu apakah data berada di Stack atau Heap.
3. **Handle Errors Idiomatically**: Gunakan `Result<T, E>` dan operator `?` alih-alih `unwrap()` agar aplikasi tangguh terhadap kegagalan.
