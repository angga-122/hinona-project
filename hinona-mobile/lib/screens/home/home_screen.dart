import 'package:flutter/material.dart';
import '../customer/scan_qr_screen.dart';
import '../staff/staff_login_screen.dart';
import '../../services/api_service.dart';
import '../../widgets/menu_pilihan.dart';
import 'menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF4B2C20); // Cokelat Tua Khas Cafe

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar (Langsung Buka Menu Saat Diklik)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  readOnly: true,
                  onTap: () => _navigateToMenu(context),
                  decoration: const InputDecoration(
                    hintText: 'Cari kopi, makanan, atau varian rasa...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    icon: Icon(Icons.search, color: colorPrimary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Header Branding
              const Center(
                child: Column(
                  children: [
                    Text(
                      'HINONA',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: colorPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hinona Coffee & Roastery',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Coffee, Roastery & Good Moments.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Menu Pilihan (menu asli dari database, bisa digeser)
              MenuPilihan(onLihatSemua: () => _navigateToMenu(context)),
              const SizedBox(height: 20),

              // 4. Card Daftar Menu
              _buildActionCard(
                context: context,
                title: 'Daftar Menu',
                subtitle: 'Jelajahi varian kopi artisan, pilihan biji kopi, dan hidangan penutup. Untuk memesan, scan QR di meja Anda.',
                icon: Icons.restaurant_menu_rounded,
                buttonText: 'LIHAT MENU',
                onTap: () => _navigateToMenu(context),
              ),
              const SizedBox(height: 16),

              // 5. Card Cek Status Pesanan
              _buildActionCard(
                context: context,
                title: 'Status Pesanan Saya',
                subtitle: 'Cek status pembuatan atau pembayaran pesanan berdasarkan nomor meja.',
                icon: Icons.receipt_long_rounded,
                buttonText: 'CEK STATUS PESANAN',
                onTap: () => _showCheckOrderStatusDialog(context),
              ),
              const SizedBox(height: 16),

              // 6. Card Tentang Cafe
              _buildActionCard(
                context: context,
                title: 'Tentang Cafe',
                subtitle: 'Mengenal cerita, visi, dan filosofi seduhan Hinona Coffee & Roastery.',
                icon: Icons.info_outline_rounded,
                buttonText: 'PELAJARI LEBIH LANJUT',
                onTap: () => _showAboutDialog(context),
              ),
              const SizedBox(height: 30),

              // 7. Tombol Utama (Pesan dari Meja -> Scan QR)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4B2C20), Color(0xFF3E2723)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _bukaScanQr(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner_rounded, color: Colors.amberAccent, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'PESAN DARI MEJA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Scan QR di meja untuk memulai pemesanan',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Staff (Langsung Membuka Halaman StaffLoginScreen)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StaffLoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_person_outlined, size: 18, color: colorPrimary),
                  label: const Text(
                    'Akses Staff / Kasir',
                    style: TextStyle(color: colorPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Action Card
  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B2C20).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF4B2C20), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4B2C20),
                side: const BorderSide(color: Color(0xFF4B2C20)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onTap,
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Lihat daftar menu saja (tanpa memesan). Untuk memesan wajib scan QR meja.
  void _navigateToMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MenuScreen()),
    );
  }

  // Buka layar scan QR meja
  void _bukaScanQr(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanQrScreen()),
    );
  }

  // Ambil angka pertama dari teks, contoh "Meja 05" -> 5, "1" -> 1
  int? _angka(String teks) {
    final m = RegExp(r'\d+').firstMatch(teks);
    if (m == null) return null;
    return int.tryParse(m.group(0)!);
  }

  // Dialog Cek Status Pesanan
  void _showCheckOrderStatusDialog(BuildContext context) {
    final TextEditingController tableController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cek Pesanan Meja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan nomor meja Anda untuk melacak status pesanan:'),
            const SizedBox(height: 12),
            TextField(
              controller: tableController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 1',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B2C20)),
            onPressed: () {
              final nomorMeja = tableController.text.trim();
              if (nomorMeja.isNotEmpty) {
                Navigator.pop(dialogContext);
                _fetchAndShowOrderStatus(context, nomorMeja);
              }
            },
            child: const Text('Cek Status', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Memanggil API & Menampilkan BottomSheet Status Pesanan
  Future<void> _fetchAndShowOrderStatus(BuildContext context, String nomorMeja) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.brown)),
    );

    try {
      final api = ApiService();
      final response = await api.getPesanan();
      if (context.mounted) Navigator.pop(context);

      final data = response.data;
      List list = [];
      if (data is Map) {
        list = data['data'] ?? data['pesanan'] ?? data['result'] ?? [];
      } else if (data is List) {
        list = data;
      }

      final cari = _angka(nomorMeja);

      final pesananMeja = list.where((p) {
        if (cari == null) return false;

        final meja = p['meja'];

        // Cocokkan lewat nomor meja ("Meja 1" -> 1)
        if (meja is Map && meja['nomor_meja'] != null) {
          return _angka(meja['nomor_meja'].toString()) == cari;
        }

        // Cadangan: cocokkan lewat meja_id
        return p['meja_id']?.toString() == cari.toString();
      }).toList();

      if (context.mounted) {
        _showStatusBottomSheet(context, nomorMeja, pesananMeja);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil pesanan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Tampilan Status Pesanan dalam BottomSheet
  void _showStatusBottomSheet(BuildContext context, String nomorMeja, List pesananList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Pesanan Meja $nomorMeja',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4B2C20)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: pesananList.isEmpty
                  ? const Center(
                      child: Text('Belum ada pesanan aktif untuk meja ini.', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: pesananList.length,
                      itemBuilder: (context, index) {
                        final item = pesananList[index];
                        final status = item['status'] ?? 'pending';
                        final total = item['total_harga'] ?? item['total'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Icon(
                              status == 'selesai'
                                  ? Icons.check_circle
                                  : (status == 'diproses' ? Icons.soup_kitchen : Icons.access_time),
                              color: status == 'selesai'
                                  ? Colors.green
                                  : (status == 'diproses' ? Colors.orange : Colors.blue),
                            ),
                            title: Text('Pesanan #${item['id'] ?? (index + 1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Status: ${status.toString().toUpperCase()}'),
                            trailing: Text(
                              'Rp $total',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Tentang Cafe
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tentang Hinona Coffee'),
        content: const Text(
          'Hinona Coffee & Roastery menghadirkan pengalaman kopi terbaik sejak 2018. Kami memanggang biji kopi lokal pilihan secara mandiri untuk menjamin cita rasa otentik di setiap cangkirnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.brown)),
          ),
        ],
      ),
    );
  }
}