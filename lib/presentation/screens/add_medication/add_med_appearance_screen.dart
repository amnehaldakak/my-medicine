import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/wizard_scaffold.dart';
import '../../controllers/medication_controller.dart';
import '../../widgets/common/wizard_scaffold.dart';

class AddMedAppearanceScreen extends StatefulWidget {
  const AddMedAppearanceScreen({super.key});
  @override
  State<AddMedAppearanceScreen> createState() => _AddMedAppearanceScreenState();
}
class _AddMedAppearanceScreenState extends State<AddMedAppearanceScreen> {
  String? _colorHex;
  String? _shape;
  final _colors = ['#FFFFFF', '#FFD700', '#FF4500', '#1E90FF', '#32CD32', '#9B59B6', '#FF69B4', '#808080'];
  final _shapes = ['Round', 'Oval', 'Capsule', 'Square', 'Diamond'];

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      step: 5, total: 6, title: 'Appearance', subtitle: 'What does your pill look like? (optional)',
      onNext: () {
        final ctrl = context.read<MedicationController>();
        ctrl.addForm.colorHex = _colorHex;
        ctrl.addForm.shape = _shape;
        ctrl.updateAddForm(ctrl.addForm);
        context.push(AppRoutes.addMedInventory);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Color', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: _colors.map((hex) {
          Color c; try { c = Color(int.parse(hex.replaceFirst('#', '0xFF'))); } catch (_) { c = Colors.grey; }
          final selected = _colorHex == hex;
          return GestureDetector(
            onTap: () => setState(() => _colorHex = hex),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: c, shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300, width: selected ? 3 : 1),
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: 20),
        Text('Shape', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: _shapes.map((s) => FilterChip(
          label: Text(s), selected: _shape == s,
          onSelected: (_) => setState(() => _shape = s),
          selectedColor: AppColors.primarySurface, checkmarkColor: AppColors.primary,
        )).toList()),
      ]),
    );
  }
}
