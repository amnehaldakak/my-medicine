import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/medication_controller.dart';
import '../../../data/models/medication.dart';

class RefillTrackerScreen extends StatelessWidget {
  const RefillTrackerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MedicationController>();
    final meds = ctrl.activeMeds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.refillHeaderBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            expandedHeight: 110,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Refill Tracker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              titlePadding: EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...meds.map((m) => _RefillCard(medication: m)),
                  const SizedBox(height: 16),
                  // Log Refill CTA
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
                    child: Column(children: [
                      const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 32),
                      const SizedBox(height: 8),
                      Text('Log a Refill', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Update your inventory after picking up your prescription', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: () {}, child: const Text('Log Refill')),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('Nearby pharmacies', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _PharmacyCard(name: 'CVS Pharmacy', distance: '0.3 mi', open: true),
                  _PharmacyCard(name: 'Walgreens', distance: '0.7 mi', open: true),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.alarm_outlined, size: 18),
                    label: const Text('Set Refill Reminders'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.refillHeaderBg,
                      side: const BorderSide(color: AppColors.refillHeaderBg),
                    ),
                  )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefillCard extends StatelessWidget {
  final Medication medication;
  const _RefillCard({required this.medication});
  @override
  Widget build(BuildContext context) {
    final stock = medication.currentInventory ?? 0;
    final refillAt = medication.refillAt ?? 10;
    final maxStock = refillAt * 3;
    final progress = (stock / maxStock).clamp(0.0, 1.0);
    final isLow = medication.needsRefill;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(medication.name, style: Theme.of(context).textTheme.titleMedium)),
          if (isLow) const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 4),
          Text('$stock pills', style: TextStyle(fontWeight: FontWeight.w600, color: isLow ? AppColors.error : AppColors.textPrimary)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress, minHeight: 8,
            backgroundColor: AppColors.chipInactive,
            valueColor: AlwaysStoppedAnimation<Color>(isLow ? AppColors.error : AppColors.primaryLight),
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(isLow ? 'Refill soon!' : 'Good supply', style: TextStyle(color: isLow ? AppColors.error : AppColors.success, fontSize: 12, fontWeight: FontWeight.w500)),
          Text('Refill at $refillAt', style: Theme.of(context).textTheme.bodySmall),
        ]),
      ]),
    );
  }
}

class _PharmacyCard extends StatelessWidget {
  final String name, distance; final bool open;
  const _PharmacyCard({required this.name, required this.distance, required this.open});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.local_pharmacy_outlined, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: Theme.of(context).textTheme.bodyLarge)),
        Text(distance, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: open ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(open ? 'Open' : 'Closed', style: TextStyle(color: open ? AppColors.success : AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
