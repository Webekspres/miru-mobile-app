import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/api_exception.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

/// Ganti email akun: email baru (+ kata sandi bila email lama sudah
/// terverifikasi) → kode OTP dikirim ke email baru → email tersimpan.
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpStep = false;
  bool _busy = false;
  bool _obscure = true;
  String? _maskedEmail;
  String? _devOtp;
  String? _emailError;
  String? _passwordError;
  String? _otpError;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  String get _currentEmail =>
      context.read<AuthProvider>().user?.email ??
      context.read<ProfileProvider>().user?.email ??
      '';

  bool get _currentVerified =>
      context.read<AuthProvider>().user?.emailVerified ??
      context.read<ProfileProvider>().user?.emailVerified ??
      false;

  /// Kata sandi hanya wajib saat mengganti email yang sudah terverifikasi.
  bool get _needsPassword =>
      _currentVerified &&
      _emailController.text.trim().toLowerCase() !=
          _currentEmail.trim().toLowerCase();

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _resendSeconds -= 1);
      if (_resendSeconds <= 0) timer.cancel();
    });
  }

  String? _first(dynamic v) =>
      v is List && v.isNotEmpty ? v.first.toString() : (v is String ? v : null);

  void _showSnack(String text, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? AppTheme.errorColor : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendOtp({bool resend = false}) async {
    if (!resend && !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _emailError = _passwordError = null;
    });
    try {
      final data = await context.read<AuthProvider>().requestEmailOtp(
            email: _emailController.text.trim(),
            password: _needsPassword ? _passwordController.text : null,
          );
      if (!mounted) return;
      if (data['email_verified'] == true) {
        // Mode testing: backend langsung memverifikasi.
        await _finish();
        return;
      }
      setState(() {
        _otpStep = true;
        _maskedEmail = data['masked_email'] as String?;
        _devOtp = data['dev_otp'] as String?;
        _otpController.clear();
      });
      _startCooldown();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = _first(e.fieldErrors?['email']);
        _passwordError = _first(e.fieldErrors?['password']);
      });
      _showSnack(e.message);
    } catch (_) {
      if (mounted) _showSnack(kGenericErrorMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_otpController.text.trim().length != 6) {
      setState(() => _otpError = 'Masukkan 6 digit kode');
      return;
    }
    setState(() {
      _busy = true;
      _otpError = null;
    });
    try {
      await context.read<AuthProvider>().verifyEmailOtp(
            otp: _otpController.text.trim(),
          );
      if (!mounted) return;
      await _finish();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _otpError = _first(e.fieldErrors?['otp']) ?? e.message);
    } catch (_) {
      if (mounted) _showSnack(kGenericErrorMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finish() async {
    await context.read<ProfileProvider>().loadProfile();
    if (!mounted) return;
    _showSnack('Email berhasil diperbarui.', error: false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _currentEmail;

    return Scaffold(
      appBar: AppBar(title: const Text('Email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            // Error hilang begitu isian diperbaiki (bukan menunggu tombol ditekan).
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  current.isEmpty
                      ? 'Belum ada email. Email dipakai untuk kode OTP saat lupa kata sandi.'
                      : 'Email saat ini: $current',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                if (!_otpStep) ...[
                  TextFormField(
                    controller: _emailController,
                    enabled: !_busy,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: 'Email baru',
                      prefixIcon: const Icon(Icons.email_outlined),
                      errorText: _emailError,
                    ),
                    onChanged: (_) => setState(() => _emailError = null),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Email wajib diisi';
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  if (_needsPassword) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_busy,
                      obscureText: _obscure,
                      // Diketik ulang → hapus error dari server untuk kolom ini.
                      onChanged: (_) {
                        if (_passwordError != null) setState(() => _passwordError = null);
                      },
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        helperText: 'Demi keamanan, konfirmasi kata sandi untuk mengganti email.',
                        prefixIcon: const Icon(Icons.lock_outline),
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          (v ?? '').isEmpty ? 'Kata sandi wajib diisi' : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _sendOtp,
                    child: Text(_busy ? 'Mengirim…' : 'Kirim kode ke email baru'),
                  ),
                ] else ...[
                  Text(
                    'Kode dikirim ke ${_maskedEmail ?? _emailController.text.trim()}. '
                    'Periksa kotak masuk atau folder spam.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (_devOtp != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Mode development: kode $_devOtp',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    // Diketik ulang → hapus error dari server untuk kolom ini.
                    onChanged: (_) {
                      if (_otpError != null) setState(() => _otpError = null);
                    },
                    decoration: InputDecoration(
                      labelText: 'Kode OTP',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      errorText: _otpError,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _verify,
                    child: Text(_busy ? 'Memverifikasi…' : 'Verifikasi'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _busy ? null : () => setState(() => _otpStep = false),
                        child: const Text('Ganti alamat'),
                      ),
                      TextButton(
                        onPressed: _busy || _resendSeconds > 0
                            ? null
                            : () => _sendOtp(resend: true),
                        child: Text(
                          _resendSeconds > 0
                              ? 'Kirim ulang ($_resendSeconds dtk)'
                              : 'Kirim ulang kode',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
