import 'package:flutter/material.dart';

import '../models/wilayah_cakupan.dart';

/// Alamat bertingkat: provinsi → kabupaten → distrik (terkunci ke Distrik
/// Mimika Baru) → kelurahan/kampung (dipilih pengguna).
class AlamatBertingkat extends StatelessWidget {
  const AlamatBertingkat({
    super.key,
    required this.cakupan,
    required this.kelurahanId,
    required this.onKelurahanChanged,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.errorText,
  });

  final WilayahCakupan cakupan;
  final int? kelurahanId;
  final ValueChanged<int?> onKelurahanChanged;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  /// Pesan validasi dari server untuk field kelurahan.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = cakupan.kelurahanById(kelurahanId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cakupan.pesan,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _LockedField(label: 'Provinsi', value: cakupan.provinsi),
        const SizedBox(height: 12),
        _LockedField(label: 'Kabupaten', value: cakupan.kabupaten),
        const SizedBox(height: 12),
        _LockedField(label: 'Distrik', value: cakupan.distrik),
        const SizedBox(height: 12),
        if (error != null && cakupan.kelurahan.isEmpty)
          Row(
            children: [
              Expanded(
                child: Text(
                  error!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          )
        else
          DropdownButtonFormField<int>(
            key: ValueKey('kelurahan-${cakupan.kelurahan.length}'),
            initialValue: selected?.id,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Kelurahan / Kampung',
              prefixIcon: const Icon(Icons.location_city_outlined),
              errorText: errorText,
              helperText: selected == null && kelurahanId != null
                  ? 'Kelurahan lama tidak dilayani. Pilih ulang.'
                  : null,
            ),
            hint: Text(isLoading ? 'Memuat kelurahan…' : 'Pilih kelurahan/kampung'),
            items: [
              for (final k in cakupan.kelurahan)
                DropdownMenuItem(value: k.id, child: Text(k.label)),
            ],
            onChanged: isLoading ? null : onKelurahanChanged,
            validator: (value) =>
                value == null ? 'Pilih kelurahan/kampung Anda' : null,
          ),
      ],
    );
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
        enabled: false,
      ),
      child: Text(value),
    );
  }
}
