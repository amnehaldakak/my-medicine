import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/medication_controller.dart';
import '../../../data/models/medication.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MedicationController>();
    final meds = ctrl.activeMeds;
    final overallAdherence = meds.isEmpty
        ? 0.0
        : meds.map((m) => m.adherenceRate).reduce((a, b) => a + b) / meds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 100,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        label: 'Overall',
                        value: '${(overallAdherence * 100).round()}%',
                        color: AppColors.primarySurface,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(
                        label: 'This Week',
                        value: '${(overallAdherence * 100 * 0.95).round()}%',
                        color: AppColors.background,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(
                        label: 'Streak 🔥',
                        value: '5 days',
                        color: AppColors.refillBannerBg,
                        valueSize: 14,
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekly calendar
                  Text('March 2026', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _WeeklyCalendar(),

                  const SizedBox(height: 20),

                  // Weekly bar chart (simple)
                  Text('Daily adherence this week', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _WeeklyBarChart(),

                  const SizedBox(height: 20),

                  // By medication
                  Text('By medication', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...meds.map((med) => _MedAdherenceRow(medication: med)),

                  const SizedBox(height: 20),

                  // Export button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Export Report PDF'),
                    ),
                  ),
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

class _StatCard extends StatelessWidget {
  final String label, value; final Color color; final double valueSize;
  const _StatCard({required this.label, required this.value, required this.color, this.valueSize = 20});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: valueSize, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      ]),
    );
  }
}

class _WeeklyCalendar extends StatelessWidget {
  final _days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final _colors = const [
    AppColors.success, AppColors.success, AppColors.success, AppColors.success,
    AppColors.warning, AppColors.error, AppColors.primaryMint,
  ];
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) => Column(children: [
        Text(_days[i], style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: _colors[i], borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text('${9 + i}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
        ),
      ])),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final _values = const [1.0, 1.0, 1.0, 1.0, 0.65, 0.33, 0.05];
  final _days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final color = _values[i] >= 0.8 ? AppColors.primaryLight
              : _values[i] >= 0.5 ? AppColors.warning : AppColors.error;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(width: 32, height: 80 * _values[i], decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 4),
              Text(_days[i], style: Theme.of(context).textTheme.bodySmall),
            ],
          );
        }),
      ),
    );
  }
}

class _MedAdherenceRow extends StatelessWidget {
  final Medication medication;
  const _MedAdherenceRow({required this.medication});
  @override
  Widget build(BuildContext context) {
    final pct = medication.logs.isEmpty ? 1.0 : medication.adherenceRate;
    final color = pct >= 0.8 ? AppColors.success : pct >= 0.5 ? AppColors.primaryLight : AppColors.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(medication.name, style: Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.ellipsis)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct, minHeight: 8,
                backgroundColor: AppColors.chipInactive,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 40, child: Text('${(pct * 100).round()}%', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
