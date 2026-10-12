import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_helpers.dart';

class AdminKategoriScreen extends StatefulWidget {
  final String token;

  const AdminKategoriScreen({super.key, required this.token});

  @override
  State<AdminKategoriScreen> createState() => _AdminKategoriScreenState();
}

class _AdminKategoriScreenState extends State<AdminKategoriScreen> {
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
      final r = await api.getKategori(widget.token);
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

  Future<void> bukaForm([Map<String, dynamic>? k]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _KategoriFormDialog(
        api: api,
        token: widget.token,
        kategori: k,
      ),
    );

    if (saved == true) {
      if (!mounted) return;
      tampilSnack(context,
          k != null ? 'Kategori berhasil diperbarui' : 'Kategori berhasil ditambahkan');
      await load();
    }
  }

  Future<void> hapus(Map<String, dynamic> k) async {
    final yakin = await konfirmasiHapus(
      context,
      'Hapus kategori?',
      'Kategori "${k['nama_kategori']}" akan dihapus.',
    );
    if (!yakin) return;

    try {
      await api.deleteKategori(widget.token, (k['id'] as num).toInt());
      if (!mounted) return;
      tampilSnack(context, 'Kategori berhasil dihapus');
      await load();
    } catch (e) {
      if (!mounted) return;
      tampilSnack(context, pesanError(e), merah: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        backgroundColor: adminColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: adminColor,
        foregroundColor: Colors.white,
        onPressed: loading ? null : () => bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
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
      return const Center(child: Text('Belum ada kategori.'));
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final k = items[i];
          return Card(
            child: ListTile(
              onTap: () => bukaForm(k),
              leading: CircleAvatar(
                backgroundColor: adminColor.withOpacity(0.1),
                child: const Icon(Icons.category, color: adminColor),
              ),
              title: Text(
                '${k['nama_kategori']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => hapus(k),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _KategoriFormDialog extends StatefulWidget {
  final ApiService api;
  final String token;
  final Map<String, dynamic>? kategori;

  const _KategoriFormDialog({
    required this.api,
    required this.token,
    this.kategori,
  });

  @override
  State<_KategoriFormDialog> createState() => _KategoriFormDialogState();
}

class _KategoriFormDialogState extends State<_KategoriFormDialog> {
  late final TextEditingController namaC;
  bool saving = false;
  String? formError;

  bool get edit => widget.kategori != null;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(
      text: edit ? '${widget.kategori!['nama_kategori']}' : '',
    );
  }

  @override
  void dispose() {
    namaC.dispose();
    super.dispose();
  }

  Future<void> simpan() async {
    final nama = namaC.text.trim();

    if (nama.isEmpty) {
      setState(() => formError = 'Nama kategori wajib diisi.');
      return;
    }

    setState(() {
      saving = true;
      formError = null;
    });

    try {
      final data = {'nama_kategori': nama};

      if (edit) {
        await widget.api.updateKategori(
          widget.token,
          (widget.kategori!['id'] as num).toInt(),
          data,
        );
      } else {
        await widget.api.createKategori(widget.token, data);
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
      title: Text(edit ? 'Ubah Kategori' : 'Tambah Kategori'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: namaC,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nama kategori',
              border: OutlineInputBorder(),
            ),
          ),
          if (formError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(formError!, style: const TextStyle(color: Colors.red)),
            ),
        ],
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