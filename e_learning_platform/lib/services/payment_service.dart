import 'dart:math';

class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;

  PaymentResult(
      {required this.success, required this.message, this.transactionId});
}

class PaymentService {
  // Mock payment processing (Stripe/PayPal simulation)
  static Future<PaymentResult> payForCourse({
    required String courseId,
    required String userId,
    required double amount,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final rng = Random();
    final success = rng.nextInt(100) < 90; // 90% success
    if (success) {
      return PaymentResult(
        success: true,
        message: 'Payment successful',
        transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    return PaymentResult(success: false, message: 'Payment failed. Try again.');
  }
}
