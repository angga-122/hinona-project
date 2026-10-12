class TransaksiModel {
  final int id;
  final String? nomorTransaksi;
  final double total;
  final String status;
  final String? metodePembayaran;

  TransaksiModel({
    required this.id,
    this.nomorTransaksi,
    required this.total,
    required this.status,
    this.metodePembayaran,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'],
      nomorTransaksi: json['nomor_transaksi'],
      total: double.tryParse(
            json['total'].toString(),
          ) ??
          0,
      status: json['status'] ?? '',
      metodePembayaran: json['metode_pembayaran'],
    );
  }
}