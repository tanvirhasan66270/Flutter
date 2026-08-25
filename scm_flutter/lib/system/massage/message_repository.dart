import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/massage_model.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class MessageRepository {
  MessageRepository(this._apiClient);

  final dynamic _apiClient;
  Dio get _dio => _apiClient.dio;

  /// (POST /api/messages)
  Future<List<MessageResponseModel>> sendMessage(MessageRequestModel dto) async {
    final res = await _dio.post(ApiConstants.messages, data: dto.toJson());
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => MessageResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ///  (GET /api/messages/inbox)
  Future<List<MessageResponseModel>> getInbox() async {
    final res = await _dio.get(ApiConstants.messageInbox);
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => MessageResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ///(GET /api/messages/chatlist)
  Future<List<dynamic>> getChatlist() async {
    final res = await _dio.get(ApiConstants.messageChatlist);
    if (res.statusCode == 204 || res.data == null) return [];
    return res.data as List;
  }

  /// (GET /api/messages/history?contactId=...)
  Future<List<MessageResponseModel>> getChatHistory(String contactId) async {
    final res = await _dio.get(
      ApiConstants.messageHistory,
      queryParameters: {'contactId': contactId},
    );
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => MessageResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// (PATCH /api/messages/{id}/read)
  Future<void> markAsRead(int id) async {
    await _dio.patch(ApiConstants.messageRead(id));
  }
}