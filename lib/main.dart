import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/medication_repository.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/medication_controller.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyMedicineApp());
}

class MyMedicineApp extends StatelessWidget {
  const MyMedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    

    return MultiProvider(
      providers: [
        // ✅ CHANGE THIS ONE LINE (Step 7)
        Provider<AuthRepository>(
          create: (_) => FirebaseAuthRepository(),           // ← was MockAuthRepository()
        ),
        // This stays the same
        Provider<MedicationRepository>(
          create: (_) => MockMedicationRepository(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(ctx.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<MedicationController>(
          create: (ctx) => MedicationController(ctx.read<MedicationRepository>()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context);
          return MaterialApp.router(
            title: 'My Medicine',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
