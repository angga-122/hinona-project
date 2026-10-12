import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/meja.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final MejaModel meja;
  final List<Map<String, dynamic>> cart;

  const CartScreen({
    super.key,
    required this.meja,
    required this.cart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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

  void tambah(int index) {
    setState(() {
      final jumlah = int.tryParse('${widget.cart[index]['jumlah']}') ?? 0;
      widget.cart[index]['jumlah'] = jumlah + 1;
    });
  }

  void kurangi(int index) {
    setState(() {
      final jumlah = int.tryParse('${widget.cart[index]['jumlah']}') ?? 0;

      if (jumlah > 1) {
        widget.cart[index]['jumlah'] = jumlah - 1;
      } else {
        widget.cart.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
      ),
      body: widget.cart.isEmpty
          ? const Center(
              child: Text(
                'Keranjang masih kosong.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.table_restaurant,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meja',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];

                      final jumlah = int.tryParse('${item['jumlah']}') ?? 0;
                      final harga = double.tryParse('${item['harga']}') ?? 0;
                      final subtotal = harga * jumlah;

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item['nama_menu']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(rupiah(harga)),
                                    const SizedBox(height: 4),
                                    Text(
                                      rupiah(subtotal),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => kurangi(index),
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(
                                    '$jumlah',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => tambah(index),
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          offset: Offset(0, -3),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pesanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              rupiah(total),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: widget.cart.isEmpty
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CheckoutScreen(
                                          meja: widget.meja,
                                          cart: widget.cart,
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(
                              Icons.shopping_cart_checkout,
                            ),
                            label: const Text(
                              'Lanjut Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}