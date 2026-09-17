import 'dart:io';
void main() {
  String tanya = '';
  do {
    print(' ');
    print('kalkulator');
    print(' ');

    print('1.+');
    print('2.-');
    print('3.x');
    print('4./');
    print('5.Keluar');
    print('');
    print('v Mau pakai perhitungan apa? (1-4) pilih 5 untuk keluar');
    String? operatorInput = stdin.readLineSync();
    if (operatorInput == null) {
      return;
    }
    int? operator = int.tryParse(operatorInput);

    if (operator == null || operator < 1 || operator > 5) {
      print(' ');
      print('Input tidak dikenali');
      tanya = 'y';
      continue;
    } else if (operator == 5) {
      return;

    } else if (operator < 5) {
      print(' ');
      print('v Masukkan angka pertama');
      double? num1 = double.tryParse(stdin.readLineSync() ?? '');

      print(' ');
      print('v Masukkan angka kedua');
      double? num2 = double.tryParse(stdin.readLineSync() ?? '');

      if (num1 == null || num2 == null || operator > 5) {
        print(' ');
        print('Input tidak valid');
        break;
      }
      double result = 0;
      bool isValidOperation = true;
      String opr = '';

      switch (operator) {
        case 1:
          result = num1 + num2;
          opr = '+';
          break;
        case 2:
          result = num1 - num2;
          opr = '-';
          break;
        case 3:
          result = num1 * num2;
          opr = 'x';
          break;
        case 4:
          if (num2 != 0) {
            result = num1 / num2;
            opr = '/';
          } else {
            print(' ');
            print('Tidak bisa melakukan pembagian dengan eangka 0');
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
      do {
        stdout.write('\nCoba Lagi [y/t] ? ');
        tanya = (stdin.readLineSync() ?? 't').toLowerCase();
      } while (tanya != 'y' && tanya != 't');
    }
  } while (tanya == 'y');
}
