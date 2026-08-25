import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/util/pdf_invoice_generator.dart';

class CustomerOrderDataScreen extends ConsumerStatefulWidget {
  const CustomerOrderDataScreen({super.key});

  @override
  ConsumerState<CustomerOrderDataScreen> createState() => _CustomerOrderDataScreenState();
}

class _CustomerOrderDataScreenState extends ConsumerState<CustomerOrderDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _parseNum(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return const Color(0xFF16A34A);
      case 'PROCESSING':
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY':
      case 'CONFIRMED':
        return const Color(0xFF2563EB);
      case 'PENDING':
        return const Color(0xFFD97706);
      case 'CANCELLED':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return const Color(0xFF16A34A);
      case 'PARTIALLY_PAID':
        return const Color(0xFFD97706);
      case 'UNPAID':
      case 'REFUNDED':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myOrdersAsync = ref.watch(myCustomerOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Customer Orders Directory',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        actions: [
          IconButton(
            tooltip: 'Refresh Orders',
            icon: const Icon(Icons.refresh, color: Color(0xFF2563EB)),
            onPressed: () => ref.invalidate(myCustomerOrdersProvider),
          ),
          const DynamicNotificationButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myCustomerOrdersProvider);
        },
        child: myOrdersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load customer orders: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(myCustomerOrdersProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (orders) {
            // Apply filtering & searching
            final filteredOrders = orders.where((order) {
              final matchesSearch = _searchQuery.isEmpty ||
                  order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  order.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  order.paymentMethod.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  order.deliveryAddress.toLowerCase().contains(_searchQuery.toLowerCase());

              final matchesStatus = _selectedStatusFilter == 'ALL' ||
                  order.status.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesStatus;
            }).toList();

            // Calculate metrics totals
            double totalVal = 0;
            double paidVal = 0;
            double dueVal = 0;
            for (var o in orders) {
              totalVal += o.totalAmount;
              paidVal += _parseNum(o.paidAmount);
              dueVal += _parseNum(o.dueAmount);
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Metrics Summary Banner ─────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics_outlined, color: Colors.blueAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ORDER PIPELINE SUMMARY',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBannerMetric('Total Orders', '${orders.length}', Colors.white),
                            ),
                            Expanded(
                              child: _buildBannerMetric('Total Value', '৳${totalVal.toStringAsFixed(0)}', const Color(0xFF60A5FA)),
                            ),
                            Expanded(
                              child: _buildBannerMetric('Paid Amount', '৳${paidVal.toStringAsFixed(0)}', const Color(0xFF4ADE80)),
                            ),
                            Expanded(
                              child: _buildBannerMetric('Due Balance', '৳${dueVal.toStringAsFixed(0)}', const Color(0xFFF87171)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Search & Filter Controls ────────────────
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by Order #, status, payment method...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['ALL', 'PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'].map((status) {
                        final isSelected = _selectedStatusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(
                              status == 'ALL' ? 'All Orders (${orders.length})' : status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            selectedColor: const Color(0xFF2563EB),
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300),
                            ),
                            onSelected: (_) => setState(() => _selectedStatusFilter = status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Order Cards Data List ───────────────────
                  if (filteredOrders.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No customer orders found.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search query or filters.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final due = _parseNum(order.dueAmount);
                        final paid = _parseNum(order.paidAmount);
                        final statusColor = _getStatusColor(order.status);
                        final paymentColor = _getPaymentStatusColor(order.paymentStatus);

                        final dateFormatted = order.createdAt.contains('T')
                            ? order.createdAt.split('T').first
                            : (order.createdAt.length >= 10 ? order.createdAt.substring(0, 10) : order.createdAt);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order Header Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.receipt_long, size: 16, color: Color(0xFF2563EB)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              order.orderNumber,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B2545)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Order Body Content
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Date & Service Details
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('ORDER DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text(dateFormatted, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('SERVICE / PRIORITY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text('${order.serviceType} (${order.priority})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('PAYMENT STATUS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: paymentColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  order.paymentStatus,
                                                  style: TextStyle(color: paymentColor, fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Line items list preview
                                    if (order.lineItems.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'PRODUCTS (${order.lineItems.length}):',
                                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 4),
                                            ...order.lineItems.take(2).map((item) => Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '• ${item.productName}',
                                                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Qty: ${item.quantity}  ×  ৳${item.unitPrice.toStringAsFixed(0)}',
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                            if (order.lineItems.length > 2)
                                              Text(
                                                '+ ${order.lineItems.length - 2} more item(s)...',
                                                style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontStyle: FontStyle.italic),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    // Financial Amounts Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                            Text('৳${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF059669))),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('PAID AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                            Text('৳${paid.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF16A34A))),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('DUE AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                            Text('৳${due.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: due > 0 ? const Color(0xFFDC2626) : Colors.grey)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),

                                    // ── Data Row PDF Action & Extra Actions Row ──
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        // PDF View / Download Button for this order data row
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1E40AF),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                                          label: const Text('View Order PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () async {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Generating PDF for ${order.orderNumber}...'),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                            await PdfInvoiceGenerator.downloadOrPrint(order: order);
                                          },
                                        ),

                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Track Order Button
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF2563EB),
                                                side: const BorderSide(color: Color(0xFFBFDBFE)),
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              icon: const Icon(Icons.location_on_outlined, size: 14),
                                              label: const Text('Track', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/customer-order-track',
                                                  arguments: order.orderNumber,
                                                );
                                              },
                                            ),
                                            if (due > 0) ...[
                                              const SizedBox(width: 6),
                                              // Pay Due Button
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF16A34A),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                icon: const Icon(Icons.payment, size: 14),
                                                label: const Text('Pay Due', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/add-payment',
                                                    arguments: order.orderNumber,
                                                  );
                                                },
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBannerMetric(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
