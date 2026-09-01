// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = provider.profile;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildAvatar(p),
              const SizedBox(height: 16),
              _buildName(p),
              const SizedBox(height: 8),
              _buildRole(p),
              const SizedBox(height: 28),
              _buildInfoCard(p),
              const SizedBox(height: 20),
              _buildStatsRow(p),
              const SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(ProfileEntity p) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryBlue,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: p.avatarUrl != null
          ? ClipOval(child: Image.network(p.avatarUrl!, fit: BoxFit.cover))
          : const Icon(Icons.local_pharmacy_rounded,
              color: Colors.white, size: 52),
    );
  }

  Widget _buildName(ProfileEntity p) {
    return Text(
      p.name,
      style: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
    );
  }

  Widget _buildRole(ProfileEntity p) {
    return Text(
      p.role,
      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
    );
  }

  Widget _buildInfoCard(ProfileEntity p) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _InfoRow(label: 'اسم الصيدلية', value: p.pharmacyName),
            const Divider(),
            _InfoRow(label: 'رقم الترخيص', value: p.licenseNumber),
            const Divider(),
            _InfoRow(label: 'رقم الجوال', value: p.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ProfileEntity p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              value: '${p.expiredDrugsCount}',
              label: 'الأدوية المنتهية',
              valueColor: AppTheme.errorRed,
              bgColor: const Color(0xFFFFEBEE),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatBox(
              value: '${p.totalAlternatives}',
              label: 'إجمالي البدائل',
              valueColor: AppTheme.primaryBlue,
              bgColor: AppTheme.lightBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
        label: const Text('تسجيل الخروج',
            style: TextStyle(color: AppTheme.errorRed)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.errorRed),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final Color bgColor;

  const _StatBox({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 34,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
