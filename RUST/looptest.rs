use std::time::Instant;

fn main() {
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