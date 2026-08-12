import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/edukasi_provider.dart';
import '../../widgets/shimmer_loading.dart';
import 'edukasi_card.dart';

class EdukasiListScreen extends StatefulWidget {
  const EdukasiListScreen({super.key});

  @override
  State<EdukasiListScreen> createState() => _EdukasiListScreenState();
}

class _EdukasiListScreenState extends State<EdukasiListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EdukasiProvider>();
      if (provider.items.isEmpty && !provider.isLoading) {
        provider.loadEdukasi();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edukasi Sampah'),
      ),
      body: Consumer<EdukasiProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  SkeletonCard(height: 240),
                  SizedBox(height: 14),
                  SkeletonCard(height: 240),
                  SizedBox(height: 14),
                  SkeletonCard(height: 240),
                ],
              ),
            );
          }

          if (provider.hasError && provider.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat edukasi',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error ?? 'Terjadi kesalahan.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => provider.loadEdukasi(),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.items.isEmpty) {
            return Center(
              child: Text(
                'Belum ada artikel edukasi.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppTheme.primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: provider.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = provider.items[index];
                return EdukasiCard(
                  item: item,
                  onTap: () => context.push('/home/edukasi/${item.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
