import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

import '../../../data/repositories/document_repository.dart';
import '../../../data/datasources/remote/api_client.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  late DocumentRepository _docRepo;
  List<dynamic> _docs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _docRepo = DocumentRepository(ApiClient());
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    setState(() => _loading = true);
    try {
      final docs = await _docRepo.getDocuments();
      if (mounted) {
        setState(() {
          // DocumentModel needs to be converted or used directly
          _docs = docs.map((d) => {'type': d.type, 'status': d.status, 'date': d.createdAt}).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text('Dokumen'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentLime,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.filter_list, color: AppTheme.primaryBlack, size: 20),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _docs.isEmpty
              ? const Center(child: Text('Belum ada dokumen'))
              : RefreshIndicator(
                  onRefresh: _loadDocs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _docs.length,
                    itemBuilder: (context, index) {
                      final doc = _docs[index];
                      // Format date simply
                      final dateStr = doc['date'].toString().split('T').first;
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
                              child: const Icon(Icons.description_outlined, color: AppTheme.primaryBlack),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pengajuan ${doc['type']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(dateStr, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            StatusBadge(status: doc['status']!),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/documents/create');
          if (result == true) _loadDocs();
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajukan'),
      ),
    );
  }
}
