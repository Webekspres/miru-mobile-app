import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/konten_edukasi.dart';
import '../../providers/edukasi_provider.dart';
import '../../widgets/markdown_document.dart';

class EdukasiDetailScreen extends StatefulWidget {
  const EdukasiDetailScreen({super.key, required this.edukasiId});

  final int edukasiId;

  @override
  State<EdukasiDetailScreen> createState() => _EdukasiDetailScreenState();
}

class _EdukasiDetailScreenState extends State<EdukasiDetailScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  Future<void> _ensureLoaded() async {
    final provider = context.read<EdukasiProvider>();
    if (provider.findById(widget.edukasiId) != null) return;
    setState(() => _loading = true);
    await provider.loadDetail(widget.edukasiId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = context.watch<EdukasiProvider>().findById(widget.edukasiId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edukasi Sampah'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : item == null
              ? _MissingArticle(onBack: () => Navigator.of(context).maybePop())
              : _ArticleBody(item: item, theme: theme),
    );
  }
}

class _MissingArticle extends StatelessWidget {
  const _MissingArticle({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 48, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Artikel tidak ditemukan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onBack, child: const Text('Kembali')),
          ],
        ),
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({required this.item, required this.theme});

  final KontenEdukasi item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.kategoriTerkaitNama != null &&
              item.kategoriTerkaitNama!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.kategoriTerkaitNama!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            item.judul,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateFormat.format(item.createdAt.toLocal()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (item.gambarUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: item.gambarUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          MarkdownDocument(data: item.isi),
        ],
      ),
    );
  }
}
