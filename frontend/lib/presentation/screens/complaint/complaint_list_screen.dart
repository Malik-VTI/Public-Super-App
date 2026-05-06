import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

import '../../../data/repositories/complaint_repository.dart';
import '../../../data/datasources/remote/api_client.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  late ComplaintRepository _complaintRepo;
  List<dynamic> _complaints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _complaintRepo = ComplaintRepository(ApiClient());
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _loading = true);
    try {
      final data = await _complaintRepo.getComplaints();
      if (mounted) setState(() { _complaints = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text('Belum ada pengaduan'))
              : RefreshIndicator(
                  onRefresh: _loadComplaints,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _complaints.length,
                    itemBuilder: (context, index) {
                      final c = _complaints[index];
                      final cat = c['category'] ?? 'UNKNOWN';
                      final dateStr = c['created_at'].toString().split('T').first;
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
                                        child: Text(c['address'] ?? '-', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(dateStr, style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                                ],
                              ),
                            ),
                            StatusBadge(status: c['status'] ?? 'SUBMITTED'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/complaints/create');
          if (result == true) _loadComplaints();
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Laporkan'),
      ),
    );
  }
}
