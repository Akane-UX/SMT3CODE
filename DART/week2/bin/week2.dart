// void main() {
//   int number = 7; // Change this value to test other numbers

//   if (number % 2 == 0) {
//     print('$number is Even.');
//   } else {
//     print('$number is Odd.');
//   }
// }

import 'dart:io';

void main() {

  stdout.write('Masukkan operator (+, -, *, /): ');
  String? operation = stdin.readLineSync();

  stdout.write('Masukkan angka pertama: ');
  double? num1 = double.tryParse(stdin.readLineSync() ?? '');

  stdout.write('Masukkan angka kedua: ');
  double? num2 = double.tryParse(stdin.readLineSync() ?? '');

  if (num1 == null || num2 == null) {
    print('Error: Input angka tidak valid!');
    return;
  }

  switch (operation) {
    case '+':
      print('Hasil: $num1 + $num2 = ${num1 + num2}');
      break;
    case '-':
      print('Hasil: $num1 - $num2 = ${num1 - num2}');
      break;
    case '*':
      print('Hasil: $num1 * $num2 = ${num1 * num2}');
      break;
    case '/':
      if (num2 != 0) {
        print('Hasil: $num1 / $num2 = ${num1 / num2}');
      } else {
        print('Error: Pembagian dengan angka nol tidak diperbolehkan.');
      }
      break;
    default:
      print('Error: Operator tidak valid! Gunakan +, -, *, atau /.');
  }
}