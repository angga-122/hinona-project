import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import 'admin_kategori_screen.dart';
import 'admin_meja_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_pelanggan_screen.dart';

class AdminDashboard extends StatelessWidget {
  final String token;

  const AdminDashboard({super.key, required this.token});

  static const colorPrimary = Color(0xFF4B2C20);

  Future<void> _logout(BuildContext context) async {
    try {
      await ApiService().logout(token);
    } catch (_) {
      // abaikan error; tetap keluar dari aplikasi
    }
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _buka(BuildContext context, Widget halaman) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => halaman));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _menu(context, Icons.restaurant_menu, 'Kelola Menu',
              () => _buka(context, AdminMenuScreen(token: token))),
          _menu(context, Icons.category, 'Kategori',
              () => _buka(context, AdminKategoriScreen(token: token))),
          _menu(context, Icons.table_restaurant, 'Meja & QR',
              () => _buka(context, AdminMejaScreen(token: token))),
          _menu(context, Icons.people, 'Pelanggan',
              () => _buka(context, AdminPelangganScreen(token: token))),
        ],
      ),
    );
  }

  Widget _menu(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: colorPrimary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}