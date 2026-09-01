// lib/presentation/screens/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/drug_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/drug_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<DrugProvider>().search(value);
    });
  }

  void _clearSearch() {
    _controller.clear();
    context.read<DrugProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DrugProvider, FavoritesProvider>(
      builder: (context, drugProvider, favProvider, _) {
        final results = drugProvider.searchResults;
        final hasQuery = drugProvider.searchQuery.isNotEmpty;
        final count = results.length;

        return Column(
          children: [
            // ─── Search Bar ─────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: '...ابحث عن دواء أو بديل بالمادة الفعالة',
                  hintTextDirection: TextDirection.rtl,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: _clearSearch,
                        )
                      : null,
                ),
              ),
            ),

            // ─── Results Header ──────────────────────────────────────────────
            if (hasQuery)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'اكتب للبحث في البدائل',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    if (drugProvider.searchState == LoadingState.success)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'نتائج مطابقة $count',
                          style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),

            // ─── Results Body ────────────────────────────────────────────────
            Expanded(
              child: _buildBody(drugProvider, favProvider, hasQuery, results),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(DrugProvider provider, FavoritesProvider favProvider,
      bool hasQuery, List results) {
    if (!hasQuery) {
      return _buildEmptySearch();
    }
    if (provider.searchState == LoadingState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }
    if (provider.searchState == LoadingState.error) {
      return Center(
        child: Text(provider.errorMessage,
            style: const TextStyle(color: AppTheme.errorRed)),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 72, color: AppTheme.dividerColor),
            const SizedBox(height: 16),
            Text(
              'لم يُعثر على نتائج لـ "${provider.searchQuery}"',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: results.length,
      itemBuilder: (_, i) => DrugCard(
        drug: results[i],
        isFavorite: favProvider.isFavorite(results[i].id),
        onFavoriteToggle: () => favProvider.toggleFavorite(results[i]),
        showMatch: true,
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_outlined,
                size: 64, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 24),
          const Text(
            'ابحث عن دواء أو مادة فعالة',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'سيتم عرض البدائل المتاحة مع نسبة التطابق تلقائيًا',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
