import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../controllers/medication_controller.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../../data/models/medication.dart';

class AddMedDosageScreen extends StatefulWidget {
  const AddMedDosageScreen({super.key});
  @override
  State<AddMedDosageScreen> createState() => _AddMedDosageScreenState();
}
class _AddMedDosageScreenState extends State<AddMedDosageScreen> {
  final _amtCtrl = TextEditingController();
  String _unit = 'mg';
  MedicationForm _form = MedicationForm.tablet;
  final _units = ['mg', 'ml', 'IU', 'mcg', '%'];
  final _forms = [MedicationForm.tablet, MedicationForm.capsule, MedicationForm.liquid, MedicationForm.patch, MedicationForm.injection];
  final _formLabels = ['Tablet', 'Capsule', 'Liquid', 'Patch', 'Injection'];

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      step: 2, total: 6, title: 'Dosage', subtitle: 'How much do you take per dose?',
      onNext: () {
        final amt = double.tryParse(_amtCtrl.text);
        if (amt == null) return;
        final ctrl = context.read<MedicationController>();
        ctrl.addForm.dosageAmount = amt;
        ctrl.addForm.dosageUnit = _unit;
        ctrl.addForm.form = _form;
        ctrl.updateAddForm(ctrl.addForm);
        context.push(AppRoutes.addMedFrequency);
      },
      child: Column(children: [
        Row(children: [
          Expanded(child: TextField(
            controller: _amtCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            decoration: const InputDecoration(hintText: 'Amount'),
          )),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _unit,
            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
            onChanged: (v) => setState(() => _unit = v!),
          ),
        ]),
        const SizedBox(height: 16),
        Text('Form', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: List.generate(_forms.length, (i) => FilterChip(
          label: Text(_formLabels[i]),
          selected: _form == _forms[i],
          onSelected: (_) => setState(() => _form = _forms[i]),
          selectedColor: AppColors.primarySurface,
          checkmarkColor: AppColors.primary,
        ))),
      ]),
    );
  }
}
