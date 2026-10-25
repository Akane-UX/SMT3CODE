//! Modul 07: Smart Pointers & Fearless Concurrency
//! Menjalankan materi: `cargo run -p smart_pointers_concurrency`

use std::sync::{mpsc, Arc, Mutex};
use std::thread;
use std::time::Duration;

fn main() {
    println!("=== 🦀 MODUL 07: SMART POINTERS & CONCURRENCY ===\n");

    // 1. Box<T> (Heap Allocation & Recursive Types)
    demo_box();

    // 2. Thread Spawning & Join Handles
    demo_thread_spawn();

    // 3. Message Passing Channels (mpsc)
    demo_channels();

    // 4. Shared State Concurrency (Arc + Mutex)
    demo_shared_state_mutex();

    println!("\n✅ Modul 07 selesai dipelajari dengan sukses!");
}

// ==========================================
// 1. BOX<T> & RECURSIVE DATA STRUCTURE
// ==========================================

#[allow(dead_code)]
#[derive(Debug)]
enum List {
    Cons(i32, Box<List>), // Menggunakan Box agar compiler tahu ukuran alokasi List
    Nil,
}

use List::{Cons, Nil};

fn demo_box() {
    println!("--- 1. Box<T> for Heap Allocation ---");

    // Alokasi angka sederhana di heap
    let b = Box::new(5);
    println!("Nilai di dalam Box di heap: {}", b);

    // Linked List rekursif dengan Box: 1 -> 2 -> 3 -> Nil
    let list = Cons(1, Box::new(Cons(2, Box::new(Cons(3, Box::new(Nil))))));
    println!("Linked List rekursif via Box: {:?}\n", list);
}

// ==========================================
// 2. THREAD SPAWNING
// ==========================================

fn demo_thread_spawn() {
    println!("--- 2. Thread Spawning & Join ---");

    // Spawn thread baru
    let handle = thread::spawn(|| {
        for i in 1..=3 {
            println!("   [Spawned Thread] Iterasi {}", i);
            thread::sleep(Duration::from_millis(50));
        }
    });

    for i in 1..=2 {
        println!("[Main Thread] Sedang bekerja {}", i);
        thread::sleep(Duration::from_millis(50));
    }

    // Tunggu spawned thread selesai sebelum melanjutkan
    handle.join().unwrap();
    println!("Spawned thread selesai bergabung kembali ke main thread.\n");
}

// ==========================================
// 3. CHANNELS (MESSAGE PASSING)
// ==========================================

fn demo_channels() {
    println!("--- 3. Message Passing Channels (mpsc) ---");

    // mpsc = multiple producer, single consumer
    let (tx, rx) = mpsc::channel();

    // Clone transmitter untuk mendemonstrasikan multiple producer
    let tx1 = tx.clone();
    thread::spawn(move || {
        let vals = vec!["Pesan 1 dari Worker A", "Pesan 2 dari Worker A"];
        for val in vals {
            tx1.send(String::from(val)).unwrap();
            thread::sleep(Duration::from_millis(40));
        }
    });

    thread::spawn(move || {
        let vals = vec!["Pesan 1 dari Worker B", "Pesan 2 dari Worker B"];
        for val in vals {
            tx.send(String::from(val)).unwrap();
            thread::sleep(Duration::from_millis(40));
        }
    });

    // Main thread bertindak sebagai consumer penerima pesan
    println!("Main thread mendengarkan pesan masuk dari channel:");
    for received in rx {
        println!("📩 Diterima: {}", received);
    }
    println!();
}

// ==========================================
// 4. SHARED STATE (ARC + MUTEX)
// ==========================================

fn demo_shared_state_mutex() {
    println!("--- 4. Shared State with Arc<Mutex<T>> ---");

    // Counter bersama yang dilindungi Mutex dan dibungkus Arc (Atomic Reference Counting)
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    // Buat 10 thread paralel yang masing-masing menambah counter sebesar 1
    for i in 0..10 {
        let counter_clone = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            // .lock() memblokir thread lain sampai mutex dilepaskan (saat num keluar scope)
            let mut num = counter_clone.lock().unwrap();
            *num += 1;
            println!("   Thread #{} menambahkan counter menjadi: {}", i, *num);
        });
        handles.push(handle);
    }

    // Tunggu seluruh 10 thread selesai
    for handle in handles {
        handle.join().unwrap();
    }

    println!("Nilai akhir counter (dijamin aman tanpa data race!): {}", *counter.lock().unwrap());
}
