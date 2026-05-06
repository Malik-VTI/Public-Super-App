import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/payment_model.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payment = ModalRoute.of(context)!.settings.arguments as PaymentModel?;
    
    if (payment == null) {
      return const Scaffold(body: Center(child: Text('Data pembayaran tidak ditemukan')));
    }

    final isSuccess = payment.status == 'SUCCESS';
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Status icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: isSuccess ? AppTheme.accentLime.withOpacity(0.2) : AppTheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded, 
                  size: 48, 
                  color: isSuccess ? AppTheme.success : AppTheme.error
                ),
              ),
              const SizedBox(height: 24),
              Text(isSuccess ? 'Pembayaran Berhasil!' : 'Pembayaran ${payment.status}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(isSuccess ? 'Transaksi Anda telah diproses' : 'Silakan coba lagi', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  children: [
                    _detailRow('Jenis', 'Pajak ${payment.billType}'),
                    _detailRow('Nomor', payment.billNumber),
                    _detailRow('Metode', payment.paymentMethod ?? '-'),
                    if (payment.bankCode != null && payment.bankCode!.isNotEmpty) _detailRow('Bank', payment.bankCode!),
                    if (payment.vaNumber != null && payment.vaNumber!.isNotEmpty) _detailRow('Virtual Account', payment.vaNumber!),
                    if (payment.qrisString != null && payment.qrisString!.isNotEmpty) _detailRow('QRIS Ref', payment.qrisString!),
                    if (payment.ewalletRef != null && payment.ewalletRef!.isNotEmpty) _detailRow('E-Wallet Ref', payment.ewalletRef!),
                    if (payment.transactionId != null) _detailRow('ID Transaksi', payment.transactionId!),
                    const Divider(height: 20),
                    _detailRow('Total Dibayar', 'Rp ${payment.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', isBold: true),
                  ],
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Unduh Bukti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
