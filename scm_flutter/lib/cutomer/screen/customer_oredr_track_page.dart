import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';

class CustomerOrderTrackScreen extends ConsumerStatefulWidget {
  const CustomerOrderTrackScreen({super.key, this.initialOrderNumber});

  final String? initialOrderNumber;

  @override
  ConsumerState<CustomerOrderTrackScreen> createState() => _CustomerOrderTrackScreenState();
}

class _CustomerOrderTrackScreenState extends ConsumerState<CustomerOrderTrackScreen> {
  late TextEditingController _searchController;
  String? searchedOrderNumber;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialOrderNumber ?? '');
    searchedOrderNumber = widget.initialOrderNumber;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = (searchedOrderNumber != null && searchedOrderNumber!.isNotEmpty)
        ? ref.watch(trackCustomerOrderProvider(searchedOrderNumber!))
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'SCM PRO',
              style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.black87),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.black54),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Track Banner & Search Box ──────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Track Your Shipment',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter your tracking ID to view real-time shipment details',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Enter Tracking ID (e.g. SCM-TRK-587421)',
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              setState(() {
                                searchedOrderNumber = _searchController.text.trim();
                              });
                            }
                          },
                          child: const Text('Track Now', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Order Details Result Section ───────────────
            if (searchedOrderNumber == null || searchedOrderNumber!.isEmpty)
              _buildEmptyState('Please enter a tracking ID to search.')
            else
              orderAsync!.when(
                data: (order) => _buildTrackingResult(order),
                loading: () => const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => _buildEmptyState('Order not found or invalid tracking ID.'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingResult(CustomerOrderResponse order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Reference Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ORDER REFERENCE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(radius: 3, backgroundColor: Colors.green),
                        const SizedBox(width: 6),
                        Text(order.status, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(order.orderNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy, size: 16, color: Colors.blue),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recipient Customer', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Settlement Financial State', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text(order.paymentStatus, style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estimated Arrival Roadmap', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(order.estimatedDelivery, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Consignment Value', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text('৳${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              // Sub Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _subInfoColumn(Icons.location_on_outlined, 'Current Location', 'Dhaka Hub'),
                  _subInfoColumn(Icons.local_shipping_outlined, 'Service Type', order.serviceType),
                  _subInfoColumn(Icons.access_time, 'Last Updated', order.createdAt),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Milestone Progress Pipeline ────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('MILESTONE PROGRESS PIPELINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _milestoneStep('Pending', Icons.access_time, true),
              _milestoneStep('Confirmed', Icons.check, true),
              _milestoneStep('Processing', Icons.settings, true),
              _milestoneStep('Shipped', Icons.local_shipping, order.status != 'PENDING'),
              _milestoneStep('Delivered', Icons.inventory, order.status == 'DELIVERED'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Shipment Details Card ──────────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('SHIPMENT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _detailRow('Order ID', order.orderNumber, 'Total Items', '${order.lineItems.length} Items'),
              const Divider(height: 20),
              _detailRow('Package Weight', '${order.weight} kg', 'Shipping Address', order.deliveryAddress),
              const Divider(height: 20),
              _detailRow('Payment Method', order.paymentMethod, 'Total Amount', '৳${order.totalAmount.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subInfoColumn(IconData icon, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _milestoneStep(String title, IconData icon, bool isCompleted) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isCompleted ? Colors.green : Colors.grey.shade200,
          child: Icon(icon, size: 16, color: isCompleted ? Colors.white : Colors.grey),
        ),
        const SizedBox(height: 6),
        Text(title, style: TextStyle(fontSize: 10, color: isCompleted ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _detailRow(String title1, String val1, String title2, String val2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title1, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(val1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title2, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(val2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 50, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}