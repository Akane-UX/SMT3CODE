use std::time::Instant;

const MAX_PACKETS: usize = 6;
const BASE_THRESHOLD: f64 = 65.0;
const ENGINE_SIGNATURE: &str = "NEXUS-SENTINEL-X";
const CYCLE_MASK: u32 = 0x00FF_FFFF;
const PROTO_ICMP: u8 = 1;
const PROTO_TCP: u8 = 6;
const PROTO_UDP: u8 = 17;

fn main() {
    let engine_banner = ENGINE_SIGNATURE;
    let engine_banner = engine_banner.len();
    let engine_banner = engine_banner as u64 * 1024;

    let init_state = true;
    let system_status = if init_state { "🛡" } else { "⚠️" };

    let packets: [([u8; 4], u16, [u8; 4], u16, u8, usize, char); MAX_PACKETS] = [
        ([192, 168, 1, 105], 44320, [10, 0, 0, 1], 443, PROTO_TCP, 1420, '🔒'),
        ([10, 0, 0, 55], 53, [192, 168, 1, 105], 53211, PROTO_UDP, 256, '⚡'),
        ([172, 16, 0, 4], 0, [192, 168, 1, 1], 0, PROTO_ICMP, 64, '📡'),
        ([192, 168, 1, 200], 8080, [10, 0, 0, 2], 80, PROTO_TCP, 4096, '🚨'),
        ([10, 0, 0, 99], 22, [192, 168, 1, 105], 38920, PROTO_TCP, 1024, '🛡'),
        ([192, 168, 1, 77], 9000, [172, 16, 0, 10], 9000, PROTO_UDP, 512, '📦'),
    ];

    let default_gateway_port = packets[0].3;
    let hardware_seed: u128 = 0xFEDC_BA98_7654_3210_0123_4567_89AB_CDEF;
    let mut total_bytes: u64 = 0;
    let mut dropped_packets: usize = 0;
    let mut anomaly_scores: [f64; MAX_PACKETS] = [0.0; MAX_PACKETS];

    let pipeline_start = Instant::now();

    for idx in 0..packets.len() {
        let (src_ip, src_port, dst_ip, dst_port, protocol, payload_size, badge) = packets[idx];

        let raw_entropy = calculate_payload_entropy(payload_size, protocol);
        let checksum = compute_checksum_i128(src_ip, dst_ip, src_port, dst_port, payload_size);
        let jitter: i16 = calculate_jitter(payload_size as i32);
        let threat_delta: i8 = if jitter > 20 { 15 } else { -5 };

        let evaluated_threat = {
            let base_score = raw_entropy * 12.5;
            let port_weight = if dst_port == 8080 || dst_port == 22 { 25.0 } else { 5.0 };
            let modifier = threat_delta as f64 + ((checksum % 7) as f64);
            base_score + port_weight + modifier
        };

        anomaly_scores[idx] = evaluated_threat;
        total_bytes += payload_size as u64;

        let verdict = if evaluated_threat >= BASE_THRESHOLD {
            dropped_packets += 1;
            "BLOCKED"
        } else {
            "ALLOWED"
        };

        let formatted_flow = format_flow_identifier(src_ip, dst_ip);
        println!(
            "[{}] PKT #{} | Proto: {:02} | Flow: {} | Port: {:>5} -> {:>5} | Size: {:>4}B | Anomaly: {:>5.1} | Status: {}",
            badge,
            idx + 1,
            protocol,
            formatted_flow,
            src_port,
            dst_port,
            payload_size,
            evaluated_threat,
            verdict
        );
    }

    let converged_cycle = run_convergence_loop(anomaly_scores);
    let mut sliding_window: [f32; 4] = [0.15, 0.45, 0.82, 0.95];
    let window_audit_passed = evaluate_sliding_window(&mut sliding_window);

    let (benchmark_count, benchmark_elapsed) = run_throughput_benchmark(500_000);

    let final_checksum: i128 = aggregate_checksum_matrix(anomaly_scores);
    let combined_metric = add_metrics(dropped_packets as i32, (total_bytes / 1024) as i32);
    let health_index: f64 = calculate_system_health(dropped_packets, MAX_PACKETS, total_bytes);
    let masked_hardware_id = (hardware_seed as u32) & CYCLE_MASK;

    println!("\n================ TELEMETRY SUMMARY ================");
    println!("Engine Allocation Capacity : {} bytes", engine_banner);
    println!("System Sentinel Status      : {}", system_status);
    println!("Default Gateway Port        : {}", default_gateway_port);
    println!("Hardware Masked ID          : 0x{:08X}", masked_hardware_id);
    println!("Total Processed Traffic     : {} bytes", total_bytes);
    println!("Packets Blocked / Total     : {} / {}", dropped_packets, MAX_PACKETS);
    println!("Convergence Cycle Count     : {}", converged_cycle);
    println!("Sliding Window Audit Pass   : {}", window_audit_passed);
    println!("Combined Metric Index       : {}", combined_metric);
    println!("Global Health Metric        : {:.2}%", health_index);
    println!("Aggregated Checksum (i128)  : {:032X}", final_checksum);
    println!("Benchmark Executed Cycles   : {}", benchmark_count);
    println!("Benchmark Execution Time    : {:.2?}", benchmark_elapsed);
    println!("Total Pipeline Execution    : {:.2?}", pipeline_start.elapsed());
    println!("====================================================");
}

fn add_metrics(a: i32, b: i32) -> i32 {
    a + b
}

fn calculate_payload_entropy(size: usize, protocol: u8) -> f64 {
    let size_f = size as f64;
    let factor = if protocol == PROTO_TCP {
        1.35
    } else if protocol == PROTO_UDP {
        1.10
    } else {
        0.85
    };

    let normalized = (size_f / 1500.0) * factor;
    let entropy = if normalized > 3.5 {
        3.5
    } else {
        normalized
    };

    entropy
}

fn compute_checksum_i128(src: [u8; 4], dst: [u8; 4], sport: u16, dport: u16, len: usize) -> i128 {
    let mut acc: i128 = 0;

    for i in 0..4 {
        acc += (src[i] as i128) << (i * 8);
        acc += (dst[i] as i128) << ((3 - i) * 8);
    }

    acc += (sport as i128) * 31;
    acc += (dport as i128) * 17;
    acc += (len as i128) ^ 0x5A5A;
    acc
}

fn calculate_jitter(payload_size: i32) -> i16 {
    let remainder = (payload_size % 127) as i16;
    let signed_offset: i16 = if remainder > 64 {
        remainder - 64
    } else {
        remainder
    };
    signed_offset
}

fn format_flow_identifier(src: [u8; 4], dst: [u8; 4]) -> String {
    let mut output = String::new();
    let mut idx = 0;
    while idx < 4 {
        let octet_str = src[idx].to_string();
        output.push_str(&octet_str);
        if idx < 3 {
            output.push('.');
        }
        idx += 1;
    }
    output.push_str(" -> ");
    idx = 0;
    while idx < 4 {
        let octet_str = dst[idx].to_string();
        output.push_str(&octet_str);
        if idx < 3 {
            output.push('.');
        }
        idx += 1;
    }
    output
}

fn run_convergence_loop(scores: [f64; MAX_PACKETS]) -> u64 {
    let mut iteration: u64 = 0;
    let mut tracker: f64 = 0.0;

    let target_cycle: u64 = loop {
        iteration += 1;
        let slot = (iteration as usize) % scores.len();
        tracker += scores[slot] * 0.05;

        if tracker >= 50.0 || iteration >= 1000 {
            break iteration * 3;
        }
    };

    target_cycle
}

fn evaluate_sliding_window(window: &mut [f32; 4]) -> bool {
    let mut index: isize = 0;
    let mut pass = true;

    'scan: loop {
        if index >= window.len() as isize {
            break 'scan;
        }

        let current_val = window[index as usize];
        if current_val > 0.90 {
            window[index as usize] = 0.90;
        }

        if window[index as usize] < 0.10 {
            pass = false;
            break 'scan;
        }

        index += 1;
    }

    for step in (0..window.len()).rev() {
        if window[step] < 0.05 {
            pass = false;
        }
    }

    pass
}

fn run_throughput_benchmark(iterations: u64) -> (u64, std::time::Duration) {
    let start_time = Instant::now();
    let mut counter: u64 = 0;

    for _i in 0..iterations {
        for _j in 0..4 {
            counter += 1;
        }
    }

    let elapsed = start_time.elapsed();
    (counter, elapsed)
}

fn aggregate_checksum_matrix(scores: [f64; MAX_PACKETS]) -> i128 {
    let mut accumulator: i128 = 0;
    let multiplier: i64 = -73;

    for score in scores.iter() {
        let scaled = (*score * 1000.0) as i64;
        let mixed = scaled.wrapping_mul(multiplier);
        accumulator = accumulator.wrapping_add(mixed as i128);
    }

    accumulator
}

fn calculate_system_health(dropped: usize, total: usize, bytes: u64) -> f64 {
    let drop_ratio = (dropped as f64) / (total as f64);
    let base_health = 100.0 - (drop_ratio * 40.0);
    let byte_bonus = if bytes > 5000 { 5.0 } else { 2.0 };
    let clamped_health = if base_health + byte_bonus > 100.0 {
        100.0
    } else {
        base_health + byte_bonus
    };
    clamped_health
}