import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../controllers/medication_controller.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../../data/models/medication.dart';

class AddMedNameScreen extends StatefulWidget {
  const AddMedNameScreen({super.key});
  @override
  State<AddMedNameScreen> createState() => _AddMedNameScreenState();
}

class _AddMedNameScreenState extends State<AddMedNameScreen> {
  final _ctrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    final form = context.read<MedicationController>().addForm;
    _ctrl.text = form.name;
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      step: 1, total: 6, title: 'What medication?', subtitle: 'Enter the name of your medication',
      onNext: () {
        if (_ctrl.text.trim().isEmpty) return;
        final ctrl = context.read<MedicationController>();
        ctrl.addForm.name = _ctrl.text.trim();
        ctrl.updateAddForm(ctrl.addForm);
        context.push(AppRoutes.addMedDosage);
      },
      child: TextField(
        controller: _ctrl, autofocus: true, textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'e.g. Lisinopril', prefixIcon: Icon(Icons.medication_outlined, size: 20)),
      ),
    );
  }
}
