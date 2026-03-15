import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../controllers/medication_controller.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../../data/models/medication.dart';

class AddMedFrequencyScreen extends StatefulWidget {
  const AddMedFrequencyScreen({super.key});
  @override
  State<AddMedFrequencyScreen> createState() => _AddMedFrequencyScreenState();
}
class _AddMedFrequencyScreenState extends State<AddMedFrequencyScreen> {
  DoseFrequency? _freq;
  final _options = [
    (DoseFrequency.daily, 'Once daily', 'Every day'),
    (DoseFrequency.twiceDaily, 'Twice daily', 'Morning and evening'),
    (DoseFrequency.threeTimesDaily, '3× daily', 'Morning, afternoon and evening'),
    (DoseFrequency.weekly, 'Weekly', 'Once per week'),
    (DoseFrequency.asNeeded, 'As needed', 'Only when required'),
  ];
  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      step: 3, total: 6, title: 'Frequency', subtitle: 'How often do you take this medication?',
      onNext: () {
        if (_freq == null) return;
        final ctrl = context.read<MedicationController>();
        ctrl.addForm.frequency = _freq;
        ctrl.updateAddForm(ctrl.addForm);
        context.push(AppRoutes.addMedTimes);
      },
      child: Column(children: _options.map((opt) {
        final selected = _freq == opt.$1;
        return GestureDetector(
          onTap: () => setState(() => _freq = opt.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(opt.$2, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textPrimary)),
                Text(opt.$3, style: Theme.of(context).textTheme.bodySmall),
              ])),
              if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            ]),
          ),
        );
      }).toList()),
    );
  }
}
