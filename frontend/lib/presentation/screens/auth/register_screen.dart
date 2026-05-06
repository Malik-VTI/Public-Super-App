import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/datasources/remote/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient());
  }

  void _register() async {
    final nik = _nikController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (nik.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi semua data')));
      return;
    }
    if (nik.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('NIK harus 16 digit')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password minimal 6 karakter')));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi password tidak cocok')));
      return;
    }

    setState(() => _loading = true);
    
    try {
      await _authRepo.register(nik, name, email, phone, password);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buat akun GovApp Anda', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
            const SizedBox(height: 32),

            _buildField('NIK', _nikController, keyboardType: TextInputType.number),
            _buildField('Nama Lengkap', _nameController),
            _buildField('Email', _emailController, keyboardType: TextInputType.emailAddress),
            _buildField('Nomor Telepon', _phoneController, keyboardType: TextInputType.phone),
            
            const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
            const SizedBox(height: 20),

            const Text('Konfirmasi Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: 'Masukkan ulang password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: 'Masukkan $label'),
          ),
        ],
      ),
    );
  }
}
