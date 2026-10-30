use crate::models::Quote;
use reqwest::Client;
use scraper::{Html, Selector};
use std::error::Error;

pub struct Scraper {
    client: Client,
    base_url: String,
}

impl Scraper {
    pub fn new(base_url: &str) -> Self {
        Self {
            client: Client::builder()
                .user_agent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36")
                .build()
                .unwrap_or_default(),
            base_url: base_url.to_string(),
        }
    }

    pub async fn scrape_page(&self, page: usize) -> Result<(Vec<Quote>, bool), Box<dyn Error>> {
        let url = format!("{}/page/{}/", self.base_url, page);
        let resp = self.client.get(&url).send().await?;
        if !resp.status().is_success() {
            return Ok((Vec::new(), false));
        }

        let body = resp.text().await?;
        let document = Html::parse_document(&body);

        let quote_selector = Selector::parse("div.quote").unwrap();
        let text_selector = Selector::parse("span.text").unwrap();
        let author_selector = Selector::parse("small.author").unwrap();
        let tag_selector = Selector::parse("div.tags a.tag").unwrap();
        let next_selector = Selector::parse("li.next a").unwrap();

        let mut quotes = Vec::new();

        for quote_element in document.select(&quote_selector) {
            let quote_text = quote_element
                .select(&text_selector)
                .next()
                .map(|el| el.text().collect::<Vec<_>>().join("").trim().to_string())
                .unwrap_or_default();

            let author_text = quote_element
                .select(&author_selector)
                .next()
                .map(|el| el.text().collect::<Vec<_>>().join("").trim().to_string())
                .unwrap_or_default();

            let tags = quote_element
                .select(&tag_selector)
                .map(|el| el.text().collect::<Vec<_>>().join("").trim().to_string())
                .collect::<Vec<String>>();

            if !quote_text.is_empty() {
                quotes.push(Quote {
                    author: author_text,
                    quote: quote_text,
                    tags,
                });
            }
        }

        let has_next = document.select(&next_selector).next().is_some();

        Ok((quotes, has_next))
    }

    pub async fn scrape_pages(&self, max_pages: usize) -> Result<(Vec<Quote>, usize), Box<dyn Error>> {
        let mut all_quotes = Vec::new();
        let mut pages_visited = 0;

        for page in 1..=max_pages {
            pages_visited += 1;
            let (quotes, has_next) = self.scrape_page(page).await?;
            if quotes.is_empty() {
                break;
            }
            all_quotes.extend(quotes);

            if !has_next {
                break;
            }
        }

        Ok((all_quotes, pages_visited))
    }
}
