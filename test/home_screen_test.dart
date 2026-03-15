import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_medicine/data/repositories/auth_repository.dart';
import 'package:my_medicine/data/repositories/medication_repository.dart';
import 'package:my_medicine/presentation/controllers/auth_controller.dart';
import 'package:my_medicine/presentation/controllers/medication_controller.dart';
import 'package:my_medicine/presentation/screens/home/home_screen.dart';
import 'package:my_medicine/core/theme/app_theme.dart';

Widget buildTestApp(Widget child) {
  return MultiProvider(
    providers: [
      Provider<AuthRepository>(create: (_) => MockAuthRepository()),
      Provider<MedicationRepository>(
          create: (_) => MockMedicationRepository()),
      ChangeNotifierProvider<AuthController>(
        create: (ctx) => AuthController(ctx.read<AuthRepository>()),
      ),
      ChangeNotifierProvider<MedicationController>(
        create: (ctx) =>
            MedicationController(ctx.read<MedicationRepository>()),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      // Should show loading first
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows medication cards after load', (tester) async {
      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      await tester.pumpAndSettle();
      // After loading, should find at least one medication entry
      expect(find.text('Lisinopril'), findsAny);
    });

    testWidgets('shows FAB for adding medication', (tester) async {
      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
