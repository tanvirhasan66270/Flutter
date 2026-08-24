import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/cutomer/provider/payment_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/widget/commonWidget.dart';

class BillingLedgerScreen extends ConsumerStatefulWidget {
  const BillingLedgerScreen({super.key, this.initialOrderNumber});
  final String? initialOrderNumber;

  @override
  ConsumerState<BillingLedgerScreen> createState() => _BillingLedgerScreenState();
}

class _BillingLedgerScreenState extends ConsumerState<BillingLedgerScreen> {
  final _searchController = TextEditingController();
  String? _searchedCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrderNumber != null) {
      _searchController.text = widget.initialOrderNumber!;
      _searchedCode = widget.initialOrderNumber;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = (_searchedCode != null) ? ref.watch(orderPaymentsProvider(_searchedCode!)) : null;
    final orderAsync = (_searchedCode != null) ? ref.watch(trackCustomerOrderProvider(_searchedCode!)) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Billing Ledger', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBanner(),
            const SizedBox(height: 20),
            if (_searchedCode == null) _buildEmptyState('Search for an order to view history')
            else ...[
               if (orderAsync != null) orderAsync.when(
                 data: (order) => _buildFinancialCard(order),
                 loading: () => const LinearProgressIndicator(),
                 error: (e, _) => ErrorBanner(message: apiErrorMessage(e)),
               ),
               const SizedBox(height: 20),
               if (paymentsAsync != null) paymentsAsync.when(
                 data: (payments) => _buildPaymentLog(payments),
                 loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
                 error: (e, _) => ErrorBanner(message: apiErrorMessage(e)),
               ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Statement', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Consolidated financial log for your orders', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Order No (ORD-...)', border: InputBorder.none, hintStyle: TextStyle(fontSize: 12)),
                    onSubmitted: (v) => setState(() => _searchedCode = v.trim()),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _searchedCode = _searchController.text.trim()),
                  icon: const Icon(Icons.search, color: Color(0xFF1E40AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(CustomerOrderResponse order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Financial Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              StatusBadge(status: order.paymentStatus),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _statItem('Grand Total', '৳${order.totalAmount}', Colors.blue),
              _statItem('Total Paid', '৳${order.paidAmount}', Colors.green),
              _statItem('Balance Due', '৳${order.dueAmount}', Colors.red),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(child: Column(children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
    ]));
  }

  Widget _buildPaymentLog(List<PaymentStatementResponse> payments) {
    if (payments.isEmpty) {
      return _buildEmptyState('No payment transactions found for this order.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TRANSACTION HISTORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        ...payments.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.payment, size: 18, color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(p.createdAt.substring(0, 16).replaceFirst('T', ' '), style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('৳${p.paidAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                Text(PaymentStatementStatusMeta.labelFor(p.issueStatus), style: TextStyle(fontSize: 9, color: p.issueStatus == PaymentStatementStatus.confirmedByOfficer ? Colors.green : Colors.orange)),
              ]),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 12))));
  }
}
