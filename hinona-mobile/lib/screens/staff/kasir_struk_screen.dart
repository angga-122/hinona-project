import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../utils/format.dart';
import 'admin_helpers.dart';

String nomorInvoice(dynamic id) =>
    'INV-${angkaInt(id).toString().padLeft(5, '0')}';

String _namaKasir(Map<String, dynamic> t) =>
    t['user'] is Map ? '${t['user']['name']}' : '-';

List<Map<String, dynamic>> _itemStruk(Map<String, dynamic> t) {
  final d = t['detail'];
  if (d is! List) return [];
  return d.map((e) => Map<String, dynamic>.from(e)).toList();
}

String _metode(Map<String, dynamic> t) =>
    '${t['metode_pembayaran'] ?? '-'}'.toUpperCase();

String _namaItem(Map<String, dynamic> d) =>
    d['menu'] is Map ? '${d['menu']['nama_menu']}' : 'Menu';

/// Teks struk polos (untuk disalin / dibagikan)
String teksStruk(Map<String, dynamic> t) {
  final b = StringBuffer();
  b.writeln('HINONA COFFEE & ROASTERY');
  b.writeln('--------------------------------');
  b.writeln('No    : ${nomorInvoice(t['id'])}');
  b.writeln('Waktu : ${tanggalJam(t['created_at'])}');
  b.writeln('Meja  : ${namaMeja(t)}');
  b.writeln('Kasir : ${_namaKasir(t)}');
  b.writeln('--------------------------------');
  for (final d in _itemStruk(t)) {
    b.writeln(_namaItem(d));
    b.writeln('  ${d['jumlah']} x ${rupiah(angka(d['harga']))} = ${rupiah(angka(d['subtotal']))}');
  }
  b.writeln('--------------------------------');
  b.writeln('TOTAL    : ${rupiah(angka(t['total']))}');
  b.writeln('Metode   : ${_metode(t)}');
  b.writeln('Bayar    : ${rupiah(angka(t['uang_bayar']))}');
  b.writeln('Kembalian: ${rupiah(angka(t['kembalian']))}');
  b.writeln('--------------------------------');
  b.writeln('Terima kasih sudah berkunjung!');
  return b.toString();
}

/// Membuat PDF struk (ukuran kertas thermal 80mm) lalu membuka dialog cetak/simpan PDF
Future<void> cetakStruk(Map<String, dynamic> t) async {
  final doc = pw.Document();
  final items = _itemStruk(t);

  final tinggi = (115 + items.length * 11) * PdfPageFormat.mm;
  final format = PdfPageFormat(80 * PdfPageFormat.mm, tinggi);

  pw.Widget baris(String kiri, String kanan, {bool tebal = false}) {
    final style = pw.TextStyle(
      fontSize: 9,
      fontWeight: tebal ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(kiri, style: style),
        pw.Text(kanan, style: style),
      ],
    );
  }

  doc.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'HINONA COFFEE & ROASTERY',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Coffee, Roastery & Good Moments',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
            pw.Divider(thickness: 0.5, height: 12),
            baris('No', nomorInvoice(t['id'])),
            baris('Waktu', tanggalJam(t['created_at'])),
            baris('Meja', namaMeja(t)),
            baris('Kasir', _namaKasir(t)),
            pw.Divider(thickness: 0.5, height: 12),
            ...items.map(
              (d) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_namaItem(d), style: const pw.TextStyle(fontSize: 9)),
                    baris(
                      '  ${d['jumlah']} x ${rupiah(angka(d['harga']))}',
                      rupiah(angka(d['subtotal'])),
                    ),
                  ],
                ),
              ),
            ),
            pw.Divider(thickness: 0.5, height: 12),
            baris('TOTAL', rupiah(angka(t['total'])), tebal: true),
            baris('Metode', _metode(t)),
            baris('Bayar', rupiah(angka(t['uang_bayar']))),
            baris('Kembalian', rupiah(angka(t['kembalian']))),
            pw.Divider(thickness: 0.5, height: 12),
            pw.Center(
              child: pw.Text(
                'Terima kasih sudah berkunjung!',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  await Printing.layoutPdf(
    name: 'Struk-${nomorInvoice(t['id'])}',
    onLayout: (_) async => doc.save(),
  );
}

// =====================================================
// LAYAR STRUK
// =====================================================

class KasirStrukScreen extends StatelessWidget {
  final Map<String, dynamic> transaksi;

  const KasirStrukScreen({super.key, required this.transaksi});

  Widget _baris(String k, String v, {bool tebal = false}) {
    final style = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: style),
          Flexible(child: Text(v, style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = transaksi;
    final items = _itemStruk(t);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('Struk'),
        backgroundColor: adminColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: teksStruk(t)));
                    if (context.mounted) {
                      tampilSnack(context, 'Struk disalin ke clipboard');
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Salin'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: adminColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    try {
                      await cetakStruk(t);
                    } catch (e) {
                      if (context.mounted) {
                        tampilSnack(context, 'Gagal mencetak: $e', merah: true);
                      }
                    }
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak / Simpan PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'HINONA COFFEE & ROASTERY',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const Center(
                  child: Text(
                    'Coffee, Roastery & Good Moments',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                const Divider(height: 24),
                _baris('No', nomorInvoice(t['id'])),
                _baris('Waktu', tanggalJam(t['created_at'])),
                _baris('Meja', namaMeja(t)),
                _baris('Kasir', _namaKasir(t)),
                const Divider(height: 24),
                ...items.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _namaItem(d),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _baris(
                          '  ${d['jumlah']} x ${rupiah(angka(d['harga']))}',
                          rupiah(angka(d['subtotal'])),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                _baris('TOTAL', rupiah(angka(t['total'])), tebal: true),
                _baris('Metode', _metode(t)),
                _baris('Bayar', rupiah(angka(t['uang_bayar']))),
                _baris('Kembalian', rupiah(angka(t['kembalian']))),
                const Divider(height: 24),
                const Center(
                  child: Text(
                    'Terima kasih sudah berkunjung!',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}