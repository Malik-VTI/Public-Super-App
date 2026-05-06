class ApiConstants {
  static const String baseUrl = 'http://localhost:8080';
  
  // Auth
  static const String login = '/api/v1/auth/login';
  static const String biometric = '/api/v1/auth/biometric';
  static const String logout = '/api/v1/auth/logout';
  static const String refresh = '/api/v1/auth/refresh';
  static const String profile = '/api/v1/auth/profile';

  // Documents
  static const String documents = '/api/v1/documents';
  static String uploadDocument(int id) => '/api/v1/documents/$id/upload';
  static String documentStatus(int id) => '/api/v1/documents/$id/status';

  // Payments
  static const String bills = '/api/v1/payments/bills';
  static const String processPayment = '/api/v1/payments/process';
  static String paymentStatus(int id) => '/api/v1/payments/$id/status';
  static const String paymentHistory = '/api/v1/payments/history';

  // Complaints
  static const String complaints = '/api/v1/complaints';
  static String uploadComplaint(int id) => '/api/v1/complaints/$id/upload';
  static String complaintDetail(int id) => '/api/v1/complaints/$id';
}
