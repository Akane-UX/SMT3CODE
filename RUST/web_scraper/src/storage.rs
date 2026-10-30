use crate::models::Quote;
use std::error::Error;
use std::fs::File;
use std::io::Write;

pub fn export_json(path: &str, quotes: &[Quote]) -> Result<(), Box<dyn Error>> {
    let json = serde_json::to_string_pretty(quotes)?;
    let mut file = File::create(path)?;
    file.write_all(json.as_bytes())?;
    Ok(())
}

pub fn export_csv(path: &str, quotes: &[Quote]) -> Result<(), Box<dyn Error>> {
    let mut writer = csv::Writer::from_path(path)?;
    writer.write_record(["Author", "Quote", "Tags"])?;

    for q in quotes {
        writer.write_record([
            &q.author,
            &q.quote,
            &q.tags.join("; "),
        ])?;
    }

    writer.flush()?;
    Ok(())
}
