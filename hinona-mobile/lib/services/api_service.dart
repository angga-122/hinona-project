import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // =========================
  // MENU (publik)
  // =========================

  Future<Response> getMenu() async => await _dio.get('menu');

  // =========================
  // MEJA / QR (publik)
  // =========================

  Future<Response> getMejaByQr(String kodeQr) async {
    return await _dio.get('pelanggan/meja/${Uri.encodeComponent(kodeQr)}');
  }

  // =========================
  // PESANAN PELANGGAN
  // =========================

  Future<Response> postPesanan(Map<String, dynamic> data) async {
    return await _dio.post('pesanan', data: data);
  }

  Future<Response> checkout(Map<String, dynamic> data) async {
    return await postPesanan(data);
  }

  Future<Response> getPesanan() async => await _dio.get('pesanan');

  // =========================
  // AUTH STAFF
  // =========================

  Future<Response> login(String email, String password) async {
    return await _dio.post('login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> logout(String token) async {
    return await _dio.post('logout', options: _auth(token));
  }

  // =========================
  // KASIR
  // =========================

  Future<Response> getTransaksi(String token) async {
    return await _dio.get('transaksi', options: _auth(token));
  }

  Future<Response> getTransaksiDetail(String token, int id) async {
    return await _dio.get('transaksi/$id', options: _auth(token));
  }

  Future<Response> getMejaKasir(String token) async {
    return await _dio.get('kasir/meja', options: _auth(token));
  }

  Future<Response> buatTransaksi(String token, Map<String, dynamic> data) async {
    return await _dio.post('transaksi', data: data, options: _auth(token));
  }

  Future<Response> ubahTransaksi(
      String token, int id, Map<String, dynamic> data) async {
    return await _dio.put('transaksi/$id', data: data, options: _auth(token));
  }

  Future<Response> hapusTransaksi(String token, int id) async {
    return await _dio.delete('transaksi/$id', options: _auth(token));
  }

  Future<Response> terimaTransaksi(String token, int id) async {
    return await _dio.post('transaksi/$id/terima', options: _auth(token));
  }

  Future<Response> prosesBayar(
    String token,
    int transaksiId,
    double uangBayar, {
    String metode = 'tunai',
  }) async {
    return await _dio.post(
      'transaksi/$transaksiId/bayar',
      data: {
        'uang_bayar': uangBayar,
        'metode_pembayaran': metode,
      },
      options: _auth(token),
    );
  }

  // =========================
  // MANAGER
  // =========================

  // Semua endpoint laporan menerima filter periode opsional:
  // {'tanggal_mulai': 'YYYY-MM-DD', 'tanggal_selesai': 'YYYY-MM-DD'}

  Future<Response> getPendapatan(String token,
      {Map<String, dynamic>? params}) async {
    return await _dio.get('laporan/pendapatan',
        queryParameters: params, options: _auth(token));
  }

  Future<Response> getMenuTerlaris(String token,
      {Map<String, dynamic>? params}) async {
    return await _dio.get('laporan/menu-terlaris',
        queryParameters: params, options: _auth(token));
  }

  Future<Response> getStatistik(String token,
      {Map<String, dynamic>? params}) async {
    return await _dio.get('laporan/statistik',
        queryParameters: params, options: _auth(token));
  }

  Future<Response> getLaporanTransaksi(String token,
      {Map<String, dynamic>? params}) async {
    return await _dio.get('laporan/transaksi',
        queryParameters: params, options: _auth(token));
  }

  // =========================
  // ADMIN: MENU
  // =========================

  Future<Response> getMenuAdmin(String token) async {
    return await _dio.get('admin/menu', options: _auth(token));
  }

  Future<Response> createMenu(String token, Map<String, dynamic> data) async {
    return await _dio.post('menu', data: data, options: _auth(token));
  }

  Future<Response> updateMenu(
      String token, int id, Map<String, dynamic> data) async {
    return await _dio.put('menu/$id', data: data, options: _auth(token));
  }

  Future<Response> deleteMenu(String token, int id) async {
    return await _dio.delete('menu/$id', options: _auth(token));
  }

  Future<Response> uploadGambarMenu(String token, int id, String path) async {
    final form = FormData.fromMap({
      'gambar': await MultipartFile.fromFile(path),
    });
    return await _dio.post('menu/$id/gambar', data: form, options: _auth(token));
  }

  // =========================
  // ADMIN: KATEGORI
  // =========================

  Future<Response> getKategori(String token) async {
    return await _dio.get('kategori', options: _auth(token));
  }

  Future<Response> createKategori(
      String token, Map<String, dynamic> data) async {
    return await _dio.post('kategori', data: data, options: _auth(token));
  }

  Future<Response> updateKategori(
      String token, int id, Map<String, dynamic> data) async {
    return await _dio.put('kategori/$id', data: data, options: _auth(token));
  }

  Future<Response> deleteKategori(String token, int id) async {
    return await _dio.delete('kategori/$id', options: _auth(token));
  }

  // =========================
  // ADMIN: MEJA
  // =========================

  Future<Response> getMeja(String token) async {
    return await _dio.get('meja', options: _auth(token));
  }

  Future<Response> createMeja(String token, Map<String, dynamic> data) async {
    return await _dio.post('meja', data: data, options: _auth(token));
  }

  Future<Response> updateMeja(
      String token, int id, Map<String, dynamic> data) async {
    return await _dio.put('meja/$id', data: data, options: _auth(token));
  }

  Future<Response> deleteMeja(String token, int id) async {
    return await _dio.delete('meja/$id', options: _auth(token));
  }

  // =========================
  // ADMIN: PELANGGAN
  // =========================

  Future<Response> getPelanggan(String token) async {
    return await _dio.get('pelanggan', options: _auth(token));
  }
}