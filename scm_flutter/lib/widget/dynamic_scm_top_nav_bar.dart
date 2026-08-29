import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class DynamicScmTopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onRefresh;

  const DynamicScmTopNavBar({
    super.key,
    this.title = 'SCM ENTERPRISE',
    this.showBackButton = false,
    this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  String _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return 'http://${ApiConstants.host}:8085/$cleanPath';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final rawName = currentUser?.name.trim() ?? 'User';
    final userInitials = rawName.length >= 2
        ? rawName.substring(0, 2).toUpperCase()
        : (rawName.isNotEmpty ? rawName.toUpperCase() : 'US');

    // Resolve avatar image from supplier directory or user profile
    String avatarUrl = '';
    final suppliersAsync = ref.watch(supplierListProvider);
    final suppliers = suppliersAsync.value ?? [];
    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;
    if (currentSupplier != null && currentSupplier.image.isNotEmpty) {
      avatarUrl = _resolveImageUrl(currentSupplier.image);
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Branding & Optional Back Button (Responsive Expanded)
            Expanded(
              child: Row(
                children: [
                  if (showBackButton) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business_center, color: Color(0xFF2563EB), size: 18),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            // Right Actions: Refresh, Notification Badge, User Avatar Image, 3-Dot Options Dropdown
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DynamicNotificationButton(),
                const SizedBox(width: 4),
                
                // User Avatar Circle (Displays Profile & Logout Popup on click)
                PopupMenuButton<String>(
                  tooltip: 'User Account',
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 8),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      final role = currentUser?.role.toUpperCase() ?? '';
                      if (role.contains('PROCUREMENT') || role.contains('LOGISTICS') || role.contains('OFFICER')) {
                        Navigator.pushNamed(context, '/procurement-profile');
                      } else if (role.contains('DRIVER')) {
                        Navigator.pushNamed(context, '/driver-profile');
                      } else {
                        Navigator.pushNamed(context, '/profile');
                      }
                    } else if (value == 'logout') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Logout', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Text('Logged in as ${currentUser?.name ?? "User"}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text('Profile', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF2563EB),
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            userInitials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 2),

                // 3-Dot Popup Menu Button (Navigation & User Options Dropdown)
                PopupMenuButton<String>(
                  tooltip: 'Options & Navigation',
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 8),
                  icon: const Icon(Icons.more_vert, color: AppTheme.secondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 220),
                  onSelected: (value) async {
                    switch (value) {
                      case 'customer_orders':
                        Navigator.pushNamed(context, '/customer-orders');
                        break;
                      case 'payment_statement':
                        Navigator.pushNamed(context, '/payment-statement');
                        break;
                      case 'shipment':
                        Navigator.pushNamed(context, '/shipments');
                        break;
                      case 'letter_of_credit':
                        Navigator.pushNamed(context, '/letter-of-credit-data');
                        break;
                      case 'lc_bank':
                        Navigator.pushNamed(context, '/lc-bank-data');
                        break;
                      case 'billing':
                        Navigator.pushNamed(context, '/billing');
                        break;
                      case 'po_line_item':
                        Navigator.pushNamed(context, '/po-line-items');
                        break;
                      case 'profile':
                        final role = currentUser?.role.toUpperCase() ?? '';
                        if (role.contains('PROCUREMENT') || role.contains('LOGISTICS') || role.contains('OFFICER')) {
                          Navigator.pushNamed(context, '/procurement-profile');
                        } else if (role.contains('DRIVER')) {
                          Navigator.pushNamed(context, '/driver-profile');
                        } else {
                          Navigator.pushNamed(context, '/profile');
                        }
                        break;
                      case 'logout':
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final userRole = currentUser?.role.toUpperCase() ?? '';
                    final isCommercial = userRole == 'COMMERCIAL_OFFICER' ||
                        userRole == 'ROLE_COMMERCIAL_OFFICER' ||
                        userRole == 'COMMERCIAL' ||
                        userRole.contains('COMMERCIAL');

                    const profileItem = PopupMenuItem<String>(
                      value: 'profile',
                      height: 36,
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: AppTheme.primary),
                          SizedBox(width: 10),
                          Text('Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );

                    const logoutItem = PopupMenuItem<String>(
                      value: 'logout',
                      height: 36,
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text('Logout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.redAccent)),
                        ],
                      ),
                    );

                    if (!isCommercial) {
                      return [profileItem, logoutItem];
                    }

                    return [
                      // PRODUCTS & ORDERS
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 28,
                        child: Text('PRODUCTS & ORDERS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'customer_orders',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Customer Orders', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'payment_statement',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Payment Statement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),

                      const PopupMenuDivider(height: 10),

                      // LOGISTICS
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 28,
                        child: Text('LOGISTICS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'shipment',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF4F46E5)),
                            SizedBox(width: 10),
                            Text('Shipment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
                          ],
                        ),
                      ),

                      const PopupMenuDivider(height: 10),

                      // COMMERCIAL
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 28,
                        child: Text('COMMERCIAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'letter_of_credit',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Letter Of Credit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'lc_bank',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('LC Bank', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'billing',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 16, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Billing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'po_line_item',
                        height: 36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.format_list_bulleted, size: 16, color: Colors.black87),
                                SizedBox(width: 10),
                                Text('PO Line Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade400, width: 0.8),
                              ),
                              child: const Text('Active', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),

                      const PopupMenuDivider(height: 10),

                      profileItem,
                      logoutItem,
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
