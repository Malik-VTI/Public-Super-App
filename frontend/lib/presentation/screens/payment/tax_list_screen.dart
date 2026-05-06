import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

import '../../../data/repositories/payment_repository.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../../data/models/payment_model.dart';

class TaxListScreen extends StatefulWidget {
  const TaxListScreen({super.key});

  @override
  State<TaxListScreen> createState() => _TaxListScreenState();
}

class _TaxListScreenState extends State<TaxListScreen> {
  late PaymentRepository _paymentRepo;
  List<PaymentModel> _bills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _paymentRepo = PaymentRepository(ApiClient());
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _loading = true);
    try {
      final bills = await _paymentRepo.getBills();
      if (mounted) setState(() { _bills = bills; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _totalAmount {
    return _bills.fold(0, (sum, item) => sum + item.amount);
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(title: const Text('Pembayaran')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadBills,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Summary card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlack,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Tagihan', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency(_totalAmount),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLime,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${_bills.length} tagihan aktif', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Tagihan Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _bills.length,
              itemBuilder: (context, index) {
                final bill = _bills[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentLime.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.receipt_outlined, size: 20, color: AppTheme.primaryBlack),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pajak ${bill.billType}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(bill.billNumber, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          StatusBadge(status: bill.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatCurrency(bill.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.of(context).pushNamed('/payments/process', arguments: bill);
                              if (result == true) _loadBills();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Bayar', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}
