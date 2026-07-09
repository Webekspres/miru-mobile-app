import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/waste_category.dart';
import '../../providers/home_provider.dart';
import '../../providers/penjemputan_provider.dart';
import '../../widgets/loading_indicator.dart';

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
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoadingCategories = true;

  String get _formattedTime {
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void initState() {
    super.initState();
    _prefillAlamat();
    _loadCategories();
  }

  @override
  void dispose() {
    _beratController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _prefillAlamat() {
    final home = context.read<HomeProvider>();
    final user = home.user;
    if (user != null && user.alamat.isNotEmpty) {
      _alamatController.text = user.alamat;
    }
  }

  void _loadCategories() {
    final home = context.read<HomeProvider>();
    if (home.categories.isNotEmpty) {
      _isLoadingCategories = false;
      return;
    }
    // If categories not loaded yet, load them
    home.loadData().then((_) {
      if (mounted) setState(() => _isLoadingCategories = false);
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final minDate = now.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(minDate) ? minDate : _selectedDate,
      firstDate: minDate,
      lastDate: now.add(const Duration(days: 30)),
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
      setState(() => _selectedDate = picked);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final berat = double.tryParse(_beratController.text) ?? 0;
    if (berat < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total estimasi berat minimal 5 kg'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final penjemputan = context.read<PenjemputanProvider>();

    final jadwal = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final result = await penjemputan.createPickup(
      estimasiBerat: berat,
      alamatJemput: _alamatController.text.trim(),
      jadwal: jadwal,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penjemputan berhasil diajukan'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else if (penjemputan.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(penjemputan.error!),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Penjemputan'),
      ),
      body: Consumer2<HomeProvider, PenjemputanProvider>(
        builder: (context, home, penjemputan, _) {
          if (_isLoadingCategories && home.categories.isEmpty) {
            return const LoadingIndicator(message: 'Memuat data sampah...');
          }

          final categories = home.categories;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info Header ──
                  _buildInfoHeader(context),
                  const SizedBox(height: 20),

                  // ── Jenis Sampah (readonly info) ──
                  if (categories.isNotEmpty) ...[
                    Text(
                      'Jenis Sampah yang Dijemput',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...categories.map(
                      (cat) => _CategoryChip(category: cat),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sampah akan ditimbang dan dinilai oleh petugas saat penjemputan.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Estimasi Berat ──
                  Text(
                    'Estimasi Berat Total',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _beratController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  const SizedBox(height: 20),

                  // ── Alamat Penjemputan ──
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
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Jadwal Penjemputan ──
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
                          label: 'Waktu',
                          value: _formattedTime,
                          icon: Icons.access_time_rounded,
                          onTap: _selectTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minimal H+1 dari hari ini.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Submit Button ──
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

// ─────────────────────────────────────────────
// Category Chip (readonly display)
// ─────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final WasteCategory category;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.eco_outlined,
            size: 18,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.nama,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '${formatter.format(category.hargaBeliPerKgAsDouble)}/kg',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Date/Time Picker Tile
// ─────────────────────────────────────────────

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
