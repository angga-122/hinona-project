import 'package:flutter/material.dart';
import '../models/menu.dart';

class MenuCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback? onAdd;

  const MenuCard({
    super.key,
    required this.menu,
    this.onAdd,
  });

  String formatRupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.fastfood,
            color: Colors.orange,
            size: 26,
          ),
        ),
        title: Text(
          menu.namaMenu,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${formatRupiah(menu.harga)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 14,
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
          onPressed: onAdd,
        ),
        onTap: onAdd,
      ),
    );
  }
}