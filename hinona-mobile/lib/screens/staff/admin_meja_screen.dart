import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_service.dart';
import 'admin_helpers.dart';

class AdminMejaScreen extends StatefulWidget {
  final String token;

  const AdminMejaScreen({super.key, required this.token});

  @override
  State<AdminMejaScreen> createState() => _AdminMejaScreenState();
}

class _AdminMejaScreenState extends State<AdminMejaScreen> {
  final ApiService api = ApiService();

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> mejas = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  bool _aktif(Map<String, dynamic> m) => m['aktif'] == true || m['aktif'] == 1;

  /// Nomor urut berikutnya, dilihat dari kode QR berpola HINONA-MEJA-<angka>
  int _nomorBerikut() {
    int maks = 0;
    final pola = RegExp(r'^HINONA-MEJA-(\d+)$');
    for (final m in mejas) {
      final cocok = pola.firstMatch('${m['kode_qr']}');
      if (cocok != null) {
        final n = int.parse(cocok.group(1)!);
        if (n > maks) maks = n;
      }
    }
    return maks + 1;
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final r = await api.getMeja(widget.token);
      if (!mounted) return;
      setState(() {
        mejas = ambilList(r.data);
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

  Future<void> ubahAktif(Map<String, dynamic> m, bool nilai) async {
    try {
      await api.updateMeja(widget.token, (m['id'] as num).toInt(), {
        'nomor_meja': m['nomor_meja'],
        'kode_qr': m['kode_qr'],
        'aktif': nilai,
      });
      if (!mounted) return;
      setState(() => m['aktif'] = nilai);
    } catch (e) {
      if (!mounted) return;
      tampilSnack(context, pesanError(e), merah: true);
    }
  }

  Future<void> hapus(Map<String, dynamic> m) async {
    final yakin = await konfirmasiHapus(
      context,
      'Hapus meja?',
      '"${m['nomor_meja']}" akan dihapus. Riwayat pesanan meja ini tetap tersimpan.',
    );
    if (!yakin) return;

    try {
      await api.deleteMeja(widget.token, (m['id'] as num).toInt());
      if (!mounted) return;
      tampilSnack(context, 'Meja berhasil dihapus');
      await load();
    } catch (e) {
      if (!mounted) return;
      tampilSnack(context, pesanError(e), merah: true);
    }
  }

    void lihatQr(Map<String, dynamic> m) {
    final kode = '${m['kode_qr']}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${m['nomor_meja']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: QrImageView(
                    data: kode,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                kode,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Scan QR ini dari fitur scan pelanggan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
  Future<void> bukaForm([Map<String, dynamic>? m]) async {
    final n = _nomorBerikut();

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MejaFormDialog(
        api: api,
        token: widget.token,
        meja: m,
        saranNomor: 'Meja $n',
        saranKode: 'HINONA-MEJA-$n',
      ),
    );

    if (saved == true) {
      if (!mounted) return;
      tampilSnack(context,
          m != null ? 'Meja berhasil diperbarui' : 'Meja berhasil ditambahkan');
      await load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meja'),
        backgroundColor: adminColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: adminColor,
        foregroundColor: Colors.white,
        onPressed: loading ? null : () => bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Meja'),
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

    if (mejas.isEmpty) {
      return const Center(child: Text('Belum ada meja.'));
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: mejas.length,
        itemBuilder: (context, i) {
          final m = mejas[i];
          final aktif = _aktif(m);

          return Card(
            child: ListTile(
              onTap: () => bukaForm(m),
              leading: CircleAvatar(
                backgroundColor: adminColor.withOpacity(0.1),
                child: const Icon(Icons.table_restaurant, color: adminColor),
              ),
              title: Text(
                '${m['nomor_meja']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: aktif ? Colors.black87 : Colors.grey,
                ),
              ),
              subtitle: Text('${m['kode_qr']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Lihat QR',
                    icon: const Icon(Icons.qr_code_2, color: adminColor),
                    onPressed: () => lihatQr(m),
                  ),
                  Switch(
                    value: aktif,
                    onChanged: (v) => ubahAktif(m, v),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => hapus(m),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MejaFormDialog extends StatefulWidget {
  final ApiService api;
  final String token;
  final Map<String, dynamic>? meja;
  final String saranNomor;
  final String saranKode;

  const _MejaFormDialog({
    required this.api,
    required this.token,
    required this.saranNomor,
    required this.saranKode,
    this.meja,
  });

  @override
  State<_MejaFormDialog> createState() => _MejaFormDialogState();
}

class _MejaFormDialogState extends State<_MejaFormDialog> {
  late final TextEditingController nomorC;
  late final TextEditingController kodeC;
  bool aktif = true;
  bool saving = false;
  String? formError;

  bool get edit => widget.meja != null;

  @override
  void initState() {
    super.initState();
    nomorC = TextEditingController(
      text: edit ? '${widget.meja!['nomor_meja']}' : widget.saranNomor,
    );
    kodeC = TextEditingController(
      text: edit ? '${widget.meja!['kode_qr']}' : widget.saranKode,
    );
    if (edit) {
      aktif = widget.meja!['aktif'] == true || widget.meja!['aktif'] == 1;
    }
  }

  @override
  void dispose() {
    nomorC.dispose();
    kodeC.dispose();
    super.dispose();
  }

  Future<void> simpan() async {
    final nomor = nomorC.text.trim();
    final kode = kodeC.text.trim();

    if (nomor.isEmpty || kode.isEmpty) {
      setState(() => formError = 'Nomor meja dan kode QR wajib diisi.');
      return;
    }

    setState(() {
      saving = true;
      formError = null;
    });

    final data = {'nomor_meja': nomor, 'kode_qr': kode, 'aktif': aktif};

    try {
      if (edit) {
        await widget.api.updateMeja(
          widget.token,
          (widget.meja!['id'] as num).toInt(),
          data,
        );
      } else {
        await widget.api.createMeja(widget.token, data);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
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
    return AlertDialog(
      title: Text(edit ? 'Ubah Meja' : 'Tambah Meja'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomorC,
              decoration: const InputDecoration(
                labelText: 'Nomor meja',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: kodeC,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Kode QR (isi QR)',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Meja aktif'),
              value: aktif,
              onChanged: (v) => setState(() => aktif = v),
            ),
            if (formError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(formError!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}