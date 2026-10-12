import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final dynamic transaksi;
  final String metodePembayaran;

  const OrderSuccessScreen({
    super.key,
    required this.transaksi,
    required this.metodePembayaran,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),

              const SizedBox(height: 25),

              const Text(
                'Pesanan Berhasil!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                metodePembayaran == 'qris'
                    ? 'Pembayaran QRIS berhasil diproses.'
                    : 'Silakan lakukan pembayaran di kasir.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}