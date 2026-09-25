import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/profile_provider.dart';
import '../../providers/wilayah_provider.dart';
import '../../services/avatar_picker.dart';
import '../../widgets/alamat_bertingkat.dart';
import '../../widgets/peta_pin_picker.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.initialUser});

  final User initialUser;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _alamatController;
  late TextEditingController _rtController;
  late TextEditingController _rwController;
  int? _kelurahanId;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _kelurahanId = widget.initialUser.kelurahanId;
    _latitude = widget.initialUser.latitude;
    _longitude = widget.initialUser.longitude;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WilayahProvider>().load();
    });
    _namaController = TextEditingController(text: widget.initialUser.namaLengkap);
    _noHpController = TextEditingController(text: widget.initialUser.noHp);
    _alamatController = TextEditingController(text: widget.initialUser.alamat);
    _rtController = TextEditingController(text: widget.initialUser.rt);
    _rwController = TextEditingController(text: widget.initialUser.rw);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  bool get _isDirty {
    final u = widget.initialUser;
    return _namaController.text.trim() != u.namaLengkap.trim() ||
        _noHpController.text.trim() != u.noHp.trim() ||
        _alamatController.text.trim() != u.alamat.trim() ||
        _rtController.text.trim() != u.rt.trim() ||
        _rwController.text.trim() != u.rw.trim() ||
        _kelurahanId != u.kelurahanId ||
        _latitude != u.latitude ||
        _longitude != u.longitude;
  }

  /// Back (AppBar / tombol sistem) saat ada perubahan: tanya dulu.
  Future<void> _onBack() async {
    if (context.read<ProfileProvider>().isSaving) return;
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final pilihan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Perubahan belum disimpan'),
        content: const Text(
          'Anda memiliki perubahan yang belum disimpan. '
          'Simpan perubahan sebelum keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (!mounted || pilihan == null) return; // ditutup: tetap di halaman
    if (pilihan) {
      await _saveProfile(); // menutup layar bila berhasil
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final cakupan = context.read<WilayahProvider>().cakupan;
    if (cakupan.kelurahanById(_kelurahanId) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kelurahan/kampung di Distrik Mimika Baru.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final profile = context.read<ProfileProvider>();
    final success = await profile.updateProfile(
      namaLengkap: _namaController.text.trim(),
      noHp: _noHpController.text.trim(),
      alamat: _alamatController.text.trim(),
      rt: _rtController.text.trim(),
      rw: _rwController.text.trim(),
      kelurahanId: _kelurahanId,
      latitude: _latitude,
      longitude: _longitude,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.of(context).pop();
    } else if (profile.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profile.error!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>();
    final wilayah = context.watch<WilayahProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          TextButton(
            onPressed: profile.isSaving ? null : _saveProfile,
            child: profile.isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar Preview ──
              Center(
                child: Column(
                  children: [
                    UserAvatar(
                      name: profile.user?.namaLengkap ?? widget.initialUser.namaLengkap,
                      imageUrl: profile.user?.avatarUrl ?? widget.initialUser.avatarUrl,
                      radius: 40,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: profile.isSaving
                          ? null
                          : () async {
                              final file = await pickAndCropAvatar(context);
                              if (file == null || !context.mounted) return;
                              final ok = await profile.updateAvatar(file);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Foto profil berhasil diperbarui'
                                        : (profile.error ?? 'Gagal menyimpan foto'),
                                  ),
                                  backgroundColor: ok
                                      ? AppTheme.primaryColor
                                      : AppTheme.errorColor,
                                ),
                              );
                            },
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Ubah foto profil'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Form Fields ──
              _buildLabel(theme, 'Nama Lengkap'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel(theme, 'No. Handphone'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Contoh: 08123456789',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'No. HP tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel(theme, 'Wilayah'),
              const SizedBox(height: 8),
              AlamatBertingkat(
                cakupan: wilayah.cakupan,
                kelurahanId: _kelurahanId,
                isLoading: wilayah.isLoading,
                error: wilayah.error,
                onRetry: () => wilayah.load(force: true),
                onKelurahanChanged: (id) => setState(() => _kelurahanId = id),
              ),
              const SizedBox(height: 20),

              _buildLabel(theme, 'Alamat Lengkap'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nama jalan, nomor rumah, patokan',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.location_on_outlined, size: 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              // ── RT (opsional) ──
              _buildLabel(theme, 'RT (opsional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rtController,
                decoration: InputDecoration(
                  hintText: 'Contoh: 001',
                  prefixIcon: const Icon(Icons.signpost_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── RW (opsional) ──
              _buildLabel(theme, 'RW (opsional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rwController,
                decoration: InputDecoration(
                  hintText: 'Contoh: 002',
                  prefixIcon: const Icon(Icons.signpost_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel(theme, 'Titik Lokasi Rumah (opsional)'),
              const SizedBox(height: 8),
              PetaPinPicker(
                cakupan: wilayah.cakupan,
                latitude: _latitude,
                longitude: _longitude,
                onChanged: (lat, lng) => setState(() {
                  _latitude = lat;
                  _longitude = lng;
                }),
              ),
              const SizedBox(height: 20),

              // ── Read-only fields ──
              _buildLabel(theme, 'Username'),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: widget.initialUser.username,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_2_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 20),

              // ── Info ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Saldo, poin, dan role tidak dapat diubah di sini. '
                        'Hubungi admin MIRU jika ada perubahan data yang tidak bisa diubah.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profile.isSaving ? null : _saveProfile,
                  child: profile.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan Perubahan'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
