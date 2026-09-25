import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/jadwal_jemput.dart';
import '../../models/waste_category.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/penjemputan_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/wilayah_provider.dart';
import '../../widgets/complete_profile_dialog.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/peta_pin_picker.dart';
import '../../widgets/shimmer_loading.dart';

class AjukanPenjemputanScreen extends StatefulWidget {
  const AjukanPenjemputanScreen({super.key});

  @override
  State<AjukanPenjemputanScreen> createState() =>
      _AjukanPenjemputanScreenState();
}

class _AjukanPenjemputanScreenState extends State<AjukanPenjemputanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _beratController = TextEditingController();
  final _alamatController = TextEditingController();

  int? _selectedJadwalId;
  bool _isLoadingCategories = true;
  WasteCategory? _selectedCategory;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _beratController.addListener(_onBeratChanged);
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!context.read<AuthSession>().isLoggedIn) return;
      final allowed = await guardTransactionRequiresAddress(context);
      if (!mounted || !allowed) return;
      context.read<WilayahProvider>().load();
      await _prefillAlamat();
      if (!mounted) return;
      await context.read<PenjemputanProvider>().loadJadwal();
    });
  }

  void _onBeratChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _beratController.removeListener(_onBeratChanged);
    _beratController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _prefillAlamat() async {
    var user = context.read<ProfileProvider>().user;
    if (user == null || !user.hasCompleteAddress) {
      user = context.read<HomeProvider>().user;
    }
    if (user == null) {
      await context.read<HomeProvider>().loadData();
      if (!mounted) return;
      user =
          context.read<ProfileProvider>().user ??
          context.read<HomeProvider>().user;
    }
    if (user == null) return;

    final text = user.formattedPickupAddress;
    if (text.isNotEmpty && _alamatController.text.trim().isEmpty) {
      _alamatController.text = text;
    }

    if (_latitude == null &&
        _longitude == null &&
        user.latitude != null &&
        user.longitude != null) {
      setState(() {
        _latitude = user!.latitude;
        _longitude = user.longitude;
      });
    }
  }

  void _loadCategories() {
    final home = context.read<HomeProvider>();
    if (home.categories.isNotEmpty) {
      _isLoadingCategories = false;
      return;
    }
    home.loadData().then((_) {
      if (mounted) setState(() => _isLoadingCategories = false);
    });
  }

  NumberFormat get _rpFormat =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  double? get _estimasiNilai {
    final category = _selectedCategory;
    if (category == null) return null;
    final berat = double.tryParse(_beratController.text.trim());
    if (berat == null || berat <= 0) return null;
    return category.hargaBeliPerKgAsDouble * berat;
  }

  Future<void> _openCategoryPicker(List<WasteCategory> categories) async {
    if (categories.isEmpty) return;

    final picked = await showModalBottomSheet<WasteCategory>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final selected = _selectedCategory?.id == cat.id;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected
                        ? AppTheme.primaryColor
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                leading: Icon(Icons.eco_outlined, color: AppTheme.primaryColor),
                title: Text(cat.nama),
                subtitle: Text(
                  '${_rpFormat.format(cat.hargaBeliPerKgAsDouble)}/kg',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: selected
                    ? const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                      )
                    : null,
                onTap: () => Navigator.of(ctx).pop(cat),
              );
            },
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedCategory = picked);
    }
  }

  Future<void> _lengkapiKelurahan() async {
    final user =
        context.read<ProfileProvider>().user ??
        context.read<HomeProvider>().user;
    if (user == null) return;
    await context.push<void>('/profile/edit', extra: user);
    if (!mounted) return;
    await context.read<PenjemputanProvider>().loadJadwal();
  }

  void _showMessage(String text, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? AppTheme.errorColor : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    final penjemputan = context.read<PenjemputanProvider>();
    if (penjemputan.isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showMessage('Pilih jenis sampah terlebih dahulu.');
      return;
    }

    final jadwalId = _selectedJadwalId;
    if (jadwalId == null) {
      _showMessage('Pilih jadwal penjemputan terlebih dahulu.');
      return;
    }

    final berat = double.tryParse(_beratController.text) ?? 0;
    if (berat < 5) {
      _showMessage('Total estimasi berat minimal 5 kg');
      return;
    }

    final result = await penjemputan.createPickup(
      estimasiBerat: berat,
      alamatJemput: _alamatController.text.trim(),
      jadwalWilayahId: jadwalId,
      latitude: _latitude,
      longitude: _longitude,
    );

    if (!mounted) return;

    if (result != null) {
      await context.read<HomeProvider>().refresh();
      if (!mounted) return;
      await _showSuccessDialog();
      if (!mounted) return;
      context.pop();
    } else if (penjemputan.hasError) {
      if (penjemputan.submitRejectedByRule) {
        await _showRejectedDialog(penjemputan.error!);
        if (!mounted) return;
        setState(() => _selectedJadwalId = null);
        await penjemputan.loadJadwal();
      } else {
        _showMessage(penjemputan.error!);
      }
    }
  }

  /// Jadwal sudah ditutup (H-1), sudah dipesan, atau wilayah belum dilayani —
  /// pesan panjang dari server, tampilkan di dialog agar tidak hilang.
  Future<void> _showRejectedDialog(String message) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.event_busy_rounded,
          color: AppTheme.errorColor,
          size: 36,
        ),
        title: const Text('Penjemputan belum bisa diajukan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog() {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primaryColor,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Penjemputan diajukan',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            'Pengajuan Anda sudah diterima. Admin akan menugaskan petugas '
            'untuk datang pada jadwal yang Anda pilih.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Baik'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ajukan Penjemputan')),
        body: const LoginPrompt(
          title: 'Ajukan Penjemputan',
          message: 'Masuk untuk mengajukan penjemputan sampah ke alamat Anda.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Penjemputan')),
      body: Consumer2<HomeProvider, PenjemputanProvider>(
        builder: (context, home, penjemputan, _) {
          final categories = home.categories;
          final loadingCategories = _isLoadingCategories && categories.isEmpty;
          final user = context.watch<ProfileProvider>().user ?? home.user;
          final hasKelurahan = user?.kelurahanId != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoHeader(context),
                  const SizedBox(height: 20),

                  Text(
                    'Pilih Jadwal Penjemputan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _JadwalSection(
                    penjemputan: penjemputan,
                    hasKelurahan: hasKelurahan,
                    selectedId: _selectedJadwalId,
                    onSelect: (id) => setState(() => _selectedJadwalId = id),
                    onLengkapiProfil: _lengkapiKelurahan,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Jenis Sampah',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (loadingCategories)
                    const SkeletonCard(height: 56)
                  else
                    _CategoryPickerTile(
                      category: _selectedCategory,
                      rpFormat: _rpFormat,
                      onTap: () => _openCategoryPicker(categories),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih satu jenis. Nilai akhir mengikuti timbangan petugas.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Estimasi Berat Total',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _beratController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 10',
                      suffixText: 'kg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Estimasi berat wajib diisi';
                      }
                      final berat = double.tryParse(v);
                      if (berat == null || berat <= 0) {
                        return 'Masukkan angka yang valid';
                      }
                      if (berat < 5) {
                        return 'Minimal 5 kg';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Minimal 5 kg total untuk satu kali penjemputan.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_estimasiNilai != null) ...[
                    const SizedBox(height: 12),
                    _EstimasiNilaiCard(
                      nilai: _estimasiNilai!,
                      kategoriNama: _selectedCategory!.nama,
                      rpFormat: _rpFormat,
                    ),
                  ],
                  const SizedBox(height: 20),

                  Text(
                    'Alamat Penjemputan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _alamatController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Masukkan alamat lengkap',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Alamat wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Titik Penjemputan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PetaPinPicker(
                    cakupan: context.watch<WilayahProvider>().cakupan,
                    latitude: _latitude,
                    longitude: _longitude,
                    onChanged: (lat, lng) => setState(() {
                      _latitude = lat;
                      _longitude = lng;
                    }),
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: penjemputan.isSubmitting ? null : _submit,
                      child: penjemputan.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Ajukan Penjemputan'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppTheme.primaryDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Penjemputan dilakukan pada hari jemput wilayah Anda yang '
              'ditetapkan admin (maks. 2 hari per minggu). Pesan paling lambat '
              'H-1. Sampah ditimbang dan dicatat oleh petugas.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPickerTile extends StatelessWidget {
  const _CategoryPickerTile({
    required this.category,
    required this.rpFormat,
    required this.onTap,
  });

  final WasteCategory? category;
  final NumberFormat rpFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = category != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryColor.withValues(alpha: 0.5)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.eco : Icons.eco_outlined,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: selected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category!.nama,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${rpFormat.format(category!.hargaBeliPerKgAsDouble)}/kg',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Pilih jenis sampah',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstimasiNilaiCard extends StatelessWidget {
  const _EstimasiNilaiCard({
    required this.nilai,
    required this.kategoriNama,
    required this.rpFormat,
  });

  final double nilai;
  final String kategoriNama;
  final NumberFormat rpFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perkiraan nilai',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rpFormat.format(nilai),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              'Harga $kategoriNama × berat',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JadwalSection extends StatelessWidget {
  const _JadwalSection({
    required this.penjemputan,
    required this.hasKelurahan,
    required this.selectedId,
    required this.onSelect,
    required this.onLengkapiProfil,
  });

  final PenjemputanProvider penjemputan;
  final bool hasKelurahan;
  final int? selectedId;
  final ValueChanged<int> onSelect;
  final VoidCallback onLengkapiProfil;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!hasKelurahan) {
      return _JadwalInfoBox(
        icon: Icons.location_city_outlined,
        message:
            'Lengkapi kelurahan/kampung di profil Anda untuk melihat '
            'jadwal penjemputan di wilayah Anda.',
        actionLabel: 'Lengkapi Profil',
        onAction: onLengkapiProfil,
      );
    }
    if (penjemputan.isLoadingJadwal && penjemputan.jadwal.isEmpty) {
      return const Column(
        children: [
          SkeletonCard(height: 64),
          SizedBox(height: 8),
          SkeletonCard(height: 64),
        ],
      );
    }
    if (penjemputan.jadwalError != null && penjemputan.jadwal.isEmpty) {
      return _JadwalInfoBox(
        icon: Icons.wifi_off_rounded,
        message: penjemputan.jadwalError!,
        actionLabel: 'Coba Lagi',
        onAction: penjemputan.loadJadwal,
      );
    }
    if (penjemputan.jadwal.isEmpty) {
      return const _JadwalInfoBox(
        icon: Icons.event_busy_outlined,
        message:
            'Belum ada jadwal penjemputan untuk wilayah Anda. '
            'Kami akan memberi tahu lewat notifikasi saat jadwal tersedia.',
      );
    }

    return Column(
      children: [
        for (final j in penjemputan.jadwal) ...[
          _JadwalTile(
            jadwal: j,
            selected: j.id == selectedId,
            onTap: () => onSelect(j.id),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          'Pemesanan ditutup H-1 sebelum tanggal jemput.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _JadwalTile extends StatelessWidget {
  const _JadwalTile({
    required this.jadwal,
    required this.selected,
    required this.onTap,
  });

  final JadwalJemput jadwal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? AppTheme.primaryColor.withValues(alpha: 0.08)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryColor
                  : theme.colorScheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? AppTheme.primaryColor
                    : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jadwal.tanggalLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${jadwal.jamLabel} · ${jadwal.wilayahNama}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (jadwal.catatan.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        jadwal.catatan,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JadwalInfoBox extends StatelessWidget {
  const _JadwalInfoBox({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF92400E)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
          ],
        ],
      ),
    );
  }
}
