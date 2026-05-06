import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/common/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            _HomeTab(),
            _ActivityTab(),
            _ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Aktivitas'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlack,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GovApp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 20),
                      const SizedBox(width: 10),
                      Text('Cari layanan...', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Layanan Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('Lihat semua', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: AppTheme.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Service grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                ServiceCard(
                  icon: Icons.description_outlined,
                  title: 'Dokumen',
                  subtitle: 'Pengajuan KTP / Paspor',
                  onTap: () => Navigator.of(context).pushNamed('/documents'),
                ),
                ServiceCard(
                  icon: Icons.payments_outlined,
                  title: 'Pembayaran',
                  subtitle: 'Pajak & Retribusi',
                  onTap: () => Navigator.of(context).pushNamed('/payments'),
                ),
                ServiceCard(
                  icon: Icons.report_problem_outlined,
                  title: 'Pengaduan',
                  subtitle: 'Fasilitas Umum',
                  onTap: () => Navigator.of(context).pushNamed('/complaints'),
                ),
                ServiceCard(
                  icon: Icons.history_rounded,
                  title: 'Riwayat',
                  subtitle: 'Semua transaksi',
                  onTap: () => Navigator.of(context).pushNamed('/payments/history'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Info Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentLime.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLime,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_outline, color: AppTheme.primaryBlack, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mode Simulasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text('Seluruh data bersifat dummy', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _ActivityItem(
                  icon: Icons.description_outlined,
                  title: 'Pengajuan KTP',
                  subtitle: '2 jam yang lalu',
                  status: 'IN_REVIEW',
                ),
                _ActivityItem(
                  icon: Icons.payments_outlined,
                  title: 'Pembayaran PBB',
                  subtitle: '1 hari yang lalu',
                  status: 'SUCCESS',
                ),
                _ActivityItem(
                  icon: Icons.report_problem_outlined,
                  title: 'Pengaduan Jalan Rusak',
                  subtitle: '3 hari yang lalu',
                  status: 'SUBMITTED',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryBlack),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          StatusBadge(status: status),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlack,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, size: 40, color: AppTheme.accentLime),
          ),
          const SizedBox(height: 14),
          const Text('Budi Santoso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('warga1@govapp.id', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 32),

          _ProfileMenuItem(icon: Icons.person_outline, label: 'Edit Profil', onTap: () {}),
          _ProfileMenuItem(icon: Icons.lock_outline, label: 'Ubah Password', onTap: () {}),
          _ProfileMenuItem(icon: Icons.help_outline, label: 'Bantuan', onTap: () {}),
          const SizedBox(height: 12),
          _ProfileMenuItem(
            icon: Icons.logout,
            label: 'Keluar',
            isDestructive: true,
            onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDestructive ? AppTheme.error.withOpacity(0.3) : AppTheme.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? AppTheme.error : AppTheme.primaryBlack),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDestructive ? AppTheme.error : AppTheme.textPrimary),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}
