import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/meja.dart';
import '../../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final MejaModel meja;
  final List<Map<String, dynamic>> cart;

  const CheckoutScreen({
    super.key,
    required this.meja,
    required this.cart,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final api = ApiService();
  final nameController = TextEditingController();
  bool loading = false;

  String rupiah(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  double get total {
    double hasil = 0;
    for (final item in widget.cart) {
      final harga = double.tryParse('${item['harga']}') ?? 0;
      final jumlah = int.tryParse('${item['jumlah']}') ?? 0;
      hasil += harga * jumlah;
    }
    return hasil;
  }

  Future<void> prosesCheckout() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama pemesan harus diisi!')),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final items = widget.cart.map((item) {
        return {
          'menu_id': item['menu_id'] ?? item['id'],
          'jumlah': item['jumlah'],
        };
      }).toList();

      await api.postPesanan({
        'meja_id': widget.meja.id,
        'nama_pemesan': nameController.text.trim(),
        'items': items,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibuat!')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal melakukan checkout: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Pesanan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.table_restaurant, size: 30),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nomor Meja', style: TextStyle(fontSize: 12)),
                      Text(
                        widget.meja.nomorMeja,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Pemesan',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.cart.map((item) {
            final jumlah = int.tryParse('${item['jumlah']}') ?? 0;
            final harga = double.tryParse('${item['harga']}') ?? 0;
            final subtotal = harga * jumlah;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${item['nama_menu'] ?? item['nama']} (x$jumlah)'),
              trailing: Text(rupiah(subtotal)),
            );
          }),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                rupiah(total),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: loading ? null : prosesCheckout,
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}