use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Quote {
    pub author: String,
    pub quote: String,
    pub tags: Vec<String>,
}
