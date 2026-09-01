// lib/infrastructure/repositories/favorites_repository_impl.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/drug_entity.dart';
import '../../domain/interfaces/i_favorites_repository.dart';
import '../api/api_service.dart';

class FavoritesRepositoryImpl implements IFavoritesRepository {
  @override
  Future<Set<int>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? [];
    return ids.map((e) => int.tryParse(e) ?? 0).toSet();
  }

  @override
  Future<void> saveFavoriteIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_ids', ids.map((e) => e.toString()).toList());
  }

  @override
  Future<List<DrugEntity>> fetchFavorites(Set<int> favoriteIds) async {
    if (favoriteIds.isEmpty) return [];
    try {
      final all = await ApiService.getDrugs();
      return all.where((d) => favoriteIds.contains(d.id)).toList();
    } catch (_) {
      return [];
    }
  }
}
