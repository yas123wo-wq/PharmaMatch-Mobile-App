// lib/presentation/providers/favorites_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/drug_entity.dart';
import '../../application/services/favorites_app_service.dart';
import '../../infrastructure/repositories/favorites_repository_impl.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesAppService _favoritesAppService;

  List<DrugEntity> _favorites = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;

  List<DrugEntity> get favorites => _favorites;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  FavoritesProvider({FavoritesAppService? favoritesAppService})
      : _favoritesAppService = favoritesAppService ?? FavoritesAppService(FavoritesRepositoryImpl()) {
    _loadFavoriteIds();
  }

  bool isFavorite(int drugId) => _favoriteIds.contains(drugId);

  Future<void> _loadFavoriteIds() async {
    _favoriteIds = await _favoritesAppService.loadFavoriteIds();
    await _fetchFavorites();
  }

  Future<void> _saveIds() async {
    await _favoritesAppService.saveFavoriteIds(_favoriteIds);
  }

  Future<void> _fetchFavorites() async {
    if (_favoriteIds.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _favorites = await _favoritesAppService.fetchFavorites(_favoriteIds);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(DrugEntity drug) async {
    if (_favoriteIds.contains(drug.id)) {
      _favoriteIds.remove(drug.id);
      _favorites.removeWhere((d) => d.id == drug.id);
    } else {
      _favoriteIds.add(drug.id);
      _favorites.add(drug);
    }
    await _saveIds();
    notifyListeners();
  }

  Future<void> removeFavorite(int drugId) async {
    _favoriteIds.remove(drugId);
    _favorites.removeWhere((d) => d.id == drugId);
    await _saveIds();
    notifyListeners();
  }
}
