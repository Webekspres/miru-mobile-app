import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/waste_category.dart';
import '../../providers/home_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/shimmer_loading.dart';

/// Static descriptions for common waste types based on category name.
/// Since backend only stores nama + harga, we provide static examples.
String _contohSampah(String nama) {
  final lower = nama.toLowerCase();
  if (lower.contains('plastik') || lower.contains('botol')) {
    return 'Botol plastik, gelas plastik, kantong plastik, ember';
  }
  if (lower.contains('kertas') || lower.contains('kardus') || lower.contains('buku') || lower.contains('koran')) {
    return 'Kardus, kertas HVS, koran, majalah, buku';
  }
  if (lower.contains('besi') || lower.contains('logam') || lower.contains('kaleng')) {
    return 'Kaleng minuman, besi tua, seng, pipa bekas';
  }
  if (lower.contains('kaca') || lower.contains('botol kaca')) {
    return 'Botol kaca, gelas kaca, kaca jendela';
  }
  if (lower.contains('kayu')) {
    return 'Kayu bekas, palet, ranting kering';
  }
  if (lower.contains('elektronik') || lower.contains('e-waste')) {
    return 'Kabel, PCB, HP bekas, charger rusak';
  }
  if (lower.contains('tekstil') || lower.contains('kain')) {
    return 'Pakaian bekas, kain perca, karung';
  }
  if (lower.contains('organik') || lower.contains('sisa')) {
    return 'Sisa makanan, daun kering, kulit buah';
  }
  if (lower.contains('aluminium')) {
    return 'Kaleng aluminium, foil, rangka aluminium';
  }
  return 'Berbagai jenis sampah yang telah dipilah';
}

/// Panduan pemilahan singkat berdasarkan kategori.
String _panduanPemilahan(String nama) {
  final lower = nama.toLowerCase();
  if (lower.contains('plastik') || lower.contains('botol')) {
    return 'Bersihkan dari sisa makanan/minuman. Pisahkan tutup botol. '
        'Pilah berdasarkan jenis: PET, HDPE, PP. '
        'Pastikan dalam kondisi kering saat disetor.';
  }
  if (lower.contains('kertas') || lower.contains('kardus') || lower.contains('buku') || lower.contains('koran')) {
    return 'Pisahkan dari sampah basah. Lipat kardus agar tidak memakan tempat. '
        'Kertas berminyak/sebaiknya tidak dicampur. '
        'Pastikan kertas dalam kondisi kering.';
  }
  if (lower.contains('besi') || lower.contains('logam') || lower.contains('kaleng')) {
    return 'Bersihkan kaleng dari sisa makanan. '
        'Pisahkan berdasarkan jenis logam (besi, aluminium, dll). '
        'Logam besar dapat dipotong agar mudah diangkut.';
  }
  if (lower.contains('kaca') || lower.contains('botol kaca')) {
    return 'Bersihkan dari sisa isi. Bungkus pecahan kaca dengan kertas '
        'untuk keamanan petugas. Pisahkan berdasarkan warna kaca.';
  }
  return 'Pastikan sampah dalam kondisi bersih dan kering. '
      'Pilah sesuai jenisnya untuk hasil optimal. '
      'Setoran minimal 1 kg per jenis sampah.';
}

/// Icon and color based on category name.
(Color bg, IconData icon) _categoryVisual(String nama) {
  final lower = nama.toLowerCase();
  if (lower.contains('plastik')) {
    return (const Color(0xFFFEF3C7), Icons.local_drink_outlined);
  }
  if (lower.contains('kertas') || lower.contains('kardus')) {
    return (const Color(0xFFDBEAFE), Icons.inventory_2_outlined);
  }
  if (lower.contains('besi') || lower.contains('logam') || lower.contains('kaleng')) {
    return (const Color(0xFFE0E7FF), Icons.handyman_outlined);
  }
  if (lower.contains('kaca')) {
    return (const Color(0xFFF3E8FF), Icons.wine_bar_outlined);
  }
  if (lower.contains('kayu')) {
    return (const Color(0xFFFEF3C7), Icons.park_outlined);
  }
  if (lower.contains('elektronik')) {
    return (const Color(0xFFFCE7F3), Icons.memory_outlined);
  }
  if (lower.contains('tekstil') || lower.contains('kain')) {
    return (const Color(0xFFFFF3E0), Icons.checkroom_outlined);
  }
  if (lower.contains('organik')) {
    return (const Color(0xFFDCFCE7), Icons.eco_outlined);
  }
  if (lower.contains('aluminium')) {
    return (const Color(0xFFF0FDF4), Icons.coffee_outlined);
  }
  return (const Color(0xFFF3F4F6), Icons.recycling_outlined);
}

class InfoSampahScreen extends StatefulWidget {
  const InfoSampahScreen({super.key});

  @override
  State<InfoSampahScreen> createState() => _InfoSampahScreenState();
}

class _InfoSampahScreenState extends State<InfoSampahScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final home = context.read<HomeProvider>();
    if (home.categories.isEmpty && !home.isLoading) {
      home.loadCategoriesOnly();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Sampah'),
        centerTitle: true,
      ),
      body: Consumer<HomeProvider>(
        builder: (context, home, _) {
          if (home.isLoading) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: const Column(
                children: [
                  SkeletonCard(height: 80),
                  SizedBox(height: 24),
                  _InfoSkeletonItem(),
                  _InfoSkeletonItem(),
                  _InfoSkeletonItem(),
                  _InfoSkeletonItem(),
                  _InfoSkeletonItem(),
                  _InfoSkeletonItem(),
                  _InfoSkeletonItem(),
                  _InfoSkeletonItem(),
                ],
              ),
            );
          }

          if (home.hasError && home.categories.isEmpty) {
            return ErrorView(
              title: 'Gagal memuat data',
              message: home.error!,
              onRetry: () => home.loadCategoriesOnly(),
            );
          }

          final categories = home.categories;

          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.recycling_outlined,
              title: 'Belum ada data sampah',
              description: 'Data kategori sampah belum tersedia. Silakan coba lagi nanti.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => home.loadCategoriesOnly(),
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Header Info ──
                      _buildInfoHeader(context),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),

                // ── Daftar Kategori (builder for performance) ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = categories[index];
                        return _CategoryCard(
                          category: cat,
                          onTap: () => _showDetailSheet(context, cat),
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),

                // ── Catatan ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  sliver: SliverToBoxAdapter(
                    child: _buildNotes(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            const Color(0xFFDCFCE7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: AppTheme.primaryColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harga Sampah Terkini',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap kategori untuk melihat panduan pemilahan.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: const Color(0xFF92400E),
              ),
              const SizedBox(width: 8),
              Text(
                'Catatan',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF92400E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Harga dapat berubah sewaktu-waktu sesuai ketetapan bank sampah.\n'
            '• Minimal setoran 1 kg per jenis sampah.\n'
            '• Sampah harus dalam kondisi bersih dan sudah dipilah.\n'
            '• Untuk informasi lebih lanjut, hubungi petugas bank sampah.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF78350F),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context, WasteCategory category) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final (bgColor, icon) = _categoryVisual(category.nama);
    final contoh = _contohSampah(category.nama);
    final panduan = _panduanPemilahan(category.nama);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category header
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 28, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.nama,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatter.format(category.hargaBeliPerKgAsDouble)} / kg',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contoh sampah
              _DetailSection(
                icon: Icons.inventory_2_outlined,
                title: 'Contoh Sampah',
                content: contoh,
              ),
              const SizedBox(height: 16),

              // Panduan pemilahan
              _DetailSection(
                icon: Icons.menu_book_outlined,
                title: 'Panduan Pemilahan',
                content: panduan,
              ),
              const SizedBox(height: 16),

              // Stok info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stok saat ini: ${NumberFormat.decimalPattern('id_ID').format(category.stokTerkiniKgAsDouble)} kg',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tutup button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Tutup'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Detail Section for Bottom Sheet
// ─────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Category Card
// ─────────────────────────────────────────────

class _InfoSkeletonItem extends StatelessWidget {
  const _InfoSkeletonItem();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: SkeletonCard(height: 76),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final WasteCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final (bgColor, icon) = _categoryVisual(category.nama);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.nama,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Min. 1 kg',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${formatter.format(category.hargaBeliPerKgAsDouble)}/kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${NumberFormat.decimalPattern('id_ID').format(category.stokTerkiniKgAsDouble)} kg',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
