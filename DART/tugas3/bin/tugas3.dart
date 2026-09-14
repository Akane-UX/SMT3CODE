import 'dart:io';

void main() {
  print(' ');
  print('kalkulator');
  print(' ');

  print('1.+');
  print('2.-');
  print('3.x');
  print('4./');
  print('v Mau pakai perhitungan apa? (1-4)');
  String? operator = stdin.readLineSync();

  print(' ');
  print('v Masukkan angka pertama');
  double? num1 = double.tryParse(stdin.readLineSync() ?? '');

  print(' ');
  print('v Masukkan angka kedua');
  double? num2 = double.tryParse(stdin.readLineSync() ?? '');

  if (num1 == null || num2 == null || operator == null) {
    print(' ');
    print('Input tidak valid');
    return;
  }

  double result = 0;
  bool isValidOperation = true;
  String opr = '';

  switch (operator) {
    case '1':
      result = num1 + num2;
      opr = '+';
      break;
    case '2':
      result = num1 - num2;
      opr = '-';
      break;
    case '3':
      result = num1 * num2;
      opr = 'x';
      break;
    case '4':
      if (num2 != 0) {
        result = num1 / num2;
        opr = '/';
      } else {
        print(' ');
        print('Tidak bisa melakukan pembagian dengan angka 0');
        isValidOperation = false;
      }
      break;
    default:
      print(' ');
      print('Input tidak dikenali');
      isValidOperation = false;
  }

  if (isValidOperation) {
    print(' ');
    print('Hasil dari perhitungan $num1 $opr $num2 adalah $result');
  }
  print(' ');
  print('Selesai');
}
