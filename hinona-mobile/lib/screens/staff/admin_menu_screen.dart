import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../widgets/menu_gambar.dart';
import '../../widgets/menu_katalog.dart' show ikonKategori;

const Color _colorPrimary = Color(0xFF4B2C20);

/// Mengubah error Dio menjadi pesan yang mudah dibaca.
String _pesanError(Object e) {
  if (e is DioException) {
    final d = e.response?.data;
    if (d is Map) {
      if (d['errors'] is Map && (d['errors'] as Map).isNotEmpty) {
        final first = (d['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) return '${first.first}';
      }
      if (d['message'] != null) return '${d['message']}';
    }
    if (e.response != null) return 'Server error (${e.response!.statusCode})';
    return 'Tidak bisa terhubung ke server.';
  }
  return '$e';
}

String _namaKategori(Map<String, dynamic> m) =>
    m['kategori'] is Map ? '${m['kategori']['nama_kategori']}' : 'Lainnya';

// =====================================================
// LAYAR DAFTAR MENU
// =====================================================

class AdminMenuScreen extends StatefulWidget {
  final String token;

  const AdminMenuScreen({super.key, required this.token});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final ApiService api = ApiService();

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> menus = [];
  List<Map<String, dynamic>> kategori = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  String rupiah(num v) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(v);

  List<Map<String, dynamic>> _toList(dynamic body) {
    final list = body is Map ? (body['data'] ?? []) : body;
    return (list as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _snack(String teks, {bool merah = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(teks),
        backgroundColor: merah ? Colors.red : Colors.green.shade700,
      ),
    );
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final hasilMenu = await api.getMenuAdmin(widget.token);
      final hasilKategori = await api.getKategori(widget.token);

      if (!mounted) return;
      setState(() {
        menus = _toList(hasilMenu.data);
        kategori = _toList(hasilKategori.data);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = _pesanError(e);
        loading = false;
      });
    }
  }

  Future<void> ubahAktif(Map<String, dynamic> m, bool nilai) async {
    try {
      await api.updateMenu(widget.token, m['id'] as int, {'aktif': nilai});
      if (!mounted) return;
      setState(() => m['aktif'] = nilai);
    } catch (e) {
      _snack(_pesanError(e), merah: true);
    }
  }

  Future<void> hapus(Map<String, dynamic> m) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus menu?'),
        content: Text('Menu "${m['nama_menu']}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    try {
      await api.deleteMenu(widget.token, m['id'] as int);
      _snack('Menu berhasil dihapus');
      await load();
    } catch (e) {
      _snack(_pesanError(e), merah: true);
    }
  }

  Future<void> bukaForm([Map<String, dynamic>? m]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MenuFormDialog(
        api: api,
        token: widget.token,
        kategori: kategori,
        menu: m,
      ),
    );

    if (saved == true) {
      _snack(m != null ? 'Menu berhasil diperbarui' : 'Menu berhasil ditambahkan');
      await load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Menu'),
        backgroundColor: _colorPrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _colorPrimary,
        foregroundColor: Colors.white,
        onPressed: loading ? null : () => bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Menu'),
      ),
      body: _isi(),
    );
  }

  Widget _isi() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    if (menus.isEmpty) {
      return const Center(child: Text('Belum ada menu. Tekan "Tambah Menu".'));
    }

    // Urutkan per kategori, lalu nama
    final urut = [...menus]..sort((a, b) {
        final k = ((a['kategori_id'] as num?) ?? 0)
            .compareTo((b['kategori_id'] as num?) ?? 0);
        if (k != 0) return k;
        return '${a['nama_menu']}'
            .toLowerCase()
            .compareTo('${b['nama_menu']}'.toLowerCase());
      });

    final baris = <Widget>[];
    String? terakhir;
    for (final m in urut) {
      final nk = _namaKategori(m);
      if (nk != terakhir) {
        final jumlah = urut.where((x) => _namaKategori(x) == nk).length;
        baris.add(_header(nk, jumlah));
        terakhir = nk;
      }
      baris.add(_kartu(m));
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
        children: baris,
      ),
    );
  }

  Widget _header(String nama, int jumlah) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Icon(ikonKategori(nama), color: _colorPrimary, size: 22),
          const SizedBox(width: 8),
          Text(
            nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _colorPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text('$jumlah menu', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: _colorPrimary.withOpacity(0.2))),
        ],
      ),
    );
  }

  Widget _kartu(Map<String, dynamic> m) {
    final aktif = m['aktif'] == true || m['aktif'] == 1;
    final harga = double.tryParse('${m['harga']}') ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => bukaForm(m),
        contentPadding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
        leading: MenuGambar(
          gambar: m['gambar']?.toString(),
          ukuran: 56,
          radius: 10,
          ikon: ikonKategori(_namaKategori(m)),
        ),
        title: Text(
          '${m['nama_menu']}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: aktif ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Text(rupiah(harga) + (aktif ? '' : '  •  Nonaktif')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
  }
}

// =====================================================
// FORM TAMBAH / UBAH MENU (widget sendiri, mengurus controller-nya sendiri)
// =====================================================

class _MenuFormDialog extends StatefulWidget {
  final ApiService api;
  final String token;
  final List<Map<String, dynamic>> kategori;
  final Map<String, dynamic>? menu;

  const _MenuFormDialog({
    required this.api,
    required this.token,
    required this.kategori,
    this.menu,
  });

  @override
  State<_MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<_MenuFormDialog> {
  late final TextEditingController namaC;
  late final TextEditingController hargaC;
  late final TextEditingController deskC;

  int? kategoriId;
  bool aktif = true;
  bool saving = false;
  String? formError;

  XFile? foto; // foto baru yang dipilih (belum diunggah)
  int? idTersimpan; // id menu baru yang sudah tersimpan (supaya tidak dobel saat ulang simpan)

  bool get edit => widget.menu != null;

  @override
  void initState() {
    super.initState();
    final cur = widget.menu ?? <String, dynamic>{};

    namaC = TextEditingController(text: edit ? '${cur['nama_menu']}' : '');
    hargaC = TextEditingController(
      text: edit
          ? (double.tryParse('${cur['harga']}') ?? 0).round().toString()
          : '',
    );
    deskC = TextEditingController(text: edit ? '${cur['deskripsi'] ?? ''}' : '');

    if (edit) {
      kategoriId = (cur['kategori_id'] as num?)?.toInt();
      aktif = cur['aktif'] == true || cur['aktif'] == 1;
    } else if (widget.kategori.isNotEmpty) {
      kategoriId = (widget.kategori.first['id'] as num).toInt();
    }

    // Pastikan nilai dropdown ada di daftar kategori
    final ada = widget.kategori.any((k) => (k['id'] as num).toInt() == kategoriId);
    if (!ada) kategoriId = null;
  }

  @override
  void dispose() {
    namaC.dispose();
    hargaC.dispose();
    deskC.dispose();
    super.dispose();
  }

  Future<void> pilihFoto() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (x != null) setState(() => foto = x);
    } catch (e) {
      setState(() => formError = 'Tidak bisa membuka galeri: $e');
    }
  }

  Future<void> simpan() async {
    final nama = namaC.text.trim();
    final harga = double.tryParse(hargaC.text.trim());

    if (nama.isEmpty || harga == null || kategoriId == null) {
      setState(() => formError =
          'Nama, harga, dan kategori wajib diisi dengan benar.');
      return;
    }

    setState(() {
      saving = true;
      formError = null;
    });

    final data = {
      'kategori_id': kategoriId,
      'nama_menu': nama,
      'harga': harga,
      'deskripsi': deskC.text.trim().isEmpty ? null : deskC.text.trim(),
      'aktif': aktif,
    };

    try {
      int? id = idTersimpan ??
          (widget.menu != null ? (widget.menu!['id'] as num).toInt() : null);

      if (id != null) {
        await widget.api.updateMenu(widget.token, id, data);
      } else {
        final r = await widget.api.createMenu(widget.token, data);
        id = ((r.data['data'] as Map)['id'] as num).toInt();
        idTersimpan = id;
      }

      if (foto != null) {
        await widget.api.uploadGambarMenu(widget.token, id, foto!.path);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        saving = false;
        formError = idTersimpan != null
            ? 'Menu tersimpan, tapi foto gagal diunggah: ${_pesanError(e)}'
            : _pesanError(e);
      });
    }
  }

  Widget _bagianFoto() {
    final Widget gambar = foto != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(foto!.path),
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          )
        : MenuGambar(
            gambar: widget.menu?['gambar']?.toString(),
            ukuran: 120,
            radius: 12,
          );

    return Column(
      children: [
        gambar,
        TextButton.icon(
          onPressed: saving ? null : pilihFoto,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(foto == null ? 'Pilih foto' : 'Ganti foto'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(edit ? 'Ubah Menu' : 'Tambah Menu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bagianFoto(),
            const SizedBox(height: 8),
            TextField(
              controller: namaC,
              decoration: const InputDecoration(
                labelText: 'Nama menu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hargaC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga (angka saja)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: kategoriId,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: widget.kategori
                  .map((k) => DropdownMenuItem<int>(
                        value: (k['id'] as num).toInt(),
                        child: Text('${k['nama_kategori']}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => kategoriId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deskC,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tampil di menu pelanggan'),
              value: aktif,
              onChanged: (v) => setState(() => aktif = v),
            ),
            if (formError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  formError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, idTersimpan != null),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _colorPrimary,
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