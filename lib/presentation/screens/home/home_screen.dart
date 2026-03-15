import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../controllers/medication_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/models/medication.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationController>().loadMedications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final medCtrl = context.watch<MedicationController>();
    final user = context.watch<AuthController>().user;
    final now = DateTime.now();
    final schedule = medCtrl.todaySchedule;
    final refillNeeded = medCtrl.refillNeeded;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned(
                    right: -30, top: -30,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight.withOpacity(0.3),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_greeting()}, ${user?.name.split(' ').first ?? 'there'} 👋',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, MMM d').format(now),
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (refillNeeded.isNotEmpty)
                    _RefillBanner(count: refillNeeded.length, onTap: () => context.push(AppRoutes.refillTracker)),
                  if (medCtrl.loading)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                  else if (schedule.isEmpty)
                    _EmptySchedule()
                  else
                    ..._buildSchedule(context, schedule, medCtrl),
                ],
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

  List<Widget> _buildSchedule(BuildContext context, Map<String, List<Medication>> schedule, MedicationController ctrl) {
    const order = ['Morning', 'Afternoon', 'Evening', 'Night'];
    final sorted = schedule.entries.toList()
      ..sort((a, b) {
        final ai = order.indexOf(a.key); final bi = order.indexOf(b.key);
        return (ai == -1 ? 99 : ai).compareTo(bi == -1 ? 99 : bi);
      });
    return sorted.map((entry) {
      final timeLabel = entry.key;
      final meds = entry.value;
      String timeStr = '';
      for (final med in meds) {
        final t = med.times.firstWhere((t) => t.label == timeLabel, orElse: () => MedicationTime(label: timeLabel, time: ''));
        if (t.time.isNotEmpty) { timeStr = t.time; break; }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('$timeLabel${timeStr.isNotEmpty ? ' • $timeStr' : ''}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          ...meds.map((med) => _MedicationDoseCard(
            medication: med,
            onTaken: () => ctrl.markDoseTaken(med.id, DateTime.now()),
            onSkip: () => ctrl.skipDose(med.id, DateTime.now()),
            onTap: () => context.push('${AppRoutes.medicationDetails}?id=${med.id}'),
          )),
        ],
      );
    }).toList();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

class _RefillBanner extends StatelessWidget {
  final int count; final VoidCallback onTap;
  const _RefillBanner({required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.refillBannerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('$count medication${count > 1 ? 's' : ''} running low — time to refill',
              style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w500, fontSize: 13))),
            const Icon(Icons.chevron_right, color: AppColors.warning, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MedicationDoseCard extends StatelessWidget {
  final Medication medication; final VoidCallback onTaken, onSkip, onTap;
  const _MedicationDoseCard({required this.medication, required this.onTaken, required this.onSkip, required this.onTap});

  Color _pillColor() {
    if (medication.colorHex == null) return AppColors.primaryLight;
    try { return Color(int.parse(medication.colorHex!.replaceFirst('#', '0xFF'))); }
    catch (_) { return AppColors.primaryLight; }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: _pillColor().withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.medication, color: _pillColor(), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(medication.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('${medication.dosageAmount.toStringAsFixed(0)} ${medication.dosageUnit}', style: Theme.of(context).textTheme.bodySmall),
            ])),
            Row(children: [
              _Chip(label: 'Skip', color: AppColors.chipInactive, textColor: AppColors.textSecondary, onTap: onSkip),
              const SizedBox(width: 8),
              _Chip(label: 'Taken', color: AppColors.primary, textColor: Colors.white, onTap: onTaken),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final Color color, textColor; final VoidCallback onTap;
  const _Chip({required this.label, required this.color, required this.textColor, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.check_circle_outline, size: 64, color: AppColors.primaryLight),
        const SizedBox(height: 16),
        Text('All done for today!', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('No medications scheduled.', style: Theme.of(context).textTheme.bodyMedium),
      ]),
    ));
  }
}
