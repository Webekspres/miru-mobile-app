import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/markdown_document.dart';
import '../../widgets/miru_logo.dart';
import '../../widgets/shimmer_loading.dart';

class TentangScreen extends StatefulWidget {
  const TentangScreen({super.key});

  @override
  State<TentangScreen> createState() => _TentangScreenState();
}

class _TentangScreenState extends State<TentangScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Tentang ${AppConstants.appName}')),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          final settings = provider.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(child: MiruLogo(variant: MiruLogoVariant.fullBg, height: 80)),
              const SizedBox(height: 16),
              Text(
                settings?.namaInstitusi ?? 'MIRU Bank Sampah',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (provider.isLoading && settings == null)
                const Column(
                  children: [
                    SkeletonBlock(height: 14),
                    SizedBox(height: 10),
                    SkeletonBlock(height: 14),
                    SizedBox(height: 10),
                    SkeletonBlock(height: 14, width: 240),
                  ],
                )
              else
                MarkdownDocument(data: settings?.tentang ?? ''),
              const SizedBox(height: 24),
              if (settings != null) ...[
                Text(
                  '${settings.alamat}\n${settings.jamOperasional}\n${settings.kontak} · ${settings.email}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ],
          );
        },
      ),
    );
  }
}
