import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/wizard_scaffold.dart';

class AddMedSuccessScreen extends StatelessWidget {
  const AddMedSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
          ),
          const SizedBox(height: 28),
          Text('Medication Added!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text("You're all set. We'll remind you when it's time to take it.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 40),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go to Today\'s Schedule'),
          )),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go(AppRoutes.addMedName),
            child: const Text('Add another medication'),
          ),
        ]),
      )),
    );
  }
}
