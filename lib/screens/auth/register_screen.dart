import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/api_exception.dart';
import '../../providers/auth_provider.dart';
import '../../providers/launch_experience.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noHpController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _setujuKebijakan = false;
  bool _isSubmitting = false;
  int _step = 1;
  bool _otpSent = false;
  String? _maskedPhone;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  String? _fieldErrorUsername;
  String? _fieldErrorNama;
  String? _fieldErrorPassword;
  String? _fieldErrorConsent;
  String? _fieldErrorNoHp;
  String? _fieldErrorOtp;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _noHpController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    setState(() {
      _fieldErrorUsername = null;
      _fieldErrorNama = null;
      _fieldErrorPassword = null;
      _fieldErrorConsent = null;
      _fieldErrorNoHp = null;
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
      _fieldErrorNama = _extractError(errors['nama_lengkap']);
      _fieldErrorPassword = _extractError(errors['password']);
      _fieldErrorConsent = _extractError(errors['setuju_kebijakan_data']);
      _fieldErrorNoHp = _extractError(errors['no_hp']);
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

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_setujuKebijakan) {
      _showError('Harus menyetujui kebijakan data untuk melanjutkan.');
      return;
    }

    _clearFieldErrors();
    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().register(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            namaLengkap: _namaController.text.trim(),
            setujuKebijakanData: true,
          );
      if (!mounted) return;
      setState(() => _step = 2);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
        _applyFieldErrors(e.fieldErrors);
        return;
      }
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (_isSubmitting || _resendSeconds > 0) return;
    if (!_otpSent && !_formKey.currentState!.validate()) return;

    _clearFieldErrors();
    setState(() => _isSubmitting = true);

    try {
      final data = await context.read<AuthProvider>().requestPhoneOtp(
            username: _usernameController.text.trim(),
            noHp: _noHpController.text.trim(),
          );
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
      if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
        _applyFieldErrors(e.fieldErrors);
        return;
      }
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Gagal mengirim kode. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _verifyOtpAndLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _clearFieldErrors();
    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final launch = context.read<LaunchExperience>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      await auth.verifyPhoneOtp(
        otp: _otpController.text.trim(),
        username: username,
        noHp: _noHpController.text.trim(),
      );
      launch.markRegistered();
      await auth.login(username: username, password: password);
      if (!mounted) return;
      if (auth.needsPhoneVerification) {
        context.go('/verify-phone');
      } else {
        context.go('/onboarding');
      }
    } on ApiException catch (e) {
      launch.consumeOnboarding();
      if (!mounted) return;
      if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
        _applyFieldErrors(e.fieldErrors);
        return;
      }
      _showError(e.message);
    } catch (_) {
      launch.consumeOnboarding();
      if (!mounted) return;
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  _step == 1 ? 'Daftar Akun Baru' : 'Verifikasi Nomor HP',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _step == 1
                      ? 'Ayo bergabung bersama kami! Membangun lingkungan hijau bersama.'
                      : 'Masukkan nomor HP, lalu isi kode yang dikirim ke WhatsApp ${_maskedPhone ?? 'Anda'}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Langkah $_step dari 2',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: _step == 1 ? _buildStep1(theme) : _buildStep2(theme),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
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

  Widget _buildStep1(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _namaController,
          decoration: InputDecoration(
            labelText: 'Nama lengkap',
            prefixIcon: const Icon(Icons.badge_outlined),
            errorText: _fieldErrorNama,
          ),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama lengkap tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            errorText: _fieldErrorUsername,
          ),
          textInputAction: TextInputAction.next,
          autocorrect: false,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username tidak boleh kosong';
            }
            if (value.trim().length < 3) {
              return 'Username minimal 3 karakter';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            errorText: _fieldErrorPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(
                () => _obscurePassword = !_obscurePassword,
              ),
            ),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            if (value.length < 6) {
              return 'Password minimal 6 karakter';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: _setujuKebijakan,
          onChanged: (value) =>
              setState(() => _setujuKebijakan = value ?? false),
          title: Text.rich(
            TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                const TextSpan(text: 'Saya menyetujui '),
                TextSpan(
                  text: 'kebijakan data pribadi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.push('/settings/kebijakan-data'),
                ),
              ],
            ),
          ),
          subtitle: _fieldErrorConsent == null
              ? null
              : Text(
                  _fieldErrorConsent!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: (_isSubmitting || !_setujuKebijakan)
                ? null
                : _handleRegister,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Lanjut'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Akun sudah dibuat. Jangan tutup halaman ini sampai nomor HP terverifikasi.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _noHpController,
          enabled: !_otpSent,
          decoration: InputDecoration(
            labelText: 'Nomor HP',
            prefixIcon: const Icon(Icons.phone_outlined),
            errorText: _fieldErrorNoHp,
          ),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nomor HP tidak boleh kosong';
            }
            if (value.trim().length < 10) {
              return 'Nomor HP minimal 10 digit';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        if (_otpSent)
          TextFormField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: 'Kode dari WhatsApp',
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
            onFieldSubmitted: (_) =>
                _isSubmitting ? null : _verifyOtpAndLogin(),
            validator: (value) {
              if (!_otpSent) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Kode wajib diisi';
              }
              if (value.trim().length < 4) {
                return 'Kode tidak valid';
              }
              return null;
            },
          ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : (_otpSent ? _verifyOtpAndLogin : _sendOtp),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_otpSent ? 'Verifikasi & masuk' : 'Kirim kode ke WhatsApp'),
          ),
        ),
        if (_otpSent) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSubmitting || _resendSeconds > 0 ? null : _sendOtp,
            child: Text(
              _resendSeconds > 0
                  ? 'Kirim ulang ($_resendSeconds dtk)'
                  : 'Kirim ulang kode',
            ),
          ),
        ],
      ],
    );
  }
}
