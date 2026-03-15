import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/medication_controller.dart';
import '../../../data/models/medication.dart';

class NotificationActionScreen extends StatefulWidget {
  final String medicationId;
  const NotificationActionScreen({super.key, required this.medicationId});
  @override
  State<NotificationActionScreen> createState() => _NotificationActionScreenState();
}

class _NotificationActionScreenState extends State<NotificationActionScreen> {
  Medication? _med;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final med = await context.read<MedicationController>().getMedication(widget.medicationId);
      if (mounted) setState(() => _med = med);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.95),
      body: Stack(
        children: [
          Positioned(right: -40, bottom: -40, child: Container(
            width: 280, height: 280,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
          )),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                const Spacer(),
                if (_med != null) ...[
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.medication, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 24),
                  Text('Time to take your medication', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(_med!.name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                  Text('${_med!.dosageAmount.toStringAsFixed(0)} ${_med!.dosageUnit}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
                ],
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(width: double.infinity, child: ElevatedButton(
                          onPressed: () {
                            if (_med != null) {
                              context.read<MedicationController>().markDoseTaken(_med!.id, DateTime.now());
                            }
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          child: const Text('✓  Taken', style: TextStyle(fontSize: 16)),
                        )),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('⏰  Remind me in 30 min'),
                        )),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: TextButton(
                          onPressed: () {
                            if (_med != null) {
                              context.read<MedicationController>().skipDose(_med!.id, DateTime.now());
                            }
                            context.pop();
                          },
                          child: const Text('Skip this dose', style: TextStyle(color: AppColors.textSecondary)),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
