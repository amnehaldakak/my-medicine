import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/medication_controller.dart';
import '../../../data/models/medication.dart';

class MedicationDetailsScreen extends StatefulWidget {
  final String medicationId;
  const MedicationDetailsScreen({super.key, required this.medicationId});
  @override
  State<MedicationDetailsScreen> createState() => _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  Medication? _med;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctrl = context.read<MedicationController>();
      final med = await ctrl.getMedication(widget.medicationId);
      if (mounted) setState(() => _med = med);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_med == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final med = _med!;
    Color pillColor = AppColors.primaryLight;
    if (med.colorHex != null) {
      try { pillColor = Color(int.parse(med.colorHex!.replaceFirst('#', '0xFF'))); } catch (_) {}
    }
    final pct = med.logs.isEmpty ? 100 : (med.adherenceRate * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Row(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: pillColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.medication, color: pillColor, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(med.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      Text('${med.dosageAmount.toStringAsFixed(0)} ${med.dosageUnit}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                        child: Text(_statusLabel(med.status),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                    ])),
                    Text('$pct%', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                  ]),
                )),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Schedule'),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      ...med.times.map((t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(children: [
                          const Icon(Icons.access_time, color: AppColors.primaryLight, size: 18),
                          const SizedBox(width: 10),
                          Text(t.label, style: Theme.of(context).textTheme.bodyLarge),
                          const Spacer(),
                          Text(t.time, style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                      )),
                      Divider(height: 16),
                      Row(children: [
                        const Icon(Icons.repeat, color: AppColors.primaryLight, size: 18),
                        const SizedBox(width: 10),
                        Text(_freqLabel(med.frequency), style: Theme.of(context).textTheme.bodyLarge),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Inventory'),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Current stock', style: Theme.of(context).textTheme.bodyLarge),
                        Text('${med.currentInventory ?? '—'} pills', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 10),
                      if (med.currentInventory != null && med.refillAt != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (med.currentInventory! / (med.refillAt! * 3)).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.chipInactive,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              med.needsRefill ? AppColors.error : AppColors.primaryLight),
                          ),
                        ),
                      if (med.needsRefill)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(children: const [
                            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 14),
                            SizedBox(width: 6),
                            Text('Refill needed soon', style: TextStyle(color: AppColors.warning, fontSize: 12)),
                          ]),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  if (med.logs.isNotEmpty) ...[
                    _SectionLabel('Recent History'),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: med.logs.reversed.take(4).toList().asMap().entries.map((e) => Column(children: [
                          ListTile(
                            leading: Icon(
                              e.value.taken ? Icons.check_circle : Icons.cancel_outlined,
                              color: e.value.taken ? AppColors.success : AppColors.error, size: 20,
                            ),
                            title: Text(e.value.taken ? 'Taken' : 'Skipped', style: Theme.of(context).textTheme.bodyLarge),
                            trailing: Text(_formatDate(e.value.scheduledAt), style: Theme.of(context).textTheme.bodySmall),
                          ),
                          if (e.key < 3) const Divider(height: 1, indent: 52),
                        ])).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        backgroundColor: AppColors.deleteRed,
                      ),
                    )),
                  ]),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Delete Medication'),
      content: Text('Are you sure you want to delete ${_med!.name}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            context.read<MedicationController>().deleteMedication(widget.medicationId);
            Navigator.pop(context);
            context.pop();
          },
          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ));
  }

  String _statusLabel(MedicationStatus s) {
    switch (s) {
      case MedicationStatus.active: return 'Active';
      case MedicationStatus.paused: return 'Paused';
      case MedicationStatus.asNeeded: return 'As Needed';
    }
  }
  String _freqLabel(DoseFrequency f) {
    switch (f) {
      case DoseFrequency.daily: return 'Once daily';
      case DoseFrequency.twiceDaily: return 'Twice daily';
      case DoseFrequency.threeTimesDaily: return '3× daily';
      case DoseFrequency.weekly: return 'Weekly';
      case DoseFrequency.asNeeded: return 'As needed';
    }
  }
  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
  );
}
