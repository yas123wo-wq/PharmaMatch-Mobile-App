// lib/application/services/favorites_app_service.dart
import '../../domain/entities/drug_entity.dart';
import '../../domain/interfaces/i_favorites_repository.dart';

class FavoritesAppService {
  final IFavoritesRepository _repository;

  FavoritesAppService(this._repository);

  Future<Set<int>> loadFavoriteIds() {
    return _repository.loadFavoriteIds();
  }

  Future<void> saveFavoriteIds(Set<int> ids) {
    return _repository.saveFavoriteIds(ids);
  }

  Future<List<DrugEntity>> fetchFavorites(Set<int> favoriteIds) {
    return _repository.fetchFavorites(favoriteIds);
  }
}
