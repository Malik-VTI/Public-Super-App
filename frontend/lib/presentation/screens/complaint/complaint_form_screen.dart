import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

import '../../../data/repositories/complaint_repository.dart';
import '../../../data/datasources/remote/api_client.dart';

class ComplaintFormScreen extends StatefulWidget {
  const ComplaintFormScreen({super.key});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  late ComplaintRepository _complaintRepo;
  String _selectedCategory = 'JALAN_RUSAK';
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = false;

  final categories = [
    {'value': 'JALAN_RUSAK', 'label': 'Jalan Rusak', 'icon': Icons.warning_amber_rounded},
    {'value': 'LAMPU_MATI', 'label': 'Lampu Mati', 'icon': Icons.lightbulb_outline},
    {'value': 'SAMPAH', 'label': 'Sampah', 'icon': Icons.delete_outline},
    {'value': 'BANJIR', 'label': 'Banjir', 'icon': Icons.water_damage_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _complaintRepo = ComplaintRepository(ApiClient());
  }

  void _submit() async {
    final description = _descriptionController.text.trim();
    final address = _addressController.text.trim();

    if (description.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi alamat dan deskripsi')));
      return;
    }

    setState(() => _loading = true);
    try {
      await _complaintRepo.createComplaint(_selectedCategory, description, address, 0.0, 0.0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaduan berhasil dikirim!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim pengaduan: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(title: const Text('Buat Pengaduan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, size: 40, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 8),
                        Text('Tap untuk pilih lokasi', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLime,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.location_on, size: 14, color: AppTheme.primaryBlack),
                          SizedBox(width: 4),
                          Text('Pilih Lokasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category
            const Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final selected = _selectedCategory == cat['value'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['value'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.accentLime : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppTheme.accentLime : AppTheme.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData, size: 16, color: AppTheme.primaryBlack),
                        const SizedBox(width: 6),
                        Text(cat['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Text('Alamat Lokasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _addressController, decoration: const InputDecoration(hintText: 'Masukkan alamat lokasi')),
            const SizedBox(height: 20),

            const Text('Deskripsi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _descriptionController, maxLines: 4, decoration: const InputDecoration(hintText: 'Jelaskan kondisi fasilitas...')),
            const SizedBox(height: 20),

            // Photo upload
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.divider),
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 32, color: AppTheme.textHint),
                    const SizedBox(height: 6),
                    Text('Upload Foto Kondisi', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Kirim Pengaduan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
