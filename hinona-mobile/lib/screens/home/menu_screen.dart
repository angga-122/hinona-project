import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../models/menu.dart';
import '../../widgets/menu_katalog.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService api = ApiService();

  bool loading = true;
  String? error;

  List<MenuModel> menus = [];

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    try {
      final response = await api.getMenu();
      final data = response.data;

      List list;
      if (data is Map && data['data'] is List) {
        list = data['data'];
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      if (!mounted) return;
      setState(() {
        menus = list
            .map((item) => MenuModel.fromJson(Map<String, dynamic>.from(item)))
            .where((m) => m.aktif)
            .toList();
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Hinona'),
        backgroundColor: const Color(0xFF4B2C20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Gagal mengambil menu:\n$error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : menus.isEmpty
                  ? const Center(child: Text('Belum ada menu.'))
                  : MenuKatalog(menus: menus, onRefresh: loadMenu),
    );
  }
}