import 'package:flutter/material.dart';
import '../models/menu.dart';
import '../services/api_service.dart';
import 'menu_gambar.dart';
import 'menu_katalog.dart' show ikonKategori;

const Color _coklat = Color(0xFF4B2C20);

String _rupiah(num v) =>
    'Rp ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

/// Deretan "Menu Pilihan" di beranda: diambil dari menu asli di database.
class MenuPilihan extends StatefulWidget {
  final VoidCallback onLihatSemua;

  const MenuPilihan({super.key, required this.onLihatSemua});

  @override
  State<MenuPilihan> createState() => _MenuPilihanState();
}

class _MenuPilihanState extends State<MenuPilihan> {
  final ApiService api = ApiService();

  bool loading = true;
  List<MenuModel> menus = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await api.getMenu();
      final body = r.data;
      final list = body is Map ? (body['data'] ?? []) : body;

      final semua = (list as List)
          .map((e) => MenuModel.fromJson(Map<String, dynamic>.from(e)))
          .where((m) => m.aktif)
          .toList();

      if (!mounted) return;
      setState(() {
        menus = _pilih(semua);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false); // gagal: bagian ini disembunyikan saja
    }
  }

  /// Ambil maksimal 8 menu, bergantian dari tiap kategori.
  /// Menu yang sudah punya foto didahulukan.
  List<MenuModel> _pilih(List<MenuModel> semua) {
    final grup = <String, List<MenuModel>>{};
    for (final m in semua) {
      grup.putIfAbsent(m.kategoriNama, () => []).add(m);
    }

    for (final g in grup.values) {
      g.sort((a, b) {
        final fa = (a.gambar ?? '').isEmpty ? 1 : 0;
        final fb = (b.gambar ?? '').isEmpty ? 1 : 0;
        return fa.compareTo(fb);
      });
    }

    final hasil = <MenuModel>[];
    var i = 0;
    while (hasil.length < 8) {
      var ada = false;
      for (final g in grup.values) {
        if (i < g.length && hasil.length < 8) {
          hasil.add(g[i]);
          ada = true;
        }
      }
      if (!ada) break;
      i++;
    }
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: _coklat)),
      );
    }

    if (menus.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Menu Pilihan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _coklat,
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onLihatSemua,
              child: const Text(
                'Lihat semua',
                style: TextStyle(color: _coklat, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 232,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: menus.length,
            itemBuilder: (context, i) => _kartu(menus[i]),
          ),
        ),
      ],
    );
  }

  Widget _kartu(MenuModel m) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => _detail(m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MenuGambar(
                  gambar: m.gambar,
                  ukuran: 150,
                  radius: 0,
                  ikon: ikonKategori(m.kategoriNama),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.kategoriNama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Text(
                        m.namaMenu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _rupiah(m.harga),
                        style: const TextStyle(
                          color: _coklat,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _detail(MenuModel m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: MenuGambar(
                  gambar: m.gambar,
                  ukuran: 200,
                  radius: 16,
                  ikon: ikonKategori(m.kategoriNama),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                m.kategoriNama,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                m.namaMenu,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (m.deskripsi != null && m.deskripsi!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    m.deskripsi!,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                _rupiah(m.harga),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _coklat,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _coklat.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: _coklat),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Untuk memesan, scan QR di meja Anda.',
                        style: TextStyle(color: _coklat, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}