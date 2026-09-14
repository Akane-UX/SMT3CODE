import 'dart:io';

void main() {
  print(' ');
  print('Cek Ganjil/Genap');
  print(' ');
  print('v masukkan angka');

  String? input = stdin.readLineSync();

  if (input != null && input.isNotEmpty) {
    int? number = int.tryParse(input);

    if (number != null) {
      if (number % 2 == 0) {
        print(' ');
        print('$number adalah bilangan Genap');
      } else {
        print(' ');
        print('$number adalah bilangan Ganjil');
      }
    } else {
      print(' ');
      print('Input yang dimasukkan bukan angka');
    }
  }
}
