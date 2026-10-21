//! Modul 05: Generics, Traits & Lifetimes
//! Menjalankan materi: `cargo run -p generics_traits_lifetimes`

use std::fmt::Display;

fn main() {
    println!("=== 🦀 MODUL 05: GENERICS, TRAITS & LIFETIMES ===\n");

    // 1. Generic Functions & Structs
    demo_generics();

    // 2. Traits & Trait Bounds
    demo_traits();

    // 3. Lifetimes Anotasi ('a)
    demo_lifetimes();

    println!("\n✅ Modul 05 selesai dipelajari dengan sukses!");
}

// ==========================================
// 1. GENERICS
// ==========================================

#[allow(dead_code)]
#[derive(Debug)]
struct Point<T, U> {
    x: T,
    y: U,
}

/// Fungsi generic yang mencari elemen terbesar dari slice
/// Syarat: T harus bisa dibandingkan (PartialOrd) dan bisa disalin (Copy)
fn find_largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut largest = list[0];
    for &item in list {
        if item > largest {
            largest = item;
        }
    }
    largest
}

fn demo_generics() {
    println!("--- 1. Generics ---");
    let point_int = Point { x: 5, y: 10 };
    let point_mix = Point { x: 3.14, y: "Label" };
    println!("Point integer: {:?}", point_int);
    println!("Point campur: {:?}", point_mix);

    let numbers = [34, 50, 25, 100, 65];
    println!("Angka terbesar: {}", find_largest(&numbers));

    let chars = ['y', 'm', 'a', 'q'];
    println!("Karakter terbesar: {}\n", find_largest(&chars));
}

// ==========================================
// 2. TRAITS
// ==========================================

pub trait Summarize {
    // Definisi method wajib
    fn author(&self) -> String;

    // Method dengan default implementation
    fn summarize(&self) -> String {
        format!("(Baca selengkapnya dari {}...)", self.author())
    }
}

pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
}

impl Summarize for NewsArticle {
    fn author(&self) -> String {
        self.author.clone()
    }

    // Override default implementation
    fn summarize(&self) -> String {
        format!("{}, oleh {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
}

impl Summarize for Tweet {
    fn author(&self) -> String {
        format!("@{}", self.username)
    }
    // Tidak meng-override summarize(), otomatis memakai default implementation!
}

/// Fungsi yang menerima tipe apapun asalkan mengimplementasikan Summarize & Display
fn notify<T: Summarize + Display>(item: &T) {
    println!("📢 NOTIFIKASI: {}", item);
    println!("Ringkasan: {}", item.summarize());
}

impl Display for Tweet {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.username, self.content)
    }
}

fn demo_traits() {
    println!("--- 2. Traits & Trait Bounds ---");

    let article = NewsArticle {
        headline: String::from("Rust Dipilih Menjadi Bahasa Inti Kernel Linux"),
        location: String::from("Berlin"),
        author: String::from("Linus Torvalds"),
    };

    let tweet = Tweet {
        username: String::from("avrlln"),
        content: String::from("Mempelajari Rust terasa sangat memuaskan!"),
    };

    println!("Article Summary: {}", article.summarize());
    println!("Tweet Summary: {}", tweet.summarize());
    println!();

    notify(&tweet);
    println!();
}

// ==========================================
// 3. LIFETIMES
// ==========================================

/// Fungsi yang membandingkan dua string slice dan mengembalikan string slice yang lebih panjang.
/// Anotasi `'a` menjamin bahwa referensi yang dikembalikan akan valid selama referensi x dan y keduanya valid!
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

fn demo_lifetimes() {
    println!("--- 3. Lifetimes ('a) ---");

    let string1 = String::from("panjangsekali");
    let string2 = "pendek";

    let result = longest(string1.as_str(), string2);
    println!("String terpanjang antara '{}' dan '{}' adalah: '{}'", string1, string2, result);
}
