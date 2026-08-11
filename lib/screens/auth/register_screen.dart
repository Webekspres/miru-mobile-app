import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/api_exception.dart';
import '../../providers/auth_provider.dart';

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
  final _alamatController = TextEditingController();
  final _nikController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();

  bool _obscurePassword = true;
  bool _setujuKebijakan = false;
  bool _isSubmitting = false;

  // Field-level error messages from API
  String? _fieldErrorUsername;
  String? _fieldErrorNama;
  String? _fieldErrorPassword;
  String? _fieldErrorNoHp;
  String? _fieldErrorAlamat;
  String? _fieldErrorNik;
  String? _fieldErrorRt;
  String? _fieldErrorRw;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _nikController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    setState(() {
      _fieldErrorUsername = null;
      _fieldErrorNama = null;
      _fieldErrorPassword = null;
      _fieldErrorNoHp = null;
      _fieldErrorAlamat = null;
      _fieldErrorNik = null;
      _fieldErrorRt = null;
      _fieldErrorRw = null;
    });
  }

  void _applyFieldErrors(Map<String, dynamic>? errors) {
    if (errors == null) return;
    setState(() {
      _fieldErrorUsername = _extractError(errors['username']);
      _fieldErrorNama = _extractError(errors['nama_lengkap']);
      _fieldErrorPassword = _extractError(errors['password']);
      _fieldErrorNoHp = _extractError(errors['no_hp']);
      _fieldErrorAlamat = _extractError(errors['alamat']);
    _fieldErrorNik = _extractError(errors['nik']);
    _fieldErrorRt = _extractError(errors['rt']);
    _fieldErrorRw = _extractError(errors['rw']);
  });
  }

  String? _extractError(dynamic error) {
    if (error == null) return null;
    if (error is List && error.isNotEmpty) return error.first.toString();
    if (error is String) return error;
    return null;
  }

  Future<void> _handleRegister() async {
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
            noHp: _noHpController.text.trim(),
            alamat: _alamatController.text.trim(),
            rt: _rtController.text.trim(),
            rw: _rwController.text.trim(),
            nik: _nikController.text.trim().isEmpty
                ? null
                : _nikController.text.trim(),
            setujuKebijakanData: true,
          );

      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.needsPhoneVerification) {
        context.go('/verify-phone');
      } else {
        context.go('/home');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      // Extract field errors from ApiException (set by EnvelopeInterceptor)
      final apiError = e.error;
      if (apiError is ApiException) {
        if (apiError.fieldErrors != null && apiError.fieldErrors!.isNotEmpty) {
          _applyFieldErrors(apiError.fieldErrors);
          return;
        }
        _showError(apiError.message);
        return;
      }
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } catch (e) {
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
                'Daftar Akun Baru',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ayo bergabung bersama kami! Membangun lingkungan hijau bersama.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nama Lengkap
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
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
                    // Username
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
                    // Password
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
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 14),
                    // No HP
                    TextFormField(
                      controller: _noHpController,
                      decoration: InputDecoration(
                        labelText: 'No. Handphone',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        errorText: _fieldErrorNoHp,
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'No. handphone tidak boleh kosong';
                        }
                        if (value.trim().length < 10) {
                          return 'No. handphone minimal 10 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Alamat
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(
                        labelText: 'Alamat',
                        prefixIcon: const Icon(Icons.home_outlined),
                        errorText: _fieldErrorAlamat,
                      ),
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // RT (opsional)
                    TextFormField(
                      controller: _rtController,
                      decoration: InputDecoration(
                        labelText: 'RT (opsional)',
                        prefixIcon: const Icon(Icons.signpost_outlined),
                        errorText: _fieldErrorRt,
                        helperText: 'Contoh: 001',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    // RW (opsional)
                    TextFormField(
                      controller: _rwController,
                      decoration: InputDecoration(
                        labelText: 'RW (opsional)',
                        prefixIcon: const Icon(Icons.signpost_outlined),
                        errorText: _fieldErrorRw,
                        helperText: 'Contoh: 002',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    // NIK (opsional)
                    TextFormField(
                      controller: _nikController,
                      decoration: InputDecoration(
                        labelText: 'NIK (opsional)',
                        prefixIcon: const Icon(Icons.credit_card_outlined),
                        errorText: _fieldErrorNik,
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    // Kebijakan data checkbox
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
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    const SizedBox(height: 16),
                    // Submit button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleRegister,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Daftar'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Login link
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
}
