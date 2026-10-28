# 🦀 Modul 08: Mini Proyek Praktik — MiniGrep CLI

Modul ini adalah proyek mini dunia nyata yang mengintegrasikan seluruh materi yang telah dipelajari:
- Argument parsing dari command-line (`std::env::args`).
- Pembacaan berkas (*File I/O*) dari disk (`std::fs::read_to_string`).
- Struktur data konfigurasi dan pemisahan logika (*Separation of Concerns*).
- Penanganan error yang elegan dengan `Result` dan operator `?`.
- Algoritma pencarian baris menggunakan Iterator fungsional (`lines()`, `filter()`).
- Penulisan Unit Test otomatis menggunakan `#[test]`.

## 🚀 Cara Menjalankan:

```bash
# Menjalankan pencarian kata "Rust" di berkas sample.txt:
cargo run -p minigrep -- Rust 08_mini_projects/minigrep/sample.txt

# Menjalankan pencarian kata "tape":
cargo run -p minigrep -- tape 08_mini_projects/minigrep/sample.txt

# Menjalankan unit tests:
cargo test -p minigrep
```
