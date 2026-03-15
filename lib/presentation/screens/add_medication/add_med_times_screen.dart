import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../controllers/medication_controller.dart';
import '../../../data/models/medication.dart';

class AddMedTimesScreen extends StatefulWidget {
  const AddMedTimesScreen({super.key});
  @override
  State<AddMedTimesScreen> createState() => _AddMedTimesScreenState();
}
class _AddMedTimesScreenState extends State<AddMedTimesScreen> {
  final List<MedicationTime> _times = [const MedicationTime(label: 'Morning', time: '8:00 AM')];

  Future<void> _pickTime(int idx) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final str = picked.format(context);
    setState(() => _times[idx] = MedicationTime(label: _times[idx].label, time: str));
  }

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      step: 4, total: 6, title: 'Times', subtitle: 'When do you take this medication?',
      onNext: () {
        final ctrl = context.read<MedicationController>();
        ctrl.addForm.times = _times;
        ctrl.updateAddForm(ctrl.addForm);
        context.push(AppRoutes.addMedAppearance);
      },
      child: Column(children: [
        ..._times.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                decoration: const InputDecoration.collapsed(hintText: 'Label (e.g. Morning)'),
                controller: TextEditingController(text: e.value.label),
                onChanged: (v) => setState(() => _times[e.key] = MedicationTime(label: v, time: _times[e.key].time)),
              ),
              GestureDetector(
                onTap: () => _pickTime(e.key),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(e.value.time, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ),
            ])),
            if (_times.length > 1) IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.error), onPressed: () => setState(() => _times.removeAt(e.key))),
          ]),
        )),
        TextButton.icon(
          onPressed: () => setState(() => _times.add(const MedicationTime(label: 'Evening', time: '8:00 PM'))),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add another time'),
        ),
      ]),
    );
  }
}
