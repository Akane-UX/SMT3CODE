//! Modul 06: Closures & Iterators (Functional Rust)
//! Menjalankan materi: `cargo run -p closures_iterators`

fn main() {
    println!("=== 🦀 MODUL 06: CLOSURES & ITERATORS ===\n");

    // 1. Closures & Environment Capturing
    demo_closures();

    // 2. Iterators & Adapters (map, filter, fold)
    demo_iterators();

    // 3. Studi Kasus Pemrosesan Data Fungsional
    demo_functional_pipeline();

    println!("\n✅ Modul 06 selesai dipelajari dengan sukses!");
}

/// Demonstrasi closures
fn demo_closures() {
    println!("--- 1. Closures (Anonymous Functions) ---");

    // Closure sederhana
    let add_one = |x: i32| x + 1;
    println!("Closure add_one(5): {}", add_one(5));

    // Menangkap variabel lingkungan dari scope luar
    let multiplier = 10;
    let multiply_by_env = |x| x * multiplier; // Menginferensi tipe x dan meminjam multiplier
    println!("Closure multiply_by_env(7): {}", multiply_by_env(7));

    // Closure dengan kata kunci `move`: memindahkan ownership lingkungan ke dalam closure
    let greeting = String::from("Selamat pagi");
    let print_greeting = move || {
        println!("Closure move greeting: '{}'", greeting);
    };
    print_greeting();
    // greeting sudah di-move ke dalam closure!
    println!();
}

/// Demonstrasi dasar Iterator
fn demo_iterators() {
    println!("--- 2. Iterators: map, filter, fold ---");

    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // Iterators bersifat LAZY: jika tidak dipanggil consumer (.collect() atau .sum()), tidak ada loop yang terjadi!
    let even_squares: Vec<i32> = numbers
        .iter()
        .filter(|&&x| x % 2 == 0) // Filter angka genap saja
        .map(|&x| x * x)          // Kuadratkan nilainya
        .collect();               // Kumpulkan ke dalam Vector baru

    println!("Original: {:?}", numbers);
    println!("Even squares (filter + map): {:?}", even_squares);

    // Consumer: .sum()
    let total_sum: i32 = numbers.iter().sum();
    println!("Total sum: {}", total_sum);

    // Consumer: .fold() (seperti reduce di JavaScript / Python)
    let product: i32 = numbers.iter().take(5).fold(1, |acc, &x| acc * x);
    println!("Perkalian 5 angka pertama (fold): {}\n", product);
}

// ==========================================
// 3. STUDI KASUS PIPELINE DATA FUNGSIONAL
// ==========================================

#[derive(Debug)]
struct Student {
    name: String,
    score: u32,
    active: bool,
}

fn demo_functional_pipeline() {
    println!("--- 3. Studi Kasus: Data Pipeline Siswa ---");

    let students = vec![
        Student { name: String::from("Avril"), score: 95, active: true },
        Student { name: String::from("Budi"), score: 70, active: false },
        Student { name: String::from("Citra"), score: 88, active: true },
        Student { name: String::from("Doni"), score: 62, active: true },
        Student { name: String::from("Eka"), score: 92, active: true },
    ];

    // Pipeline fungsional: Ambil siswa aktif dengan nilai >= 85, ekstrak namanya, jadikan uppercase
    let top_active_students: Vec<String> = students
        .iter()
        .filter(|s| s.active && s.score >= 85)
        .map(|s| s.name.to_uppercase())
        .collect();

    println!("Siswa aktif berprestasi tinggi: {:?}", top_active_students);

    // Hitung rata-rata nilai siswa yang aktif
    let active_students: Vec<&Student> = students.iter().filter(|s| s.active).collect();
    let total_active_score: u32 = active_students.iter().map(|s| s.score).sum();
    let average_score = total_active_score as f64 / active_students.len() as f64;

    println!("Rata-rata nilai siswa aktif: {:.2}", average_score);
}
