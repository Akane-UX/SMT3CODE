import 'dart:io';

void main() {
  print('Inputkan sebuah karakter : ');
  String karakter = stdin.readLineSync()!.toLowerCase();

  if (['a','e','i','o','u','A','I','U','E','O'].contains(karakter)) {
    print('Karakter $karakter adalah huruf vokal');
  } else {
    print('Karakter $karakter adalah huruf konsonan');
  }
}
