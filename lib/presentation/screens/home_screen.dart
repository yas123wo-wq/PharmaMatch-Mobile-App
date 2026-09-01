// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/drug_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/drug_card.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrugProvider>().loadDrugs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DrugProvider, FavoritesProvider>(
      builder: (context, drugProvider, favProvider, _) {
        return RefreshIndicator(
          color: AppTheme.primaryBlue,
          onRefresh: () => drugProvider.loadDrugs(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeBanner(),
                const SizedBox(height: 16),
                _buildStatsRow(drugProvider),
                const SizedBox(height: 8),
                const SectionHeader(title: 'أدوية متاحة في المخزون'),
                _buildDrugsList(drugProvider, favProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'مرحباً بك في PharmaMatch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'ابحث عن بدائل الأدوية بسرعة وسهولة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.medical_services_rounded,
              color: Colors.white70, size: 48),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DrugProvider provider) {
    final drugs = provider.drugs;
    final available = drugs.where((d) => d.isAvailable).length;
    final expired = drugs.where((d) {
      if (d.expiryDate == null) return false;
      return d.expiryDate!.isBefore(DateTime.now());
    }).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(
            label: 'إجمالي الأدوية',
            value: '${drugs.length}',
            icon: Icons.medication_rounded,
            color: AppTheme.primaryBlue,
            bgColor: AppTheme.lightBlue,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'متاح',
            value: '$available',
            icon: Icons.check_circle_outline_rounded,
            color: AppTheme.successGreen,
            bgColor: const Color(0xFFE8F5E9),
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'منتهي الصلاحية',
            value: '$expired',
            icon: Icons.warning_amber_rounded,
            color: AppTheme.errorRed,
            bgColor: const Color(0xFFFFEBEE),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugsList(DrugProvider provider, FavoritesProvider favProvider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.state == LoadingState.error) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(provider.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    if (provider.drugs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('لا توجد أدوية في المخزون',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.drugs.length,
      itemBuilder: (_, i) => DrugCard(
        drug: provider.drugs[i],
        isFavorite: favProvider.isFavorite(provider.drugs[i].id),
        onFavoriteToggle: () => favProvider.toggleFavorite(provider.drugs[i]),
        showMatch: false,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
