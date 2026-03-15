import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../controllers/medication_controller.dart';
import '../../../data/models/medication.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  MedicationStatus _filter = MedicationStatus.active;
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationController>().loadMedications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MedicationController>();
    final filtered = ctrl.medications.where((m) {
      final matchStatus = m.status == _filter;
      final matchSearch = _search.isEmpty || m.name.toLowerCase().contains(_search.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 100,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Pill Cabinet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Search
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      hintText: 'Search medications...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter tabs
                  Row(
                    children: [
                      _FilterChip(label: 'Active', selected: _filter == MedicationStatus.active, onTap: () => setState(() => _filter = MedicationStatus.active)),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Paused', selected: _filter == MedicationStatus.paused, onTap: () => setState(() => _filter = MedicationStatus.paused)),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'As-needed', selected: _filter == MedicationStatus.asNeeded, onTap: () => setState(() => _filter = MedicationStatus.asNeeded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (ctrl.loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.medication_outlined, size: 64, color: AppColors.chipInactive),
                const SizedBox(height: 16),
                Text('No medications found', style: Theme.of(context).textTheme.titleMedium),
              ])),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _MedListCard(
                    medication: filtered[i],
                    onTap: () => context.push('${AppRoutes.medicationDetails}?id=${filtered[i].id}'),
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addMedName),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.chipInactive,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w500, fontSize: 13,
        )),
      ),
    );
  }
}

class _MedListCard extends StatelessWidget {
  final Medication medication; final VoidCallback onTap;
  const _MedListCard({required this.medication, required this.onTap});
  @override
  Widget build(BuildContext context) {
    Color pillColor = AppColors.primaryLight;
    if (medication.colorHex != null) {
      try { pillColor = Color(int.parse(medication.colorHex!.replaceFirst('#', '0xFF'))); } catch (_) {}
    }
    final pct = (medication.adherenceRate * 100).round();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: pillColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.medication, color: pillColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(medication.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('${medication.dosageAmount.toStringAsFixed(0)} ${medication.dosageUnit} · ${_freqLabel(medication.frequency)}',
                style: Theme.of(context).textTheme.bodySmall),
              if (medication.needsRefill)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: const [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 14),
                    SizedBox(width: 4),
                    Text('Refill needed', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500)),
                  ]),
                ),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (medication.logs.isNotEmpty)
                Text('$pct%', style: TextStyle(
                  color: pct >= 80 ? AppColors.success : pct >= 50 ? AppColors.warning : AppColors.error,
                  fontWeight: FontWeight.w700, fontSize: 15,
                )),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ]),
          ],
        ),
      ),
    );
  }
  String _freqLabel(DoseFrequency f) {
    switch (f) {
      case DoseFrequency.daily: return 'Once daily';
      case DoseFrequency.twiceDaily: return 'Twice daily';
      case DoseFrequency.threeTimesDaily: return '3x daily';
      case DoseFrequency.weekly: return 'Weekly';
      case DoseFrequency.asNeeded: return 'As needed';
    }
  }
}
