import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'kasir_dashboard.dart';
import 'manager_dashboard.dart';

class StaffDashboard extends StatelessWidget {
  final String role;
  final String token;

  const StaffDashboard({
    super.key,
    required this.role,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AdminDashboard(token: token);

      case 'kasir':
        return KasirDashboard(token: token);

      case 'manager':
      case 'pemilik':
        return ManagerDashboard(token: token);

      default:
        return Scaffold(
          appBar: AppBar(
            title: const Text('Staff Dashboard'),
          ),
          body: const Center(
            child: Text(
              'Role staff tidak dikenali.',
            ),
          ),
        );
    }
  }
}