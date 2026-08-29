import 'dart:async';

import 'package:chaskiy/requests/chat.request.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderChatPage extends StatefulWidget {
  const OrderChatPage({required this.chatEntity, super.key});

  final ChatEntity chatEntity;

  @override
  State<OrderChatPage> createState() => _OrderChatPageState();
}

class _OrderChatPageState extends State<OrderChatPage> {
  final ChatRequest _request = ChatRequest();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<_OrderChatMessage> _messages = const [];
  Timer? _timer;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  String get _orderCode {
    final segments = widget.chatEntity.path.split('/');
    return segments.length > 1 ? segments[1] : '';
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _loadMessages(silent: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (_orderCode.isEmpty) return;
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final response = await _request
          .getMessages(_orderCode)
          .timeout(const Duration(seconds: 12));
      if (!response.allGood || response.body is! Map) {
        throw response.message ?? 'No pudimos cargar el chat'.tr();
      }
      final source = response.body['messages'];
      final messages =
          source is List
              ? source
                  .whereType<Map>()
                  .map((item) => _OrderChatMessage.fromJson(item))
                  .toList()
              : <_OrderChatMessage>[];
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _error = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (error) {
      if (!silent && mounted) setState(() => _error = error.toString());
    } finally {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final response = await _request
          .sendMessage(_orderCode, message)
          .timeout(const Duration(seconds: 12));
      if (!response.allGood) {
        throw response.message ?? 'No pudimos enviar el mensaje'.tr();
      }
      _controller.clear();
      await _loadMessages(silent: true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.chatEntity.mainUser.id;
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatEntity.title ?? 'Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? _ChatError(message: _error!, retry: _loadMessages)
                      : _messages.isEmpty
                      ? Center(child: Text('Aún no hay mensajes'.tr()))
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final mine = message.userId == currentUserId;
                          return Align(
                            alignment:
                                mine
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    mine
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color:
                                      mine
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                          : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_sending,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje…'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon:
                        _sending
                            ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatError extends StatelessWidget {
  const _ChatError({required this.message, required this.retry});

  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: retry, child: Text('Reintentar'.tr())),
          ],
        ),
      ),
    );
  }
}

class _OrderChatMessage {
  const _OrderChatMessage({required this.text, required this.userId});

  final String text;
  final String userId;

  factory _OrderChatMessage.fromJson(Map source) {
    return _OrderChatMessage(
      text: '${source['text'] ?? ''}',
      userId: '${source['user_id'] ?? ''}',
    );
  }
}
