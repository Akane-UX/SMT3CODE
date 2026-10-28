//! Modul 08: MiniGrep CLI
//! Contoh penggunaan: `cargo run -p minigrep -- Rust 08_mini_projects/minigrep/sample.txt`

use std::env;
use std::fs;
use std::process;

/// Menyimpan konfigurasi argumen CLI
struct Config {
    query: String,
    file_path: String,
}

impl Config {
    /// Membangun konfigurasi dari iterator argumen
    fn build(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("Penggunaan: minigrep <query> <file_path>");
        }

        let query = args[1].clone();
        let file_path = args[2].clone();

        Ok(Config { query, file_path })
    }
}

/// Menjalankan pembacaan file dan pencarian baris yang cocok
fn run(config: Config) -> Result<(), Box<dyn std::error::Error>> {
    let contents = fs::read_to_string(&config.file_path)?;

    println!("🔎 Mencari '{}' di berkas '{}'...\n", config.query, config.file_path);

    let results = search(&config.query, &contents);

    if results.is_empty() {
        println!("(Tidak ada baris yang cocok)");
    } else {
        println!("Hasil temuan:");
        for (line_num, line) in results {
            println!("  [{:>2}] {}", line_num, line);
        }
    }

    Ok(())
}

/// Algoritma pencarian baris menggunakan fungsional iterator
/// Mengembalikan tuple (nomor_baris, isi_baris)
fn search<'a>(query: &str, contents: &'a str) -> Vec<(usize, &'a str)> {
    contents
        .lines()
        .enumerate()
        .filter(|(_, line)| line.to_lowercase().contains(&query.to_lowercase()))
        .map(|(idx, line)| (idx + 1, line))
        .collect()
}

fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::build(&args).unwrap_or_else(|err| {
        eprintln!("❌ Kesalahan Argumen: {}", err);
        eprintln!("💡 Tip: Coba jalankan: cargo run -p minigrep -- Rust 08_mini_projects/minigrep/sample.txt");
        process::exit(1);
    });

    if let Err(e) = run(config) {
        eprintln!("❌ Kesalahan Aplikasi: {}", e);
        process::exit(1);
    }
}

// ==========================================
// AUTOMATED UNIT TESTS
// ==========================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_search_single_match() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
Duct tape.";

        let results = search(query, contents);
        // "duct" cocok dengan "productive." (baris 2) dan "Duct tape." (baris 4)
        assert_eq!(results.len(), 2);
        assert_eq!(results[0], (2, "safe, fast, productive."));
        assert_eq!(results[1], (4, "Duct tape."));
    }

    #[test]
    fn test_search_case_insensitive() {
        let query = "rUsT";
        let contents = "\
Rust:
safe, fast, productive.
Trust me.";

        let results = search(query, contents);
        assert_eq!(results.len(), 2);
    }
}
