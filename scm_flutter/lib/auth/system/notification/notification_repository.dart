import 'package:dio/dio.dart';
import 'package:scm_flutter/util/apiConstants.dart'; 

class NotificationRepository {
  NotificationRepository(this._apiClient);

  final dynamic _apiClient;
  Dio get _dio => _apiClient.dio;

  ///  (GET /api/notifications)
  Future<List<dynamic>> getUserNotifications() async {
    final res = await _dio.get(ApiConstants.notifications);
    if (res.statusCode == 204 || res.data == null) return [];
    return res.data as List;
  }

  /// (GET /api/notifications/unread-count)
  Future<int> getUnreadCount() async {
    final res = await _dio.get(ApiConstants.notificationUnreadCount);
    return (res.data ?? 0) as int;
  }

  /// (PATCH /api/notifications/{id}/read)
  Future<void> markAsRead(int id) async {
    await _dio.patch(ApiConstants.notificationRead(id));
  }

  /// (PATCH /api/notifications/read-all)
  Future<void> markAllAsRead() async {
    await _dio.patch(ApiConstants.notificationReadAll);
  }
}