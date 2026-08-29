import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/system/notification/notification_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllAsRead();
              ref.invalidate(notificationListProvider);
              ref.invalidate(notificationUnreadCountProvider);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading notifications: $err')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = notifications[index] as Map<String, dynamic>;
              final bool isRead = item['isRead'] ?? item['read'] ?? false;
              final String title = item['title'] ?? 'Notification';
              final String message = item['message'] ?? '';
              final int? id = item['id'];

              return ListTile(
                tileColor: isRead ? Colors.transparent : Colors.blue.withValues(alpha: 0.05),
                leading: CircleAvatar(
                  backgroundColor: isRead ? AppTheme.borderGrey : AppTheme.primary,
                  child: Icon(
                    isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: isRead ? Colors.grey.shade700 : Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(message),
                onTap: () async {
                  if (id != null && !isRead) {
                    await ref.read(notificationRepositoryProvider).markAsRead(id);
                    ref.invalidate(notificationListProvider);
                    ref.invalidate(notificationUnreadCountProvider);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
