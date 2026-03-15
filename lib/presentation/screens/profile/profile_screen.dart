import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  CircleAvatar(radius: 36, backgroundColor: AppColors.primaryLight,
                    child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 10),
                  Text(user?.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(user?.email ?? '', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ]),
              )),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Account'),
                  _SettingsCard(items: [
                    _SettingsItem(icon: Icons.person_outline, label: 'Edit Profile', onTap: () {}),
                    _SettingsItem(icon: Icons.share_outlined, label: 'Share with Doctor', onTap: () {}),
                    _SettingsItem(icon: Icons.lock_outline, label: 'Change Password', onTap: () {}),
                  ]),
                  const SizedBox(height: 16),
                  _SectionLabel('Reminders'),
                  _SettingsCard(items: [
                    _ToggleItem(icon: Icons.notifications_outlined, label: 'Push Notifications', value: true),
                    _ToggleItem(icon: Icons.volume_up_outlined, label: 'Sound', value: true),
                    _ToggleItem(icon: Icons.vibration_outlined, label: 'Vibration', value: true),
                  ]),
                  const SizedBox(height: 16),
                  _SectionLabel('Health'),
                  _SettingsCard(items: [
                    _SettingsItem(icon: Icons.bar_chart_outlined, label: 'View Full History', onTap: () {}),
                    _SettingsItem(icon: Icons.picture_as_pdf_outlined, label: 'Export Report', onTap: () {}),
                    _SettingsItem(icon: Icons.local_pharmacy_outlined, label: 'Refill Tracker', onTap: () => context.push(AppRoutes.refillTracker)),
                  ]),
                  const SizedBox(height: 16),
                  _SectionLabel('App'),
                  _SettingsCard(items: [
                    _SettingsItem(icon: Icons.info_outline, label: 'About', onTap: () {}),
                    _SettingsItem(icon: Icons.star_outline, label: 'Rate App', onTap: () {}),
                    _SettingsItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
                  ]),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await context.read<AuthController>().logout();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> items;
  const _SettingsCard({required this.items});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: items.asMap().entries.map((e) => Column(children: [
          e.value,
          if (e.key < items.length - 1) const Divider(height: 1, indent: 52),
        ])).toList(),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}

class _ToggleItem extends StatefulWidget {
  final IconData icon; final String label; final bool value;
  const _ToggleItem({required this.icon, required this.label, required this.value});
  @override
  State<_ToggleItem> createState() => _ToggleItemState();
}
class _ToggleItemState extends State<_ToggleItem> {
  late bool _val;
  @override
  void initState() { super.initState(); _val = widget.value; }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon, color: AppColors.primary, size: 22),
      title: Text(widget.label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Switch(value: _val, onChanged: (v) => setState(() => _val = v), activeColor: AppColors.primary),
    );
  }
}
