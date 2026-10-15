//! Modul 01: Fondasi Sintaks & Tooling Rust
//! Menjalankan materi: `cargo run -p basics`

fn main() {
    println!("=== 🦀 MODUL 01: FONDASI SINTAKS RUST ===\n");

    // 1. Immutability & Mutability
    demo_variables_mutability();

    // 2. Variable Shadowing
    demo_shadowing();

    // 3. Tipe Data Skalar & Compound
    demo_data_types();

    // 4. Statement vs Expression & Fungsi
    demo_functions_and_expressions();

    // 5. Control Flow (if, loop, while, for)
    demo_control_flow();

    // 6. Nested loop counter
    test();

    println!("\n✅ Modul 01 selesai dipelajari dengan sukses!");
}

/// Demonstrasi variabel immutable dan mutable
fn demo_variables_mutability() {
    println!("--- 1. Variables & Mutability ---");
    let x = 10; // Secara default immutable (tidak bisa diubah)
    println!("Nilai x (immutable): {}", x);

    let mut y = 20; // Eksplisit mutable dengan kata kunci `mut`
    println!("Nilai y awal (mutable): {}", y);
    y = 25;
    println!("Nilai y setelah diubah: {}", y);

    // Konstanta: selalu bernilai tetap, wajib ada tipe data eksplisit, dievaluasi saat compile time
    const MAX_POINTS: u32 = 100_000;
    println!("Konstanta MAX_POINTS: {}\n", MAX_POINTS);
}

/// Demonstrasi teknik Shadowing
fn demo_shadowing() {
    println!("--- 2. Variable Shadowing ---");
    let spaces = "   "; // Bertipe &str
    println!("Panjang spaces awal (string): '{}'", spaces);

    // Shadowing: mendeklarasikan ulang variabel dengan nama yang sama menggunakan `let`
    let spaces = spaces.len(); // Sekarang bertipe usize!
    println!("Nilai spaces setelah shadowing (angka): {}\n", spaces);
}

/// Demonstrasi tipe data primitif Rust
fn demo_data_types() {
    println!("--- 3. Data Types (Scalar & Compound) ---");

    // Skalar: integer, float, bool, char
    let integer: i32 = -42;
    let unsigned_int: u64 = 999;
    let floating: f64 = 3.14159;
    let boolean: bool = true;
    let emoji: char = '🦀'; // char di Rust berukuran 4 byte (Unicode Scalar Value)

    println!(
        "Scalar -> int: {}, uint: {}, float: {}, bool: {}, char: {}",
        integer, unsigned_int, floating, boolean, emoji
    );

    // Compound 1: Tuple (kumpulan nilai berbagai tipe dengan ukuran tetap)
    let tup: (i32, f64, &str) = (500, 6.4, "Rustacean");
    let (a, b, c) = tup; // Destructuring tuple
    println!("Tuple destructure -> a: {}, b: {}, c: {}", a, b, c);
    println!("Tuple direct index -> tup.0: {}", tup.0);

    // Compound 2: Array (tipe data seragam, panjang tetap di Stack)
    let numbers: [i32; 5] = [10, 20, 30, 40, 50];
    println!("Array elements -> length: {}, first: {}", numbers.len(), numbers[0]);
    println!();
}

/// Demonstrasi Expression vs Statement dan nilai kembali
fn demo_functions_and_expressions() {
    println!("--- 4. Functions & Expressions ---");

    // Blok ekspresi: baris terakhir tanpa titik koma bernilai hasil kembali
    let y = {
        let x = 3;
        x + 1 // Expression: tidak ada titik koma (;) di sini!
    };
    println!("Hasil kalkulasi blok ekspresi y: {}", y);

    let sum = add_numbers(15, 27);
    println!("Hasil pemanggilan add_numbers(15, 27): {}\n", sum);
}

/// Fungsi dengan parameter dan return value
/// Perhatikan: ekspresi `a + b` tanpa `;` adalah idiomatik Rust (implicit return)
fn add_numbers(a: i32, b: i32) -> i32 {
    a + b
}

/// Demonstrasi struktur kendali (if, loop, while, for)
fn demo_control_flow() {
    println!("--- 5. Control Flow ---");

    // 'if' sebagai ekspresi
    let condition = true;
    let number = if condition { 42 } else { 0 };
    println!("Nilai number dari if expression: {}", number);

    // 'loop' dengan pengembalian nilai via 'break'
    let mut counter = 0;
    let result = loop {
        counter += 1;
        if counter == 10 {
            break counter * 2; // Mengembalikan 20 keluar dari loop!
        }
    };
    println!("Hasil pengembalian loop break: {}", result);

    // 'while' loop
    let mut countdown = 3;
    print!("Countdown: ");
    while countdown > 0 {
        print!("{} ", countdown);
        countdown -= 1;
    }
    println!("🚀 Launch!");

    // 'for in' loop (paling sering dan paling aman digunakan di Rust)
    let items = ["Rust", "Arch Linux", "Fast", "Memory Safe"];
    print!("Item iterate: ");
    for item in items.iter() {
        print!("[{}] ", item);
    }
    println!();
}
use std::time::Instant;

fn test() {
    // Use u64 for the counter and loop variables to ensure they can handle
    // a very large number of iterations without overflow.
    let mut count: u64 = 0;

    println!("Starting the nested loop counter...");

    // Start the timer
    let start_time = Instant::now();

    // Outer loop runs 100,000 times
    for _i in 0..100000 {
        // Inner loop runs 10,000 times
        for _j in 0..10000 {
            count += 1;
        }
    }

    // Stop the timer and calculate the duration
    let end_time = Instant::now();
    let elapsed_time = end_time.duration_since(start_time);

    println!("\n--- Execution Finished ---");
    println!("Total iterations: {}", count);
    println!("Time taken: {:.2?} seconds", elapsed_time);
    println!("------------------------");
}