class PaymentModel {
  final int id;
  final int userId;
  final String billType;
  final String billNumber;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.billType,
    required this.billNumber,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      userId: json['user_id'],
      billType: json['bill_type'] ?? '',
      billNumber: json['bill_number'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
