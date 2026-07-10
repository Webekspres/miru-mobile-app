import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/complaint.dart';
import '../../providers/auth_session.dart';
import '../../providers/pengaduan_provider.dart';
import '../../widgets/login_prompt.dart';

class PengaduanFormScreen extends StatefulWidget {
  const PengaduanFormScreen({super.key});

  @override
  State<PengaduanFormScreen> createState() => _PengaduanFormScreenState();
}

class _PengaduanFormScreenState extends State<PengaduanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keluhanController = TextEditingController();
  ComplaintJenis? _selectedJenis;

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedJenis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis pengaduan terlebih dahulu'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final pengaduan = context.read<PengaduanProvider>();
    final result = await pengaduan.createComplaint(
      jenisPengaduan: _selectedJenis!.apiValue,
      keluhan: _keluhanController.text.trim(),
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengaduan #${result.id} berhasil dikirim'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      context.pop();
    } else if (pengaduan.hasSubmitError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pengaduan.submitError!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pengaduan Baru')),
        body: const LoginPrompt(
          title: 'Pengaduan Baru',
          message: 'Masuk untuk mengajukan pengaduan kepada MIRU Bank Sampah.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaduan Baru'),
      ),
      body: Consumer<PengaduanProvider>(
        builder: (context, pengaduan, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Info ──
                  _buildInfoHeader(context),
                  const SizedBox(height: 20),

                  // ── Jenis Pengaduan ──
                  Text(
                    'Jenis Pengaduan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ComplaintJenis>(
                    initialValue: _selectedJenis,
                    hint: const Text('Pilih jenis pengaduan'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: ComplaintJenis.values.map((jenis) {
                      return DropdownMenuItem(
                        value: jenis,
                        child: Text(
                          jenis.displayLabel,
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedJenis = value);
                    },
                    validator: (v) =>
                        v == null ? 'Pilih jenis pengaduan' : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Keluhan ──
                  Text(
                    'Keluhan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jelaskan keluhan Anda dengan detail (maks. 500 karakter)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _keluhanController,
                    maxLines: 6,
                    maxLength: 500,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Contoh: Saya telah melakukan setoran sampah pada tanggal 3 Juli 2026 namun saldo saya belum bertambah...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Keluhan wajib diisi';
                      }
                      if (v.trim().length < 10) {
                        return 'Keluhan terlalu pendek (min. 10 karakter)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Info SLA ──
                  _buildSlaInfo(theme),
                  const SizedBox(height: 28),

                  // ── Submit Button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: pengaduan.isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: pengaduan.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kirim Pengaduan',
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
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF991B1B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pengaduan akan ditindaklanjuti oleh admin MIRU '
              'maksimal 2 hari kerja.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF991B1B),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaInfo(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
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
                'Yang Perlu Diketahui',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0369A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoBullet(theme, 'Ditindaklanjuti maksimal 2 hari kerja'),
          const SizedBox(height: 6),
          _infoBullet(theme, 'Pantau status pengaduan di tab "Pengaduan"'),
          const SizedBox(height: 6),
          _infoBullet(
            theme,
            'Admin akan memberikan tanggapan melalui fitur ini',
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
