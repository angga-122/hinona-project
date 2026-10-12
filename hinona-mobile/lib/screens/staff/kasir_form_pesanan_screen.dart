import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/format.dart';
import 'admin_helpers.dart';

/// Dipakai untuk MEMBUAT pesanan baru (transaksi == null)
/// atau MENGUBAH pesanan yang sudah ada (transaksi diisi).
class KasirFormPesananScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? transaksi;

  const KasirFormPesananScreen({
    super.key,
    required this.token,
    this.transaksi,
  });

  @override
  State<KasirFormPesananScreen> createState() => _KasirFormPesananScreenState();
}

class _KasirFormPesananScreenState extends State<KasirFormPesananScreen> {
  final ApiService api = ApiService();

  bool loading = true;
  bool saving = false;
  String? error;

  List<Map<String, dynamic>> menus = [];
  List<Map<String, dynamic>> mejas = [];

  final Map<int, int> qty = {}; // menu_id -> jumlah
  int mejaId = 0; // 0 = tanpa meja (bawa pulang)
  String cari = '';

  bool get edit => widget.transaksi != null;

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
      final m = await api.getMenu();
      final j = await api.getMejaKasir(widget.token);

      final daftarMenu = ambilList(m.data);
      final daftarMeja = ambilList(j.data);

      if (edit) {
        final t = widget.transaksi!;

        mejaId = t['meja_id'] == null ? 0 : angkaInt(t['meja_id']);

        final detail = t['detail'];
        if (detail is List) {
          for (final d in detail) {
            final idMenu = angkaInt(d['menu_id']);
            qty[idMenu] = angkaInt(d['jumlah']);

            // Menu yang sudah dinonaktifkan tetap ditampilkan agar tidak hilang
            final ada = daftarMenu.any((x) => angkaInt(x['id']) == idMenu);
            if (!ada) {
              daftarMenu.add({
                'id': idMenu,
                'nama_menu': d['menu'] is Map ? d['menu']['nama_menu'] : 'Menu #$idMenu',
                'harga': d['harga'],
              });
            }
          }
        }

        // Meja yang sudah dinonaktifkan tetap bisa dipilih
        if (mejaId != 0 && !daftarMeja.any((x) => angkaInt(x['id']) == mejaId)) {
          if (t['meja'] is Map) {
            daftarMeja.add(Map<String, dynamic>.from(t['meja']));
          } else {
            mejaId = 0;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        menus = daftarMenu;
        mejas = daftarMeja;
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

  void _ubahQty(int id, int delta) {
    setState(() {
      final n = (qty[id] ?? 0) + delta;
      if (n <= 0) {
        qty.remove(id);
      } else {
        qty[id] = n;
      }
    });
  }

  double get total {
    double hasil = 0;
    for (final m in menus) {
      final n = qty[angkaInt(m['id'])] ?? 0;
      hasil += angka(m['harga']) * n;
    }
    return hasil;
  }

  int get jumlahItem => qty.values.fold(0, (a, b) => a + b);

  Future<void> simpan() async {
    if (qty.isEmpty) {
      tampilSnack(context, 'Pilih minimal satu menu.', merah: true);
      return;
    }

    setState(() => saving = true);

    final data = {
      'meja_id': mejaId == 0 ? null : mejaId,
      'items': qty.entries
          .map((e) => {'menu_id': e.key, 'jumlah': e.value})
          .toList(),
    };

    try {
      if (edit) {
        await api.ubahTransaksi(
          widget.token,
          angkaInt(widget.transaksi!['id']),
          data,
        );
      } else {
        await api.buatTransaksi(widget.token, data);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      tampilSnack(context, pesanError(e), merah: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(edit ? 'Ubah Pesanan' : 'Pesanan Baru'),
        backgroundColor: adminColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: loading || error != null ? null : _bawah(),
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

    final q = cari.trim().toLowerCase();
    final daftar = menus
        .where((m) => q.isEmpty || '${m['nama_menu']}'.toLowerCase().contains(q))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: DropdownButtonFormField<int>(
            value: mejaId,
            decoration: const InputDecoration(
              labelText: 'Meja',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<int>(
                value: 0,
                child: Text('Tanpa meja (bawa pulang)'),
              ),
              ...mejas.map(
                (m) => DropdownMenuItem<int>(
                  value: angkaInt(m['id']),
                  child: Text('${m['nomor_meja']}'),
                ),
              ),
            ],
            onChanged: (v) => setState(() => mejaId = v ?? 0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: TextField(
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
              ? const Center(child: Text('Menu tidak ditemukan.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: daftar.length,
                  itemBuilder: (context, i) {
                    final m = daftar[i];
                    final id = angkaInt(m['id']);
                    final n = qty[id] ?? 0;

                    return Card(
                      color: n > 0 ? adminColor.withOpacity(0.06) : null,
                      child: ListTile(
                        title: Text(
                          '${m['nama_menu']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(rupiah(angka(m['harga']))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (n > 0)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _ubahQty(id, -1),
                              ),
                            if (n > 0)
                              Text(
                                '$n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: adminColor),
                              onPressed: () => _ubahQty(id, 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _bawah() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$jumlahItem item',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    rupiah(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: adminColor,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: adminColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
              onPressed: saving || qty.isEmpty ? null : simpan,
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(edit ? 'Simpan Perubahan' : 'Buat Pesanan'),
            ),
          ],
        ),
      ),
    );
  }
}