// lib/presentation/providers/drug_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/drug_entity.dart';
import '../../application/services/drug_app_service.dart';
import '../../infrastructure/repositories/drug_repository_impl.dart';
import '../../infrastructure/api/api_service.dart';

enum LoadingState { idle, loading, success, error }

class DrugProvider extends ChangeNotifier {
  final DrugAppService _drugAppService;

  DrugProvider({DrugAppService? drugAppService})
      : _drugAppService = drugAppService ?? DrugAppService(DrugRepositoryImpl());

  List<DrugEntity> _drugs = [];
  List<DrugEntity> _searchResults = [];
  List<String> _activeIngredients = [];
  LoadingState _state = LoadingState.idle;
  LoadingState _searchState = LoadingState.idle;
  String _errorMessage = '';
  String _searchQuery = '';

  // ─── Getters ─────────────────────────────────────────────────────────────
  List<DrugEntity> get drugs => _drugs;
  List<DrugEntity> get searchResults => _searchResults;
  List<String> get activeIngredients => _activeIngredients;
  LoadingState get state => _state;
  LoadingState get searchState => _searchState;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isLoading => _state == LoadingState.loading;
  bool get isSearching => _searchState == LoadingState.loading;

  // ─── Methods ─────────────────────────────────────────────────────────────

  Future<void> loadDrugs() async {
    _state = LoadingState.loading;
    notifyListeners();
    try {
      _drugs = await _drugAppService.getDrugs();
      _state = LoadingState.success;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'حدث خطأ غير متوقع';
      _state = LoadingState.error;
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchState = LoadingState.idle;
      notifyListeners();
      return;
    }
    _searchState = LoadingState.loading;
    notifyListeners();
    try {
      _searchResults = await _drugAppService.searchAlternatives(query.trim());
      _searchState = LoadingState.success;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'حدث خطأ في البحث';
      _searchState = LoadingState.error;
    }
    notifyListeners();
  }

  Future<void> loadActiveIngredients({String? query}) async {
    try {
      _activeIngredients = await _drugAppService.getActiveIngredients(query: query);
      notifyListeners();
    } catch (_) {}
  }

  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _searchState = LoadingState.idle;
    notifyListeners();
  }
}
