import 'dart:io';

import 'package:dio/dio.dart';
import 'package:translator_plus/translator_plus.dart';

final dio = Dio();
final translator = GoogleTranslator();

void main() async {
  var response = await dio.get('https://dummyjson.com/recipes');
  var data = response.data as Map;
  var data2 = data['recipes'];

  print('Daftar Resep : ');
  for (int i=0; i<data2.length; i++) {
    var produk = data2[i] as Map;
    print('${produk['id']} - ${produk['name']}');
  }

  stdout.write('Input ID Resep : ');
  int id = int.parse(stdin.readLineSync()!);
  await detailResep(id);
}

Future<void> detailResep(int id) async {
  var response = await dio.get('https://dummyjson.com/recipes/$id');
  var data = response.data as Map;

  print('\nNama Resep : ${data['name']}');
  print('Bahan :');
  for (var bahan in data['ingredients']) {
    print('- $bahan (${await terjemahkan(bahan)})');
  }
  print('Cara :');
  for (var langkah in data['instructions']) {
    print('- $langkah (${await terjemahkan(langkah)})');
  }
  print('Porsi : ${data['servings']}');
  print('Kesulitan : ${await terjemahkan(data['difficulty'])}');
  print('Asal : ${data['cuisine']}');
}

Future<String> terjemahkan(String teks) async {
  var hasil = await translator.translate(teks, to: 'id');
  return hasil.text;
}