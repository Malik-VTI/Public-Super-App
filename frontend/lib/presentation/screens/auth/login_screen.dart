import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/datasources/remote/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient());
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi email dan password')),
      );
      return;
    }
    setState(() => _loading = true);
    
    try {
      await _authRepo.login(_emailController.text, _passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal, periksa kredensial Anda')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlack,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_balance, color: AppTheme.accentLime, size: 28),
              ),
              const SizedBox(height: 24),
              const Text('Selamat Datang', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Masuk ke akun GovApp Anda', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
              const SizedBox(height: 40),

              // Email
              const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'contoh@govapp.id'),
              ),
              const SizedBox(height: 20),

              // Password
              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Masuk'),
                ),
              ),
              const SizedBox(height: 16),

              // Biometric button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Simulate biometric login
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  },
                  icon: const Icon(Icons.fingerprint, size: 20),
                  label: const Text('Login dengan Biometrik'),
                ),
              ),
              const SizedBox(height: 24),

              // Links
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                  child: const Text('Lupa Password?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun?', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/register'),
                    child: const Text('Daftar', style: TextStyle(color: AppTheme.primaryBlack, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Demo credentials hint
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.accentLime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Demo Credentials', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Email: warga1@govapp.id', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    Text('Password: password123', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
