import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Renders an assistant reply with light formatting support so answers from the
/// AI orchestrator keep their structure instead of collapsing into one block.
///
/// Supported syntax (the subset the backend prompts actually emit):
/// * `- item`, `* item`, `• item` — bullet list
/// * `1. item`, `1) item` — numbered list
/// * `# Heading` … `###### Heading` — highlighted heading
/// * `**bold**`, `__bold__` — inline emphasis
///
/// Anything else is rendered verbatim, so malformed markdown never hides text.
class ChatMessageBody extends StatelessWidget {
  final String content;
  final TextStyle style;

  /// User turns are shown as typed; only assistant replies are parsed.
  final bool isUser;

  const ChatMessageBody({
    super.key,
    required this.content,
    required this.style,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Text(content, style: style);
    }

    final blocks = _parseBlocks(content);
    if (blocks.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    _ChatBlockKind? previousKind;

    for (final block in blocks) {
      if (children.isNotEmpty) {
        final tight =
            block.kind.isList &&
            previousKind != null &&
            previousKind.isList &&
            previousKind == block.kind;
        children.add(SizedBox(height: tight ? AppSpacing.xxs / 2 : 6));
      }
      children.add(_buildBlock(block));
      previousKind = block.kind;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildBlock(_ChatBlock block) {
    switch (block.kind) {
      case _ChatBlockKind.heading:
        return Text.rich(
          TextSpan(
            children: _inlineSpans(
              block.text,
              style.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: (style.fontSize ?? 12) + 1,
              ),
            ),
          ),
        );
      case _ChatBlockKind.bullet:
        return _ListItemRow(
          marker: const ExcludeSemantics(child: Text('•')),
          markerColor: AppColors.primary,
          text: block.text,
          style: style,
        );
      case _ChatBlockKind.numbered:
        return _ListItemRow(
          marker: Text(
            '${block.number}.',
            style: style.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          markerWidth: 18,
          text: block.text,
          style: style,
        );
      case _ChatBlockKind.paragraph:
        return Text.rich(TextSpan(children: _inlineSpans(block.text, style)));
    }
  }
}

class _ListItemRow extends StatelessWidget {
  final Widget marker;
  final Color? markerColor;
  final String text;
  final TextStyle style;
  final double markerWidth;

  const _ListItemRow({
    required this.marker,
    required this.text,
    required this.style,
    this.markerColor,
    this.markerWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: markerWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: DefaultTextStyle(
              style: style.copyWith(
                color: markerColor ?? AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              child: marker,
            ),
          ),
        ),
        Expanded(
          child: Text.rich(TextSpan(children: _inlineSpans(text, style))),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Parsing
// -----------------------------------------------------------------------------

enum _ChatBlockKind {
  paragraph,
  heading,
  bullet,
  numbered;

  bool get isList =>
      this == _ChatBlockKind.bullet || this == _ChatBlockKind.numbered;
}

class _ChatBlock {
  final _ChatBlockKind kind;
  final String text;
  final int? number;

  const _ChatBlock(this.kind, this.text, {this.number});
}

final RegExp _bulletPattern = RegExp(r'^\s*[-*•]\s+(.*)$');
final RegExp _numberedPattern = RegExp(r'^\s*(\d{1,2})[.)]\s+(.*)$');
final RegExp _headingPattern = RegExp(r'^\s*#{1,6}\s+(.*)$');
final RegExp _boldPattern = RegExp(r'\*\*(.+?)\*\*|__(.+?)__');

List<_ChatBlock> _parseBlocks(String raw) {
  final lines = raw.replaceAll('\r\n', '\n').split('\n');
  final blocks = <_ChatBlock>[];
  final paragraph = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    final text = paragraph.join('\n').trim();
    if (text.isNotEmpty) blocks.add(_ChatBlock(_ChatBlockKind.paragraph, text));
    paragraph.clear();
  }

  void addBlock(_ChatBlock block) {
    flushParagraph();
    blocks.add(block);
  }

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      flushParagraph();
      continue;
    }

    final heading = _headingPattern.firstMatch(line);
    if (heading != null) {
      addBlock(_ChatBlock(_ChatBlockKind.heading, heading.group(1)!.trim()));
      continue;
    }

    final bullet = _bulletPattern.firstMatch(line);
    if (bullet != null) {
      addBlock(_ChatBlock(_ChatBlockKind.bullet, bullet.group(1)!.trim()));
      continue;
    }

    final numbered = _numberedPattern.firstMatch(line);
    if (numbered != null) {
      addBlock(
        _ChatBlock(
          _ChatBlockKind.numbered,
          numbered.group(2)!.trim(),
          number: int.parse(numbered.group(1)!),
        ),
      );
      continue;
    }

    paragraph.add(trimmed);
  }
  flushParagraph();

  return blocks;
}

List<InlineSpan> _inlineSpans(String text, TextStyle base) {
  final highlight = base.copyWith(fontWeight: FontWeight.w700);
  final spans = <InlineSpan>[];
  var index = 0;

  for (final match in _boldPattern.allMatches(text)) {
    if (match.start > index) {
      spans.add(
        TextSpan(text: text.substring(index, match.start), style: base),
      );
    }
    final inner = match.group(1) ?? match.group(2) ?? '';
    spans.add(TextSpan(text: inner, style: highlight));
    index = match.end;
  }

  if (index < text.length) {
    spans.add(TextSpan(text: text.substring(index), style: base));
  }
  if (spans.isEmpty) {
    spans.add(TextSpan(text: text, style: base));
  }
  return spans;
}
