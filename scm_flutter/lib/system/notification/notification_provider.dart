import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/system/notification/notification_repository.dart';


/// ১. NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

/// (GET /api/notifications)
final notificationListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUserNotifications();
});

/// (GET /api/notifications/unread-count)
final notificationUnreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
});