// lib/presentation/screens/drug_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/drug_entity.dart';
import '../providers/favorites_provider.dart';
import '../widgets/add_drug_bottom_sheet.dart';

class DrugDetailScreen extends StatelessWidget {
  final DrugEntity drug;

  const DrugDetailScreen({super.key, required this.drug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drug.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'تعديل الدواء',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddDrugBottomSheet(drugToEdit: drug),
              );
            },
          ),
          Consumer<FavoritesProvider>(
            builder: (context, favProvider, child) {
              final isFavorite = favProvider.isFavorite(drug.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: isFavorite ? AppTheme.errorRed : AppTheme.textSecondary,
                ),
                onPressed: () => favProvider.toggleFavorite(drug),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.medication_rounded, size: 40, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drug.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          drug.activeIngredient,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                _buildStatCard(
                  label: 'السعر',
                  value: '${drug.price} ر.س',
                  icon: Icons.attach_money_rounded,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  label: 'الكمية المتاحة',
                  value: '${drug.stock} عبوة',
                  icon: Icons.inventory_2_rounded,
                  color: drug.stock > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details Section
            const Text(
              'تفاصيل الدواء',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildDetailRow('التصنيف:', drug.category),
                  const Divider(height: 24, color: AppTheme.dividerColor),
                  _buildDetailRow('الموقع (الرف):', drug.location),
                  const Divider(height: 24, color: AppTheme.dividerColor),
                  _buildDetailRow('تاريخ الانتهاء:', drug.expiryFormatted),
                  const Divider(height: 24, color: AppTheme.dividerColor),
                  _buildDetailRow('حالة المخزون:', drug.stockStatus),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddDrugBottomSheet(drugToEdit: drug),
                );
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text(
                'تعديل بيانات هذا الدواء',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String label, required String value, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
