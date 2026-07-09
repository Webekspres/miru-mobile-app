import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';

class SaldoCard extends StatelessWidget {
  const SaldoCard({
    super.key,
    required this.saldo,
    this.poin,
    this.isLoading = false,
  });

  final double saldo;
  final int? poin;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 72,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo Anda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(saldo),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (poin != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${NumberFormat.decimalPattern('id_ID').format(poin)} poin',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  static String _formatCurrency(double value) {
    final hasFraction = value.truncateToDouble() != value;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: hasFraction ? 2 : 0,
    );
    return formatter.format(value);
  }
}
