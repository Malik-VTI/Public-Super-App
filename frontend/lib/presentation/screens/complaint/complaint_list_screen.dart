import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class ComplaintListScreen extends StatelessWidget {
  const ComplaintListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = [
      {'category': 'JALAN_RUSAK', 'address': 'Jl. Merdeka No. 45', 'status': 'SUBMITTED', 'date': '1 hari lalu'},
      {'category': 'LAMPU_MATI', 'address': 'Jl. Sudirman Km 3', 'status': 'IN_PROGRESS', 'date': '3 hari lalu'},
    ];

    final categoryIcons = {
      'JALAN_RUSAK': Icons.warning_amber_rounded,
      'LAMPU_MATI': Icons.lightbulb_outline,
      'SAMPAH': Icons.delete_outline,
      'BANJIR': Icons.water_damage_outlined,
    };

    final categoryLabels = {
      'JALAN_RUSAK': 'Jalan Rusak',
      'LAMPU_MATI': 'Lampu Mati',
      'SAMPAH': 'Sampah',
      'BANJIR': 'Banjir',
    };

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(title: const Text('Pengaduan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final c = complaints[index];
          final cat = c['category']!;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLime.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcons[cat] ?? Icons.report, size: 22, color: AppTheme.primaryBlack),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryLabels[cat] ?? cat, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(c['address']!, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(c['date']!, style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                    ],
                  ),
                ),
                StatusBadge(status: c['status']!),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/complaints/create'),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Laporkan'),
      ),
    );
  }
}
