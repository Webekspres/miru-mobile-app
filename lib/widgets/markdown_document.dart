import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MarkdownDocument extends StatelessWidget {
  const MarkdownDocument({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = data.trim();
    if (body.isEmpty) {
      return Text(
        'Konten belum tersedia.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return MarkdownBody(
      data: body,
      selectable: true,
      imageBuilder: (uri, title, alt) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: uri.toString(),
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          ),
        );
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: theme.textTheme.bodyMedium?.copyWith(
          height: 1.55,
          color: theme.colorScheme.onSurface,
        ),
        h1: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        blockquoteDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
