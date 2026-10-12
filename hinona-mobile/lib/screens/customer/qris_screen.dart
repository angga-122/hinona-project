import 'package:flutter/material.dart';
import 'order_success_screen.dart';

class QrisScreen extends StatelessWidget {
  final dynamic transaksi;

  const QrisScreen({
    super.key,
    required this.transaksi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran QRIS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Scan QRIS untuk membayar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            Container(
              width: 260,
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_2,
                  size: 200,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Silakan scan QRIS Hinona Coffee & Roastery',
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderSuccessScreen(
                        transaksi: transaksi,
                        metodePembayaran: 'qris',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Saya Sudah Bayar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}