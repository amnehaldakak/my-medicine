import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
  });
}

const _pages = [
  _OnboardingPage(
    title: 'Never miss a pill',
    subtitle:
        'Get timely reminders for every dose so you stay on track with your treatment.',
    icon: Icons.notifications_active_outlined,
    iconBg: AppColors.primarySurface,
  ),
  _OnboardingPage(
    title: 'Track Refills',
    subtitle:
        'Know exactly when you\'re running low and find nearby pharmacies with ease.',
    icon: Icons.inventory_2_outlined,
    iconBg: AppColors.refillBannerBg,
  ),
  _OnboardingPage(
    title: 'Share with Doctor',
    subtitle:
        'Export your medication history and adherence reports to share with your care team.',
    icon: Icons.share_outlined,
    iconBg: AppColors.primarySurface,
  ),
];

class OnboardingScreen extends StatelessWidget {
  final int pageIndex;
  const OnboardingScreen({super.key, required this.pageIndex});

  String get _nextRoute {
    switch (pageIndex) {
      case 0:
        return AppRoutes.onboardingTrackRefills;
      case 1:
        return AppRoutes.onboardingShareDoctor;
      default:
        return AppRoutes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[pageIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == pageIndex ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == pageIndex
                          ? AppColors.primary
                          : AppColors.chipInactive,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 60),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: page.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 48),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(_nextRoute),
                  child: Text(
                    pageIndex == 2 ? 'Get Started' : 'Continue',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (pageIndex < 2)
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
