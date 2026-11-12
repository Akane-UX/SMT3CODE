void main() {

  var kendaraan1 = Kendaraan('Mobil', 180, 4);
  var kendaraan2 = Kendaraan('Motor', 120, 2);
 
  kendaraan1.klakson();
  kendaraan2.klakson();
}

class Kendaraan {
  String jenis;
  int kecepatanMaksimal;
  int roda;

  Kendaraan(this.jenis, this.kecepatanMaksimal, this.roda);

  void klakson() {
    print('Kendaraan jenis $jenis berbunyi: Beep beep!');
  }
}
