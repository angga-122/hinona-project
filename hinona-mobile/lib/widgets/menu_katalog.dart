import 'package:flutter/material.dart';
import '../models/menu.dart';
import 'menu_gambar.dart';

const Color _coklat = Color(0xFF4B2C20);

IconData ikonKategori(String nama) {
  final n = nama.toLowerCase();
  if (n.contains('non')) return Icons.local_drink;
  if (n.contains('coffee') || n.contains('kopi')) return Icons.coffee;
  if (n.contains('tea') || n.contains('teh')) return Icons.emoji_food_beverage;
  if (n.contains('food') || n.contains('makan')) return Icons.restaurant;
  if (n.contains('snack')) return Icons.bakery_dining;
  return Icons.restaurant_menu;
}

String _rupiah(num v) =>
    'Rp ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

class MenuKatalog extends StatefulWidget {
  final List<MenuModel> menus;

  /// Kalau diisi, tiap menu punya tombol tambah (+). Kalau null, hanya tampilan.
  final void Function(MenuModel menu)? onAdd;

  /// Kalau diisi, daftar bisa ditarik ke bawah untuk muat ulang.
  final Future<void> Function()? onRefresh;

  const MenuKatalog({
    super.key,
    required this.menus,
    this.onAdd,
    this.onRefresh,
  });

  @override
  State<MenuKatalog> createState() => _MenuKatalogState();
}

class _MenuKatalogState extends State<MenuKatalog> {
  final TextEditingController cariC = TextEditingController();
  String kategoriDipilih = 'Semua';

  @override
  void dispose() {
    cariC.dispose();
    super.dispose();
  }

  /// Daftar nama kategori, urut sesuai id kategori (Coffee dulu, dst).
  List<String> get _daftarKategori {
    final urut = [...widget.menus]
      ..sort((a, b) => (a.kategoriId ?? 9999).compareTo(b.kategoriId ?? 9999));
    final hasil = <String>[];
    for (final m in urut) {
      if (!hasil.contains(m.kategoriNama)) hasil.add(m.kategoriNama);
    }
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    final q = cariC.text.trim().toLowerCase();
    final kategoriList = _daftarKategori;
    final aktifKat = kategoriList.contains(kategoriDipilih) ? kategoriDipilih : 'Semua';

    final tampil = widget.menus.where((m) {
      final cocokNama = q.isEmpty || m.namaMenu.toLowerCase().contains(q);
      final cocokKat = aktifKat == 'Semua' || m.kategoriNama == aktifKat;
      return cocokNama && cocokKat;
    }).toList()
      ..sort((a, b) => a.namaMenu.toLowerCase().compareTo(b.namaMenu.toLowerCase()));

    final isi = <Widget>[];
    for (final kat in kategoriList) {
      final itemKat = tampil.where((m) => m.kategoriNama == kat).toList();
      if (itemKat.isEmpty) continue;
      isi.add(_judulKategori(kat, itemKat.length));
      isi.addAll(itemKat.map(_kartu));
    }

    Widget daftar;
    if (isi.isEmpty) {
      daftar = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text('Menu tidak ditemukan', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    } else {
      daftar = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: isi,
      );
      if (widget.onRefresh != null) {
        daftar = RefreshIndicator(onRefresh: widget.onRefresh!, child: daftar);
      }
    }

    return Column(
      children: [
        // Kolom cari
        Container(
          color: _coklat,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: TextField(
            controller: cariC,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari menu favorit kamu...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search, color: _coklat),
              suffixIcon: q.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        cariC.clear();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Chip kategori
        Container(
          color: Colors.white,
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: ['Semua', ...kategoriList].map((k) {
                final dipilih = aktifKat == k;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: k == 'Semua'
                        ? null
                        : Icon(
                            ikonKategori(k),
                            size: 18,
                            color: dipilih ? Colors.white : _coklat,
                          ),
                    label: Text(k),
                    selected: dipilih,
                    showCheckmark: false,
                    selectedColor: _coklat,
                    labelStyle: TextStyle(
                      color: dipilih ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => kategoriDipilih = k),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(child: daftar),
      ],
    );
  }

  Widget _judulKategori(String nama, int jumlah) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Row(
        children: [
          Icon(ikonKategori(nama), color: _coklat, size: 22),
          const SizedBox(width: 8),
          Text(
            nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _coklat,
            ),
          ),
          const SizedBox(width: 8),
          Text('$jumlah menu', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: _coklat.withOpacity(0.2))),
        ],
      ),
    );
  }

  Widget _kartu(MenuModel m) {
    final bisaTambah = widget.onAdd != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: bisaTambah ? () => widget.onAdd!(m) : null,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              MenuGambar(
                gambar: m.gambar,
                ukuran: 88,
                radius: 12,
                ikon: ikonKategori(m.kategoriNama),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.namaMenu,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (m.deskripsi != null && m.deskripsi!.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                m.deskripsi!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _rupiah(m.harga),
                        style: const TextStyle(
                          color: _coklat,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (bisaTambah)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(color: _coklat, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => widget.onAdd!(m),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}