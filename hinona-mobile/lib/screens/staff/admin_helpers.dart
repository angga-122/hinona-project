import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const Color adminColor = Color(0xFF4B2C20);

/// Mengubah error Dio menjadi pesan yang mudah dibaca.
String pesanError(Object e) {
  if (e is DioException) {
    final d = e.response?.data;
    if (d is Map) {
      if (d['errors'] is Map && (d['errors'] as Map).isNotEmpty) {
        final first = (d['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) return '${first.first}';
      }
      if (d['message'] != null) return '${d['message']}';
    }
    if (e.response != null) return 'Server error (${e.response!.statusCode})';
    return 'Tidak bisa terhubung ke server.';
  }
  return '$e';
}

void tampilSnack(BuildContext context, String teks, {bool merah = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(teks),
      backgroundColor: merah ? Colors.red : Colors.green.shade700,
    ),
  );
}

List<Map<String, dynamic>> ambilList(dynamic body) {
  final list = body is Map ? (body['data'] ?? []) : body;
  return (list as List).map((e) => Map<String, dynamic>.from(e)).toList();
}

Future<bool> konfirmasiHapus(BuildContext context, String judul, String isi) async {
  final hasil = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(judul),
      content: Text(isi),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return hasil == true;
}