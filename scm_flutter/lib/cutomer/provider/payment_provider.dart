import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/cutomer/data/payment_repository.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

final orderPaymentsProvider = FutureProvider.autoDispose.family<List<PaymentStatementResponse>, String>((ref, orderNumber) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getPaymentsByOrderNumber(orderNumber);
});
