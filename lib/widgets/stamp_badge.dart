import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/models.dart';

/// Small circular badge styled like a school register's ink stamp —
/// the same signature motif used on the web dashboard.
class StampBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const StampBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  factory StampBadge.attendance(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return StampBadge(label: 'Present', color: GurukulColors.sage, background: GurukulColors.sageLight);
      case AttendanceStatus.late:
        return StampBadge(label: 'Late', color: GurukulColors.marigold, background: Colors.white);
      case AttendanceStatus.halfDay:
        return StampBadge(label: 'Half day', color: GurukulColors.marigold, background: Colors.white);
      case AttendanceStatus.absent:
        return StampBadge(label: 'Absent', color: GurukulColors.brick, background: GurukulColors.brickLight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
