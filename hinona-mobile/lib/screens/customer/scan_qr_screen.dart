import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/api_service.dart';
import '../../models/meja.dart';
import 'customer_menu_screen.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final api = ApiService();

  bool processing = false;
  String? pesan;

  String _pesanError(Object e) {
    if (e is DioException) {
      if (e.response == null) {
        return 'Tidak bisa terhubung ke server. Cek koneksi dan alamat server.';
      }
      final code = e.response!.statusCode;
      if (code == 404) {
        return 'QR tidak dikenali atau meja tidak aktif. Gunakan QR meja Hinona.';
      }
      final d = e.response!.data;
      if (d is Map && d['message'] != null) return '${d['message']}';
      return 'Server error ($code).';
    }
    return 'Terjadi kesalahan: $e';
  }

  Future<void> handleQr(String value) async {
    if (processing) return;

    setState(() {
      processing = true;
      pesan = null;
    });

    try {
      final response = await api.getMejaByQr(value.trim());

      final body = response.data;

      final data = body is Map && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'])
          : Map<String, dynamic>.from(body);

      final meja = MejaModel.fromJson(data);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerMenuScreen(meja: meja),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        pesan = _pesanError(e);
      });

      // Jeda sebentar supaya kamera tidak membaca ulang QR yang sama terus-menerus
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() {
        processing = false;
      });
    }
  }

  Future<void> _inputManual() async {
    final c = TextEditingController();

    final kode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Masukkan Kode Meja'),
        content: TextField(
          controller: c,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'contoh: HINONA-MEJA-1',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );

    if (kode != null && kode.isNotEmpty) {
      await handleQr(kode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Meja')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) return;

              final code = capture.barcodes.first.rawValue;

              if (code != null && code.isNotEmpty) {
                handleQr(code);
              }
            },
          ),
          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: pesan != null ? Colors.red.shade700 : Colors.black87,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    pesan ??
                        (processing
                            ? 'Memeriksa QR meja...'
                            : 'Arahkan kamera ke QR meja Hinona'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: processing ? null : _inputManual,
                  icon: const Icon(Icons.keyboard, color: Colors.white),
                  label: const Text(
                    'Masukkan kode manual',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}