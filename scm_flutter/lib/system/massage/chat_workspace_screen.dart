import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/massage_model.dart';
import 'package:scm_flutter/system/massage/message_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';

class ChatWorkspaceScreen extends ConsumerWidget {
  const ChatWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContact = ref.watch(selectedContactProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chat Workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: 'Refresh Chats',
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: () {
              ref.invalidate(chatlistProvider);
              if (selectedContact != null) {
                ref.invalidate(chatHistoryProvider(selectedContact.contactId));
              }
            },
          ),
          const SizedBox(width: 8),
        ],
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
          width: 320,
          child: _ChatSidebar(),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: selectedContact == null
              ? const _ChatPlaceholder()
              : _ChatDetail(key: ValueKey(selectedContact.contactId), contact: selectedContact),
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
      return _ChatDetail(
        key: ValueKey(selectedContact.contactId),
        contact: selectedContact,
        onBack: () => ref.read(selectedContactProvider.notifier).state = null,
      );
    }
    return const _ChatSidebar();
  }
}

class _ChatSidebar extends ConsumerStatefulWidget {
  const _ChatSidebar();

  @override
  ConsumerState<_ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends ConsumerState<_ChatSidebar> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatlistAsync = ref.watch(chatlistProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
        ),

        // Contacts List
        Expanded(
          child: chatlistAsync.when(
            data: (contacts) {
              final filtered = contacts.where((c) {
                if (_searchQuery.isEmpty) return true;
                return c.contactName.toLowerCase().contains(_searchQuery) ||
                    c.role.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty ? 'No contacts available' : 'No contacts found matching "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(chatlistProvider.future),
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, idx) => const Divider(height: 1, indent: 72, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    final isSelected = ref.watch(selectedContactProvider)?.contactId == contact.contactId;

                    return ListTile(
                      onTap: () {
                        ref.read(selectedContactProvider.notifier).state = contact;
                      },
                      selected: isSelected,
                      selectedTileColor: AppTheme.primary.withValues(alpha: 0.08),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                            radius: 20,
                            child: Text(
                              contact.contactName.isNotEmpty
                                  ? contact.contactName.substring(0, contact.contactName.length >= 2 ? 2 : 1).toUpperCase()
                                  : '?',
                              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              contact.contactName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.lastMessageTime != null && contact.lastMessageTime!.isNotEmpty)
                            Text(
                              _formatTime(contact.lastMessageTime!),
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                contact.role.toUpperCase(),
                                style: const TextStyle(color: Color(0xFF2563EB), fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (contact.lastMessage != null && contact.lastMessage!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  contact.lastMessage!,
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: contact.unreadCount > 0
                          ? CircleAvatar(
                              radius: 10,
                              backgroundColor: AppTheme.primary,
                              child: Text(
                                contact.unreadCount.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(apiErrorMessage(e), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.red)))),
          ),
        ),
      ],
    );
  }

  static String _formatTime(String rawTime) {
    if (rawTime.isEmpty) return '';
    try {
      if (rawTime.contains('T')) {
        final dt = DateTime.parse(rawTime);
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
      }
      return rawTime;
    } catch (_) {
      return rawTime;
    }
  }
}

class _ChatDetail extends ConsumerStatefulWidget {
  const _ChatDetail({super.key, required this.contact, this.onBack});
  final ChatContactModel contact;
  final VoidCallback? onBack;

  @override
  ConsumerState<_ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends ConsumerState<_ChatDetail> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  String _selectedPriority = MessagePriority.medium;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final currentContext = context;

    try {
      final repo = ref.read(messageRepositoryProvider);
      await repo.sendMessage(MessageRequestModel(
        recipientId: widget.contact.contactId,
        subject: 'Chat Message',
        body: text,
        priority: _selectedPriority,
      ));
      _msgController.clear();
      ref.invalidate(chatHistoryProvider(widget.contact.contactId));
      ref.invalidate(chatlistProvider);
      _scrollToBottom();
    } catch (e) {
      if (mounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _markUnreadAsRead(List<MessageResponseModel> messages) {
    final repo = ref.read(messageRepositoryProvider);
    for (final m in messages) {
      if (m.senderId == widget.contact.contactId && m.status == MessageStatus.unread) {
        repo.markAsRead(m.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(chatHistoryProvider(widget.contact.contactId));

    return Column(
      children: [
        // Chat Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              if (widget.onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                child: Text(
                  widget.contact.contactName.isNotEmpty
                      ? widget.contact.contactName.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contact.contactName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(widget.contact.role, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  setState(() => _selectedPriority = val);
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: MessagePriority.low, child: Text('Priority: Low')),
                  const PopupMenuItem(value: MessagePriority.medium, child: Text('Priority: Medium')),
                  const PopupMenuItem(value: MessagePriority.high, child: Text('Priority: High')),
                ],
                icon: Icon(
                  Icons.flag,
                  color: _selectedPriority == MessagePriority.high
                      ? Colors.red
                      : (_selectedPriority == MessagePriority.medium ? Colors.orange : Colors.grey),
                ),
                tooltip: 'Set Message Priority',
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: () => ref.invalidate(chatHistoryProvider(widget.contact.contactId)),
                tooltip: 'Refresh messages',
              ),
            ],
          ),
        ),

        // Messages List
        Expanded(
          child: historyAsync.when(
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.forum_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No message history yet',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Send a message below to start the conversation.',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                );
              }

              _markUnreadAsRead(messages);
              _scrollToBottom();

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(chatHistoryProvider(widget.contact.contactId).future),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId != widget.contact.contactId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.primary : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isMe ? 14 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 14),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (msg.priority == MessagePriority.high) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: isMe ? 0.3 : 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'HIGH PRIORITY',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.red,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            Text(
                              msg.body,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 13.5,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatMsgTime(msg.createdAt),
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : Colors.grey,
                                    fontSize: 9.5,
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    msg.status == MessageStatus.read ? Icons.done_all : Icons.done,
                                    size: 13,
                                    color: msg.status == MessageStatus.read ? Colors.lightBlueAccent : Colors.white70,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(apiErrorMessage(e), textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ),
        ),

        // Message Input Dock
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: _isSending ? Colors.grey : AppTheme.primary,
                child: IconButton(
                  icon: _isSending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _isSending ? null : _send,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMsgTime(String rawTime) {
    if (rawTime.isEmpty) return '';
    try {
      if (rawTime.contains('T')) {
        final dt = DateTime.parse(rawTime);
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
      }
      return rawTime;
    } catch (_) {
      return rawTime;
    }
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
              'Select a contact from the sidebar to view conversation history and exchange messages.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
