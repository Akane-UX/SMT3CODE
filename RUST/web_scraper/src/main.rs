mod models;
mod scraper;
mod storage;

use scraper::Scraper;
use std::env;
use std::error::Error;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().collect();
    let max_pages: usize = args
        .get(1)
        .and_then(|val| val.parse::<usize>().ok())
        .unwrap_or(2);

    let target_url = "https://quotes.toscrape.com";
    println!("Web Scraper Rust");
    println!("Target URL : {}", target_url);
    println!("Max Pages  : {}", max_pages);
    println!("Starting scraping process...\n");

    let scraper = Scraper::new(target_url);
    let (quotes, pages_scraped) = scraper.scrape_pages(max_pages).await?;

    println!("Scraping completed!");
    println!("Total pages scraped : {}", pages_scraped);
    println!("Total quotes found   : {}\n", quotes.len());

    println!("Preview sample (first 3 items):");
    for (i, quote) in quotes.iter().take(3).enumerate() {
        println!("{}. Author : {}", i + 1, quote.author);
        println!("   Quote  : {}", quote.quote);
        println!("   Tags   : {}\n", quote.tags.join(", "));
    }

    let json_output = "quotes.json";
    let csv_output = "quotes.csv";

    storage::export_json(json_output, &quotes)?;
    println!("Exported JSON to {}", json_output);

    storage::export_csv(csv_output, &quotes)?;
    println!("Exported CSV to {}", csv_output);

    Ok(())
}
