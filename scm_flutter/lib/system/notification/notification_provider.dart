import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/system/notification/notification_repository.dart';


/// ১. NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

/// (GET /api/notifications)
final notificationListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repository = ref.watch(notificationRepositoryProvider);
  try {
    return await repository.getUserNotifications();
  } catch (_) {
    return [];
  }
});

/// (GET /api/notifications/unread-count)
final notificationUnreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final repository = ref.watch(notificationRepositoryProvider);
  try {
    return await repository.getUnreadCount();
  } catch (_) {
    return 0;
  }
});