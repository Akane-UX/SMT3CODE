//! Modul 03: Structs, Enums & Pattern Matching
//! Menjalankan materi: `cargo run -p structs_enums`

fn main() {
    println!("=== 🦀 MODUL 03: STRUCTS, ENUMS & MATCHING ===\n");

    // 1. Structs & Implementasi Method
    demo_structs_and_methods();

    // 2. Enums dengan Payload Data
    demo_rich_enums();

    // 3. Exhaustive Pattern Matching
    demo_pattern_matching();

    // 4. Option Enum (Anti-Null Paradigm)
    demo_option_enum();

    // 5. Sintaks if let
    demo_if_let();

    println!("\n✅ Modul 03 selesai dipelajari dengan sukses!");
}

// ==========================================
// 1. STRUCTS & METHODS
// ==========================================

#[derive(Debug)] // Memungkinkan format cetak {:?}
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    // Associated Function (Konstruktor) - tidak menerima &self
    fn new(width: u32, height: u32) -> Self {
        Rectangle { width, height }
    }

    // Associated Function: membuat bujur sangkar
    fn square(size: u32) -> Self {
        Rectangle {
            width: size,
            height: size,
        }
    }

    // Method: menerima referensi &self
    fn area(&self) -> u32 {
        self.width * self.height
    }

    // Method dengan parameter tambahan
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}

fn demo_structs_and_methods() {
    println!("--- 1. Structs & Methods ---");
    let rect1 = Rectangle::new(30, 50);
    let rect2 = Rectangle::new(10, 40);
    let square = Rectangle::square(25);

    println!("rect1: {:?}", rect1);
    println!("Luas rect1: {}", rect1.area());
    println!("Apakah rect1 bisa memuat rect2? {}", rect1.can_hold(&rect2));
    println!("Bujur sangkar: {:?}, Luas: {}\n", square, square.area());
}

// ==========================================
// 2 & 3. ENUMS & PATTERN MATCHING
// ==========================================

#[derive(Debug)]
enum WebEvent {
    PageLoad,
    KeyPress(char),
    Paste(String),
    Click { x: i64, y: i64 },
}

fn inspect_event(event: WebEvent) {
    // Pattern matching harus exhaustif (mencakup semua varian)
    match event {
        WebEvent::PageLoad => println!("Halaman selesai dimuat!"),
        WebEvent::KeyPress(c) => println!("Tombol ditekan: '{}'", c),
        WebEvent::Paste(text) => println!("Teks di-paste: '{}'", text),
        WebEvent::Click { x, y } => println!("Mouse diklik di koordinat: ({}, {})", x, y),
    }
}

fn demo_rich_enums() {
    println!("--- 2. Enums with Data Payloads ---");
    let ev1 = WebEvent::PageLoad;
    let ev2 = WebEvent::KeyPress('q');
    let ev3 = WebEvent::Paste(String::from("https://rust-lang.org"));
    let ev4 = WebEvent::Click { x: 1920, y: 1080 };

    inspect_event(ev1);
    inspect_event(ev2);
    inspect_event(ev3);
    inspect_event(ev4);
    println!();
}

fn demo_pattern_matching() {
    println!("--- 3. Pattern Matching with Guards & Wildcard ---");
    let status_code = 404;

    let message = match status_code {
        200 => "OK - Sukses",
        301 | 302 => "Redirect",
        400..=499 => "Client Error", // Range matching
        500..=599 => "Server Error",
        _ => "Unknown Status",        // Wildcard fallback
    };

    println!("Status {} -> {}\n", status_code, message);
}

// ==========================================
// 4. OPTION ENUM
// ==========================================

fn find_user_by_id(id: u32) -> Option<String> {
    if id == 1 {
        Some(String::from("avrlln"))
    } else {
        None // Menggantikan null secara aman
    }
}

fn demo_option_enum() {
    println!("--- 4. Option<T> (Replacing Null) ---");

    let user_exists = find_user_by_id(1);
    let user_not_found = find_user_by_id(99);

    match user_exists {
        Some(name) => println!("User ditemukan: {}", name),
        None => println!("User tidak ditemukan!"),
    }

    match user_not_found {
        Some(name) => println!("User ditemukan: {}", name),
        None => println!("User 99 tidak ditemukan (None) - ditangani aman tanpa crash!"),
    }
    println!();
}

// ==========================================
// 5. IF LET SYNTAX
// ==========================================

fn demo_if_let() {
    println!("--- 5. Sintaks if let ---");
    let some_value: Option<i32> = Some(42);

    // Daripada menulis match dengan cabang None => (), gunakan if let:
    if let Some(val) = some_value {
        println!("Mengekstrak nilai menggunakan if let: {}", val);
    } else {
        println!("Tidak ada nilai");
    }
}
