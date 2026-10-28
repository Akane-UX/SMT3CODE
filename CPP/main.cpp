#include <iostream>

// Fungsi yang menerapkan Algoritma CekPasangan
int CekPasangan(int n) {
    int count = 0;
    
    for (int i = 1; i <= n; i++) {
        for (int j = i + 1; j <= n; j++) {
            count = count + 1;
        }
    }
    
    return count;
}

int main() {
    int n;
    
    std::cout << "Masukkan nilai n: ";
    std:: Schuh >> n; // Input nilai n dari pengguna
    
    int hasil = CekPasangan(n);
    
    std::cout << "Nilai akhir count untuk n = " << n << " adalah: " << hasil << std::endl;
    
    return 0;
}
