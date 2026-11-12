void main() {
  var peserta1 = PesertaKursus('Budi', 'Dart Programming'); 
  var peserta2 = PesertaKursus.lunas('Siti', 'UI/UX Design');

  peserta1.tampilkanData();
  peserta2.tampilkanData();
  
  print('\n-- Menguji method ubahStatusPembayaran() pada peserta 1 --');
  peserta1.ubahStatusPembayaran();
  peserta1.tampilkanData();
}

class PesertaKursus {
  String namaLengkap;
  String namaKursus;
  bool sudahLunas;

  PesertaKursus(this.namaLengkap, this.namaKursus, {this.sudahLunas = false});
  PesertaKursus.lunas(this.namaLengkap, this.namaKursus) : sudahLunas = true;

  void ubahStatusPembayaran() {
    sudahLunas = true;
    print('$namaLengkap telah melunasi pembayaran kursus $namaKursus.');
  }

  void tampilkanData() {
    print('Peserta: $namaLengkap');
    print('Peserta: $namaKursus');
    print('Peserta: $sudahLunas');
  }
}