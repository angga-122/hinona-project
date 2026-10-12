import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/format.dart';
import '../home/home_screen.dart';
import 'admin_helpers.dart';
import 'kasir_detail_screen.dart';
import 'kasir_form_pesanan_screen.dart';

class KasirDashboard extends StatefulWidget {
  final String token;

  const KasirDashboard({super.key, required this.token});

  @override
  State<KasirDashboard> createState() => _KasirDashboardState();
}

class _KasirDashboardState extends State<KasirDashboard> {
  final ApiService api = ApiService();

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> transaksi = [];
  List<Map<String, dynamic>> menus = [];

  Timer? _timer;
  bool hanyaHariIni = true;
  String cari = '';
  final TextEditingController cariC = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
    // Cek pesanan baru dari pelanggan setiap 15 detik
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => load(diam: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    cariC.dispose();
    super.dispose();
  }

  Future<void> load({bool diam = false}) async {
    if (!diam) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final t = await api.getTransaksi(widget.token);
      final m = await api.getMenu();

      if (!mounted) return;
      setState(() {
        transaksi = ambilList(t.data);
        menus = ambilList(m.data);
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (diam) return; // refresh otomatis: abaikan error sementara
      setState(() {
        error = pesanError(e);
        loading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await api.logout(widget.token);
    } catch (_) {
      // abaikan; tetap keluar
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _buka(Map<String, dynamic> t) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KasirDetailScreen(token: widget.token, transaksi: t),
      ),
    );
    if (mounted) load(diam: true);
  }

  Future<void> _buatBaru() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => KasirFormPesananScreen(token: widget.token),
      ),
    );
    if (ok == true && mounted) {
      tampilSnack(context, 'Pesanan berhasil dibuat');
      load(diam: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jumlahMasuk = transaksi
        .where((t) => t['status'] == 'menunggu' || t['status'] == 'diproses')
        .length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kasir'),
          backgroundColor: adminColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'Muat ulang',
              icon: const Icon(Icons.refresh),
              onPressed: () => load(),
            ),
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amberAccent,
            tabs: [
              Tab(text: 'Masuk ($jumlahMasuk)'),
              const Tab(text: 'Riwayat'),
              const Tab(text: 'Menu'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: adminColor,
          foregroundColor: Colors.white,
          onPressed: _buatBaru,
          icon: const Icon(Icons.add),
          label: const Text('Pesanan Baru'),
        ),
        body: _isi(),
      ),
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
              ElevatedButton(onPressed: () => load(), child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      children: [
        _tabMasuk(),
        _tabRiwayat(),
        _tabMenu(),
      ],
    );
  }

  // ---------------- TAB 1: PESANAN MASUK ----------------

  Widget _tabMasuk() {
    final daftar = transaksi
        .where((t) => t['status'] == 'menunggu' || t['status'] == 'diproses')
        .toList()
      ..sort((a, b) => angkaInt(a['id']).compareTo(angkaInt(b['id'])));

    if (daftar.isEmpty) return _kosong('Belum ada pesanan masuk.');

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: daftar.length,
        itemBuilder: (context, i) => _kartu(daftar[i]),
      ),
    );
  }

  // ---------------- TAB 2: RIWAYAT ----------------

  Widget _tabRiwayat() {
    var daftar = transaksi
        .where((t) => t['status'] == 'selesai' || t['status'] == 'dibatalkan')
        .toList();

    if (hanyaHariIni) {
      daftar = daftar.where((t) => hariIni(t['created_at'])).toList();
    }

    final totalSelesai = daftar
        .where((t) => t['status'] == 'selesai')
        .fold<double>(0, (s, t) => s + angka(t['total']));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Hari ini'),
                selected: hanyaHariIni,
                onSelected: (_) => setState(() => hanyaHariIni = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Semua'),
                selected: !hanyaHariIni,
                onSelected: (_) => setState(() => hanyaHariIni = false),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: adminColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${daftar.length} transaksi  •  Total ${rupiah(totalSelesai)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: daftar.isEmpty
              ? _kosong('Belum ada riwayat transaksi.')
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    itemCount: daftar.length,
                    itemBuilder: (context, i) => _kartu(daftar[i]),
                  ),
                ),
        ),
      ],
    );
  }

  // ---------------- TAB 3: MENU (hanya lihat) ----------------

  Widget _tabMenu() {
    final q = cari.trim().toLowerCase();
    final daftar = menus
        .where((m) => q.isEmpty || '${m['nama_menu']}'.toLowerCase().contains(q))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: cariC,
            onChanged: (v) => setState(() => cari = v),
            decoration: const InputDecoration(
              hintText: 'Cari menu...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: daftar.isEmpty
              ? _kosong('Menu tidak ditemukan.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                  itemCount: daftar.length,
                  itemBuilder: (context, i) {
                    final m = daftar[i];
                    final kategori = m['kategori'] is Map
                        ? '${m['kategori']['nama_kategori']}'
                        : '-';
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: adminColor.withOpacity(0.1),
                          child: const Icon(Icons.local_cafe, color: adminColor),
                        ),
                        title: Text(
                          '${m['nama_menu']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(kategori),
                        trailing: Text(
                          rupiah(angka(m['harga'])),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------------- Komponen ----------------

  Widget _kosong(String teks) {
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        children: [
          const SizedBox(height: 180),
          Center(child: Text(teks, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _kartu(Map<String, dynamic> t) {
    final status = '${t['status']}';

    return Card(
      child: ListTile(
        onTap: () => _buka(t),
        leading: CircleAvatar(
          backgroundColor: warnaStatus(status).withOpacity(0.15),
          child: Icon(Icons.receipt_long, color: warnaStatus(status)),
        ),
        title: Text(
          '${namaMeja(t)}  •  #${t['id']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${ringkasItem(t)}\n${tanggalJam(t['created_at'])}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              rupiah(angka(t['total'])),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            chipStatus(status),
          ],
        ),
      ),
    );
  }
}