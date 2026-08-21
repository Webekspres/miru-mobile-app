import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../models/pickup.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge._({
    required this.label,
    required this.color,
    required this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final IconData icon;

  factory StatusBadge.pickup({
    required PickupStatus status,
    Key? key,
  }) {
    return StatusBadge._(
      key: key,
      label: status.displayLabel,
      color: status.badgeColor,
      icon: _pickupIcon(status),
    );
  }

  factory StatusBadge.complaint({
    required ComplaintStatus status,
    Key? key,
  }) {
    return StatusBadge._(
      key: key,
      label: status.displayLabel,
      color: _complaintColor(status),
      icon: _complaintIcon(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Color _complaintColor(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.terbuka => const Color(0xFFEAB308),
      ComplaintStatus.ditutup => const Color(0xFF22C55E),
    };
  }

  static IconData _pickupIcon(PickupStatus status) {
    return switch (status) {
      PickupStatus.menunggu => Icons.schedule_rounded,
      PickupStatus.disetujui => Icons.check_circle_outline_rounded,
      PickupStatus.dijadwalkan => Icons.calendar_today_rounded,
      PickupStatus.dalamPerjalanan => Icons.local_shipping_outlined,
      PickupStatus.dijemput => Icons.inventory_2_outlined,
      PickupStatus.selesai => Icons.task_alt_rounded,
      PickupStatus.ditolak => Icons.cancel_outlined,
    };
  }

  static IconData _complaintIcon(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.terbuka => Icons.pending_outlined,
      ComplaintStatus.ditutup => Icons.check_circle_outline_rounded,
    };
  }
}
