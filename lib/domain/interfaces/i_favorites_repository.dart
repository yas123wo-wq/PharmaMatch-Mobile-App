// lib/domain/interfaces/i_favorites_repository.dart
import '../entities/drug_entity.dart';

abstract class IFavoritesRepository {
  Future<Set<int>> loadFavoriteIds();
  Future<void> saveFavoriteIds(Set<int> ids);
  Future<List<DrugEntity>> fetchFavorites(Set<int> favoriteIds);
}
