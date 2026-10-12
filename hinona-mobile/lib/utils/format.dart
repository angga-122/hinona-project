import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String rupiah(num v) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(v);

double angka(dynamic v) => double.tryParse('$v') ?? 0;

int angkaInt(dynamic v) => (double.tryParse('$v') ?? 0).round();

DateTime? _tgl(dynamic iso) => DateTime.tryParse('$iso')?.toLocal();

String tanggalJam(dynamic iso) {
  final d = _tgl(iso);
  if (d == null) return '-';
  return DateFormat('dd/MM/yyyy HH:mm').format(d);
}

bool hariIni(dynamic iso) {
  final d = _tgl(iso);
  if (d == null) return false;
  final n = DateTime.now();
  return d.year == n.year && d.month == n.month && d.day == n.day;
}

Color warnaStatus(String s) {
  switch (s) {
    case 'menunggu':
      return Colors.orange;
    case 'diproses':
      return Colors.blue;
    case 'selesai':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

String labelStatus(String s) {
  switch (s) {
    case 'menunggu':
      return 'Menunggu';
    case 'diproses':
      return 'Diproses';
    case 'selesai':
      return 'Selesai';
    case 'dibatalkan':
      return 'Dibatalkan';
    default:
      return s;
  }
}

Widget chipStatus(String s) {
  final c = warnaStatus(s);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      labelStatus(s),
      style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}

String namaMeja(Map<String, dynamic> t) =>
    t['meja'] is Map ? '${t['meja']['nomor_meja']}' : 'Bawa pulang';

String ringkasItem(Map<String, dynamic> t) {
  final d = t['detail'];
  if (d is! List || d.isEmpty) return '-';
  return d.map((e) {
    final nama = e['menu'] is Map ? '${e['menu']['nama_menu']}' : 'Menu';
    return '${e['jumlah']}x $nama';
  }).join(', ');
}