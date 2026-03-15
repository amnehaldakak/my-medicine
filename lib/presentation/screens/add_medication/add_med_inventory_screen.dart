import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../controllers/medication_controller.dart';
import '../../widgets/common/wizard_scaffold.dart';

class AddMedInventoryScreen extends StatefulWidget {
  const AddMedInventoryScreen({super.key});
  @override
  State<AddMedInventoryScreen> createState() => _AddMedInventoryScreenState();
}
class _AddMedInventoryScreenState extends State<AddMedInventoryScreen> {
  final _stockCtrl = TextEditingController();
  final _refillCtrl = TextEditingController(text: '10');
  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      step: 6, total: 6, title: 'Inventory', subtitle: 'Track your pill supply (optional)',
      nextLabel: 'Save Medication',
      onNext: () async {
        final ctrl = context.read<MedicationController>();
        ctrl.addForm.currentInventory = int.tryParse(_stockCtrl.text);
        ctrl.addForm.refillAt = int.tryParse(_refillCtrl.text) ?? 10;
        ctrl.updateAddForm(ctrl.addForm);
        await ctrl.saveNewMedication();
        if (context.mounted) context.go(AppRoutes.addMedSuccess);
      },
      child: Column(children: [
        TextField(
          controller: _stockCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Current stock (pills)', prefixIcon: Icon(Icons.inventory_2_outlined, size: 20)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _refillCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Remind me to refill at (pills)', prefixIcon: Icon(Icons.alarm_outlined, size: 20)),
        ),
      ]),
    );
  }
}
