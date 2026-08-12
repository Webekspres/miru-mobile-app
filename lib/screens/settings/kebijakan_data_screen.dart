import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../widgets/markdown_document.dart';

class KebijakanDataScreen extends StatefulWidget {
  const KebijakanDataScreen({super.key});

  @override
  State<KebijakanDataScreen> createState() => _KebijakanDataScreenState();
}

class _KebijakanDataScreenState extends State<KebijakanDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kebijakan Data')),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.settings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.hasError && provider.settings == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(provider.error ?? 'Gagal memuat kebijakan data.'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MarkdownDocument(data: provider.settings?.kebijakan ?? ''),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
