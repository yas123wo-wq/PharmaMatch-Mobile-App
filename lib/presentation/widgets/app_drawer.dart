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
                    _showNoticeDialog(
                      context,
                      title: 'الإعدادات',
                      message: 'تخصيص إعدادات التطبيق والتنبيهات قيد التطوير حالياً وستكون متاحة في الإصدار القادم.',
                      icon: Icons.settings_rounded,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: AppTheme.textSecondary),
                  title: const Text('المساعدة والدعم', style: TextStyle(color: AppTheme.textPrimary)),
                  onTap: () {
                    _showNoticeDialog(
                      context,
                      title: 'الدعم الفني',
                      message: 'للمساعدة والاستفسار يرجى التواصل مع الدعم الفني لمشروع PharmaMatch. هذه الميزة ستكون مجهزة بالكامل في الإصدار القادم.',
                      icon: Icons.support_agent_rounded,
                    );
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
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تسجيل الخروج بنجاح'),
                backgroundColor: AppTheme.primaryBlue,
                duration: Duration(seconds: 2),
              ),
            );
          },
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

  void _showNoticeDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) {
    Navigator.pop(context); // إغلاق القائمة الجانبية أولاً
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'حسناً',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
