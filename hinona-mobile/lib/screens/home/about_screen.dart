import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Tentang Hinona')),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Container(
              height: 210,
              width: double.infinity,

              decoration: BoxDecoration(
                color:
                    const Color(0xFF25170F),

                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: const Center(
                child: Icon(
                  Icons.local_cafe,
                  size: 90,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Hinona Coffee & Roastery',

              style: TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Hinona adalah cafe dengan konsep nyaman untuk menikmati kopi, minuman, makanan, dan waktu bersama teman. Aplikasi ini membantu pelanggan melihat menu dan melakukan pemesanan langsung dari meja melalui QR.',

              style: TextStyle(
                height: 1.6,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Cara Pesan',

              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              '1. Duduk di meja yang tersedia.\n'
              '2. Scan QR meja.\n'
              '3. Pilih menu.\n'
              '4. Masukkan ke keranjang.\n'
              '5. Pilih metode pembayaran.\n'
              '6. Pesanan diproses oleh Hinona.',
            ),
          ],
        ),
      ),
    );
  }
}