import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/medication_utils.dart';
import '../../../data/models/medication.dart';

/// Full card used in the Pill Cabinet list
class MedicationListTile extends StatelessWidget {
  final Medication med;
  final VoidCallback onTap;

  const MedicationListTile({
    super.key,
    required this.med,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Pill icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: MedicationUtils.pillColor(med.colorHex).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication,
                color: MedicationUtils.pillColor(med.colorHex),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${med.dosageAmount.toStringAsFixed(0)} ${med.dosageUnit}  ·  ${MedicationUtils.frequencyLabel(med.frequency)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (med.needsRefill) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            size: 12, color: AppColors.warning),
                        const SizedBox(width: 4),
                        const Text(
                          'Refill needed',
                          style: TextStyle(
                              color: AppColors.warning, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: MedicationUtils.statusColor(med.status)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                MedicationUtils.statusLabel(med.status),
                style: TextStyle(
                  color: MedicationUtils.statusColor(med.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact row card used in Home schedule
class ScheduleMedCard extends StatelessWidget {
  final Medication med;
  final VoidCallback onTap;
  final VoidCallback onTake;
  final VoidCallback onSkip;

  const ScheduleMedCard({
    super.key,
    required this.med,
    required this.onTap,
    required this.onTake,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MedicationUtils.pillColor(med.colorHex).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication,
                color: MedicationUtils.pillColor(med.colorHex),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    '${med.dosageAmount.toStringAsFixed(0)} ${med.dosageUnit} · ${MedicationUtils.formLabel(med.form)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Take / Skip buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(
                    label: 'Skip',
                    color: AppColors.textSecondary,
                    onTap: onSkip),
                const SizedBox(width: 8),
                _ActionBtn(
                    label: 'Take',
                    color: AppColors.primary,
                    filled: true,
                    onTap: onTake),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.color,
      this.filled = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
