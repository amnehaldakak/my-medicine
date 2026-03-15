import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/medication.dart';

/// Single horizontal adherence progress row
class AdherenceRow extends StatelessWidget {
  final Medication med;
  final double rate; // 0.0 - 1.0

  const AdherenceRow({super.key, required this.med, required this.rate});

  Color get _barColor {
    if (rate >= 0.9) return AppColors.success;
    if (rate >= 0.6) return AppColors.primaryLight;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (rate * 100).toStringAsFixed(0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              med.name,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.chipInactive,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: rate.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: _barColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 38,
            child: Text(
              '$pct%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Week bar chart showing daily adherence
class WeekBarChart extends StatelessWidget {
  final List<DateTime> days;
  final List<double> values; // 0.0 - 1.0 per day

  const WeekBarChart({
    super.key,
    required this.days,
    required this.values,
  });

  Color _color(double v) {
    if (v == 0) return AppColors.error;
    if (v < 0.5) return AppColors.warning;
    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    const maxH = 90.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(days.length, (i) {
          final v = i < values.length ? values[i] : 0.0;
          final barH = v == 0 ? 4.0 : (v * maxH).clamp(4.0, maxH);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                width: 28,
                height: barH,
                decoration: BoxDecoration(
                  color: _color(v),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('E').format(days[i])[0],
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Circular week calendar with color-coded adherence dots
class WeekCalendarStrip extends StatelessWidget {
  final List<DateTime> days;
  final List<double> values;

  const WeekCalendarStrip({
    super.key,
    required this.days,
    required this.values,
  });

  Color _dotColor(double v) {
    if (v == 0) return AppColors.error;
    if (v < 0.5) return AppColors.warning;
    if (v < 1.0) return AppColors.primaryLight;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (i) {
        final d = days[i];
        final v = i < values.length ? values[i] : 0.0;
        final isToday =
            d.day == today.day && d.month == today.month;
        return Column(
          children: [
            Text(
              DateFormat('E').format(d)[0],
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _dotColor(v),
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${d.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
