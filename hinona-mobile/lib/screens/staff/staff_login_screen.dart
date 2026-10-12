import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'staff_dashboard.dart'; // Sesuaikan path jika berbeda

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
        final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password wajib diisi!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final response = await api.login(email, password);

      if (mounted) setState(() => _isLoading = false);

      final responseData = response.data;
      
      // Ambil token dari berbagai kemungkinan struktur JSON backend
      final token = responseData['token'] ?? 
                    responseData['access_token'] ?? 
                    responseData['data']?['token'];

      // Ambil role dari response Laravel (jika ada), default ke 'kasir'
      final userRole = responseData['user']?['role'] ?? 
                       responseData['data']?['user']?['role'] ?? 
                       'kasir';

      if (token != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Kasir Berhasil!'), backgroundColor: Colors.green),
          );

          // Navigasi ke StaffDashboard dengan mengirimkan token dan role
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StaffDashboard(
                token: token,
                role: userRole,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login gagal: Token tidak ditemukan'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal! Periksa email/password atau koneksi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF4B2C20);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: colorPrimary,
        title: const Text('Login Staff & Kasir', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront_rounded, size: 80, color: colorPrimary),
                const SizedBox(height: 16),
                const Text(
                  'HINONA STAFF',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorPrimary),
                ),
                const SizedBox(height: 8),
                const Text('Masukkan akun staff/kasir untuk mengelola transaksi', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),

                // Field Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Kasir',
                    prefixIcon: Icon(Icons.email, color: colorPrimary),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Field Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: colorPrimary),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('MASUK KASIR', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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