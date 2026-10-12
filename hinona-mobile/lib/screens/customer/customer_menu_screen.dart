import 'package:flutter/material.dart';
import '../../models/menu.dart';
import '../../models/meja.dart';
import '../../services/api_service.dart';
import '../../widgets/menu_katalog.dart';
import 'cart_screen.dart';

class CustomerMenuScreen extends StatefulWidget {
  final MejaModel meja;

  const CustomerMenuScreen({
    super.key,
    required this.meja,
  });

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  final api = ApiService();

  List<MenuModel> menus = [];
  final List<Map<String, dynamic>> cart = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    try {
      final response = await api.getMenu();
      final body = response.data;
      final list = body is Map ? body['data'] ?? [] : body;

      if (!mounted) return;
      setState(() {
        menus = List<Map<String, dynamic>>.from(list)
            .map((json) => MenuModel.fromJson(json))
            .where((m) => m.aktif)
            .toList();
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Gagal memuat menu. Periksa koneksi lalu coba lagi.';
      });
    }
  }

  void addMenu(MenuModel menu) {
    setState(() {
      final index = cart.indexWhere((item) => item['menu_id'] == menu.id);
      if (index >= 0) {
        cart[index]['jumlah']++;
      } else {
        cart.add({
          'menu_id': menu.id,
          'nama_menu': menu.namaMenu,
          'harga': menu.harga,
          'jumlah': 1,
        });
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+1 ${menu.namaMenu} ditambahkan'),
        duration: const Duration(milliseconds: 600),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.brown.shade800,
      ),
    );
  }

  int get totalCartItems => cart.fold(0, (sum, item) => sum + (item['jumlah'] as int));
  double get totalCartPrice => cart.fold(0.0, (sum, item) => sum + ((item['harga'] as num) * (item['jumlah'] as int)));

  String formatRupiah(num value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  void _bukaKeranjang() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(meja: widget.meja, cart: cart),
      ),
    ).then((_) {
      if (mounted) setState(() {}); // segarkan jumlah item setelah kembali dari keranjang
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4B2C20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hinona Coffee & Roastery', style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text('Meja: ${widget.meja.nomorMeja}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _bukaKeranjang,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                if (totalCartItems > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.orange.shade700,
                      child: Text(
                        '$totalCartItems',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              loading = true;
                              error = null;
                            });
                            loadMenu();
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: MenuKatalog(
                        menus: menus,
                        onAdd: addMenu,
                        onRefresh: loadMenu,
                      ),
                    ),

                    // Bar ringkasan keranjang di bawah
                    if (cart.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('$totalCartItems Item dipilih', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(formatRupiah(totalCartPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4B2C20))),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4B2C20),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _bukaKeranjang,
                                icon: const Icon(Icons.shopping_cart_checkout),
                                label: const Text('Lihat Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}