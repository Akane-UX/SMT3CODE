// void main() {
//   int n = 10;
//   int a = 0;
//   int b = 1;
//   print("Fibonacci Series up to $n terms:");
//   for (int i = 0; i < n; i++) {
//     print(a);
//     int next = a + b;
//     a = b;
//     b = next;
//   }
// }
import 'dart:io';

int n = 6;
// Fungsi yang menerapkan Algoritma CekPasangan
int cekPasangan(int n) {
  int count = 0;

  for (int i = 1; i <= n; i++) {
    for (int j = i + 1; j <= n; j++) {
      count = count + 1;
    }
  }

  return count;
}

void main() {
  // Meminta input dari pengguna melalui terminal
  stdout.write('Masukkan nilai n: ');
  String? input = stdin.readLineSync();

  if (input != null && int.tryParse(input) != null) {
    int n = int.parse(input);
    int hasil = cekPasangan(n);
    print('Nilai akhir count untuk n = $n adalah: $hasil');
  } else {
    print('Input tidak valid. Harap masukkan angka.');
  }
}
