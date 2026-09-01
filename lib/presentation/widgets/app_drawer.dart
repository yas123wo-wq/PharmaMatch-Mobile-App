// lib/presentation/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildItem(
                  icon: Icons.home_rounded,
                  title: 'الرئيسية',
                  index: 0,
                ),
                _buildItem(
                  icon: Icons.search_rounded,
                  title: 'البحث عن بدائل',
                  index: 1,
                ),
                _buildItem(
                  icon: Icons.favorite_rounded,
                  title: 'المفضلة',
                  index: 2,
                ),
                _buildItem(
                  icon: Icons.person_rounded,
                  title: 'حسابي',
                  index: 3,
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.settings_rounded, color: AppTheme.textSecondary),
                  title: const Text('الإعدادات', style: TextStyle(color: AppTheme.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: AppTheme.textSecondary),
                  title: const Text('المساعدة والدعم', style: TextStyle(color: AppTheme.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        return DrawerHeader(
          decoration: const BoxDecoration(
            color: AppTheme.primaryBlue,
          ),
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Icon(Icons.person_rounded, size: 40, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Text(
                profile.pharmacyName.isNotEmpty ? profile.pharmacyName : 'صيدلية PharmaMatch',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.name.isNotEmpty ? profile.name : 'صيدلي',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.lightBlue.withOpacity(0.5),
      onTap: () => onNavigate(index),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
          label: const Text('تسجيل الخروج', style: TextStyle(color: AppTheme.errorRed)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.errorRed,
            side: const BorderSide(color: AppTheme.errorRed),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
