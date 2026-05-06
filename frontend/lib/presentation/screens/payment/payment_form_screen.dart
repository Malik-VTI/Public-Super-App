import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  String _selectedMethod = 'Bank Transfer';
  bool _loading = false;

  final methods = ['Bank Transfer', 'E-Wallet', 'Virtual Account'];

  void _process() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacementNamed('/payments/status');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Tagihan', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  _row('Jenis', 'Pajak PBB'),
                  _row('Nomor', 'PBB-2023-001'),
                  const Divider(height: 24),
                  _row('Total', 'Rp 1.500.000', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Metode Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            ...methods.map((m) => GestureDetector(
              onTap: () => setState(() => _selectedMethod = m),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _selectedMethod == m ? AppTheme.primaryBlack : AppTheme.divider, width: _selectedMethod == m ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      m == 'Bank Transfer' ? Icons.account_balance : m == 'E-Wallet' ? Icons.wallet : Icons.credit_card,
                      size: 20,
                      color: AppTheme.primaryBlack,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(m, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    if (_selectedMethod == m)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.accentLime,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.check, size: 14, color: AppTheme.primaryBlack),
                      ),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _process,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
