import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_helpers.dart';

class AdminPelangganScreen extends StatefulWidget {
  final String token;

  const AdminPelangganScreen({super.key, required this.token});

  @override
  State<AdminPelangganScreen> createState() => _AdminPelangganScreenState();
}

class _AdminPelangganScreenState extends State<AdminPelangganScreen> {
  final ApiService api = ApiService();

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final r = await api.getPelanggan(widget.token);
      if (!mounted) return;
      setState(() {
        items = ambilList(r.data);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = pesanError(e);
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelanggan'),
        backgroundColor: adminColor,
        foregroundColor: Colors.white,
      ),
      body: _isi(),
    );
  }

  Widget _isi() {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: load, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada data pelanggan.\n\n'
            'Daftar ini terisi saat data pelanggan disimpan oleh aplikasi.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final p = items[i];
          final nama = (p['nama'] == null || '${p['nama']}'.isEmpty)
              ? 'Tanpa nama'
              : '${p['nama']}';
          final hp = (p['no_hp'] == null || '${p['no_hp']}'.isEmpty)
              ? '-'
              : '${p['no_hp']}';
          final meja =
              p['meja'] is Map ? '${p['meja']['nomor_meja']}' : '-';

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: adminColor.withOpacity(0.1),
                child: const Icon(Icons.person, color: adminColor),
              ),
              title: Text(
                nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('HP: $hp  •  Meja: $meja'),
            ),
          );
        },
      ),
    );
  }
}