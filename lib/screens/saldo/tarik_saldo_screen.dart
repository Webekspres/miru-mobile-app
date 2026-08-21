import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/saldo_provider.dart';
import '../../widgets/complete_profile_dialog.dart';
import '../../widgets/login_prompt.dart';

class TarikSaldoScreen extends StatefulWidget {
  const TarikSaldoScreen({super.key});

  @override
  State<TarikSaldoScreen> createState() => _TarikSaldoScreenState();
}

class _TarikSaldoScreenState extends State<TarikSaldoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _nominalFocus = FocusNode();
  bool _hasInteracted = false;
  String? _serverNominalError;
  File? _ktpFile;
  String? _ktpError;

  // Validation state
  String? _validationMessage;
  bool _isValid = false;
  Color _validationColor = Colors.transparent;

  static const double _minWithdrawal = 50000;
  static const double _besarNominal = 1000000;
  static const List<double> _quickAmounts = [
    50000,
    100000,
    150000,
    200000,
  ];

  @override
  void initState() {
    super.initState();
    _nominalController.addListener(_onNominalChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!context.read<AuthSession>().isLoggedIn) return;
      guardTransactionRequiresAddress(context);
    });
  }

  @override
  void dispose() {
    _nominalController.removeListener(_onNominalChanged);
    _nominalController.dispose();
    _nominalFocus.dispose();
    super.dispose();
  }

  double? _parsedNominal() {
    final raw =
        _nominalController.text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(raw);
  }

  bool get _needsKtp {
    final n = _parsedNominal();
    return n != null && n >= _besarNominal;
  }

  Future<void> _pickKtp() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _ktpFile = File(picked.path);
      _ktpError = null;
    });
  }

  // ─────────────────────────────────────────────
  // Real-time Input Formatting & Validation
  // ─────────────────────────────────────────────

  void _onNominalChanged() {
    if (_serverNominalError != null) {
      _serverNominalError = null;
      context.read<SaldoProvider>().clearSubmitError();
    }

    final text = _nominalController.text;
    if (text.isEmpty) {
      setState(() {
        _hasInteracted = false;
        _validationMessage = null;
        _isValid = false;
        _validationColor = Colors.transparent;
      });
      return;
    }

    setState(() => _hasInteracted = true);

    // Parse raw value (remove dots)
    final rawValue = text.replaceAll('.', '');
    final nominal = int.tryParse(rawValue);

    if (nominal == null || nominal <= 0) {
      setState(() {
        _validationMessage = 'Masukkan nominal yang valid';
        _isValid = false;
        _validationColor = AppTheme.errorColor;
      });
      return;
    }

    // Format with dots (e.g., 50000 → 50.000)
    final formatted = NumberFormat.decimalPattern('id_ID').format(nominal);
    if (text != formatted) {
      _nominalController.text = formatted;
      _nominalController.selection = TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      );
    }

    // Validate
    final saldo = _getSaldo();

    if (nominal < _minWithdrawal) {
      setState(() {
        _validationMessage =
            'Minimal penarikan Rp${NumberFormat.decimalPattern('id_ID').format(_minWithdrawal)}';
        _isValid = false;
        _validationColor = AppTheme.errorColor;
      });
      return;
    }

    if (nominal > saldo) {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      setState(() {
        _validationMessage =
            'Nominal melebihi saldo (${formatter.format(saldo)})';
        _isValid = false;
        _validationColor = AppTheme.errorColor;
      });
      return;
    }

    setState(() {
      _validationMessage = null;
      _isValid = true;
      _validationColor = AppTheme.primaryColor;
    });
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  double _getSaldo() {
    return context.read<HomeProvider>().saldo;
  }

  String _formatRupiah(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  // ─────────────────────────────────────────────
  // Quick Amount Buttons
  // ─────────────────────────────────────────────

  void _setQuickAmount(double amount) {
    _nominalController.text =
        NumberFormat.decimalPattern('id_ID').format(amount.toInt());
    _nominalFocus.unfocus();
    setState(() => _hasInteracted = true);
    _onNominalChanged();
  }

  String? _extractFieldError(dynamic error) {
    if (error == null) return null;
    if (error is List && error.isNotEmpty) return error.first.toString();
    if (error is String && error.trim().isNotEmpty) return error;
    return null;
  }

  // ─────────────────────────────────────────────
  // Submit Flow
  // ─────────────────────────────────────────────

  Future<void> _showConfirmationDialog({
    required double nominal,
    required String metode,
  }) async {
    _nominalFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Konfirmasi Penarikan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _ConfirmationRow(
                label: 'Nominal',
                value: _formatRupiah(nominal),
                valueColor: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 12),
              _ConfirmationRow(
                label: 'Metode',
                value: metode == 'tunai' ? 'Tunai' : metode,
                valueColor: null,
              ),
              const SizedBox(height: 16),
              // Warning banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Penarikan akan diproses dalam 1–2 hari kerja. '
                        'Saldo akan terpotong setelah pengajuan disetujui oleh admin.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ya, Ajukan'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _submitWithdrawal(nominal: nominal, metode: metode);
    }
  }

  Future<void> _submitWithdrawal({
    required double nominal,
    required String metode,
  }) async {
    final saldo = context.read<SaldoProvider>();
    final result = await saldo.createWithdrawal(
      nominal: nominal,
      metode: metode,
      lampiranKtp: nominal >= _besarNominal ? _ktpFile : null,
    );

    if (!mounted) return;

    if (result != null) {
      _nominalFocus.unfocus();
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Penarikan diproses'),
            content: Text(
              'Pengajuan penarikan Anda sudah kami terima. '
              'Pencairan dilakukan dalam 1–2 hari kerja.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mengerti'),
              ),
            ],
          );
        },
      );
      if (mounted) context.pop();
      return;
    }

    final nominalError = _extractFieldError(saldo.submitFieldErrors?['nominal']);
    if (nominalError != null) {
      setState(() {
        _serverNominalError = nominalError;
        _hasInteracted = true;
        _isValid = false;
        _validationMessage = nominalError;
        _validationColor = AppTheme.errorColor;
      });
      _formKey.currentState?.validate();
      return;
    }

    if (saldo.hasSubmitError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saldo.submitError!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final rawValue =
        _nominalController.text.replaceAll('.', '').replaceAll(',', '.');
    final nominal = double.tryParse(rawValue) ?? 0;
    final saldo = _getSaldo();

    if (nominal < _minWithdrawal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Minimal penarikan adalah Rp${NumberFormat.decimalPattern('id_ID').format(_minWithdrawal.toInt())}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (nominal > saldo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal tidak boleh melebihi saldo Anda'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (nominal >= _besarNominal && _ktpFile == null) {
      setState(() {
        _ktpError =
            'Penarikan Rp1.000.000 atau lebih wajib foto KTP. File dihapus setelah petugas memproses.';
      });
      return;
    }

    _showConfirmationDialog(
      nominal: nominal,
      metode: 'tunai',
    );
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tarik Saldo')),
        body: const LoginPrompt(
          title: 'Tarik Saldo',
          message: 'Masuk untuk mengajukan penarikan saldo Anda.',
        ),
      );
    }

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarik Saldo'),
      ),
      body: Consumer2<HomeProvider, SaldoProvider>(
        builder: (context, home, saldo, _) {
          final currentSaldo = home.saldo;

          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Saldo Card ──
                  _SaldoDisplayCard(
                    saldo: currentSaldo,
                    formatter: formatter,
                    theme: theme,
                  ),
                  const SizedBox(height: 24),

                  // ── Nominal Input ──
                  Text(
                    'Nominal Penarikan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nominalController,
                    focusNode: _nominalFocus,
                    keyboardType: TextInputType.number,
                    onTapOutside: (_) => _nominalFocus.unfocus(),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _nominalController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _nominalController.clear();
                                setState(() => _hasInteracted = false);
                              },
                            )
                          : null,
                    ),
                    validator: (v) {
                      if (_serverNominalError != null) return _serverNominalError;
                      if (v == null || v.trim().isEmpty) {
                        return 'Nominal penarikan wajib diisi';
                      }
                      final rawValue =
                          v.replaceAll('.', '').replaceAll(',', '.');
                      final nominal = double.tryParse(rawValue);
                      if (nominal == null || nominal <= 0) {
                        return 'Masukkan nominal yang valid';
                      }
                      if (nominal < _minWithdrawal) {
                        return 'Minimal penarikan Rp${NumberFormat.decimalPattern('id_ID').format(_minWithdrawal.toInt())}';
                      }
                      if (nominal > currentSaldo) {
                        return 'Nominal melebihi saldo Anda (${formatter.format(currentSaldo)})';
                      }
                      return null;
                    },
                  ),

                  // ── Real-time validation message ──
                  if (_hasInteracted && _validationMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: _validationColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _validationMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _validationColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_hasInteracted && _isValid && _validationMessage == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: _validationColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Nominal valid',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _validationColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 4),
                  Text(
                    'Minimal Rp${NumberFormat.decimalPattern('id_ID').format(_minWithdrawal.toInt())}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Quick Amount Buttons ──
                  _buildQuickAmountChips(theme, currentSaldo),

                  const SizedBox(height: 20),

                  // ── Metode ──
                  Text(
                    'Metode Penarikan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MetodeSelector(theme: theme),
                  const SizedBox(height: 20),

                  if (_needsKtp) ...[
                    Text(
                      'Foto KTP (sementara)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickKtp,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: Text(
                        _ktpFile == null
                            ? 'Ambil foto KTP'
                            : 'Foto KTP terpilih — ganti',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hanya untuk verifikasi pencairan ini. Tidak disimpan di profil dan dihapus setelah diproses.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    if (_ktpError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _ktpError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],

                  // ── SLA Info ──
                  _SlaInfoBanner(theme: theme),
                  const SizedBox(height: 28),

                  // ── Submit Button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!_hasInteracted || !_isValid)
                          ? null
                          : (saldo.isSubmitting ? null : _onSubmit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: saldo.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Ajukan Penarikan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAmountChips(ThemeData theme, double saldo) {
    // Filter quick amounts based on saldo
    final availableAmounts =
        _quickAmounts.where((a) => a <= saldo).toList();

    if (availableAmounts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih nominal cepat',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableAmounts.map((amount) {
            final label = _formatRupiah(amount);
            return ActionChip(
              label: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _setQuickAmount(amount),
              backgroundColor: const Color(0xFFDBEAFE),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Saldo Display Card
// ─────────────────────────────────────────────

class _SaldoDisplayCard extends StatelessWidget {
  const _SaldoDisplayCard({
    required this.saldo,
    required this.formatter,
    required this.theme,
  });

  final double saldo;
  final NumberFormat formatter;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Saldo Anda',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatter.format(saldo),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saldo tersedia untuk ditarik',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Metode Selector (Tunai — default, read-only)
// ─────────────────────────────────────────────

class _MetodeSelector extends StatelessWidget {
  const _MetodeSelector({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.monetization_on_outlined,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tunai',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ambil langsung di kantor',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.primaryColor,
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SLA Info Banner
// ─────────────────────────────────────────────

class _SlaInfoBanner extends StatelessWidget {
  const _SlaInfoBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFF0369A1),
              ),
              const SizedBox(width: 8),
              Text(
                'Informasi Penarikan',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0369A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoBullet(theme, 'Penarikan diproses dalam 1–2 hari kerja'),
          const SizedBox(height: 6),
          _infoBullet(theme, 'Pengambilan tunai di kantor MIRU Bank Sampah'),
          const SizedBox(height: 6),
          _infoBullet(theme, 'Tidak ada biaya administrasi untuk penarikan'),
          const SizedBox(height: 6),
          _infoBullet(
            theme,
            'Saldo akan terpotong setelah pengajuan disetujui admin',
          ),
        ],
      ),
    );
  }

  Widget _infoBullet(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(Icons.circle, size: 5, color: Color(0xFF0369A1)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF0C4A6E),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Confirmation Row
// ─────────────────────────────────────────────

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
