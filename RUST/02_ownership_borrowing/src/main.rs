 //! Modul 02: Ownership, References & Borrowing
//! Menjalankan materi: `cargo run -p ownership_borrowing`

fn main() {
    println!("=== 🦀 MODUL 02: OWNERSHIP & BORROWING ===\n");

    // 1. Move vs Copy Semantics
    demo_move_vs_copy();

    // 2. Passing Ownership to Functions
    demo_ownership_in_functions();

    // 3. Borrowing dengan Immutable Reference (&T)
    demo_immutable_borrowing();

    // 4. Mutating borrowed data dengan Mutable Reference (&mut T)
    demo_mutable_borrowing();

    // 5. String & Array Slices (&str, &[T])
    demo_slices();

    println!("\n✅ Modul 02 selesai dipelajari dengan sukses!");
}

/// Menjelaskan perbedaan Copy (Stack) dan Move (Heap)
fn demo_move_vs_copy() {
    println!("--- 1. Move Semantics vs Copy Semantics ---");

    // Tipe primitif mengimplementasikan trait Copy (Stack-only)
    let a = 42;
    let b = a; // Nilai disalin!
    println!("Stack Copy: a = {}, b = {} (keduanya valid)", a, b);

    // Tipe Heap (String) TIDAK mengimplementasikan Copy
    let s1 = String::from("Halo Rust");
    let s2 = s1; // OWNERSHIP DIPINDAHKAN (MOVE) ke s2!

    // Catatan: jika kita mencoba mengakses s1 di sini: `println!("{}", s1);`
    // Compiler Rust akan langsung menolak dan melempar error: "borrow of moved value: `s1`"!
    println!("Heap Move: s2 = '{}' (s1 sudah tidak valid/moved)\n", s2);

    // Jika ingin duplikasi data heap secara mendalam, gunakan .clone() eksplisit
    let s3 = s2.clone();
    println!("Deep Clone: s2 = '{}', s3 = '{}' (keduanya valid)\n", s2, s3);
}

/// Memperlihatkan kepemilikan yang ditransfer masuk dan keluar fungsi
fn demo_ownership_in_functions() {
    println!("--- 2. Ownership in Functions ---");

    let my_string = String::from("Sistem Operasi");
    takes_ownership(my_string);
    // my_string sekarang sudah tidak bisa dipakai lagi di sini karena sudah di-drop di akhir takes_ownership!

    let received_string = gives_ownership();
    println!("Menerima kepemilikan dari fungsi: '{}'\n", received_string);
}

fn takes_ownership(s: String) {
    println!("Fungsi takes_ownership menerima: '{}'", s);
    // Di akhir blok kurung kurawal ini, 's' keluar scope dan memori langsung di-drop otomatis!
}

fn gives_ownership() -> String {
    let s = String::from("Kembalian dari fungsi");
    s // Mengembalikan s memindahkan kepemilikan ke pemanggil fungsi
}

/// Meminjam data secara read-only tanpa memindahkan kepemilikan
fn demo_immutable_borrowing() {
    println!("--- 3. Immutable Borrowing (&T) ---");

    let s1 = String::from("Antigravity CLI");

    // Mengirim &s1 artinya meminjamkan referensi, s1 tetap menjadi pemilik
    let len = calculate_length(&s1);
    println!("Panjang '{}' adalah {} karakter.", s1, len);
    println!("s1 masih tetap valid dan bisa digunakan!\n");
}

fn calculate_length(s: &String) -> usize {
    s.len()
    // Di sini s hanya referensi, jadi ketika keluar scope, nilai aslinya TIDAK di-drop
}

/// Meminjam data dengan hak mengubah (&mut T)
fn demo_mutable_borrowing() {
    println!("--- 4. Mutable Borrowing (&mut T) ---");

    let mut message = String::from("Halo");
    println!("Sebelum dimutasi: '{}'", message);

    append_world(&mut message);
    println!("Setelah dimutasi: '{}'", message);

    // ATURAN KRUSIAL:
    // Tidak boleh ada mutable reference jika sudah ada immutable reference yang aktif!
    let mut data = String::from("Arch");
    let r1 = &data; // immutable borrow
    let r2 = &data; // immutable borrow lagi (BOLEH BANYAK READER)
    println!("Multi reader aman: r1 = '{}', r2 = '{}'", r1, r2);
    // Scope r1 dan r2 selesai di sini setelah penggunaan terakhir (Non-Lexical Lifetimes)

    let r3 = &mut data; // SEKARANG BOLEH MUTABLE BORROW!
    r3.push_str(" Linux");
    println!("Data setelah mutable borrow eksklusif: '{}'\n", r3);
}

fn append_world(s: &mut String) {
    s.push_str(", Dunia!");
}

/// Slices: Referensi ke sebagian elemen koleksi
fn demo_slices() {
    println!("--- 5. Slices (&str & &[T]) ---");

    let s = String::from("Hello World");
    let hello = &s[0..5];  // Slice dari index 0 sampai 4
    let world = &s[6..11]; // Slice dari index 6 sampai 10

    println!("Original: '{}'", s);
    println!("Slice 1: '{}'", hello);
    println!("Slice 2: '{}'", world);

    // Array slice
    let numbers = [1, 2, 3, 4, 5, 6, 7];
    let middle_slice = &numbers[2..5]; // Elemen [3, 4, 5]
    println!("Array slice: {:?}", middle_slice);
}
