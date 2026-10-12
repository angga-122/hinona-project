import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/format.dart';
import 'admin_helpers.dart';
import 'kasir_form_pesanan_screen.dart';
import 'kasir_struk_screen.dart';

class KasirDetailScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> transaksi;

  const KasirDetailScreen({
    super.key,
    required this.token,
    required this.transaksi,
  });

  @override
  State<KasirDetailScreen> createState() => _KasirDetailScreenState();
}

class _KasirDetailScreenState extends State<KasirDetailScreen> {
  final ApiService api = ApiService();

  late Map<String, dynamic> t;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    t = Map<String, dynamic>.from(widget.transaksi);
  }

  String get status => '${t['status']}';
  int get _id => angkaInt(t['id']);
  List<Map<String, dynamic>> get items => ambilList(t['detail'] ?? []);

  // ---------------- Aksi ----------------

  Future<void> _muatUlang() async {
    try {
      final r = await api.getTransaksiDetail(widget.token, _id);
      if (!mounted) return;
      setState(() => t = Map<String, dynamic>.from(r.data['data']));
    } catch (e) {
      if (!mounted) return;
      tampilSnack(context, pesanError(e), merah: true);
    }
  }

  Future<void> terima() async {
    setState(() => busy = true);
    try {
      final r = await api.terimaTransaksi(widget.token, _id);
      if (!mounted) return;
      setState(() {
        t = Map<String, dynamic>.from(r.data['data']);
        busy = false;
      });
      tampilSnack(context, 'Pesanan diterima');
    } catch (e) {
      if (!mounted) return;
      setState(() => busy = false);
      tampilSnack(context, pesanError(e), merah: true);
    }
  }

  Future<void> ubah() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => KasirFormPesananScreen(
          token: widget.token,
          transaksi: t,
        ),
      ),
    );

    if (ok == true) {
      await _muatUlang();
      if (!mounted) return;
      tampilSnack(context, 'Pesanan berhasil diperbarui');
    }
  }

  Future<void> hapus() async {
    final yakin = await konfirmasiHapus(
      context,
      'Hapus pesanan?',
      'Pesanan #$_id (${namaMeja(t)}) akan dihapus permanen.',
    );
    if (!yakin) return;

    setState(() => busy = true);
    try {
      await api.hapusTransaksi(widget.token, _id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => busy = false);
      tampilSnack(context, pesanError(e), merah: true);
    }
  }

  Future<void> bayar() async {
    final hasil = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BayarDialog(
        api: api,
        token: widget.token,
        transaksi: t,
      ),
    );

    if (hasil != null && mounted) {
      setState(() => t = hasil);
      tampilSnack(context, 'Pembayaran berhasil');
      _lihatStruk();
    }
  }

  void _lihatStruk() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KasirStrukScreen(transaksi: t)),
    );
  }

  // ---------------- Tampilan ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan #$_id'),
        backgroundColor: adminColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: _aksi(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        namaMeja(t),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      chipStatus(status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dibuat: ${tanggalJam(t['created_at'])}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ...items.map(_barisItem),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        rupiah(angka(t['total'])),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: adminColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (status == 'selesai') ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _info('Metode', '${t['metode_pembayaran'] ?? '-'}'.toUpperCase()),
                    _info('Uang diterima', rupiah(angka(t['uang_bayar']))),
                    _info('Kembalian', rupiah(angka(t['kembalian']))),
                    _info(
                      'Kasir',
                      t['user'] is Map ? '${t['user']['name']}' : '-',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _barisItem(Map<String, dynamic> d) {
    final nama = d['menu'] is Map ? '${d['menu']['nama_menu']}' : 'Menu';

    return ListTile(
      dense: true,
      title: Text(nama, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${d['jumlah']} x ${rupiah(angka(d['harga']))}'),
      trailing: Text(
        rupiah(angka(d['subtotal'])),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _info(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Colors.grey)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _utama(IconData ikon, String teks, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: adminColor,
          foregroundColor: Colors.white,
        ),
        onPressed: busy ? null : onTap,
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(ikon),
        label: Text(teks),
      ),
    );
  }

  Widget? _aksi() {
    if (status == 'dibatalkan') return null;

    final tombol = <Widget>[];

    if (status == 'selesai') {
      tombol.add(_utama(Icons.print, 'Cetak Struk', _lihatStruk));
    } else {
      if (status == 'menunggu') {
        tombol.add(_utama(Icons.check, 'Terima Pesanan', terima));
      } else {
        tombol.add(_utama(Icons.payments, 'Proses Pembayaran', bayar));
      }

      tombol.add(const SizedBox(height: 8));
      tombol.add(
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : ubah,
                icon: const Icon(Icons.edit),
                label: const Text('Ubah'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: busy ? null : hapus,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus'),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: tombol),
      ),
    );
  }
}

// =====================================================
// DIALOG PEMBAYARAN (hanya tunai)
// =====================================================

class _BayarDialog extends StatefulWidget {
  final ApiService api;
  final String token;
  final Map<String, dynamic> transaksi;

  const _BayarDialog({
    required this.api,
    required this.token,
    required this.transaksi,
  });

  @override
  State<_BayarDialog> createState() => _BayarDialogState();
}

class _BayarDialogState extends State<_BayarDialog> {
  final TextEditingController uangC = TextEditingController();

  bool saving = false;
  String? formError;

  double get total => angka(widget.transaksi['total']);
  double get uang => double.tryParse(uangC.text.trim().replaceAll('.', '')) ?? 0;

  @override
  void initState() {
    super.initState();
    uangC.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    uangC.dispose();
    super.dispose();
  }

  void _isiUang(double nilai) {
    uangC.text = nilai.round().toString();
  }

  Future<void> simpan() async {
    if (uang < total) {
      setState(() => formError = 'Uang yang diterima kurang dari total.');
      return;
    }

    setState(() {
      saving = true;
      formError = null;
    });

    try {
      final r = await widget.api.prosesBayar(
        widget.token,
        angkaInt(widget.transaksi['id']),
        uang,
        metode: 'tunai',
      );

      if (!mounted) return;
      Navigator.pop(context, Map<String, dynamic>.from(r.data['data']));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        saving = false;
        formError = pesanError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kembalian = uang - total;

    return AlertDialog(
      title: const Text('Pembayaran Tunai'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total tagihan', style: TextStyle(color: Colors.grey)),
            Text(
              rupiah(total),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: adminColor,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: uangC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Uang diterima',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Uang pas'),
                  onPressed: () => _isiUang(total),
                ),
                ActionChip(
                  label: const Text('50.000'),
                  onPressed: () => _isiUang(50000),
                ),
                ActionChip(
                  label: const Text('100.000'),
                  onPressed: () => _isiUang(100000),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              uang <= 0
                  ? 'Kembalian: -'
                  : (kembalian >= 0
                      ? 'Kembalian: ${rupiah(kembalian)}'
                      : 'Kurang: ${rupiah(-kembalian)}'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kembalian >= 0 && uang > 0 ? Colors.green : Colors.red,
              ),
            ),
            if (formError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(formError!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: adminColor,
            foregroundColor: Colors.white,
          ),
          onPressed: saving ? null : simpan,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Bayar'),
        ),
      ],
    );
  }
}