import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/waste_category.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/penjemputan_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/wit_datetime.dart';
import '../../widgets/complete_profile_dialog.dart';
import '../../widgets/login_prompt.dart';
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

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoadingCategories = true;
  bool _isFetchingLocation = false;
  WasteCategory? _selectedCategory;
  double? _latitude;
  double? _longitude;

  String get _formattedTime {
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void initState() {
    super.initState();
    final minJadwal = WitDateTime.now().add(const Duration(hours: 1));
    _selectedDate = WitDateTime.dateOnly(minJadwal);
    _selectedTime = TimeOfDay(hour: minJadwal.hour, minute: minJadwal.minute);
    _beratController.addListener(_onBeratChanged);
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!context.read<AuthSession>().isLoggedIn) return;
      context.read<SettingsProvider>().loadSettings(silent: true);
      final allowed = await guardTransactionRequiresAddress(context);
      if (!mounted || !allowed) return;
      await _prefillAlamat();
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
      user = context.read<ProfileProvider>().user ??
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

  NumberFormat get _rpFormat => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );

  double? get _estimasiNilai {
    final category = _selectedCategory;
    if (category == null) return null;
    final berat = double.tryParse(_beratController.text.trim());
    if (berat == null || berat <= 0) return null;
    return category.hargaBeliPerKgAsDouble * berat;
  }

  String? _validateJadwal() {
    final jadwal = WitDateTime.combine(_selectedDate, _selectedTime);
    final nowWit = WitDateTime.now();
    if (!jadwal.isAfter(nowWit)) {
      return 'Jadwal penjemputan tidak boleh di masa lalu.';
    }
    if (jadwal.isBefore(nowWit.add(const Duration(hours: 1)))) {
      return 'Jadwal penjemputan minimal 1 jam dari sekarang.';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final nowWit = WitDateTime.now();
    final firstDate = WitDateTime.dateOnly(nowWit);
    final lastDate = firstDate.add(const Duration(days: 30));
    var initial = WitDateTime.dateOnly(_selectedDate);
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = WitDateTime.dateOnly(picked));
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
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
                leading: Icon(
                  Icons.eco_outlined,
                  color: AppTheme.primaryColor,
                ),
                title: Text(cat.nama),
                subtitle: Text(
                  '${_rpFormat.format(cat.hargaBeliPerKgAsDouble)}/kg',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
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

  Future<void> _ambilLokasi() async {
    setState(() => _isFetchingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showMessage(
          'Layanan lokasi perangkat belum aktif. Aktifkan dulu, lalu coba lagi.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showMessage(
          'Izin lokasi diperlukan untuk menandai titik penjemputan.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showMessage(
          'Izin lokasi ditutup. Buka pengaturan aplikasi untuk mengizinkan lokasi.',
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Tidak dapat mengambil lokasi. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
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
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showMessage('Pilih jenis sampah terlebih dahulu.');
      return;
    }

    final jadwalError = _validateJadwal();
    if (jadwalError != null) {
      _showMessage(jadwalError);
      return;
    }

    final berat = double.tryParse(_beratController.text) ?? 0;
    if (berat < 5) {
      _showMessage('Total estimasi berat minimal 5 kg');
      return;
    }

    final jadwal = WitDateTime.combine(_selectedDate, _selectedTime);
    final penjemputan = context.read<PenjemputanProvider>();

    final result = await penjemputan.createPickup(
      estimasiBerat: berat,
      alamatJemput: _alamatController.text.trim(),
      jadwal: jadwal,
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
      _showMessage(penjemputan.error!);
    }
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
            'Pengajuan Anda sudah diterima. Petugas akan meninjau jadwal '
            'dan menghubungi Anda jika perlu penyesuaian.',
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
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
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
      appBar: AppBar(
        title: const Text('Ajukan Penjemputan'),
      ),
      body: Consumer3<HomeProvider, PenjemputanProvider, SettingsProvider>(
        builder: (context, home, penjemputan, settingsProv, _) {
          if (_isLoadingCategories && home.categories.isEmpty) {
            return const SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 60, 16, 24),
              child: ListSkeleton(itemCount: 4),
            );
          }

          final categories = home.categories;
          final settings = settingsProv.settings;
          final diLuarJam = settings?.isDiLuarJamKerja(_selectedTime) ?? false;
          final jamLabel = settings?.jamKerjaLabel ?? '';

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
                    'Jenis Sampah',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                  _LokasiPinCard(
                    latitude: _latitude,
                    longitude: _longitude,
                    isLoading: _isFetchingLocation,
                    onAmbilLokasi: _isFetchingLocation ? null : _ambilLokasi,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Jadwal Penjemputan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerTile(
                          label: 'Tanggal',
                          value: dateFormat.format(_selectedDate),
                          icon: Icons.calendar_month_outlined,
                          onTap: _selectDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerTile(
                          label: 'Waktu (WIT)',
                          value: _formattedTime,
                          icon: Icons.access_time_rounded,
                          onTap: _selectTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak boleh di masa lalu. Minimal 1 jam dari sekarang (waktu Papua).',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (diLuarJam) ...[
                    const SizedBox(height: 12),
                    _JamKerjaWarning(jamLabel: jamLabel),
                  ],
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
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
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
              'Petugas akan datang ke alamat Anda pada jadwal yang dipilih. '
              'Sampah akan ditimbang dan dicatat oleh petugas.',
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

class _LokasiPinCard extends StatelessWidget {
  const _LokasiPinCard({
    required this.latitude,
    required this.longitude,
    required this.isLoading,
    required this.onAmbilLokasi,
  });

  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final VoidCallback? onAmbilLokasi;

  bool get _hasPin => latitude != null && longitude != null;

  String get _osmUrl {
    final lat = latitude!.toStringAsFixed(6);
    final lng = longitude!.toStringAsFixed(6);
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$lat,$lng&zoom=16&size=600x240&markers=$lat,$lng,ol-marker';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_hasPin)
            SizedBox(
              height: 140,
              child: Image.network(
                _osmUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _PinFallback(
                  latitude: latitude!,
                  longitude: longitude!,
                ),
              ),
            )
          else
            const SizedBox(
              height: 88,
              child: _PinFallback.empty(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasPin)
                  Text(
                    '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    'Belum ada titik. Ambil lokasi perangkat atau pakai titik dari profil.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onAmbilLokasi,
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(
                      isLoading ? 'Mengambil lokasi…' : 'Ambil lokasi saya',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Titik ini hanya penanda lokasi, bukan pelacakan perjalanan.',
                  style: theme.textTheme.labelSmall?.copyWith(
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
}

class _PinFallback extends StatelessWidget {
  const _PinFallback({
    required this.latitude,
    required this.longitude,
  }) : empty = false;

  const _PinFallback.empty()
      : latitude = 0,
        longitude = 0,
        empty = true;

  final double latitude;
  final double longitude;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFECFDF5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              empty ? Icons.add_location_alt_outlined : Icons.location_on,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            if (!empty) ...[
              const SizedBox(height: 6),
              Text(
                '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryDark,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _JamKerjaWarning extends StatelessWidget {
  const _JamKerjaWarning({required this.jamLabel});

  final String jamLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jam = jamLabel.isEmpty ? 'jam kerja' : '$jamLabel WIT';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Text(
        'Jadwal di luar jam kerja ($jam). Pengajuan tetap bisa dikirim; '
        'petugas memproses pada jam kerja.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF92400E),
          height: 1.4,
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
