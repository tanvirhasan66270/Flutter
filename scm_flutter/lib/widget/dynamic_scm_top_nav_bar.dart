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
                if (onRefresh != null)
                  IconButton(
                    tooltip: 'Refresh Data',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: const Icon(Icons.refresh, color: AppTheme.secondary, size: 18),
                    onPressed: onRefresh,
                  ),
                const DynamicNotificationButton(),
                const SizedBox(width: 4),
                
                // User Avatar Circle (Displays User Image if present, else fallback to Initial)
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF2563EB),
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  onBackgroundImageError: avatarUrl.isNotEmpty
                      ? (exception, stackTrace) {
                          // Fallback handling if network image load fails
                        }
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          userInitials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                        )
                      : null,
                ),

                const SizedBox(width: 2),

                // 3-Dot Popup Menu Button (Profile & Logout Dropdown)
                PopupMenuButton<String>(
                  tooltip: 'User Options',
                  icon: const Icon(Icons.more_vert, color: AppTheme.secondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      Navigator.pushNamed(context, '/profile');
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
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 18, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text('Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
