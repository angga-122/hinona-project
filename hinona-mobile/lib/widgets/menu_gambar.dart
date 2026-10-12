import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Mengubah nilai kolom `gambar` menjadi alamat URL lengkap.
/// - Kalau sudah berupa http(s)://... dipakai apa adanya.
/// - Kalau berupa path (mis. "menu/abc.jpg") diarahkan ke storage Laravel.
String? urlGambarMenu(String? gambar) {
  if (gambar == null || gambar.trim().isEmpty) return null;
  final g = gambar.trim();
  if (g.startsWith('http://') || g.startsWith('https://')) return g;

  final base = AppConfig.baseUrl.replaceFirst(RegExp(r'api/?$'), '');
  return '${base}storage/${g.replaceFirst(RegExp(r'^/+'), '')}';
}

class MenuGambar extends StatelessWidget {
  final String? gambar;
  final double ukuran;
  final double radius;
  final IconData ikon;

  const MenuGambar({
    super.key,
    required this.gambar,
    this.ukuran = 80,
    this.radius = 12,
    this.ikon = Icons.local_cafe,
  });

  Widget _pengganti() {
    return Container(
      width: ukuran,
      height: ukuran,
      color: const Color(0xFFF3E9E3),
      child: Icon(ikon, size: ukuran * 0.4, color: const Color(0xFF8D6E63)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = urlGambarMenu(gambar);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: ukuran,
        height: ukuran,
        child: url == null
            ? _pengganti()
            : Image.network(
                url,
                width: ukuran,
                height: ukuran,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _pengganti(),
                errorBuilder: (context, error, stack) => _pengganti(),
              ),
      ),
    );
  }
}