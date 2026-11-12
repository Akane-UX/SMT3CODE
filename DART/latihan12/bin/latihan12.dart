void main() {
  var produk1 = Produk('Laptop ASUS ROG', 12500000, 'Elektronik');
  var produk2 = Produk.umum('XBOX Seris X', 10499000);

  produk1.tampilkanInfo();
  produk2.tampilkanInfo();
}

class Produk {
  String namaBarang;
  double harga;
  String kategori;

  Produk(this.namaBarang, this.harga, this.kategori);
  Produk.umum(this.namaBarang, this.harga) : kategori = 'Umum';

  void tampilkanInfo() {
    print('Nama Barang: $namaBarang');
    print('Harga: Rp$harga');
    print('Kategori: $kategori');
    print('--------------------------');
  }
}