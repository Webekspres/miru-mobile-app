import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/api_exception.dart';
import '../../providers/auth_provider.dart';

/// Minimal layar verifikasi OTP WhatsApp setelah login
/// (akun admin-created dengan `phone_verified=false`).
class PhoneVerifyScreen extends StatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  State<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends State<PhoneVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isSending = false;
  bool _isVerifying = false;
  bool _otpSent = false;
  String? _maskedPhone;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
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
    if (_isSending || _resendSeconds > 0) return;

    setState(() => _isSending = true);

    try {
      final data = await context.read<AuthProvider>().requestPhoneOtp();
      if (!mounted) return;

      setState(() {
        _otpSent = true;
        _maskedPhone = data['masked_phone'] as String?;
      });
      _startResendCooldown(60);
      _showInfo(
        'Cek notifikasi WhatsApp untuk kode verifikasi.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } on DioException {
      if (!mounted) return;
      _showError('Gagal mengirim kode. Silakan coba lagi.');
    } catch (_) {
      if (!mounted) return;
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    try {
      await context.read<AuthProvider>().verifyPhoneOtp(
            otp: _otpController.text.trim(),
          );
      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } on DioException {
      if (!mounted) return;
      _showError('Verifikasi gagal. Silakan coba lagi.');
    } catch (_) {
      if (!mounted) return;
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go('/login');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  String _displayPhone(AuthProvider auth) {
    if (_maskedPhone != null && _maskedPhone!.isNotEmpty) {
      return _maskedPhone!;
    }
    final raw = auth.user?.noHp ?? '';
    if (raw.length < 6) return raw.isEmpty ? '—' : raw;
    return '${raw.substring(0, 4)}****${raw.substring(raw.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final busy = _isSending || _isVerifying;

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Verifikasi Nomor HP'),
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
                    Icons.sms_outlined,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verifikasi WhatsApp',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Akun Anda belum diverifikasi. '
                    'Masukkan kode OTP yang dikirim ke WhatsApp '
                    '${_displayPhone(auth)}.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'Kode OTP',
                      prefixIcon: Icon(Icons.pin_outlined),
                      hintText: '6 digit',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onFieldSubmitted: (_) => busy ? null : _verifyOtp(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kode OTP wajib diisi';
                      }
                      if (value.trim().length < 4) {
                        return 'Kode OTP tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: busy ? null : _verifyOtp,
                      child: _isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verifikasi'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: busy || _resendSeconds > 0 ? null : _sendOtp,
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _resendSeconds > 0
                                ? 'Kirim ulang ($_resendSeconds dtk)'
                                : (_otpSent
                                    ? 'Kirim ulang OTP'
                                    : 'Kirim OTP'),
                          ),
                  ),
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
