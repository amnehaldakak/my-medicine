import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_medicine/app_exports.dart';
import 'package:provider/provider.dart';

import '../presentation/screens/add_medication/add_med_appearance_screen.dart';
import '../presentation/screens/add_medication/add_med_dosage_screen.dart';
import '../presentation/screens/add_medication/add_med_frequency_screen.dart';
import '../presentation/screens/add_medication/add_med_inventory_screen.dart';
import '../presentation/screens/add_medication/add_med_name_screen.dart';
import '../presentation/screens/add_medication/add_med_success_screen.dart';
import '../presentation/screens/add_medication/add_med_times_screen.dart';
import '../presentation/screens/auth/create_account_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/details/medication_details_screen.dart';
import '../presentation/screens/details/notification_action_screen.dart';
import '../presentation/screens/details/refill_tracker_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/medications/medications_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/onboarding/splash_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/progress/progress_screen.dart';
import '../presentation/screens/shell/main_shell.dart';
import 'constants/app_routes.dart';



final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  final authController = Provider.of<AuthController
  >(context, listen: false);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuth = authController.isAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.createAccount;
      final isOnboarding =
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation == AppRoutes.splash;

      if (!isAuth && !isAuthRoute && !isOnboarding) {
        return AppRoutes.login;
      }
      return null;
    },
    refreshListenable: authController,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      // Onboarding
      GoRoute(
        path: AppRoutes.onboardingNeverMiss,
        builder: (_, __) =>
            const OnboardingScreen(pageIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.onboardingTrackRefills,
        builder: (_, __) =>
            const OnboardingScreen(pageIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.onboardingShareDoctor,
        builder: (_, __) =>
            const OnboardingScreen(pageIndex: 2),
      ),
      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAccount,
        builder: (_, __) => const CreateAccountScreen(),
      ),
      // Main shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.medications,
            builder: (_, __) => const MedicationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder: (_, __) => const ProgressScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      // Detail screens (full-screen, above shell)
      GoRoute(
        path: AppRoutes.medicationDetails,
        builder: (_, state) {
          final medId = state.uri.queryParameters['id'] ?? '';
          return MedicationDetailsScreen(medicationId: medId);
        },
      ),
      GoRoute(
        path: AppRoutes.refillTracker,
        builder: (_, __) => const RefillTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationAction,
        builder: (_, state) {
          final medId = state.uri.queryParameters['id'] ?? '';
          return NotificationActionScreen(medicationId: medId);
        },
      ),
      // Add medication wizard
      GoRoute(
        path: AppRoutes.addMedName,
        builder: (_, __) => const AddMedNameScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMedDosage,
        builder: (_, __) => const AddMedDosageScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMedFrequency,
        builder: (_, __) => const AddMedFrequencyScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMedTimes,
        builder: (_, __) => const AddMedTimesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMedAppearance,
        builder: (_, __) => const AddMedAppearanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMedInventory,
        builder: (_, __) => const AddMedInventoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMedSuccess,
        builder: (_, __) => const AddMedSuccessScreen(),
      ),
    ],
  );
}
