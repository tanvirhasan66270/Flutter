import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/system/massage/message_provider.dart';
import 'package:scm_flutter/entity/massage_model.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';

class ChatWorkspaceScreen extends ConsumerWidget {
  const ChatWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chat Workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const _WideChatLayout();
          } else {
            return const _NarrowChatLayout();
          }
        },
      ),
    );
  }
}

class _WideChatLayout extends ConsumerWidget {
  const _WideChatLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContact = ref.watch(selectedContactProvider);

    return Row(
      children: [
        const SizedBox(
          width: 300,
          child: _ChatSidebar(),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: selectedContact == null
              ? const _ChatPlaceholder()
              : _ChatDetail(contact: selectedContact),
        ),
      ],
    );
  }
}

class _NarrowChatLayout extends ConsumerWidget {
  const _NarrowChatLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContact = ref.watch(selectedContactProvider);

    if (selectedContact != null) {
      return _ChatDetail(contact: selectedContact, onBack: () => ref.read(selectedContactProvider.notifier).state = null);
    }
    return const _ChatSidebar();
  }
}

class _ChatSidebar extends ConsumerWidget {
  const _ChatSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatlistAsync = ref.watch(chatlistProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: chatlistAsync.when(
            data: (contacts) => ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (ctx, idx) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isSelected = ref.watch(selectedContactProvider)?.contactId == contact.contactId;

                return ListTile(
                  onTap: () => ref.read(selectedContactProvider.notifier).state = contact,
                  selected: isSelected,
                  selectedTileColor: AppTheme.primary.withValues(alpha: 0.05),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      contact.contactName.substring(0, index < 2 ? 2 : 1).toUpperCase(),
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  title: Text(
                    contact.contactName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          contact.role.toUpperCase(),
                          style: const TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  trailing: contact.unreadCount > 0
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: AppTheme.primary,
                          child: Text(
                            contact.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        )
                      : null,
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(apiErrorMessage(e))),
          ),
        ),
      ],
    );
  }
}

class _ChatDetail extends ConsumerStatefulWidget {
  const _ChatDetail({required this.contact, this.onBack});
  final ChatContactModel contact;
  final VoidCallback? onBack;

  @override
  ConsumerState<_ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends ConsumerState<_ChatDetail> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    try {
      final repo = ref.read(messageRepositoryProvider);
      await repo.sendMessage(MessageRequestModel(
        recipientId: widget.contact.contactId,
        subject: 'Chat Message',
        body: text,
        priority: MessagePriority.medium,
      ));
      _msgController.clear();
      ref.invalidate(chatHistoryProvider(widget.contact.contactId));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(chatHistoryProvider(widget.contact.contactId));

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              if (widget.onBack != null) 
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.contact.contactName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(widget.contact.role, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: historyAsync.when(
            data: (messages) => ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId != widget.contact.contactId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
                      ],
                    ),
                    child: Text(
                      msg.body,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13),
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(apiErrorMessage(e))),
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _send,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatPlaceholder extends StatelessWidget {
  const _ChatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primary, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'SCM Chat Desk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Choose a contact from the list to pull credentials and retrieve message records.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
