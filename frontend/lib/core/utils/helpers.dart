class AppHelpers {
  static String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${(diff.inDays / 7).floor()} minggu lalu';
  }

  static String categoryLabel(String category) {
    final labels = {
      'JALAN_RUSAK': 'Jalan Rusak',
      'LAMPU_MATI': 'Lampu Mati',
      'SAMPAH': 'Sampah',
      'BANJIR': 'Banjir',
    };
    return labels[category] ?? category;
  }
}
