import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

import '../../../data/models/payment_model.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/datasources/remote/api_client.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  late PaymentRepository _paymentRepo;
  String _selectedMethod = 'BANK_TRANSFER';
  String _selectedProvider = 'BCA';
  bool _loading = false;

  final methods = [
    {'id': 'BANK_TRANSFER', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'id': 'VIRTUAL_ACCOUNT', 'name': 'Virtual Account', 'icon': Icons.credit_card},
    {'id': 'EWALLET', 'name': 'E-Wallet', 'icon': Icons.account_balance_wallet},
    {'id': 'QRIS', 'name': 'QRIS', 'icon': Icons.qr_code},
  ];

  final banks = ['BCA', 'BNI', 'MANDIRI', 'BRI'];
  final ewallets = ['GOPAY', 'OVO', 'DANA', 'LINKAJA'];

  @override
  void initState() {
    super.initState();
    _paymentRepo = PaymentRepository(ApiClient());
  }

  void _process(PaymentModel bill) async {
    setState(() => _loading = true);
    
    try {
      String bankCode = '';
      String ewalletType = '';
      
      if (_selectedMethod == 'BANK_TRANSFER' || _selectedMethod == 'VIRTUAL_ACCOUNT') {
        bankCode = _selectedProvider;
      } else if (_selectedMethod == 'EWALLET') {
        ewalletType = _selectedProvider;
      }

      final result = await _paymentRepo.processPayment(bill.id, _selectedMethod, bankCode, ewalletType);
      
      if (!mounted) return;
      // Pass the updated payment as argument to status screen
      Navigator.of(context).pushReplacementNamed('/payments/status', arguments: result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran gagal: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = ModalRoute.of(context)!.settings.arguments as PaymentModel;
    
    // Auto-update provider selection when method changes
    final currentProviders = (_selectedMethod == 'BANK_TRANSFER' || _selectedMethod == 'VIRTUAL_ACCOUNT') 
        ? banks 
        : (_selectedMethod == 'EWALLET' ? ewallets : <String>[]);
    if (currentProviders.isNotEmpty && !currentProviders.contains(_selectedProvider)) {
      _selectedProvider = currentProviders.first;
    }

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
                  _row('Jenis', 'Pajak ${bill.billType}'),
                  _row('Nomor', bill.billNumber),
                  const Divider(height: 24),
                  _row('Total', 'Rp ${bill.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Metode Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            ...methods.map((m) => GestureDetector(
              onTap: () => setState(() => _selectedMethod = m['id'] as String),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _selectedMethod == m['id'] ? AppTheme.primaryBlack : AppTheme.divider, width: _selectedMethod == m['id'] ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      size: 20,
                      color: AppTheme.primaryBlack,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(m['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    if (_selectedMethod == m['id'])
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

            if (currentProviders.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_selectedMethod == 'EWALLET' ? 'Pilih Provider' : 'Pilih Bank', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedProvider,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: currentProviders.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedProvider = val);
                },
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _process(bill),
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
