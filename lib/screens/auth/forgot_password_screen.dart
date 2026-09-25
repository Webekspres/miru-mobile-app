import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/api_exception.dart';
import '../../providers/auth_provider.dart';

enum _ForgotStep { username, email, otp }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  _ForgotStep _step = _ForgotStep.username;
  bool _isSubmitting = false;
  String? _maskedEmail;
  String? _fieldErrorUsername;
  String? _fieldErrorEmail;
  String? _fieldErrorOtp;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    setState(() {
      _fieldErrorUsername = null;
      _fieldErrorEmail = null;
      _fieldErrorOtp = null;
    });
  }

  String? _extractError(dynamic error) {
    if (error == null) return null;
    if (error is List && error.isNotEmpty) return error.first.toString();
    if (error is String) return error;
    return null;
  }

  void _applyFieldErrors(Map<String, dynamic>? errors) {
    if (errors == null) return;
    setState(() {
      _fieldErrorUsername = _extractError(errors['username']);
      _fieldErrorEmail = _extractError(errors['email']);
      _fieldErrorOtp = _extractError(errors['otp']);
    });
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

  Future<void> _submitUsername() async {
    if (!_formKey.currentState!.validate()) return;
    _clearFieldErrors();
    setState(() => _isSubmitting = true);

    try {
      final data = await context.read<AuthProvider>().forgotPassword(
            username: _usernameController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _maskedEmail = data['masked_email'] as String?;
        _step = _ForgotStep.email;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _applyFieldErrors(e.fieldErrors);
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError(kGenericErrorMessage);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitEmail({bool fromResend = false}) async {
    if (!fromResend && !_formKey.currentState!.validate()) return;
    _clearFieldErrors();
    setState(() => _isSubmitting = true);

    try {
      final data = await context.read<AuthProvider>().requestResetPasswordOtp(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _maskedEmail = data['masked_email'] as String? ?? _maskedEmail;
        _step = _ForgotStep.otp;
      });
      _startResendCooldown(60);
      _showSuccess(
        'Kode dikirim. Cek kotak masuk atau folder spam email Anda.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _applyFieldErrors(e.fieldErrors);
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError(kGenericErrorMessage);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitOtp() async {
    if (!_formKey.currentState!.validate()) return;
    _clearFieldErrors();
    setState(() => _isSubmitting = true);

    try {
      final token = await context.read<AuthProvider>().verifyResetPasswordOtp(
            username: _usernameController.text.trim(),
            otp: _otpController.text.trim(),
          );
      if (!mounted) return;
      context.pushReplacement('/reset-password', extra: token);
    } on ApiException catch (e) {
      if (!mounted) return;
      _applyFieldErrors(e.fieldErrors);
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError(kGenericErrorMessage);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isSubmitting || _resendSeconds > 0) return;
    await _submitEmail(fromResend: true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  String get _subtitle {
    switch (_step) {
      case _ForgotStep.username:
        return 'Masukkan username akun Anda. Kami akan menampilkan email yang terdaftar.';
      case _ForgotStep.email:
        return 'Email terdaftar: ${_maskedEmail ?? '—'}. Masukkan email yang sama agar kami kirim kode ke email tersebut.';
      case _ForgotStep.otp:
        return 'Masukkan kode yang dikirim ke ${_maskedEmail ?? 'email Anda'}.';
    }
  }

  VoidCallback? get _onSubmit {
    if (_isSubmitting) return null;
    switch (_step) {
      case _ForgotStep.username:
        return _submitUsername;
      case _ForgotStep.email:
        return _submitEmail;
      case _ForgotStep.otp:
        return _submitOtp;
    }
  }

  String get _submitLabel {
    switch (_step) {
      case _ForgotStep.username:
        return 'Lanjut';
      case _ForgotStep.email:
        return 'Kirim kode ke email';
      case _ForgotStep.otp:
        return 'Verifikasi kode';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Lupa Password'),
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
                  Icons.lock_reset_rounded,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Atur Ulang Password',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_step == _ForgotStep.username)
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      helperText: 'Username yang dipakai saat mendaftar',
                      errorText: _fieldErrorUsername,
                    ),
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onFieldSubmitted: (_) => _onSubmit?.call(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                if (_step == _ForgotStep.email)
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      helperText: 'Harus sama dengan email yang terdaftar',
                      errorText: _fieldErrorEmail,
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (_) => _onSubmit?.call(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                if (_step == _ForgotStep.otp)
                  TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'Kode dari email',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      hintText: '6 digit',
                      errorText: _fieldErrorOtp,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onFieldSubmitted: (_) => _onSubmit?.call(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kode wajib diisi';
                      }
                      if (value.trim().length < 4) {
                        return 'Kode tidak valid';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_submitLabel),
                  ),
                ),
                if (_step == _ForgotStep.otp) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isSubmitting || _resendSeconds > 0
                        ? null
                        : _resendOtp,
                    child: Text(
                      _resendSeconds > 0
                          ? 'Kirim ulang ($_resendSeconds dtk)'
                          : 'Kirim ulang kode',
                    ),
                  ),
                ],
                if (_step != _ForgotStep.username) ...[
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              if (_step == _ForgotStep.otp) {
                                _step = _ForgotStep.email;
                                _otpController.clear();
                              } else {
                                _step = _ForgotStep.username;
                              }
                            });
                          },
                    child: const Text('Kembali'),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah ingat password? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Masuk',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
