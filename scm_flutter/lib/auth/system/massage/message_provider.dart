import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/auth/system/massage/message_repository.dart';
import 'package:scm_flutter/entity/massage_model.dart';


/// ১. MessageRepository
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(ref.watch(apiClientProvider));
});

/// (GET /api/messages/inbox)
final inboxProvider = FutureProvider.autoDispose<List<MessageResponseModel>>((ref) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getInbox();
});

/// (GET /api/messages/chatlist)
final chatlistProvider = FutureProvider.autoDispose<List<ChatContactModel>>((ref) async {
  final repository = ref.watch(messageRepositoryProvider);
  final data = await repository.getChatlist();
  return data.map((e) => ChatContactModel.fromJson(e as Map<String, dynamic>)).toList();
});

/// (GET /api/messages/history)
final chatHistoryProvider = FutureProvider.autoDispose.family<List<MessageResponseModel>, String>((ref, contactId) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getChatHistory(contactId);
});

final selectedContactProvider = StateProvider<ChatContactModel?>((ref) => null);
