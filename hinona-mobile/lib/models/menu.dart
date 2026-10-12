class Menu {
  final int id;
  final String nama;
  final double harga;
  final String? deskripsi;
  final String? gambar;
  final int? kategoriId;
  final String? kategori;
  final bool aktif;

  Menu({
    required this.id,
    required this.nama,
    required this.harga,
    this.deskripsi,
    this.gambar,
    this.kategoriId,
    this.kategori,
    this.aktif = true,
  });

  // Getter alias agar kompatibel dengan kode yang memanggil 'namaMenu'
  String get namaMenu => nama;

  // Nama kategori untuk pengelompokan (default "Lainnya")
  String get kategoriNama =>
      (kategori == null || kategori!.trim().isEmpty) ? 'Lainnya' : kategori!;

  factory Menu.fromJson(Map<String, dynamic> json) {
    String? namaKategori;
    if (json['kategori'] is Map) {
      namaKategori = json['kategori']['nama_kategori']?.toString();
    } else if (json['kategori'] is String) {
      namaKategori = json['kategori'];
    }

    return Menu(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? json['nama_menu'] ?? '',
      harga: double.tryParse(
            json['harga']?.toString() ?? '0',
          ) ??
          0,
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      kategoriId: json['kategori_id'],
      kategori: namaKategori,
      aktif: json['aktif'] == 1 || json['aktif'] == true || json['status'] == 'aktif' || json['aktif'] == null,
    );
  }
}

// Alias agar file lain yang memanggil MenuModel tetap terbaca
typedef MenuModel = Menu;