import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/datasources/remote/api_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscure = true;
  bool _loading = false;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient());
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    final nik = _nikController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || nik.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi semua data')));
      return;
    }

    setState(() => _loading = true);
    
    try {
      await _authRepo.resetPassword(email, nik, password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah. Silakan login.')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal reset password: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verifikasi Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Masukkan Email dan NIK yang terdaftar untuk mengatur ulang password Anda.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 32),

            const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'contoh@govapp.id'),
            ),
            const SizedBox(height: 20),

            const Text('NIK', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nikController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '16 digit NIK'),
            ),
            const SizedBox(height: 40),

            const Text('Password Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Minimal 6 karakter',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _resetPassword,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
