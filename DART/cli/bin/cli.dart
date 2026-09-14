import 'dart:io';

void main() {
  print('=== Program Cek Ganjil / Genap ===');
  stdout.write('Masukkan sebuah angka: ');
  
  // Membaca input dari user
  String? input = stdin.readLineSync();
  
  if (input != null && input.isNotEmpty) {
    int? number = int.tryParse(input);
    
    if (number != null) {
      // Kondisi untuk menentukan genap atau ganjil
      if (number % 2 == 0) {
        print('$number adalah bilangan GENAP.');
      } else {
        print('$number adalah bilangan GANJIL.');
      }
    } else {
      print('Error: Input yang dimasukkan bukan angka!');
    }
  }
}