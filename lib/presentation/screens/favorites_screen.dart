// lib/presentation/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/drug_entity.dart';
import '../providers/favorites_provider.dart';
import 'drug_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Title Section ────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'الأدوية المفضلة والمتابعة',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '.هذه الأدوية تتابع حركتها وصلاحيتها بشكل دوري وسريع',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ─── List ─────────────────────────────────────────────────────────
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.favorites.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: provider.favorites.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (ctx, i) =>
                              _FavoriteItem(drug: provider.favorites[i]),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.favorite_border_rounded,
              size: 72, color: AppTheme.dividerColor),
          SizedBox(height: 16),
          Text(
            'لا توجد أدوية مفضلة بعد',
            style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'أضف أدوية إلى المفضلة من نتائج البحث',
            style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final DrugEntity drug;
  const _FavoriteItem({required this.drug});

  @override
  Widget build(BuildContext context) {
    final expiryColor = _expiryColor(drug.expiryStatus);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DrugDetailScreen(drug: drug)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    drug.name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${drug.expiryStatus} - ${drug.stockStatus}',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: expiryColor, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.star_rounded,
                  color: AppTheme.starYellow, size: 28),
              onPressed: () =>
                  context.read<FavoritesProvider>().removeFavorite(drug.id),
              tooltip: 'إزالة من المفضلة',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Color _expiryColor(String status) {
    switch (status) {
      case 'ممتازة':
        return AppTheme.successGreen;
      case 'متوسطة':
        return AppTheme.warningOrange;
      case 'قاربت على الانتهاء':
        return AppTheme.errorRed;
      case 'منتهية':
        return Colors.red.shade900;
      default:
        return AppTheme.textSecondary;
    }
  }
}
