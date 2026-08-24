import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';

class CustomerDashboardScreen extends ConsumerStatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  ConsumerState<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends ConsumerState<CustomerDashboardScreen> {
  int _currentIndex = 0;

  final double walletBalance = 0.00;
  final double dueAmountTotal = 0.00;
  final int totalOrders = 0;
  final int activeOrders = 0;
  final int deliveredOrders = 0;
  final int pendingOrders = 0;
  final int cancelledOrders = 0;

  final List<dynamic> recentOrders = [];
  final List<dynamic> recommendations = [
    {
      'name': 'Heavy Duty Double Needle Sewing Machine',
      'price': 32000.00,
      'rating': 4.8,
      'reviews': 128,
      'inStock': true,
    },
    {
      'name': 'Industrial Garments Big Knitting Machine',
      'price': 110000.00,
      'rating': 4.7,
      'reviews': 96,
      'inStock': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userName = (currentUser?.name != null && currentUser!.name.isNotEmpty)
        ? currentUser.name
        : 'Customer';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 8),
            const Text(
              'SCM ENTERPRISE',
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
              backgroundColor: const Color(0xFF2563EB),
              child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Banner ──────────────────────────
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Welcome back, $userName ',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text('👋', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Track your orders & profile details.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(radius: 3, backgroundColor: Colors.greenAccent),
                              SizedBox(width: 6),
                              Text('Live', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.local_shipping_rounded, color: Colors.white24, size: 70),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Wallet & Due Cards ──────────────────────
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                            SizedBox(width: 6),
                            Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳${walletBalance.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.pink.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.calendar_today_outlined, color: Colors.pink, size: 18),
                            SizedBox(width: 6),
                            Text('Due Payments', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳${dueAmountTotal.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Order Metrics Grid ──────────────────────
            Row(
              children: [
                _buildMetricCard('Total Orders', '$totalOrders', '↑ 12% this month', Colors.blue, Icons.shopping_bag_outlined),
                const SizedBox(width: 8),
                _buildMetricCard('Active Orders', '$activeOrders', '2 Processing', Colors.green, Icons.inventory_2_outlined),
                const SizedBox(width: 8),
                _buildMetricCard('Delivered', '$deliveredOrders', '0% Success', Colors.teal, Icons.check_circle_outline),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.hourglass_empty_rounded, color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$pendingOrders', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text('Pending • Waiting Payment', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$cancelledOrders', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text('Cancelled • Last 6 Months', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Quick Actions ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('View All →', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics( ),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildQuickActionItem('Place New Order', Icons.shopping_cart_outlined, () {
                  Navigator.of(context).pushNamed('/book-parcel');
                }),
                _buildQuickActionItem('Add Payment', Icons.payment_outlined, () {}),
                _buildQuickActionItem('Track Product', Icons.location_on_outlined, () {}),
                _buildQuickActionItem('Billing Ledger', Icons.receipt_long_outlined, () {}),
                _buildQuickActionItem('Invoices', Icons.description_outlined, () {}),
                _buildQuickActionItem('Support Desk', Icons.headset_mic_outlined, () {}),
                _buildQuickActionItem('Wishlist', Icons.favorite_border_rounded, () {}),
                _buildQuickActionItem('My Profile', Icons.person_outline_rounded, () {
                  Navigator.of(context).pushNamed('/profile');
                }),
              ],
            ),
            const SizedBox(height: 20),

            // ── Active Order Pipeline ───────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Active Order Pipeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('View All →', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Icon(Icons.inbox_rounded, color: Colors.blueAccent, size: 48),
                  const SizedBox(height: 8),
                  const Text('No active order records found.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Recommended for You ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Recommended for You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('View All →', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final item = recommendations[index];
                  return Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 40)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['name'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '৳${item['price'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(' ${item['rating']} (${item['reviews']})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.shopping_cart_outlined, size: 12),
                            label: const Text('Add to cart'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.of(context).pushNamed('/my-parcels');
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String count, String subtitle, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2563EB), size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}