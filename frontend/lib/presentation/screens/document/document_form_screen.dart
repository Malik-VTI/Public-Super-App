import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

import '../../../data/repositories/document_repository.dart';
import '../../../data/datasources/remote/api_client.dart';

class DocumentFormScreen extends StatefulWidget {
  const DocumentFormScreen({super.key});

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  late DocumentRepository _docRepo;
  String _selectedType = 'KTP';
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _docRepo = DocumentRepository(ApiClient());
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final nik = _nikController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || nik.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi semua data')));
      return;
    }

    setState(() => _loading = true);
    
    try {
      await _docRepo.createDocument(_selectedType, {
        'name': name,
        'nik': nik,
        'address': address,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil dikirim!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengajukan dokumen: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(title: const Text('Ajukan Dokumen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            const Text('Jenis Dokumen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: ['KTP', 'PASPOR'].map((type) {
                final selected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    selectedColor: AppTheme.accentLime,
                    onSelected: (_) => setState(() => _selectedType = type),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text('Nama Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Masukkan nama lengkap')),
            const SizedBox(height: 20),

            const Text('NIK', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _nikController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '16 digit NIK')),
            const SizedBox(height: 20),

            const Text('Alamat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _addressController, maxLines: 3, decoration: const InputDecoration(hintText: 'Alamat lengkap')),
            const SizedBox(height: 24),

            // Upload area
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.divider, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 36, color: AppTheme.textHint),
                    const SizedBox(height: 8),
                    Text('Upload Dokumen Pendukung', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text('JPG, PNG, PDF (maks 5MB)', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Kirim Pengajuan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
