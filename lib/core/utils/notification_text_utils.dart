import 'package:flutter/material.dart';

/// Utility functions for formatting notification text with RTL support and bold markdown.

/// Check if text contains Hebrew characters (Unicode U+0590 to U+05FF)
bool containsHebrew(String text) {
  return text.runes.any((rune) => rune >= 0x0590 && rune <= 0x05FF);
}

/// Check if notification should use RTL based on title or message content.
/// Uses unified detection - if either contains Hebrew, both use RTL.
bool notificationIsRTL(String title, String message) {
  return containsHebrew(title) || containsHebrew(message);
}

/// Parse text with **bold** markdown syntax and return list of TextSpans.
/// Handles unclosed markers by treating them as literal text.
List<TextSpan> parseBoldMarkdown(String text, TextStyle baseStyle) {
  final spans = <TextSpan>[];
  final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

  // Split by ** markers
  final parts = text.split('**');

  for (var i = 0; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;

    // Odd indices are bold (between ** markers)
    final isBold = i % 2 == 1;
    spans.add(TextSpan(
      text: parts[i],
      style: isBold ? boldStyle : baseStyle,
    ));
  }

  // Handle edge case: if odd number of **, last part should be normal
  // (unclosed bold marker treated as literal)
  if (parts.length % 2 == 0 && spans.isNotEmpty) {
    // Re-add the trailing ** that was stripped
    final lastSpan = spans.removeLast();
    spans.add(TextSpan(
      text: '**${lastSpan.text}',
      style: baseStyle,
    ));
  }

  return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
}

/// A widget that displays notification text with:
/// - Bold markdown support (**text** becomes bold)
/// - RTL text direction support
class NotificationText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool isRTL;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const NotificationText({
    super.key,
    required this.text,
    required this.style,
    required this.isRTL,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final direction = isRTL ? TextDirection.rtl : TextDirection.ltr;
    final spans = parseBoldMarkdown(text, style);

    return Text.rich(
      TextSpan(children: spans),
      textDirection: direction,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign ?? (isRTL ? TextAlign.right : TextAlign.start),
    );
  }
}
