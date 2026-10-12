import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/format.dart';
import '../home/home_screen.dart';
import 'admin_helpers.dart';

enum _Periode { hariIni, tujuhHari, tigaPuluhHari, bulanIni, semua, kustom }

/// Dashboard Pemilik / Manager:
/// laporan penjualan, pendapatan, menu terlaris, statistik,
/// dan transaksi berdasarkan periode.
class ManagerDashboard extends StatefulWidget {
  final String token;

  const ManagerDashboard({super.key, required this.token});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final ApiService api = ApiService();
  final DateFormat _fApi = DateFormat('yyyy-MM-dd');
  final DateFormat _fTampil = DateFormat('dd MMM yyyy');

  bool loading = true;
  String? error;

  _Periode periode = _Periode.tujuhHari;
  DateTimeRange? rentang;

  Map<String, dynamic> stat = {};
  List<Map<String, dynamic>> menuTerlaris = [];
  List<Map<String, dynamic>> transaksi = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  // ---------------- Data ----------------

  Map<String, dynamic> _params() {
    final now = DateTime.now();
    final hari = DateTime(now.year, now.month, now.day);
    DateTime? mulai;
    DateTime? selesai;

    switch (periode) {
      case _Periode.hariIni:
        mulai = hari;
        selesai = hari;
        break;
      case _Periode.tujuhHari:
        mulai = hari.subtract(const Duration(days: 6));
        selesai = hari;
        break;
      case _Periode.tigaPuluhHari:
        mulai = hari.subtract(const Duration(days: 29));
        selesai = hari;
        break;
      case _Periode.bulanIni:
        mulai = DateTime(now.year, now.month, 1);
        selesai = hari;
        break;
      case _Periode.semua:
        break;
      case _Periode.kustom:
        if (rentang != null) {
          mulai = rentang!.start;
          selesai = rentang!.end;
        }
        break;
    }

    return {
      if (mulai != null) 'tanggal_mulai': _fApi.format(mulai),
      if (selesai != null) 'tanggal_selesai': _fApi.format(selesai),
    };
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final p = _params();
      final hasil = await Future.wait([
        api.getStatistik(widget.token, params: p),
        api.getMenuTerlaris(widget.token, params: p),
        api.getLaporanTransaksi(widget.token, params: p),
      ]);

      if (!mounted) return;
      setState(() {
        final d = hasil[0].data;
        stat = Map<String, dynamic>.from(
            (d is Map ? d['data'] : null) ?? <String, dynamic>{});
        menuTerlaris = ambilList(hasil[1].data);
        transaksi = ambilList(hasil[2].data);
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

  List<Map<String, dynamic>> _list(String kunci) => ambilList(stat[kunci] ?? []);

  Future<void> _pilihPeriode(_Periode p) async {
    if (p == _Periode.kustom) {
      final now = DateTime.now();
      final hasil = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024),
        lastDate: DateTime(now.year, now.month, now.day),
        initialDateRange: rentang,
        helpText: 'Pilih rentang tanggal',
      );
      if (hasil == null) return;
      rentang = hasil;
    }
    setState(() => periode = p);
    load();
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

  String get _labelPeriode {
    switch (periode) {
      case _Periode.hariIni:
        return 'Hari ini';
      case _Periode.tujuhHari:
        return '7 hari terakhir';
      case _Periode.tigaPuluhHari:
        return '30 hari terakhir';
      case _Periode.bulanIni:
        return 'Bulan ini';
      case _Periode.semua:
        return 'Semua waktu';
      case _Periode.kustom:
        if (rentang == null) return 'Pilih tanggal';
        return '${_fTampil.format(rentang!.start)} - ${_fTampil.format(rentang!.end)}';
    }
  }

  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Manager'),
          backgroundColor: adminColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'Muat ulang',
              icon: const Icon(Icons.refresh),
              onPressed: load,
            ),
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amberAccent,
            tabs: [
              Tab(text: 'Ringkasan'),
              Tab(text: 'Menu Terlaris'),
              Tab(text: 'Transaksi'),
            ],
          ),
        ),
        body: Column(
          children: [
            _barisPeriode(),
            Expanded(child: _isi()),
          ],
        ),
      ),
    );
  }

  Widget _barisPeriode() {
    final pilihan = <_Periode, String>{
      _Periode.hariIni: 'Hari ini',
      _Periode.tujuhHari: '7 hari',
      _Periode.tigaPuluhHari: '30 hari',
      _Periode.bulanIni: 'Bulan ini',
      _Periode.semua: 'Semua',
      _Periode.kustom: periode == _Periode.kustom ? _labelPeriode : 'Pilih tanggal',
    };

    return Container(
      color: Colors.white,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: pilihan.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: e.key == _Periode.kustom
                    ? const Icon(Icons.date_range, size: 18)
                    : null,
                label: Text(e.value),
                selected: periode == e.key,
                selectedColor: adminColor.withOpacity(0.15),
                onSelected: (_) => _pilihPeriode(e.key),
              ),
            );
          }).toList(),
        ),
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
              ElevatedButton(onPressed: load, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      children: [
        _tabRingkasan(),
        _tabMenuTerlaris(),
        _tabTransaksi(),
      ],
    );
  }

  // ---------------- TAB 1: RINGKASAN ----------------

  Widget _tabRingkasan() {
    final harian = _list('per_hari');
    final metode = _list('per_metode');
    final kategori = _list('per_kategori');

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        children: [
          // Kartu utama: total pendapatan
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: adminColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pendapatan  •  $_labelPeriode',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    rupiah(angka(stat['total_pendapatan'])),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _kartuStat(Icons.receipt_long, 'Transaksi',
                  '${angkaInt(stat['jumlah_transaksi'])}', Colors.blue),
              _kartuStat(Icons.trending_up, 'Rata-rata / transaksi',
                  rupiah(angka(stat['rata_rata_transaksi'])), Colors.green),
            ],
          ),
          Row(
            children: [
              _kartuStat(Icons.local_cafe, 'Item terjual',
                  '${angkaInt(stat['item_terjual'])}', Colors.brown),
              _kartuStat(Icons.cancel_outlined, 'Dibatalkan',
                  '${angkaInt(stat['transaksi_dibatalkan'])}', Colors.red),
            ],
          ),
          _judul('Pendapatan Harian'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: harian.isEmpty
                  ? _kosongKecil('Belum ada penjualan pada periode ini.')
                  : _daftarHarian(harian),
            ),
          ),
          _judul('Metode Pembayaran'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: metode.isEmpty
                  ? _kosongKecil('Belum ada data.')
                  : Column(
                      children: metode.map((m) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.payments_outlined, color: adminColor),
                          title: Text(
                            '${m['metode']}'.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${angkaInt(m['jumlah'])} transaksi'),
                          trailing: Text(
                            rupiah(angka(m['total'])),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          _judul('Penjualan per Kategori'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: kategori.isEmpty
                  ? _kosongKecil('Belum ada data.')
                  : Column(
                      children: kategori.map((k) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.category_outlined, color: adminColor),
                          title: Text(
                            '${k['kategori']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${angkaInt(k['total_terjual'])} item terjual'),
                          trailing: Text(
                            rupiah(angka(k['total_pendapatan'])),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _kartuStat(IconData ikon, String judul, String nilai, Color warna) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(ikon, size: 18, color: warna),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  nilai,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _judul(String teks) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        teks,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _kosongKecil(String teks) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(teks, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  /// Daftar pendapatan per hari (terbaru di atas).
  Widget _daftarHarian(List<Map<String, dynamic>> data) {
    final urut = data.reversed.toList();

    return Column(
      children: urut.map((e) {
        final tgl = DateTime.tryParse('${e['tanggal']}');
        final label = tgl == null ? '-' : DateFormat('EEE, dd MMM yyyy').format(tgl);

        return ListTile(
          dense: true,
          leading: const Icon(Icons.calendar_today_outlined, color: adminColor, size: 20),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${angkaInt(e['jumlah'])} transaksi'),
          trailing: Text(
            rupiah(angka(e['pendapatan'])),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- TAB 2: MENU TERLARIS ----------------

  Widget _tabMenuTerlaris() {
    if (menuTerlaris.isEmpty) {
      return _kosong('Belum ada penjualan menu pada periode ini.');
    }

    double maks = 0;
    for (final m in menuTerlaris) {
      final v = angka(m['total_terjual']);
      if (v > maks) maks = v;
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: menuTerlaris.length,
        itemBuilder: (context, i) {
          final m = menuTerlaris[i];
          final terjual = angka(m['total_terjual']);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: i < 3 ? Colors.amber.shade600 : adminColor.withOpacity(0.1),
                    foregroundColor: i < 3 ? Colors.white : adminColor,
                    child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${m['nama_menu'] ?? '-'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${m['nama_kategori'] ?? ''}  •  ${rupiah(angka(m['total_pendapatan']))}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: maks > 0 ? terjual / maks : 0,
                            minHeight: 6,
                            backgroundColor: adminColor.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation(adminColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${terjual.round()}x',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- TAB 3: TRANSAKSI ----------------

  Widget _tabTransaksi() {
    final total = transaksi.fold<double>(0, (s, t) => s + angka(t['total']));

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: adminColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${transaksi.length} transaksi  •  Total ${rupiah(total)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: transaksi.isEmpty
              ? _kosong('Belum ada transaksi pada periode ini.')
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: transaksi.length,
                    itemBuilder: (context, i) => _kartuTransaksi(transaksi[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _kartuTransaksi(Map<String, dynamic> t) {
    final status = '${t['status']}';
    final metodeTeks = t['metode_pembayaran'] == null
        ? ''
        : '  •  ${t['metode_pembayaran'].toString().toUpperCase()}';

    return Card(
      child: ListTile(
        onTap: () => _detail(t),
        leading: CircleAvatar(
          backgroundColor: warnaStatus(status).withOpacity(0.15),
          child: Icon(Icons.receipt_long, color: warnaStatus(status)),
        ),
        title: Text(
          '${namaMeja(t)}  •  #${t['id']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${ringkasItem(t)}\n${tanggalJam(t['created_at'])}$metodeTeks',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Text(
          rupiah(angka(t['total'])),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _detail(Map<String, dynamic> t) {
    final items = ambilList(t['detail'] ?? []);
    final kasir = t['user'] is Map ? '${t['user']['name']}' : '-';
    final metode = t['metode_pembayaran'] != null ? '${t['metode_pembayaran']}'.toUpperCase() : '-';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Transaksi #${t['id']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    chipStatus('${t['status']}'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${namaMeja(t)}  •  ${tanggalJam(t['created_at'])}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 24),
                ...items.map((e) {
                  final nama = e['menu'] is Map ? '${e['menu']['nama_menu']}' : 'Menu';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(child: Text('${angkaInt(e['jumlah'])}x  $nama')),
                        Text(rupiah(angka(e['subtotal']))),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                _baris('Total', rupiah(angka(t['total'])), tebal: true),
                _baris('Metode', metode),
                _baris('Uang dibayar', rupiah(angka(t['uang_bayar']))),
                _baris('Kembalian', rupiah(angka(t['kembalian']))),
                _baris('Kasir', kasir),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _baris(String label, String nilai, {bool tebal = false}) {
    final gaya = TextStyle(fontWeight: tebal ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: gaya),
          Text(nilai, style: gaya),
        ],
      ),
    );
  }

  Widget _kosong(String teks) {
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 140),
          Center(child: Text(teks, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}