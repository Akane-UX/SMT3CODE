//! Modul 04: Koleksi Standar & Penanganan Error
//! Menjalankan materi: `cargo run -p collections_error_handling`

use std::collections::HashMap;

fn main() {
    println!("=== 🦀 MODUL 04: KOLEKSI & ERROR HANDLING ===\n");

    // 1. Vector (Vec<T>)
    demo_vectors();

    // 2. String Manipulation
    demo_strings();

    // 3. HashMap
    demo_hashmap();

    // 4. Result & Error Propagation (?)
    demo_error_handling();

    println!("\n✅ Modul 04 selesai dipelajari dengan sukses!");
}

/// Demonstrasi penggunaan dynamic array Vector
fn demo_vectors() {
    println!("--- 1. Vector (Vec<T>) ---");

    // Membuat vector dengan macro vec!
    let mut numbers = vec![10, 20, 30];
    numbers.push(40);
    numbers.push(50);
    println!("Vector awal: {:?}", numbers);

    // Mengakses elemen dengan cara aman via .get() -> mengembalikan Option<&T>
    let index_to_access = 2;
    match numbers.get(index_to_access) {
        Some(val) => println!("Elemen pada index {}: {}", index_to_access, val),
        None => println!("Index {} di luar jangkauan!", index_to_access),
    }

    // Mengakses index yang tidak ada tanpa crash (out of bounds safe)
    let out_of_bounds = 100;
    match numbers.get(out_of_bounds) {
        Some(val) => println!("Elemen: {}", val),
        None => println!("Index {} ditangani dengan aman via Option::None!", out_of_bounds),
    }

    // Iterasi dan mutasi elemen vector
    for num in &mut numbers {
        *num *= 2; // Dereference pointer untuk mengubah nilai
    }
    println!("Vector setelah dikalikan 2: {:?}\n", numbers);
}

/// Demonstrasi String vs &str
fn demo_strings() {
    println!("--- 2. String & String Slices ---");

    let mut s = String::from("Rust");
    s.push(' ');
    s.push_str("Language");
    println!("String hasil push: '{}'", s);

    // Format macro (menggabungkan string tanpa mengambil alih ownership)
    let part1 = "Sistem";
    let part2 = "Operasi";
    let combined = format!("{} {} 2026", part1, part2);
    println!("Format macro string: '{}'\n", combined);
}

/// Demonstrasi HashMap
fn demo_hashmap() {
    println!("--- 3. HashMap (Key-Value) ---");

    let mut scores = HashMap::new();
    scores.insert(String::from("Tim Biru"), 10);
    scores.insert(String::from("Tim Kuning"), 25);

    // Pola entry().or_insert(): hanya masukkan jika kunci belum ada
    scores.entry(String::from("Tim Merah")).or_insert(50);
    scores.entry(String::from("Tim Biru")).or_insert(99); // Tidak akan menimpa 10

    println!("Daftar skor tim:");
    for (team, score) in &scores {
        println!("- {}: {}", team, score);
    }

    // Studi kasus praktis: menghitung frekuensi kata
    let text = "halo dunia selamat datang di dunia rust halo rust";
    let mut word_counts = HashMap::new();
    for word in text.split_whitespace() {
        let count = word_counts.entry(word).or_insert(0);
        *count += 1;
    }
    println!("Frekuensi kata: {:?}\n", word_counts);
}

// ==========================================
// 4. ERROR HANDLING
// ==========================================

#[derive(Debug)]
enum MathError {
    DivisionByZero,
    NegativeSquareRoot,
}

/// Fungsi pembagian yang aman mengembalikan Result
fn divide(a: f64, b: f64) -> Result<f64, MathError> {
    if b == 0.0 {
        Err(MathError::DivisionByZero)
    } else {
        Ok(a / b)
    }
}

/// Fungsi kalkulasi kompleks memanfaatkan operator ?
fn complex_calculation(a: f64, b: f64) -> Result<f64, MathError> {
    // Jika divide gagal, fungsi ini langsung return Err tanpa lanjut ke bawah
    let division_result = divide(a, b)?;
    
    if division_result < 0.0 {
        return Err(MathError::NegativeSquareRoot);
    }

    Ok(division_result.sqrt())
}

fn demo_error_handling() {
    println!("--- 4. Error Handling (Result & ? Operator) ---");

    // Kasus 1: Pembagian sukses
    match divide(100.0, 4.0) {
        Ok(res) => println!("100 / 4 = {}", res),
        Err(e) => println!("Error: {:?}", e),
    }

    // Kasus 2: Pembagian dengan 0
    match divide(10.0, 0.0) {
        Ok(res) => println!("Hasil: {}", res),
        Err(MathError::DivisionByZero) => println!("Ditangani dengan aman: Pembagian dengan nol terdeteksi!"),
        Err(e) => println!("Error lain: {:?}", e),
    }

    // Kasus 3: Propagasi error berantai via ?
    let calc1 = complex_calculation(100.0, 4.0);
    println!("Kalkulasi valid: {:?}", calc1);

    let calc2 = complex_calculation(10.0, 0.0);
    println!("Kalkulasi error (div by zero): {:?}", calc2);
}
