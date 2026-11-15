import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/calm_widgets.dart';
import '../../data/models/chat_message.dart';
import '../../providers/app_providers.dart';

/// "Tanya Si Cehat" — the 5th shell tab, pinned in the middle of the bar.
///
/// The whole conversation is in memory: every send re-posts the tail of the
/// thread, so opening the tab never fetches a previous session.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const List<String> _suggestions = [
    'Menu sarapan sehat itu apa?',
    'Berapa jam tidur yang ideal?',
    'Cara mengurangi minuman manis?',
    'Olahraga ringan apa yang bisa di rumah?',
  ];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submit(String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    _inputFocus.requestFocus();
    await ref.read(chatProvider).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);

    ref.listen<ChatProvider>(chatProvider, (previous, next) {
      final threadGrew =
          (previous?.messages.length ?? 0) != next.messages.length;
      final typingChanged = (previous?.isSending ?? false) != next.isSending;
      if (threadGrew || typingChanged) _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          AppHeader(
            compact: true,
            title: 'Tanya Si Cehat',
            actions: [
              if (chat.hasMessages)
                HeaderIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Mulai percakapan baru',
                  onPressed: () => ref.read(chatProvider).clearConversation(),
                ),
            ],
          ),
          Expanded(
            child: chat.isEmpty
                ? _EmptyState(suggestions: _suggestions, onSelected: _submit)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageGutter,
                      AppSpacing.md,
                      AppSpacing.pageGutter,
                      AppSpacing.md,
                    ),
                    itemCount: chat.messages.length + (chat.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= chat.messages.length) {
                        return const _TypingBubble();
                      }
                      return _MessageBubble(message: chat.messages[index]);
                    },
                  ),
          ),
          if (chat.error != null)
            _ErrorBanner(
              message: chat.error!,
              onDismiss: () => ref.read(chatProvider).clearError(),
            ),
          _Composer(
            controller: _inputController,
            focusNode: _inputFocus,
            isSending: chat.isSending,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final radius = Radius.circular(AppRadius.md);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs + 2,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: isUser ? radius : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : radius,
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          message.content,
          style: AppTypography.body.copyWith(
            color: isUser ? AppColors.onPrimary : AppColors.text,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Semantics(
          liveRegion: true,
          label: 'Si Cehat sedang mengetik',
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.more_horiz_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'Si Cehat sedang mengetik…',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const _EmptyState({required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageGutter,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Halo! Aku Si Cehat', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tanya seputar makan, minum, aktivitas, tidur, dan kebiasaan '
              'sehat harian. Aku bukan dokter, ya.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final suggestion in suggestions)
                  _SuggestionChip(
                    label: suggestion,
                    onTap: () => onSelected(suggestion),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.button,
      child: InkWell(
        borderRadius: AppRadius.button,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.button,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.dangerText,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.dangerText,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            iconSize: 16,
            color: AppColors.dangerText,
            tooltip: 'Tutup pesan',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final ValueChanged<String> onSubmit;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: ChatProvider.maxMessageLength,
                  textInputAction: TextInputAction.send,
                  onSubmitted: onSubmit,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Tulis pertanyaan…',
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textPlaceholder,
                    ),
                    counterText: '',
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final canSend = value.text.trim().isNotEmpty && !isSending;
                  return _SendButton(
                    enabled: canSend,
                    onPressed: () => onSubmit(controller.text),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _SendButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Kirim pesan',
      excludeSemantics: true,
      child: Material(
        color: enabled ? AppColors.primary : AppColors.chipNeutralBg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: AppSizes.minTouchTarget,
            height: AppSizes.minTouchTarget,
            child: Icon(
              Icons.send_rounded,
              size: 20,
              color: enabled ? AppColors.onPrimary : AppColors.textPlaceholder,
            ),
          ),
        ),
      ),
    );
  }
}
