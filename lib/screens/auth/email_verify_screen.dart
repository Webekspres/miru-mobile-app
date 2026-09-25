import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/api_exception.dart';
import '../../providers/auth_provider.dart';

/// Gate setelah login: akun tanpa email terverifikasi (`email_required`)
/// wajib isi email + OTP sekali sebelum memakai aplikasi.
class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSending = false;
  bool _isVerifying = false;
  bool _otpSent = false;
  String? _maskedEmail;
  String? _emailError;
  String? _otpError;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    final email = context.read<AuthProvider>().user?.email ?? '';
    _emailController.text = email;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCooldown([int seconds = 60]) {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (_isSending || _resendSeconds > 0) return;
    if (!_otpSent && !_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _emailError = null;
    });
    try {
      final data = await context.read<AuthProvider>().requestEmailOtp(
            email: _emailController.text,
          );
      if (!mounted) return;
      if (data['email_verified'] == true) {
        context.go('/home');
        return;
      }
      setState(() {
        _otpSent = true;
        _maskedEmail = data['masked_email'] as String?;
      });
      _startResendCooldown(60);
      final devOtp = data['dev_otp'] as String?;
      _showInfo(
        data['dev_otp_mode'] == true && devOtp != null
            ? 'Mode development: gunakan OTP $devOtp'
            : 'Kode dikirim. Cek kotak masuk atau folder spam email Anda.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      final fieldError = _first(e.fieldErrors?['email']);
      if (fieldError != null && !_otpSent) {
        setState(() => _emailError = fieldError);
      } else {
        _showError(e.message);
      }
    } catch (_) {
      if (!mounted) return;
      _showError(kGenericErrorMessage);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isVerifying = true;
      _otpError = null;
    });
    try {
      await context.read<AuthProvider>().verifyEmailOtp(
            otp: _otpController.text,
          );
      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _otpError = _first(e.fieldErrors?['otp']) ?? e.message);
    } catch (_) {
      if (!mounted) return;
      _showError(kGenericErrorMessage);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  String? _first(dynamic value) {
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go('/login');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = _isSending || _isVerifying;

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Verifikasi Email'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: busy ? null : _logout,
              child: const Text('Keluar'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verifikasi email Anda',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _otpSent
                        ? 'Masukkan 6 digit kode yang dikirim ke '
                            '${_maskedEmail ?? 'email Anda'}. Kode berlaku 5 menit.'
                        : 'Email dipakai untuk kode OTP saat lupa kata sandi. '
                            'Verifikasi cukup sekali.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_otpSent && !busy,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: 'nama@contoh.com',
                      errorText: _emailError,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => busy ? null : _sendOtp(),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Email wajib diisi';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  if (_otpSent) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: 'Kode OTP',
                        prefixIcon: const Icon(Icons.pin_outlined),
                        hintText: '6 digit',
                        errorText: _otpError,
                      ),
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onFieldSubmitted: (_) => busy ? null : _verifyOtp(),
                      validator: (value) =>
                          (value?.trim().length ?? 0) == 6
                              ? null
                              : 'Masukkan 6 digit kode',
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: busy ? null : (_otpSent ? _verifyOtp : _sendOtp),
                      child: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_otpSent ? 'Verifikasi' : 'Kirim Kode OTP'),
                    ),
                  ),
                  if (_otpSent) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => setState(() {
                                    _otpSent = false;
                                    _otpController.clear();
                                    _otpError = null;
                                  }),
                          child: const Text('Ganti email'),
                        ),
                        TextButton(
                          onPressed:
                              busy || _resendSeconds > 0 ? null : _sendOtp,
                          child: Text(
                            _resendSeconds > 0
                                ? 'Kirim ulang ($_resendSeconds dtk)'
                                : 'Kirim ulang kode',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
