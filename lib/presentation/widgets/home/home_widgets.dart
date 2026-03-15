import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

/// Yellow warning banner shown on Home when meds need refill
class RefillBanner extends StatelessWidget {
  final int count;
  const RefillBanner({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.refillTracker),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.refillBannerBg,
          borderRadius: BorderRadius.circular(12),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count medication${count > 1 ? 's' : ''} running low — tap to refill',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

/// Section header for a time-of-day group (Morning • 8:00 AM)
class ScheduleGroupHeader extends StatelessWidget {
  final String label;
  final String time;

  const ScheduleGroupHeader({
    super.key,
    required this.label,
    required this.time,
  });

  IconData get _icon {
    switch (label) {
      case 'Morning':
        return Icons.wb_sunny_outlined;
      case 'Afternoon':
        return Icons.wb_cloudy_outlined;
      case 'Evening':
        return Icons.nights_stay_outlined;
      default:
        return Icons.bedtime_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(_icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            '$label • $time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// Empty state for when there are no meds scheduled today
class EmptyTodayState extends StatelessWidget {
  const EmptyTodayState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 48, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 20),
            Text('All done for today!',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('No more medications scheduled',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
